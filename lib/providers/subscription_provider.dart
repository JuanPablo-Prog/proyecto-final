import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/plan.dart';

/// Suscripción activa del usuario (Realtime Database: subscriptions/{uid}).
class SubscriptionProvider extends ChangeNotifier {
  StreamSubscription<DatabaseEvent>? _sub;
  String? _uid;

  Plan? plan;
  DateTime? renewsAt;
  bool active = false;

  int get discountPercent => active ? (plan?.discountPercent ?? 0) : 0;

  /// Llamado por ProxyProvider cuando cambia el usuario.
  void bind(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _sub?.cancel();
    plan = null;
    active = false;
    renewsAt = null;
    if (uid == null) {
      // bind() se invoca durante el build (ProxyProvider): se notifica después.
      scheduleMicrotask(notifyListeners);
      return;
    }
    _sub = FirebaseDatabase.instance.ref('subscriptions/$uid').onValue.listen((e) {
      final v = e.snapshot.value;
      if (v is Map && v['status'] == 'active') {
        plan = Plan.byId(v['planId']?.toString());
        active = plan != null;
        final r = v['renewsAt'];
        renewsAt = r is num ? DateTime.fromMillisecondsSinceEpoch(r.toInt()) : null;
      } else {
        plan = null;
        active = false;
        renewsAt = null;
      }
      notifyListeners();
    }, onError: (_) {});
  }

  Future<void> cancel() async {
    final uid = _uid;
    if (uid == null) return;
    await FirebaseDatabase.instance.ref('subscriptions/$uid/status').set('cancelled');
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
