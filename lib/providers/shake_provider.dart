import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_application_1/database/destination_dao.dart';

/// SENSOR: acelerómetro. Al agitar el teléfono la app sugiere un "destino
/// sorpresa". También expone la intensidad en vivo para el medidor de la UI.
class ShakeProvider extends ChangeNotifier {
  static const double _threshold = 24; // m/s² (la gravedad ronda 9.8)
  static const _cooldown = Duration(milliseconds: 1800);

  StreamSubscription<AccelerometerEvent>? _sub;
  void Function(DestinationDAO)? _onShake;
  List<DestinationDAO> Function()? _source;
  DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastUi = DateTime.fromMillisecondsSinceEpoch(0);

  double intensity = 0; // 0..1
  bool sensorAvailable = true;

  void start({
    required List<DestinationDAO> Function() source,
    required void Function(DestinationDAO) onShake,
  }) {
    _source = source;
    _onShake = onShake;
    if (_sub != null) return;
    try {
      _sub = accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen(
        _onEvent,
        onError: (_) {
          sensorAvailable = false;
          notifyListeners();
        },
        cancelOnError: true,
      );
    } catch (_) {
      sensorAvailable = false;
    }
  }

  void _onEvent(AccelerometerEvent e) {
    final magnitude = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
    final now = DateTime.now();

    // Actualiza el medidor ~10 veces por segundo.
    if (now.difference(_lastUi).inMilliseconds > 100) {
      _lastUi = now;
      intensity = ((magnitude - 9.8).abs() / (_threshold - 9.8)).clamp(0.0, 1.0);
      notifyListeners();
    }

    if (magnitude > _threshold && now.difference(_last) > _cooldown) {
      _last = now;
      pick();
    }
  }

  /// También se puede llamar desde un botón (web / escritorio sin acelerómetro).
  void pick() {
    final list = _source?.call() ?? const [];
    if (list.isEmpty) return;
    _onShake?.call(list[Random().nextInt(list.length)]);
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    _onShake = null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
