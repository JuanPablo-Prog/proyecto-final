import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/database/destination_dao.dart';
import 'package:flutter_application_1/components/net_image.dart';

final money = NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

class DestinationCard extends StatelessWidget {
  final DestinationDAO destination;
  final VoidCallback onTap;
  const DestinationCard({super.key, required this.destination, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final d = destination;
    final t = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetImage(d.imageUrl),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Chip(
                      label: Text(d.category, style: const TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Text(d.state, style: t.bodySmall),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('${money.format(d.price)} ',
                          style: t.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700)),
                      Text('/ persona', style: t.bodySmall),
                      const Spacer(),
                      const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                      Text(d.rating.toStringAsFixed(1), style: t.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
