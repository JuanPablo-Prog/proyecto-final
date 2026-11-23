import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/components/responsive.dart';
import 'package:flutter_application_1/providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationProvider>().markAllRead();
    });
  }

  String _origin(String o) => switch (o) {
        'foreground' => 'Primer plano',
        'background' => 'Segundo plano',
        'terminated' => 'App cerrada',
        _ => o,
      };

  @override
  Widget build(BuildContext context) {
    final n = context.watch<NotificationProvider>();
    final fmt = DateFormat('d MMM · HH:mm', 'es_MX');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (n.inbox.isNotEmpty)
            IconButton(
              tooltip: 'Borrar todo',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: n.clear,
            ),
        ],
      ),
      body: n.inbox.isEmpty
          ? const Center(child: Text('Aún no tienes notificaciones'))
          : Responsive.constrained(
              max: 720,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: n.inbox.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final item = n.inbox[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.notifications_outlined),
                      title: Text(item.title),
                      subtitle: Text(
                          '${item.body}\n${fmt.format(item.receivedAt)} · ${_origin(item.origin)}'),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
