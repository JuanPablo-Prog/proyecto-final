import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/components/responsive.dart';
import 'package:flutter_application_1/database/plan.dart';
import 'package:flutter_application_1/providers/subscription_provider.dart';
import 'package:flutter_application_1/components/destination_card.dart';
import 'package:flutter_application_1/screens/checkout_screen.dart';

/// Suscripciones: tres planes (modelo de prestación de servicios).
class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionProvider>();
    final wide = Responsive.isWide(context);

    final cards = Plan.all
        .map((p) => _PlanCard(plan: p, current: sub.active && sub.plan?.id == p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Planes de suscripción')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Responsive.constrained(
          max: 1000,
          child: Column(
            children: [
              if (sub.active)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.verified, color: Colors.green),
                    title: Text('Plan ${sub.plan!.name} activo'),
                    subtitle: Text(sub.renewsAt == null
                        ? 'Suscripción vigente'
                        : 'Se renueva el ${DateFormat.yMMMMd('es_MX').format(sub.renewsAt!)}'),
                    trailing: TextButton(
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Cancelar suscripción'),
                            content: const Text('Perderás tu descuento en reservas. ¿Continuar?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Volver')),
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Cancelar plan')),
                            ],
                          ),
                        );
                        if (ok == true) await sub.cancel();
                      },
                      child: const Text('Cancelar'),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final c in cards) Expanded(child: c),
                  ],
                )
              else
                Column(children: cards),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Plan plan;
  final bool current;
  const _PlanCard({required this.plan, required this.current});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: plan.highlighted
              ? BorderSide(color: scheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (plan.highlighted)
                Chip(
                  label: const Text('Más popular'),
                  backgroundColor: scheme.primaryContainer,
                  visualDensity: VisualDensity.compact,
                ),
              Text(plan.name, style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(money.format(plan.price),
                      style: t.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700, color: scheme.primary)),
                  Text(' / mes', style: t.bodyMedium),
                ],
              ),
              const SizedBox(height: 12),
              for (final perk in plan.perks)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline, size: 20, color: scheme.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(perk)),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: current
                    ? null
                    : () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => CheckoutScreen.subscription(plan: plan))),
                child: Text(current ? 'Plan actual' : 'Elegir ${plan.name}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
