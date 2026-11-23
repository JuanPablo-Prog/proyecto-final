import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/components/responsive.dart';
import 'package:flutter_application_1/providers/destination_provider.dart';
import 'package:flutter_application_1/providers/navigation_provider.dart';
import 'package:flutter_application_1/providers/notification_provider.dart';
import 'package:flutter_application_1/providers/session_provider.dart';
import 'package:flutter_application_1/providers/shake_provider.dart';
import 'package:flutter_application_1/providers/subscription_provider.dart';
import 'package:flutter_application_1/components/parallax_card.dart';
import 'package:flutter_application_1/components/user_avatar.dart';
import 'package:flutter_application_1/screens/destination_detail_screen.dart';

/// Dashboard: saludo + avatar sincronizado, medidor del acelerómetro,
/// destinos destacados con parallax y acceso a planes.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final dest = context.watch<DestinationProvider>();
    final unread = context.select<NotificationProvider, int>((n) => n.unread);
    final sub = context.watch<SubscriptionProvider>();
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    // Centra la cuadrícula en pantallas anchas (máx. 1200 px de contenido).
    final double side = 16 + (width > 1232 ? (width - 1200) / 2 : 0.0);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          toolbarHeight: 72,
          titleSpacing: 16,
          title: Row(
            children: [
              GestureDetector(
                onTap: () => context.read<NavigationProvider>().go(3),
                child: const UserAvatar(radius: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hola,', style: t.bodySmall),
                    Text(session.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Mapa de la agencia',
              icon: const Icon(Icons.map_outlined),
              onPressed: () => Navigator.of(context).pushNamed('/map'),
            ),
            IconButton(
              tooltip: 'Notificaciones',
              icon: Badge(
                isLabelVisible: unread > 0,
                label: Text('$unread'),
                child: const Icon(Icons.notifications_outlined),
              ),
              onPressed: () => Navigator.of(context).pushNamed('/notifications'),
            ),
            IconButton(
              tooltip: 'Menú',
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
            const SizedBox(width: 6),
          ],
        ),
        SliverToBoxAdapter(
          child: Responsive.constrained(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ShakeCard(),
                  const SizedBox(height: 12),
                  if (sub.active)
                    Card(
                      color: scheme.primaryContainer,
                      child: ListTile(
                        leading: const Icon(Icons.workspace_premium),
                        title: Text('Plan ${sub.plan!.name} activo'),
                        subtitle: Text('${sub.discountPercent}% de descuento en tus reservas'),
                        onTap: () => Navigator.of(context).pushNamed('/plans'),
                      ),
                    )
                  else
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.workspace_premium_outlined, color: scheme.primary),
                        title: const Text('Suscríbete y ahorra hasta 20%'),
                        subtitle: const Text('Planes desde \$149 al mes'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).pushNamed('/plans'),
                      ),
                    ),
                  const SizedBox(height: 18),
                  Text('Destinos destacados',
                      style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
        if (dest.loading)
          const SliverToBoxAdapter(
              child: Padding(
                  padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())))
        else if (dest.featured.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(dest.error ?? 'Aún no hay destinos. Importa el JSON de ejemplo en Realtime Database.',
                    textAlign: TextAlign.center),
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: side, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 560,
                mainAxisExtent: 230,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                childCount: dest.featured.length,
                (context, i) {
                  final d = dest.featured[i];
                  return ParallaxDestinationCard(
                    destination: d,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => DestinationDetailScreen(destination: d))),
                  );
                },
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

/// Tarjeta con medidor en vivo del acelerómetro.
class _ShakeCard extends StatelessWidget {
  const _ShakeCard();

  @override
  Widget build(BuildContext context) {
    final shake = context.watch<ShakeProvider>();
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.vibration, color: scheme.onSecondaryContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    shake.sensorAvailable
                        ? 'Agita tu teléfono para un destino sorpresa'
                        : 'Sin acelerómetro en este dispositivo',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: scheme.onSecondaryContainer),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: shake.intensity,
                minHeight: 10,
                backgroundColor: scheme.surface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: shake.pick,
                icon: const Icon(Icons.casino_outlined),
                label: const Text('Sorpréndeme'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
