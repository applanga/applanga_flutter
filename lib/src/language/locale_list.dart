import 'package:applanga_flutter/src/applanga_exception.dart';
import 'package:flutter/material.dart';
import 'package:intl/locale.dart' as intl_locale;

extension LocaleListExtension on List<Locale> {
  void addUniqueLocale(Locale locale) {
    if (!any((element) => element.toLanguageTag() == locale.toLanguageTag())) {
      add(locale);
    }
  }
}

extension LocaleExtension on Locale {
  bool hasScriptCode() {
    return scriptCode != null && scriptCode!.isNotEmpty;
  }

  bool hasCountryCode() {
    return countryCode != null && countryCode!.isNotEmpty;
  }
}

class LocaleList {
  List<Locale> _localeList = [];
  late final Locale baseLanguage;
  late final Map<String, List<String>>? customLanguageFallback;

  LocaleList(Locale locale, String baseLanguage,
      {this.customLanguageFallback}) {
    this.baseLanguage = _localeFromString(baseLanguage);
    changeLocale(locale);
  }

  List<Locale> get list => _localeList;

  List<String> get listAsLocaleStrings =>
      _localeList.map((e) => e.toLanguageTag()).toList();

  Locale get locale => _localeList.first;

  String get localeAsString => locale.toLanguageTag();

  bool hasCurrentLocale() {
    return _localeList.isNotEmpty;
  }

  void changeLocale(Locale locale) {
    List<Locale> newLocaleList = [];
    List<Locale>? customFallback =
        getCustomFallbackForLanguage(locale.toLanguageTag());
    if (customFallback == null) {
      newLocaleList.add(locale);
      if (locale.hasScriptCode()) {
        newLocaleList.addUniqueLocale(
            Locale("${locale.languageCode}-${locale.scriptCode}"));
      }
      if (locale.hasCountryCode() && !locale.hasScriptCode()) {
        newLocaleList.addUniqueLocale(
            Locale("${locale.languageCode}-${locale.countryCode}"));
      }
      newLocaleList.addUniqueLocale(Locale(locale.languageCode));
    } else {
      for (Locale c in customFallback) {
        newLocaleList.addUniqueLocale(c);
      }
    }

    newLocaleList.addUniqueLocale(baseLanguage);

    _localeList = newLocaleList;
  }

  List<Locale>? getCustomFallbackForLanguage(String language) {
    if (customLanguageFallback == null) {
      return null;
    }
    for (String languageTag in customLanguageFallback!.keys) {
      if (languageTag == language) {
        return customLanguageFallback![languageTag]!
            .map((e) => _localeFromString(e))
            .toList();
      }
    }
    return null;
  }

  Locale _localeFromString(String language) {
    final locale = intl_locale.Locale.tryParse(language);
    if (locale == null) {
      throw ApplangaFlutterException(
          "ApplangaFlutter baseLanguage not found: $language");
    }
    return Locale.fromSubtags(
        languageCode: locale.languageCode,
        scriptCode: locale.scriptCode,
        countryCode: locale.countryCode);
  }

  static Locale localeListResolutionCallback(locales, supportedLocales) {
    Locale? deviceLanguage;
    Locale? deviceLanguageLong;
    if (locales != null) {
      for (var locale in locales) {
        if (deviceLanguageLong != null) break;
        if (deviceLanguage != null) break;
        for (Locale supportedLocale in supportedLocales) {
          if (supportedLocale == locale) {
            deviceLanguageLong = locale;
            break;
          } else if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == null) {
            deviceLanguage = Locale(supportedLocale.languageCode);
          }
        }
      }
    }
    return deviceLanguageLong ?? deviceLanguage ?? supportedLocales.first;
  }
}
