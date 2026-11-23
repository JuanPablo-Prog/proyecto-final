import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/components/app_keys.dart';
import 'package:flutter_application_1/database/app_notification.dart';

/// Escuchador GLOBAL de Cloud Messaging (se crea con lazy:false en main.dart,
/// por lo que está activo en todas las pantallas).
///
/// Cubre los tres estados de la app:
///  - foreground : FirebaseMessaging.onMessage      -> aviso dentro de la app
///  - background : FirebaseMessaging.onMessageOpenedApp
///  - terminated : FirebaseMessaging.instance.getInitialMessage()
/// El envío se hace desde la consola de Firebase (sin backend propio).
class NotificationProvider extends ChangeNotifier {
  static const topics = <String, String>{
    'ofertas': 'Ofertas y promociones',
    'playas': 'Destinos de playa',
    'pueblos_magicos': 'Pueblos Mágicos',
    'aventura': 'Aventura y naturaleza',
    'cultura': 'Cultura y gastronomía',
  };
  static const _kInbox = 'notif_inbox';
  static const _kTopics = 'notif_topics';

  final SharedPreferences _prefs;
  final List<StreamSubscription> _subs = [];

  List<AppNotification> inbox = [];
  Set<String> subscribed = {};
  String? token;
  bool permissionGranted = false;
  int unread = 0;

  NotificationProvider(this._prefs) {
    inbox = AppNotification.decodeList(_prefs.getString(_kInbox));
    subscribed = (_prefs.getStringList(_kTopics) ?? ['ofertas']).toSet();
  }

  bool get supportsTopics => !kIsWeb;

  Future<void> init() async {
    final fm = FirebaseMessaging.instance;
    try {
      final settings = await fm.requestPermission(alert: true, badge: true, sound: true);
      permissionGranted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      // iOS: mostrar banner también en primer plano.
      await fm.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true);
      token = await fm.getToken();
      debugPrint('FCM token: $token');
    } catch (e) {
      debugPrint('FCM init error: $e');
    }

    // Reaplica las suscripciones guardadas.
    if (supportsTopics) {
      for (final t in subscribed) {
        try {
          await fm.subscribeToTopic(t);
        } catch (_) {}
      }
    }

    // 1) FOREGROUND
    _subs.add(FirebaseMessaging.onMessage.listen((m) {
      _store(m, 'foreground');
      _showBanner(m);
    }));

    // 2) BACKGROUND (el usuario toca la notificación del sistema)
    _subs.add(FirebaseMessaging.onMessageOpenedApp.listen((m) {
      _store(m, 'background');
      _openInbox();
    }));

    // 3) TERMINATED (la app se abrió desde una notificación)
    final initial = await fm.getInitialMessage();
    if (initial != null) {
      _store(initial, 'terminated');
      Future.delayed(const Duration(milliseconds: 900), _openInbox);
    }
    notifyListeners();
  }

  // --------------------------------------------------------------- temas FCM
  bool isSubscribed(String topic) => subscribed.contains(topic);

  Future<String?> toggleTopic(String topic, bool value) async {
    try {
      if (supportsTopics) {
        if (value) {
          await FirebaseMessaging.instance.subscribeToTopic(topic);
        } else {
          await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
        }
      }
      value ? subscribed.add(topic) : subscribed.remove(topic);
      await _prefs.setStringList(_kTopics, subscribed.toList());
      notifyListeners();
      return null;
    } catch (e) {
      return 'No se pudo actualizar la suscripción (¿sin conexión?)';
    }
  }

  // ----------------------------------------------------------------- bandeja
  void markAllRead() {
    unread = 0;
    notifyListeners();
  }

  Future<void> clear() async {
    inbox = [];
    unread = 0;
    await _prefs.remove(_kInbox);
    notifyListeners();
  }

  void _store(RemoteMessage m, String origin) {
    final n = AppNotification(
      title: m.notification?.title ?? m.data['title']?.toString() ?? 'Agencia de Turismo',
      body: m.notification?.body ?? m.data['body']?.toString() ?? '',
      receivedAt: DateTime.now(),
      origin: origin,
    );
    inbox.insert(0, n);
    if (inbox.length > 50) inbox = inbox.sublist(0, 50);
    unread++;
    _prefs.setString(_kInbox, AppNotification.encodeList(inbox));
    notifyListeners();
  }

  void _showBanner(RemoteMessage m) {
    final title = m.notification?.title ?? 'Nueva notificación';
    final body = m.notification?.body ?? '';
    AppKeys.messenger.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (body.isNotEmpty) Text(body),
          ],
        ),
        action: SnackBarAction(label: 'VER', onPressed: _openInbox),
      ));
  }

  void _openInbox() {
    AppKeys.navigator.currentState?.pushNamed('/notifications');
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}
