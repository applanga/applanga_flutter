import 'package:applanga_flutter/applanga_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:module_a/l10n/gen/module_a_localizations.dart';

// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unused_local_variable
// ignore_for_file: no_leading_underscores_for_local_identifiers
class ApplangaModuleALocalizations extends ModuleALocalizations {
  final ModuleALocalizations _original;

  ApplangaModuleALocalizations(locale)
      : _original = lookupModuleALocalizations(locale),
        super(locale.toString());

  static const LocalizationsDelegate<ModuleALocalizations> delegate =
      _ApplangaModuleALocalizationsDelegate();
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
}

class _ApplangaModuleALocalizationsDelegate
    extends LocalizationsDelegate<ModuleALocalizations> {
  const _ApplangaModuleALocalizationsDelegate();

  static const _keys = ['welcome'];

  @override
  Future<ModuleALocalizations> load(Locale locale) async {
    var result = ApplangaModuleALocalizations(locale);
    await ApplangaFlutter.instance.setMetaData(
        locale, 'en', '6410524376a12116ad72d97e', _keys,
        getDynamicStrings: false);
    await ApplangaFlutter.instance.loadLocaleAndUpdate(locale);
    return result;
  }

  @override
  bool isSupported(Locale locale) =>
      ModuleALocalizations.delegate.isSupported(locale);

  @override
  bool shouldReload(_ApplangaModuleALocalizationsDelegate old) => false;
}
