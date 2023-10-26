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
      Locale l = const Locale.fromSubtags(
          languageCode: "de", countryCode: "DE");
      LocaleList localeList = LocaleList(l, "en", customFallback: customFallback);
      expect(localeList.list.length, 2);
      expect(localeList.list[0].toLanguageTag(), "de-AT");
      expect(localeList.list[1].toLanguageTag(), "en");
    });

    test('Should respect a custom fallback2', () async {
      Map<String, List<String>> customFallback = {
        "es-MX": ["es-MX", "es-US", "es"],
        "de-DE": ["de-AT", "en"],
      };
      Locale l = const Locale.fromSubtags(
          languageCode: "es", countryCode: "MX");
      LocaleList localeList = LocaleList(l, "en", customFallback: customFallback);
      expect(localeList.list.length, 4);
      expect(localeList.list[0].toLanguageTag(), "es-MX");
      expect(localeList.list[1].toLanguageTag(), "es-US");
      expect(localeList.list[2].toLanguageTag(), "es");
      expect(localeList.list[3].toLanguageTag(), "en");
    });
  });
}
