import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/components/responsive.dart';
import 'package:flutter_application_1/providers/notification_provider.dart';

/// Suscripción del usuario a temas de interés (FCM Topics).
class TopicsScreen extends StatelessWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final n = context.watch<NotificationProvider>();
    final messenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Temas de interés')),
      body: Responsive.constrained(
        max: 640,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!n.supportsTopics)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Los temas FCM solo funcionan en Android / iOS.'),
                ),
              ),
            if (!n.permissionGranted)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.notifications_off_outlined),
                  title: Text('Permiso de notificaciones no concedido'),
                  subtitle: Text('Actívalo en los ajustes del sistema.'),
                ),
              ),
            for (final e in NotificationProvider.topics.entries)
              Card(
                child: SwitchListTile(
                  title: Text(e.value),
                  subtitle: Text('Tema: ${e.key}'),
                  value: n.isSubscribed(e.key),
                  onChanged: (v) async {
                    final err = await n.toggleTopic(e.key, v);
                    if (err != null) messenger.showSnackBar(SnackBar(content: Text(err)));
                  },
                ),
              ),
            const SizedBox(height: 8),
            if (n.token != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.key_outlined),
                  title: const Text('Token FCM del dispositivo'),
                  subtitle: SelectableText(n.token!, style: const TextStyle(fontSize: 11)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
