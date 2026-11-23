import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/toggle_provider.dart';

/// Campo de contraseña con botón de mostrar/ocultar (estado en Provider).
class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputAction action;
  final void Function(String)? onSubmitted;

  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Contraseña',
    this.validator,
    this.action = TextInputAction.done,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ToggleProvider(true),
      child: Consumer<ToggleProvider>(
        builder: (context, t, _) => TextFormField(
          controller: controller,
          obscureText: t.value,
          validator: validator,
          textInputAction: action,
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(t.value ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: t.toggle,
            ),
          ),
        ),
      ),
    );
  }
}
