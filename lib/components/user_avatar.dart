import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/session_provider.dart';

/// Avatar sincronizado: dashboard y perfil leen del mismo SessionProvider,
/// así un cambio de foto se refleja al instante en ambos lugares.
class UserAvatar extends StatelessWidget {
  final double radius;
  const UserAvatar({super.key, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SessionProvider>();
    final scheme = Theme.of(context).colorScheme;
    // Cuentas por correo: foto propia (base64 en la base de datos).
    final bytes = s.canEditPhoto ? s.photoBytes : null;
    final url = bytes == null ? s.photoUrl : null;
    final initial = s.displayName.isNotEmpty ? s.displayName[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      // CachedNetworkImageProvider guarda la foto en disco: se ve sin internet.
      backgroundImage: bytes != null
          ? MemoryImage(bytes)
          : (url != null && url.isNotEmpty ? CachedNetworkImageProvider(url) : null),
      child: (bytes == null && (url == null || url.isEmpty))
          ? Text(initial,
              style: TextStyle(
                  fontSize: radius * 0.8,
                  fontWeight: FontWeight.w600,
                  color: scheme.onPrimaryContainer))
          : null,
    );
  }
}
