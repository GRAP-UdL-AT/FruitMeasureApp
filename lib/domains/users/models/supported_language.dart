import 'package:flutter/material.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';

enum SupportedLanguage {
  spanish(Locale('es')),
  english(Locale('en')),
  catalan(Locale('ca'));

  const SupportedLanguage(this.locale);
  final Locale locale;
}

extension SupportedLanguageX on SupportedLanguage {
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case SupportedLanguage.spanish:
        return l10n.languageEs;
      case SupportedLanguage.english:
        return l10n.languageEn;
      case SupportedLanguage.catalan:
        return l10n.languageCa;
    }
  }
}
