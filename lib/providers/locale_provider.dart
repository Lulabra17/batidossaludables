import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LocaleProvider extends ChangeNotifier {
  static const _localeKey = 'app_locale';
  static const _themeKey = 'app_theme';
  final Box _prefs;

  LocaleProvider(this._prefs);

  Locale get locale {
    final saved = _prefs.get(_localeKey) as String?;
    if (saved != null) return Locale(saved);
    final platformLocales =
        WidgetsBinding.instance.platformDispatcher.locales;
    if (platformLocales.any((l) => l.languageCode == 'es')) {
      return const Locale('es');
    }
    return const Locale('en');
  }

  void setLocale(String languageCode) {
    _prefs.put(_localeKey, languageCode);
    notifyListeners();
  }

  ThemeMode get themeMode {
    final saved = _prefs.get(_themeKey) as String?;
    if (saved == 'dark') return ThemeMode.dark;
    if (saved == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  bool get isDark {
    if (themeMode == ThemeMode.dark) return true;
    if (themeMode == ThemeMode.light) return false;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  void toggleTheme() {
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    _prefs.put(_themeKey, newMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }
}
