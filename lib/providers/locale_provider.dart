import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LocaleProvider extends ChangeNotifier {
  static const _key = 'app_locale';
  final Box _prefs;

  LocaleProvider(this._prefs);

  Locale get locale {
    final saved = _prefs.get(_key) as String?;
    if (saved != null) return Locale(saved);
    // Sin preferencia guardada: detecta el idioma del dispositivo
    final platformLocales =
        WidgetsBinding.instance.platformDispatcher.locales;
    if (platformLocales.any((l) => l.languageCode == 'es')) {
      return const Locale('es');
    }
    return const Locale('en');
  }

  void setLocale(String languageCode) {
    _prefs.put(_key, languageCode);
    notifyListeners();
  }
}
