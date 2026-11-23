import 'package:flutter/material.dart';

/// Temas de la app (mismos 3 modos de la práctica):
/// 0 --> Noche   1 --> Día   2 --> Cálido
/// Todos usan la tipografía personalizada Poppins.
class ThemeApp {
  static const fontFamily = 'Poppins';
  static const _seed = Color(0xFF00897B);

  static ThemeData lightTheme() =>
      _build(ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light));

  static ThemeData darkTheme() =>
      _build(ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark));

  // Esquema "cálido" tomado de tu práctica (ajusta los colores a tu gusto).
  static ThemeData warmTheme() => _build(const ColorScheme(
        brightness: Brightness.dark,
        primary: Colors.grey,
        onPrimary: Colors.amber,
        secondary: Colors.red,
        onSecondary: Colors.green,
        error: Colors.red,
        onError: Colors.red,
        surface: Colors.greenAccent,
        onSurface: Colors.blueGrey,
      ));

  static ThemeData _build(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
