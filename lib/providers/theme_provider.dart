import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/components/theme_app.dart';

/// Sustituye a GlobalValues.banThem (ValueNotifier, prohibido en este proyecto).
/// 0 --> Noche   1 --> Día   2 --> Cálido   (persistente)
class ThemeProvider extends ChangeNotifier {
  static const _key = 'theme_ban';
  final SharedPreferences _prefs;
  int _ban;

  ThemeProvider(this._prefs) : _ban = (_prefs.getInt(_key) ?? 1).clamp(0, 2);

  int get ban => _ban;

  ThemeData get theme {
    switch (_ban) {
      case 0:
        return ThemeApp.darkTheme();
      case 2:
        return ThemeApp.warmTheme();
      default:
        return ThemeApp.lightTheme();
    }
  }

  Future<void> setTheme(int value) async {
    _ban = value;
    notifyListeners();
    await _prefs.setInt(_key, value);
  }
}
