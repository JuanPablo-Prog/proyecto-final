import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/components/password_field.dart';
import 'package:flutter_application_1/components/validators.dart';
import 'package:flutter_application_1/providers/session_provider.dart';
import 'package:flutter_application_1/screens/forgot_password_screen.dart';
import 'package:flutter_application_1/screens/register_screen.dart';

/// Misma presentación de tu práctica (imagen de fondo + logo + tarjeta morada),
/// ahora conectada a Firebase Auth. El estado de carga vive en SessionProvider.
class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _toast(String? error) {
    if (error != null && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    _toast(await context.read<SessionProvider>().signIn(_email.text, _pass.text));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SessionProvider>();
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width * 0.9 > 460 ? 460.0 : width * 0.9;

    final txtUser = TextFormField(
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: Validators.email,
      decoration: const InputDecoration(
        labelText: 'Correo electrónico',
        prefixIcon: Icon(Icons.mail_outline),
      ),
    );

    final txtPwd = PasswordField(
      controller: _pass,
      validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
      onSubmitted: (_) => _submit(),
    );

    final btnLogin = FilledButton.icon(
      onPressed: s.busy ? null : _submit,
      icon: s.busy
          ? const SizedBox(
              height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
          : const Icon(Icons.login),
      label: const Text('Iniciar Sesión'),
    );

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: width,
        decoration: BoxDecoration(
          color: const Color(0xFF263238),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: const AssetImage('resources/imagen.jpg'),
            onError: (_, __) {}, // si falta la imagen se queda el color de fondo
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Image.asset(
                    'resources/logo.png',
                    height: 130,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.flight_takeoff_rounded, size: 100, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: cardWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(20),
                      color: const Color.fromARGB(190, 119, 53, 158),
                    ),
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          txtUser,
                          const Divider(color: Colors.transparent),
                          txtPwd,
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen())),
                              child: const Text('¿Olvidaste tu contraseña?',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          btnLogin,
                          const SizedBox(height: 14),
                          const Row(children: [
                            Expanded(child: Divider(color: Colors.white54)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('o continúa con',
                                  style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                            Expanded(child: Divider(color: Colors.white54)),
                          ]),
                          const SizedBox(height: 14),
                          Row(children: [
                            Expanded(
                              child: FilledButton.tonalIcon(
                                style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48)),
                                onPressed: s.busy
                                    ? null
                                    : () async => _toast(await s.signInWithGoogle()),
                                icon: const Icon(Icons.g_mobiledata, size: 30),
                                label: const Text('Google'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton.tonalIcon(
                                style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48)),
                                onPressed: s.busy
                                    ? null
                                    : () async => _toast(await s.signInWithGithub()),
                                icon: const Icon(Icons.code),
                                label: const Text('GitHub'),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('¿No tienes cuenta?',
                                  style: TextStyle(color: Colors.white)),
                              TextButton(
                                onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const RegisterScreen())),
                                child: const Text('Regístrate',
                                    style: TextStyle(
                                        color: Colors.amber, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
