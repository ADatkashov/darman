import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppL10n get l10n => AppL10n.of(this);
  String get localeCode => Localizations.localeOf(this).languageCode;
}
