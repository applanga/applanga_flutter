import 'package:applanga_flutter/applanga_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;

// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unused_local_variable
class ApplangaLocalizations extends AppLocalizations {
  final AppLocalizations _original;

  ApplangaLocalizations(_locale)
      : _original = lookupAppLocalizations(_locale),
        super(_locale.toString());

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _ApplangaLocalizationsDelegate();
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];
  static const List<Locale> supportedLocales =
      AppLocalizations.supportedLocales;

  @override
  String get increment =>
      ApplangaFlutter.instance.getIcuString('increment') ?? _original.increment;

  @override
  String get goToSecondPage =>
      ApplangaFlutter.instance.getIcuString('goToSecondPage') ??
      _original.goToSecondPage;

  @override
  String get secondPageTitle =>
      ApplangaFlutter.instance.getIcuString('secondPageTitle') ??
      _original.secondPageTitle;

  @override
  String get helloFromSecondPage =>
      ApplangaFlutter.instance.getIcuString('helloFromSecondPage') ??
      _original.helloFromSecondPage;

  @override
  String homePageTitle(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);
    return ApplangaFlutter.instance.getIcuString(
            'homePageTitle', {'date': date}, {'date': dateString}) ??
        _original.homePageTitle(date);
  }

  @override
  String youHavePushedTheButtonXTimes(int count, Object finger) {
    String _temp0 = intl.Intl.pluralLogic(count,
        locale: localeName,
        other: 'You have clicked the button with your $finger $count times.',
        zero: 'You have not clicked the button with your $finger yet.');
    return ApplangaFlutter.instance.getIcuString('youHavePushedTheButtonXTimes',
            {'count': count, 'finger': finger}) ??
        _original.youHavePushedTheButtonXTimes(count, finger);
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
      locale,
      'en',
      _keys,
    );
    await ApplangaFlutter.instance.loadLocaleAndUpdate(locale);
    return result;
  }

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.delegate.isSupported(locale);

  @override
  bool shouldReload(_ApplangaLocalizationsDelegate old) => false;
}
