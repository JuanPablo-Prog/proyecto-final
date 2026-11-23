import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Imagen con caché en disco (visible sin conexión tras la primera descarga).
class NetImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  const NetImage(this.url, {super.key, this.fit = BoxFit.cover, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (url.isEmpty) return _placeholder(scheme, Icons.landscape_outlined);
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: const Duration(milliseconds: 250),
      placeholder: (_, __) => _placeholder(scheme, Icons.image_outlined),
      errorWidget: (_, __, ___) => _placeholder(scheme, Icons.cloud_off_outlined),
    );
  }

  Widget _placeholder(ColorScheme scheme, IconData icon) => Container(
        width: width,
        height: height,
        color: scheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(icon, color: scheme.onSurfaceVariant),
      );
}
