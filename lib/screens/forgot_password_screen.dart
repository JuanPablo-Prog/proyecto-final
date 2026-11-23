import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/components/responsive.dart';
import 'package:flutter_application_1/components/validators.dart';
import 'package:flutter_application_1/providers/session_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<SessionProvider>().sendPasswordReset(_email.text);
    messenger.showSnackBar(SnackBar(
      content: Text(error ?? 'Enviamos un enlace a ${_email.text.trim()}. Revisa tu correo.'),
    ));
    if (error == null) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<SessionProvider>().busy;
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Responsive.constrained(
              max: 440,
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.lock_reset, size: 72),
                    const SizedBox(height: 16),
                    Text(
                      'Ingresa el correo de tu cuenta y te enviaremos un enlace para crear una nueva contraseña.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      onFieldSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: busy ? null : _send,
                      child: const Text('Enviar enlace'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
