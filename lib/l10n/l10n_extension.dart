import 'package:flutter/material.dart';

import 'app_localizations.dart';

// Re-exportamos AppLocalizations para que un solo import alcance en todos los archivos
export 'app_localizations.dart';

/// Extensión para acceder a traducciones directamente desde el contexto.
/// Uso: context.l10n.algunaClave
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
