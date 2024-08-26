// Import the test package and Counter class
import 'package:applanga_flutter/src/language/locale_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('locale list', () {
    test('Should create a full locale list with all natural fallbacks',
        () async {
      Locale l =
          const Locale.fromSubtags(languageCode: "de", countryCode: "AT");
      LocaleList localeList = LocaleList(l, "en");
      expect(localeList.list.length, 3);
      expect(localeList.list[0].toLanguageTag(), "de-AT");
      expect(localeList.list[1].toLanguageTag(), "de");
      expect(localeList.list[2].toLanguageTag(), "en");
    });
    test('Should create a full locale list with all natural fallbacks2',
        () async {
      Locale l =
          const Locale.fromSubtags(languageCode: "es", countryCode: "US");
      LocaleList localeList = LocaleList(l, "fr");
      expect(localeList.list.length, 3);
      expect(localeList.list[0].toLanguageTag(), "es-US");
      expect(localeList.list[1].toLanguageTag(), "es");
      expect(localeList.list[2].toLanguageTag(), "fr");
    });
    test('Should create a full locale list with all natural fallbacks chinese',
        () async {
      Locale l = const Locale.fromSubtags(
          languageCode: "zh", scriptCode: "Hant", countryCode: "HK");
      LocaleList localeList = LocaleList(l, "en");
      expect(localeList.list.length, 4);
      expect(localeList.list[0].toLanguageTag(), "zh-Hant-HK");
      expect(localeList.list[1].toLanguageTag(), "zh-Hant");
      expect(localeList.list[2].toLanguageTag(), "zh");
      expect(localeList.list[3].toLanguageTag(), "en");
    });

    test('Should respect a custom fallback', () async {
      Map<String, List<String>> customFallback = {
        "es-MX": ["es-MX", "es-US", "es"],
        "de-DE": ["de-AT", "en"],
      };
      Locale l =
          const Locale.fromSubtags(languageCode: "de", countryCode: "DE");
      LocaleList localeList =
          LocaleList(l, "en", customLanguageFallback: customFallback);
      expect(localeList.list.length, 2);
      expect(localeList.list[0].toLanguageTag(), "de-AT");
      expect(localeList.list[1].toLanguageTag(), "en");
    });

    test('Should respect a custom fallback2', () async {
      Map<String, List<String>> customFallback = {
        "es-MX": ["es-MX", "es-US", "es"],
        "de-DE": ["de-AT", "en"],
      };
      Locale l =
          const Locale.fromSubtags(languageCode: "es", countryCode: "MX");
      LocaleList localeList =
          LocaleList(l, "en", customLanguageFallback: customFallback);
      expect(localeList.list.length, 4);
      expect(localeList.list[0].toLanguageTag(), "es-MX");
      expect(localeList.list[1].toLanguageTag(), "es-US");
      expect(localeList.list[2].toLanguageTag(), "es");
      expect(localeList.list[3].toLanguageTag(), "en");
    });
  });
  group('locale list resolution callback', () {
    Locale de = const Locale.fromSubtags(languageCode: "de");
    Locale deAt =
        const Locale.fromSubtags(languageCode: "de", countryCode: "AT");

    Locale en = const Locale.fromSubtags(languageCode: "en");
    Locale enUS =
        const Locale.fromSubtags(languageCode: "en", countryCode: "US");

    Locale es = const Locale.fromSubtags(languageCode: "es");
    Locale esUS =
        const Locale.fromSubtags(languageCode: "es", countryCode: "US");

    test('Should return the exact locale if it is supported', () async {
      List<Locale> deviceLocales = [esUS, enUS];
      List<Locale> supportedLocales = [deAt, enUS, esUS];
      Locale locale = LocaleList.localeListResolutionCallback(
          deviceLocales, supportedLocales);

      expect(locale.languageCode, "es");
      expect(locale.countryCode, "US");
    });

    test('Should return the exact locale if it is supported2', () async {
      List<Locale> deviceLocales = [enUS, esUS];
      List<Locale> supportedLocales = [deAt, enUS, esUS];
      Locale locale = LocaleList.localeListResolutionCallback(
          deviceLocales, supportedLocales);

      expect(locale.languageCode, "en");
      expect(locale.countryCode, "US");
    });

    test('Should return the locale without country code if supported', () async {
      List<Locale> deviceLocales = [esUS, enUS];
      List<Locale> supportedLocales = [deAt, enUS, es];
      Locale locale = LocaleList.localeListResolutionCallback(
          deviceLocales, supportedLocales);

      expect(locale.languageCode, "es");
      expect(locale.countryCode, null);
    });

    test('Should return the locale without country code if supported2', () async {
      List<Locale> deviceLocales = [esUS, enUS];
      List<Locale> supportedLocales = [deAt, en];
      Locale locale = LocaleList.localeListResolutionCallback(
          deviceLocales, supportedLocales);

      expect(locale.languageCode, "en");
      expect(locale.countryCode, null);
    });

    test('Should return the locale without country code if supported3', () async {
      List<Locale> deviceLocales = [esUS, enUS];
      List<Locale> supportedLocales = [deAt, enUS, es];
      Locale locale = LocaleList.localeListResolutionCallback(
          deviceLocales, supportedLocales);

      expect(locale.languageCode, "es");
      expect(locale.countryCode, null);
    });

    test('Should return the first supported locale if no device language is supported', () async {
      List<Locale> deviceLocales = [esUS];
      List<Locale> supportedLocales = [deAt, en];
      Locale locale = LocaleList.localeListResolutionCallback(
          deviceLocales, supportedLocales);

      expect(locale.languageCode, "de");
      expect(locale.countryCode, "AT");
    });

    test('Should return the first supported locale if no device language is set', () async {
      List<Locale> deviceLocales = [];
      List<Locale> supportedLocales = [esUS, deAt, en];
      Locale locale = LocaleList.localeListResolutionCallback(
          deviceLocales, supportedLocales);

      expect(locale.languageCode, "es");
      expect(locale.countryCode, "US");
    });
  });
}
