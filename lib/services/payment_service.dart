import 'dart:math';
import 'package:flutter_application_1/components/validators.dart';

enum CardBrand { visa, mastercard, amex, unknown }

CardBrand detectBrand(String number) {
  final d = Validators.digits(number);
  if (d.startsWith('4')) return CardBrand.visa;
  if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(d)) return CardBrand.mastercard;
  if (RegExp(r'^3[47]').hasMatch(d)) return CardBrand.amex;
  return CardBrand.unknown;
}

class PaymentResult {
  final bool success;
  final String message;
  final String? transactionId;
  const PaymentResult(this.success, this.message, [this.transactionId]);
}

class CardData {
  final String number, holder, expiry, cvv;
  const CardData(this.number, this.holder, this.expiry, this.cvv);
}

/// Contrato de pasarela. Para producción se implementa con Stripe / Mercado Pago
/// (creando el PaymentIntent / preferencia en un backend o Cloud Function) y se
/// cambia la instancia en CheckoutProvider. La UI no cambia.
abstract class PaymentGateway {
  Future<PaymentResult> charge({
    required CardData card,
    required double amount,
    required String description,
  });
}

/// Pasarela simulada en "modo prueba", con las mismas tarjetas de prueba de Stripe:
///  4242 4242 4242 4242 -> aprobada
///  4000 0000 0000 0002 -> rechazada
///  4000 0000 0000 9995 -> fondos insuficientes
///  4000 0000 0000 0069 -> tarjeta vencida
class SimulatedGateway implements PaymentGateway {
  @override
  Future<PaymentResult> charge({
    required CardData card,
    required double amount,
    required String description,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final n = Validators.digits(card.number);
    switch (n) {
      case '4000000000000002':
        return const PaymentResult(false, 'Tarjeta rechazada por el banco emisor.');
      case '4000000000009995':
        return const PaymentResult(false, 'Fondos insuficientes.');
      case '4000000000000069':
        return const PaymentResult(false, 'La tarjeta está vencida.');
    }
    final id = 'TXN-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}';
    return PaymentResult(true, 'Pago aprobado', id);
  }
}
