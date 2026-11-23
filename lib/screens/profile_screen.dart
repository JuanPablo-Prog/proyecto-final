import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/components/responsive.dart';
import 'package:flutter_application_1/providers/session_provider.dart';
import 'package:flutter_application_1/providers/subscription_provider.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:flutter_application_1/components/user_avatar.dart';
import 'package:flutter_application_1/screens/topics_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _changePhoto(BuildContext context) async {
    final session = context.read<SessionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 300, maxHeight: 300, imageQuality: 60);
    if (picked == null) return;
    final err = await session.updatePhoto(await picked.readAsBytes());
    messenger.showSnackBar(SnackBar(content: Text(err ?? 'Foto actualizada')));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SessionProvider>();
    final theme = context.watch<ThemeProvider>();
    final sub = context.watch<SubscriptionProvider>();
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Responsive.constrained(
          max: 640,
          child: Column(
            children: [
              Stack(
                children: [
                  const UserAvatar(radius: 56),
                  // Solo las cuentas por correo pueden editar la foto.
                  if (s.canEditPhoto)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: s.busy
                          ? const CircleAvatar(
                              radius: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : CircleAvatar(
                              radius: 18,
                              backgroundColor: scheme.primary,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                tooltip: 'Cambiar foto',
                                icon: Icon(Icons.camera_alt, size: 18, color: scheme.onPrimary),
                                onPressed: () => _changePhoto(context),
                              ),
                            ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(s.displayName, style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              Text(s.email, style: t.bodyMedium),
              const SizedBox(height: 10),
              Wrap(spacing: 8, children: [
                Chip(
                  avatar: const Icon(Icons.login, size: 16),
                  label: Text(s.providerLabel()),
                ),
                Chip(
                  avatar: Icon(
                      s.needsVerification ? Icons.error_outline : Icons.verified_outlined,
                      size: 16),
                  label: Text(s.needsVerification ? 'Sin verificar' : 'Cuenta verificada'),
                ),
              ]),
              if (!s.canEditPhoto)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Tu foto proviene de ${s.providerLabel()}; solo las cuentas de correo pueden cambiarla.',
                    textAlign: TextAlign.center,
                    style: t.bodySmall,
                  ),
                ),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.workspace_premium_outlined),
                      title: const Text('Mi suscripción'),
                      subtitle: Text(sub.active
                          ? 'Plan ${sub.plan!.name} · ${sub.discountPercent}% de descuento'
                          : 'Sin suscripción activa'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).pushNamed('/plans'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications_active_outlined),
                      title: const Text('Temas de notificaciones'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => const TopicsScreen())),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.map_outlined),
                      title: const Text('Ubicación de la agencia'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).pushNamed('/map'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Apariencia', style: t.titleSmall),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(
                                value: 1,
                                icon: Icon(Icons.light_mode_outlined),
                                label: Text('Día')),
                            ButtonSegment(
                                value: 0,
                                icon: Icon(Icons.dark_mode_outlined),
                                label: Text('Noche')),
                            ButtonSegment(
                                value: 2,
                                icon: Icon(Icons.brightness_4_outlined),
                                label: Text('Cálido')),
                          ],
                          selected: {theme.ban},
                          onSelectionChanged: (v) => theme.setTheme(v.first),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: s.signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
