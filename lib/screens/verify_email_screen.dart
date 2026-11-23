import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/components/responsive.dart';
import 'package:flutter_application_1/providers/session_provider.dart';

/// Bloquea el acceso hasta que el correo esté verificado.
class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SessionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Responsive.constrained(
              max: 440,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.mark_email_unread_outlined, size: 84, color: scheme.primary),
                  const SizedBox(height: 20),
                  Text('Verifica tu correo',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text(
                    'Enviamos un enlace de confirmación a\n${s.email}\nÁbrelo y luego toca "Ya verifiqué".',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: s.busy
                        ? null
                        : () async {
                            final ok = await s.refreshVerification();
                            if (!ok) {
                              messenger.showSnackBar(const SnackBar(
                                  content: Text('Aún no detectamos la verificación.')));
                            }
                          },
                    child: const Text('Ya verifiqué'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: (s.busy || s.resendCooldown > 0)
                        ? null
                        : () async {
                            final err = await s.resendVerification();
                            messenger.showSnackBar(SnackBar(
                                content: Text(err ?? 'Correo reenviado. Revisa tu bandeja.')));
                          },
                    child: Text(s.resendCooldown > 0
                        ? 'Reenviar correo (${s.resendCooldown}s)'
                        : 'Reenviar correo de confirmación'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(onPressed: s.signOut, child: const Text('Usar otra cuenta')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
