import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:applanga_flutter/src/generator/localization_visitors.dart';
import 'package:flutter_test/flutter_test.dart';

// Fixtures below mirror the real output of `flutter gen-l10n` for the
// example app (example/lib/generated/app_localizations{,_en}.dart), trimmed
// to the parts the generator visitors actually inspect.
const String _abstractLocalizationsClassSource = '''
abstract class AppLocalizations {
  AppLocalizations(String locale);

  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  String homePageTitle(DateTime date);

  String youHavePushedTheButtonXTimes(int count, Object finger);

  String get increment;

  String get goToSecondPage;
}
''';

const String _baseLanguageClassSource = r'''
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String homePageTitle(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'ApplangaFlutter Example $dateString';
  }

  @override
  String youHavePushedTheButtonXTimes(int count, Object finger) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have clicked the button with your $finger $count times.',
      zero: 'You have not clicked the button with your $finger yet.',
    );
    return '$_temp0';
  }

  @override
  String get increment => 'Increment';

  @override
  String get goToSecondPage => 'Go to Second Page';
}
''';

void main() {
  group('LocalizationClassVisitor', () {
    test('extracts the supportedLocales list from the abstract class', () {
      final visitor = LocalizationClassVisitor();
      final parsed = parseString(content: _abstractLocalizationsClassSource);
      for (final declaration in parsed.unit.declarations) {
        declaration.visitChildren(visitor);
      }

      expect(visitor.supportedLocalesDeclarations, ["Locale('en')"]);
    });
  });

  group('LocalizationBaseLangVisitor', () {
    late LocalizationBaseLangVisitor visitor;

    setUp(() {
      visitor = LocalizationBaseLangVisitor();
      final parsed = parseString(content: _baseLanguageClassSource);
      for (final declaration in parsed.unit.declarations) {
        declaration.visitChildren(visitor);
      }
    });

    test('extracts all String members in declaration order', () {
      expect(visitor.ids, [
        'homePageTitle',
        'youHavePushedTheButtonXTimes',
        'increment',
        'goToSecondPage',
      ]);
    });

    test('separates getters from parameterised methods', () {
      expect(visitor.getter, ['increment', 'goToSecondPage']);
    });

    test('detects intl usage', () {
      expect(visitor.useIntlImport, isTrue);
    });

    test('extracts parameterised (ICU) methods with their params', () {
      expect(visitor.formattingList, hasLength(2));

      final homePageTitle =
          visitor.formattingList.firstWhere((m) => m.name == 'homePageTitle');
      expect(homePageTitle.nameWithParams, 'homePageTitle(DateTime date)');
      expect(homePageTitle.originalParams, {'date': 'date'});
      // `dateDateFormat.format(date)` is assigned to `dateString`, so the
      // visitor should record that `date` gets re-formatted as `dateString`.
      expect(homePageTitle.formattedParams, {'date': 'dateString'});

      final pluralMethod = visitor.formattingList
          .firstWhere((m) => m.name == 'youHavePushedTheButtonXTimes');
      expect(pluralMethod.nameWithParams,
          'youHavePushedTheButtonXTimes(int count, Object finger)');
      expect(pluralMethod.originalParams, {'count': 'count', 'finger': 'finger'});
      // `Intl.pluralLogic(...)` isn't a `.format(...)` call, so no param
      // renaming should be recorded for this method.
      expect(pluralMethod.formattedParams, isNull);
    });
  });
}
