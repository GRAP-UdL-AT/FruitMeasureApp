import 'package:flutter/material.dart';
import 'package:fruit_measure_app/domains/users/models/supported_language.dart';
import 'package:fruit_measure_app/domains/users/models/user.dart';
import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:hive_ce/hive.dart';

class LanguageManager {
  static SupportedLanguage _current = _getDeviceLanguage();
  static final _notifier = ValueNotifier(_current.locale);

  static SupportedLanguage get current => _current;
  static Locale get locale => _current.locale;

  static void setLanguage(SupportedLanguage lang) {
    _current = lang;
    _notifier.value = lang.locale;
    _saveLanguagePreference(lang);
  }

  static void addListener(VoidCallback listener) =>
      _notifier.addListener(listener);
  static void removeListener(VoidCallback listener) =>
      _notifier.removeListener(listener);

  static void loadSavedLanguage() {
    final user = currentUser;
    if (user != null && user.preferredLanguage != null) {
      final savedLang = _languageCodeToEnum(user.preferredLanguage!);
      _current = savedLang;
      _notifier.value = savedLang.locale;
    }
  }

  static void _saveLanguagePreference(SupportedLanguage lang) {
    final user = currentUser;
    if (user != null) {
      user.preferredLanguage = lang.locale.languageCode;
      final userBox = Hive.box<User>(userBoxName);
      userBox.put(user.id, user);
    }
  }

  static SupportedLanguage _languageCodeToEnum(String code) {
    switch (code) {
      case 'en':
        return SupportedLanguage.english;
      case 'es':
        return SupportedLanguage.spanish;
      case 'ca':
      default:
        return SupportedLanguage.catalan;
    }
  }

  static SupportedLanguage _getDeviceLanguage() {
    return SupportedLanguage.catalan;
  }
}
