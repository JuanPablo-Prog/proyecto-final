import 'package:flutter/material.dart';

/// Llaves globales para mostrar avisos y navegar desde fuera del árbol de
/// widgets (por ejemplo, cuando llega una notificación push).
class AppKeys {
  static final navigator = GlobalKey<NavigatorState>();
  static final messenger = GlobalKey<ScaffoldMessengerState>();
}
