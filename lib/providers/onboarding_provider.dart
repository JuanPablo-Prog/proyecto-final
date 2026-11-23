import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider extends ChangeNotifier {
  static const _key = 'onboarding_seen';
  final SharedPreferences _prefs;
  int _page = 0;
  late bool _seen;

  OnboardingProvider(this._prefs) {
    _seen = _prefs.getBool(_key) ?? false;
  }

  int get page => _page;
  bool get seen => _seen;

  void setPage(int i) {
    _page = i;
    notifyListeners();
  }

  Future<void> finish() async {
    _seen = true;
    notifyListeners();
    await _prefs.setBool(_key, true);
  }
}
