import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/destination_dao.dart';
import 'package:flutter_application_1/components/net_image.dart';

/// WIDGET AVANZADO (innovación UI): tarjeta con efecto parallax construida con
/// `Flow` + `FlowDelegate`. La imagen se desplaza a distinta velocidad que la
/// lista, calculando su posición con el `ScrollPosition` (repaint sin rebuild).
class ParallaxDestinationCard extends StatelessWidget {
  final DestinationDAO destination;
  final VoidCallback onTap;
  const ParallaxDestinationCard({super.key, required this.destination, required this.onTap});

  static const double _extra = 1.45; // la imagen es 45% más alta que la tarjeta

  @override
  Widget build(BuildContext context) {
    final d = destination;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Flow(
              delegate: _ParallaxFlowDelegate(
                scrollable: Scrollable.of(context),
                itemContext: context,
                extra: _extra,
              ),
              children: [NetImage(d.imageUrl)],
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.45, 1],
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(d.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.place, size: 15, color: Colors.white70),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text('${d.state} · ${d.days} días',
                            style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ),
                      const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                      Text(' ${d.rating.toStringAsFixed(1)}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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

class _ParallaxFlowDelegate extends FlowDelegate {
  final ScrollableState scrollable;
  final BuildContext itemContext;
  final double extra;

  _ParallaxFlowDelegate({
    required this.scrollable,
    required this.itemContext,
    required this.extra,
  }) : super(repaint: scrollable.position);

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) =>
      BoxConstraints.tightFor(
        width: constraints.maxWidth,
        height: constraints.maxHeight * extra,
      );

  @override
  void paintChildren(FlowPaintingContext context) {
    final scrollBox = scrollable.context.findRenderObject() as RenderBox?;
    final itemBox = itemContext.findRenderObject() as RenderBox?;
    if (scrollBox == null || itemBox == null || !itemBox.attached) return;

    final itemOffset = itemBox.localToGlobal(
      itemBox.size.centerLeft(Offset.zero),
      ancestor: scrollBox,
    );
    final viewport = scrollable.position.viewportDimension;
    final fraction = (itemOffset.dy / viewport).clamp(0.0, 1.0);
    final alignment = Alignment(0.0, fraction * 2 - 1);

    final bgSize = Size(context.size.width, context.size.height * extra);
    final rect = alignment.inscribe(bgSize, Offset.zero & context.size);
    context.paintChild(0, transform: Transform.translate(offset: Offset(0, rect.top)).transform);
  }

  @override
  bool shouldRepaint(_ParallaxFlowDelegate old) =>
      scrollable != old.scrollable || itemContext != old.itemContext || extra != old.extra;
}
