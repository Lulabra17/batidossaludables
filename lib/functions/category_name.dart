import 'package:batidos_salud/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';

String categoryLocalizedName(BuildContext context, int id) {
  final l10n = context.l10n;
  switch (id) {
    case 1:  return l10n.cat1;
    case 2:  return l10n.cat2;
    case 3:  return l10n.cat3;
    case 4:  return l10n.cat4;
    case 5:  return l10n.cat5;
    case 6:  return l10n.cat6;
    case 7:  return l10n.cat7;
    case 8:  return l10n.cat8;
    case 9:  return l10n.cat9;
    case 10: return l10n.cat10;
    case 11: return l10n.cat11;
    case 12: return l10n.cat12;
    case 13: return l10n.cat13;
    case 14: return l10n.cat14;
    case 15: return l10n.cat15;
    case 16: return l10n.cat16;
    case 17: return l10n.cat17;
    case 18: return l10n.cat18;
    default: return '';
  }
}
