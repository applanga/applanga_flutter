import 'package:applanga_flutter/applanga_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:module_b/l10n/gen/module_b_localizations.dart';

// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unused_local_variable
// ignore_for_file: no_leading_underscores_for_local_identifiers
class ApplangaModuleBLocalizations extends ModuleBLocalizations {
  final ModuleBLocalizations _original;

  ApplangaModuleBLocalizations(locale)
      : _original = lookupModuleBLocalizations(locale),
        super(locale.toString());

  static const LocalizationsDelegate<ModuleBLocalizations> delegate =
      _ApplangaModuleBLocalizationsDelegate();
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];
  static Locale localeListResolutionCallback(locales, supportedLocales) =>
      ApplangaFlutter.localeListResolutionCallback(locales, supportedLocales);

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
  ];

  @override
  String get welcome => ApplangaFlutter.instance
      .getTranslation('welcome', defaultValue: _original.welcome)!;

  @override
  String get description => ApplangaFlutter.instance
      .getTranslation('description', defaultValue: _original.description)!;
}

class _ApplangaModuleBLocalizationsDelegate
    extends LocalizationsDelegate<ModuleBLocalizations> {
  const _ApplangaModuleBLocalizationsDelegate();

  static const _keys = ['welcome', 'description'];

  @override
  Future<ModuleBLocalizations> load(Locale locale) async {
    var result = ApplangaModuleBLocalizations(locale);
    await ApplangaFlutter.instance.setMetaData(
        locale, 'en', '6410524376a12116ad72d97e', _keys,
        getDynamicStrings: false);
    await ApplangaFlutter.instance.loadLocaleAndUpdate(locale);
    return result;
  }

  @override
  bool isSupported(Locale locale) =>
      ModuleBLocalizations.delegate.isSupported(locale);

  @override
  bool shouldReload(_ApplangaModuleBLocalizationsDelegate old) => false;
}
