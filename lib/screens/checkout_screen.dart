import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/components/input_formatters.dart';
import 'package:flutter_application_1/components/responsive.dart';
import 'package:flutter_application_1/components/validators.dart';
import 'package:flutter_application_1/database/plan.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/providers/checkout_provider.dart';
import 'package:flutter_application_1/providers/session_provider.dart';
import 'package:flutter_application_1/services/payment_service.dart';
import 'package:flutter_application_1/components/destination_card.dart';

/// Pantalla nativa de pago con tarjeta. Sirve para:
///  - Pedido de paquetes (modelo de venta de productos)
///  - Suscripción a un plan (modelo de prestación de servicios)
class CheckoutScreen extends StatefulWidget {
  final Plan? plan;
  final int discountPercent;

  const CheckoutScreen.order({super.key, this.discountPercent = 0}) : plan = null;
  const CheckoutScreen.subscription({super.key, required Plan this.plan}) : discountPercent = 0;

  bool get isSubscription => plan != null;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _form = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _holder = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Limpia estado de pagos anteriores al abrir la pantalla.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CheckoutProvider>().reset();
    });
  }

  @override
  void dispose() {
    _number.dispose();
    _holder.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!_form.currentState!.validate()) return;
    final checkout = context.read<CheckoutProvider>();
    final uid = context.read<SessionProvider>().user!.uid;
    final cart = context.read<CartProvider>();
    final card = CardData(_number.text, _holder.text.trim(), _expiry.text, _cvv.text);

    final ok = widget.isSubscription
        ? await checkout.paySubscription(uid: uid, plan: widget.plan!, card: card)
        : await checkout.payOrder(
            uid: uid, cart: cart, discountPercent: widget.discountPercent, card: card);

    if (!mounted) return;
    if (ok) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 56),
          title: const Text('¡Pago exitoso!'),
          content: Text(
            '${widget.isSubscription ? 'Tu plan ${widget.plan!.name} ya está activo.' : 'Tu reserva fue confirmada.'}'
            '\n\nFolio: ${checkout.transactionId}',
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(120, 44)),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(checkout.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkout = context.watch<CheckoutProvider>();
    final cart = context.watch<CartProvider>();
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final processing = checkout.status == PaymentStatus.processing;

    final amount = widget.isSubscription
        ? widget.plan!.price
        : cart.totalWith(widget.discountPercent);
    final title = widget.isSubscription
        ? 'Suscripción ${widget.plan!.name} (mensual)'
        : '${cart.count} viajero(s) · ${cart.items.length} paquete(s)';

    return Scaffold(
      appBar: AppBar(title: const Text('Pago seguro')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Responsive.constrained(
            max: 520,
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: ListTile(
                      title: Text(title),
                      subtitle: const Text('Total a pagar (MXN)'),
                      trailing: Text(money.format(amount),
                          style: t.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700, color: scheme.primary)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CardPreview(
                    number: checkout.cardNumber,
                    brand: checkout.brand,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _number,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CardNumberFormatter()],
                    validator: Validators.cardNumber,
                    onChanged: checkout.onCardNumberChanged,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Número de tarjeta',
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _holder,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.required(v, 'El titular'),
                    decoration: const InputDecoration(
                      labelText: 'Nombre del titular',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expiry,
                          keyboardType: TextInputType.number,
                          inputFormatters: [ExpiryFormatter()],
                          validator: Validators.expiry,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Vence (MM/AA)',
                            prefixIcon: Icon(Icons.event),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _cvv,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(checkout.cvvLength),
                          ],
                          validator: (v) => Validators.cvv(v, length: checkout.cvvLength),
                          onFieldSubmitted: (_) => _pay(),
                          decoration: const InputDecoration(
                            labelText: 'CVV',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: processing ? null : _pay,
                    icon: processing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5))
                        : const Icon(Icons.lock),
                    label: Text(processing ? 'Procesando…' : 'Pagar ${money.format(amount)}'),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Modo prueba · usa 4242 4242 4242 4242 (aprobada), '
                    '4000 0000 0000 0002 (rechazada) o 4000 0000 0000 9995 (sin fondos). '
                    'Cualquier fecha futura y CVV.',
                    textAlign: TextAlign.center,
                    style: t.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardPreview extends StatelessWidget {
  final String number;
  final CardBrand brand;
  const _CardPreview({required this.number, required this.brand});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = switch (brand) {
      CardBrand.visa => 'VISA',
      CardBrand.mastercard => 'MASTERCARD',
      CardBrand.amex => 'AMEX',
      CardBrand.unknown => 'TARJETA',
    };
    final shown = number.isEmpty ? '•••• •••• •••• ••••' : number;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 170,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: brand == CardBrand.unknown
              ? [scheme.primary, scheme.tertiary]
              : brand == CardBrand.visa
                  ? [const Color(0xFF1A237E), const Color(0xFF3949AB)]
                  : brand == CardBrand.mastercard
                      ? [const Color(0xFFB71C1C), const Color(0xFFF57C00)]
                      : [const Color(0xFF006064), const Color(0xFF26A69A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.contactless_outlined, color: Colors.white),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            ],
          ),
          Text(shown,
              style: const TextStyle(
                  color: Colors.white, fontSize: 21, letterSpacing: 2, fontWeight: FontWeight.w500)),
          const Text('Viaja MX',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}
