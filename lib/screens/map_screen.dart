import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/destination_provider.dart';

/// Mapa NATIVO (se dibuja con Flutter, sin WebView) con la ubicación física de
/// la agencia y los destinos del catálogo.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  // Sucursal de la agencia (ajusta las coordenadas a tu establecimiento real).
  static const agency = LatLng(20.1394, -101.1757);
  static const agencyName = 'Viaja MX · Sucursal Uriangato';
  static const agencyAddress = 'Centro, Uriangato, Guanajuato';
  static const agencyHours = 'Lun–Sáb 9:00–19:00';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final destinations = context.watch<DestinationProvider>().all;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuestra ubicación')),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(initialCenter: agency, initialZoom: 6.2),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'mx.agencia.turismo',
              ),
              MarkerLayer(markers: [
                for (final d in destinations)
                  Marker(
                    point: LatLng(d.lat, d.lng),
                    width: 38,
                    height: 38,
                    child: Tooltip(
                      message: d.name,
                      child: Icon(Icons.location_on, size: 38, color: scheme.tertiary),
                    ),
                  ),
                Marker(
                  point: agency,
                  width: 52,
                  height: 52,
                  child: Container(
                    decoration: BoxDecoration(color: scheme.error, shape: BoxShape.circle),
                    child: Icon(Icons.storefront, color: scheme.onError, size: 28),
                  ),
                ),
              ]),
              const RichAttributionWidget(
                attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  color: scheme.surface,
                  elevation: 3,
                  child: const ListTile(
                    leading: Icon(Icons.storefront),
                    title: Text(agencyName),
                    subtitle: Text('$agencyAddress\n$agencyHours'),
                    isThreeLine: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
