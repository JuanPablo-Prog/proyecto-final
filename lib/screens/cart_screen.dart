import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/components/responsive.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/providers/navigation_provider.dart';
import 'package:flutter_application_1/providers/subscription_provider.dart';
import 'package:flutter_application_1/components/destination_card.dart';
import 'package:flutter_application_1/components/net_image.dart';
import 'package:flutter_application_1/screens/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  /// true cuando se muestra como pestaña; false cuando se abre como ruta.
  final bool embedded;
  const CartScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final sub = context.watch<SubscriptionProvider>();
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final content = cart.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 72, color: scheme.outline),
                const SizedBox(height: 12),
                const Text('Tu carrito está vacío'),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  style: FilledButton.styleFrom(minimumSize: const Size(180, 46)),
                  onPressed: () => context.read<NavigationProvider>().go(1),
                  child: const Text('Explorar destinos'),
                ),
              ],
            ),
          )
        : Responsive.constrained(
            max: 800,
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final item = cart.items[i];
                      final d = item.destination;
                      return Dismissible(
                        key: ValueKey(d.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                              color: scheme.errorContainer,
                              borderRadius: BorderRadius.circular(20)),
                          child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
                        ),
                        onDismissed: (_) => cart.remove(d.id),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: SizedBox(
                                      width: 84, height: 84, child: NetImage(d.imageUrl)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(d.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: t.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                      Text('${money.format(d.price)} por persona',
                                          style: t.bodySmall),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          IconButton.filledTonal(
                                            visualDensity: VisualDensity.compact,
                                            onPressed: () =>
                                                cart.setTravelers(d.id, item.travelers - 1),
                                            icon: const Icon(Icons.remove, size: 18),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            child: Text('${item.travelers}', style: t.titleMedium),
                                          ),
                                          IconButton.filledTonal(
                                            visualDensity: VisualDensity.compact,
                                            onPressed: () =>
                                                cart.setTravelers(d.id, item.travelers + 1),
                                            icon: const Icon(Icons.add, size: 18),
                                          ),
                                          const Spacer(),
                                          Text(money.format(item.subtotal),
                                              style: t.titleSmall
                                                  ?.copyWith(fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      children: [
                        _row('Subtotal', money.format(cart.subtotal), t),
                        if (sub.discountPercent > 0)
                          _row('Descuento ${sub.plan!.name} (${sub.discountPercent}%)',
                              '-${money.format(cart.discountAmount(sub.discountPercent))}', t,
                              color: scheme.primary),
                        const Divider(),
                        _row('Total', money.format(cart.totalWith(sub.discountPercent)), t,
                            bold: true),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => CheckoutScreen.order(
                                  discountPercent: sub.discountPercent))),
                          child: const Text('Proceder al pago'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );

    return Scaffold(
      appBar: AppBar(title: const Text('Mi carrito')),
      body: content,
    );
  }

  Widget _row(String l, String v, TextTheme t, {bool bold = false, Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(l, style: bold ? t.titleMedium : t.bodyMedium?.copyWith(color: color))),
            Text(v,
                style: (bold ? t.titleMedium : t.bodyMedium)
                    ?.copyWith(fontWeight: bold ? FontWeight.w700 : null, color: color)),
          ],
        ),
      );
}
