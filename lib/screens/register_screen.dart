import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/components/responsive.dart';
import 'package:flutter_application_1/components/validators.dart';
import 'package:flutter_application_1/providers/session_provider.dart';
import 'package:flutter_application_1/components/password_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _pass2.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final error = await context
        .read<SessionProvider>()
        .register(_name.text, _email.text, _pass.text);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    } else {
      // RootGate mostrará la pantalla de verificación; se cierra esta ruta.
      nav.popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<SessionProvider>().busy;
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
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
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: (v) => Validators.required(v, 'El nombre'),
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 14),
                    PasswordField(
                      controller: _pass,
                      validator: Validators.password,
                      action: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    PasswordField(
                      controller: _pass2,
                      label: 'Confirmar contraseña',
                      validator: (v) => v != _pass.text ? 'Las contraseñas no coinciden' : null,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Te enviaremos un correo para verificar tu cuenta antes de entrar.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: busy ? null : _submit,
                      child: busy
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5))
                          : const Text('Registrarme'),
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
