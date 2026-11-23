import 'package:flutter/material.dart';

/// Utilidades de diseño responsivo (móvil / tablet / escritorio).
class Responsive {
  static const double wideBreakpoint = 760;
  static const double maxContentWidth = 1200;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wideBreakpoint;

  /// Centra el contenido y limita su ancho en pantallas grandes.
  static Widget constrained({required Widget child, double max = maxContentWidth}) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: max),
        child: child,
      ),
    );
  }
}
