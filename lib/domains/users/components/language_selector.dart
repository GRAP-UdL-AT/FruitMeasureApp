import 'package:flutter/material.dart';
import 'package:fruit_measure_app/domains/users/models/language_manager.dart';
import 'package:fruit_measure_app/domains/users/models/supported_language.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key, this.enabled = true});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SupportedLanguage>(
          value: LanguageManager.current,
          underline: const SizedBox(),
          items:
              SupportedLanguage.values.map((lang) {
                return DropdownMenuItem<SupportedLanguage>(
                  value: lang,
                  child: Text(lang.localizedName(l10n)),
                );
              }).toList(),
          onChanged:
              enabled
                  ? (newLang) {
                    if (newLang != null) {
                      LanguageManager.setLanguage(newLang);
                    }
                  }
                  : null,
        ),
      ),
    );
  }
}
