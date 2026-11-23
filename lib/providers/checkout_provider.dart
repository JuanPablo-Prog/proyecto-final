import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/plan.dart';
import 'package:flutter_application_1/services/payment_service.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';

enum PaymentStatus { idle, processing, success, failed }

/// Estado del formulario de tarjeta y flujo de cobro (pedidos y suscripciones).
class CheckoutProvider extends ChangeNotifier {
  final PaymentGateway gateway;
  CheckoutProvider({PaymentGateway? gateway}) : gateway = gateway ?? SimulatedGateway();

  String cardNumber = '';
  CardBrand brand = CardBrand.unknown;

  PaymentStatus status = PaymentStatus.idle;
  String message = '';
  String? transactionId;

  void onCardNumberChanged(String v) {
    cardNumber = v;
    final b = detectBrand(v);
    if (b != brand) {
      brand = b;
      notifyListeners();
    }
  }

  int get cvvLength => brand == CardBrand.amex ? 4 : 3;

  void reset() {
    cardNumber = '';
    brand = CardBrand.unknown;
    status = PaymentStatus.idle;
    message = '';
    transactionId = null;
    notifyListeners();
  }

  Future<PaymentResult> _charge(CardData card, double amount, String description) async {
    status = PaymentStatus.processing;
    notifyListeners();
    final r = await gateway.charge(card: card, amount: amount, description: description);
    status = r.success ? PaymentStatus.success : PaymentStatus.failed;
    message = r.message;
    transactionId = r.transactionId;
    notifyListeners();
    return r;
  }

  /// Modelo de venta de productos: paga el carrito y guarda el pedido.
  Future<bool> payOrder({
    required String uid,
    required CartProvider cart,
    required int discountPercent,
    required CardData card,
  }) async {
    final total = cart.totalWith(discountPercent);
    final r = await _charge(card, total, 'Reserva de paquetes turísticos');
    if (!r.success) return false;
    final digits = card.number.replaceAll(RegExp(r'\D'), '');
    try {
      await FirebaseDatabase.instance.ref('orders/$uid').push().set({
        'transactionId': r.transactionId,
        'total': total,
        'discountPercent': discountPercent,
        'createdAt': ServerValue.timestamp,
        'last4': digits.substring(digits.length - 4),
        'items': cart.items
            .map((i) => {
                  'destinationId': i.destination.id,
                  'name': i.destination.name,
                  'travelers': i.travelers,
                  'unitPrice': i.destination.price,
                })
            .toList(),
      });
    } catch (_) {/* el pago ya se aprobó; el registro se reintenta con persistencia */}
    cart.clear();
    return true;
  }

  /// Modelo de prestación de servicios: suscripción mensual.
  Future<bool> paySubscription({
    required String uid,
    required Plan plan,
    required CardData card,
  }) async {
    final r = await _charge(card, plan.price, 'Suscripción ${plan.name}');
    if (!r.success) return false;
    final now = DateTime.now();
    try {
      await FirebaseDatabase.instance.ref('subscriptions/$uid').set({
        'planId': plan.id,
        'planName': plan.name,
        'price': plan.price,
        'discountPercent': plan.discountPercent,
        'status': 'active',
        'transactionId': r.transactionId,
        'startedAt': now.millisecondsSinceEpoch,
        'renewsAt': DateTime(now.year, now.month + 1, now.day).millisecondsSinceEpoch,
      });
    } catch (_) {}
    return true;
  }
}
