import 'package:flutter/widgets.dart';
import 'package:vgv_best_practices/l10n/arb/app_localizations.dart';
export 'package:vgv_best_practices/l10n/arb/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
