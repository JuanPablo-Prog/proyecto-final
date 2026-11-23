import 'package:flutter/material.dart';

/// Interruptor genérico (ej. mostrar/ocultar contraseña) sin usar setState.
class ToggleProvider extends ChangeNotifier {
  bool _value;
  ToggleProvider([this._value = true]);

  bool get value => _value;

  void toggle() {
    _value = !_value;
    notifyListeners();
  }
}
