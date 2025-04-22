import 'package:applanga_flutter/applanga_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;
import 'package:example/l10n/app_localizations.dart';

// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unused_local_variable
// ignore_for_file: no_leading_underscores_for_local_identifiers
class ApplangaLocalizations extends AppLocalizations {
  final AppLocalizations _original;

  ApplangaLocalizations(locale)
      : _original = lookupAppLocalizations(locale),
        super(locale.toString());

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _ApplangaLocalizationsDelegate();
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
    Locale('de'),
    Locale('de', 'AT'),
    Locale('en', 'US'),
    Locale('es'),
    Locale('es', 'CL'),
    Locale('fr'),
    Locale('ru')
  ];

  @override
  String get increment => ApplangaFlutter.instance
      .getTranslation('increment', defaultValue: _original.increment)!;

  @override
  String get goToSecondPage =>
      ApplangaFlutter.instance.getTranslation('goToSecondPage',
          defaultValue: _original.goToSecondPage)!;

  @override
  String get secondPageTitle =>
      ApplangaFlutter.instance.getTranslation('secondPageTitle',
          defaultValue: _original.secondPageTitle)!;

  @override
  String get helloFromSecondPage =>
      ApplangaFlutter.instance.getTranslation('helloFromSecondPage',
          defaultValue: _original.helloFromSecondPage)!;

  @override
  String homePageTitle(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);
    return ApplangaFlutter.instance.getTranslation('homePageTitle',
        args: {'date': date},
        formattedArgs: {'date': dateString},
        defaultValue: _original.homePageTitle(date))!;
  }

  @override
  String youHavePushedTheButtonXTimes(int count, Object finger) {
    String _temp0 = intl.Intl.pluralLogic(count,
        locale: localeName,
        other: 'You have clicked the button with your $finger $count times.',
        zero: 'You have not clicked the button with your $finger yet.');
    return ApplangaFlutter.instance.getTranslation(
        'youHavePushedTheButtonXTimes',
        args: {'count': count, 'finger': finger},
        defaultValue: _original.youHavePushedTheButtonXTimes(count, finger))!;
  }
}

class _ApplangaLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _ApplangaLocalizationsDelegate();

  static const _keys = [
    'homePageTitle',
    'youHavePushedTheButtonXTimes',
    'increment',
    'goToSecondPage',
    'secondPageTitle',
    'helloFromSecondPage'
  ];

  @override
  Future<AppLocalizations> load(Locale locale) async {
    var result = ApplangaLocalizations(locale);
    await ApplangaFlutter.instance.setMetaData(
        locale, 'en', '6410524376a12116ad72d97e', _keys,
        getDynamicStrings: false);
    await ApplangaFlutter.instance.loadLocaleAndUpdate(locale);
    return result;
  }

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.delegate.isSupported(locale);

  @override
  bool shouldReload(_ApplangaLocalizationsDelegate old) => false;
}
