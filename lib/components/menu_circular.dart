import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';

/// Menú circular para cambiar de tema (0 Noche, 1 Día, 2 Cálido).
class menuCircular extends StatelessWidget {
  const menuCircular({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeProvider>();
    return CircularMenu(
      alignment: Alignment.bottomCenter,
      backgroundWidget: const SizedBox.shrink(),
      toggleButtonColor: Colors.red,
      items: [
        CircularMenuItem(
            icon: Icons.light_mode, color: Colors.green, onTap: () => theme.setTheme(1)),
        CircularMenuItem(
            icon: Icons.dark_mode, color: Colors.blue, onTap: () => theme.setTheme(0)),
        CircularMenuItem(
            icon: Icons.brightness_4, color: Colors.orange, onTap: () => theme.setTheme(2)),
      ],
    );
  }
}
