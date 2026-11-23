import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/components/responsive.dart';
import 'package:flutter_application_1/database/destination_dao.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/providers/navigation_provider.dart';
import 'package:flutter_application_1/components/destination_card.dart';
import 'package:flutter_application_1/components/net_image.dart';

class DestinationDetailScreen extends StatelessWidget {
  final DestinationDAO destination;
  const DestinationDetailScreen({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    final d = destination;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final point = LatLng(d.lat, d.lng);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(d.name, style: const TextStyle(shadows: [Shadow(blurRadius: 8)])),
              background: Stack(fit: StackFit.expand, children: [
                NetImage(d.imageUrl),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                ),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Responsive.constrained(
              max: 800,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      Chip(avatar: const Icon(Icons.place, size: 18), label: Text(d.state)),
                      Chip(avatar: const Icon(Icons.category, size: 18), label: Text(d.category)),
                      Chip(avatar: const Icon(Icons.schedule, size: 18), label: Text('${d.days} días')),
                      Chip(
                          avatar: const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                          label: Text(d.rating.toStringAsFixed(1))),
                    ]),
                    const SizedBox(height: 16),
                    Text('Acerca del destino',
                        style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(d.description, style: t.bodyLarge),
                    const SizedBox(height: 24),
                    Text('Ubicación', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox(
                        height: 220,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: point,
                            initialZoom: 9,
                            interactionOptions:
                                const InteractionOptions(flags: InteractiveFlag.none),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'mx.agencia.turismo',
                            ),
                            MarkerLayer(markers: [
                              Marker(
                                point: point,
                                width: 44,
                                height: 44,
                                child: Icon(Icons.location_on, size: 44, color: scheme.error),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed('/map'),
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Ver mapa completo'),
                      ),
                    ),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Desde', style: t.bodySmall),
                  Text(money.format(d.price),
                      style: t.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700, color: scheme.primary)),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    context.read<CartProvider>().add(d);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text('${d.name} agregado al carrito'),
                        action: SnackBarAction(
                          label: 'VER',
                          onPressed: () {
                            context.read<NavigationProvider>().go(2);
                            Navigator.of(context).popUntil((r) => r.isFirst);
                          },
                        ),
                      ));
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Reservar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
