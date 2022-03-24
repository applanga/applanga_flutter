import 'package:applanga_flutter/applanga_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:example/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
      as IntegrationTestWidgetsFlutterBinding;
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  const _pumpSettleDuration = Duration(milliseconds: 3500);

  testWidgets('Take all screenshots with ApplangaWidget',
      (WidgetTester tester) async {
    for (var _locale in AppLocalizations.supportedLocales) {
      await tester.pumpWidget(
          MyApp(
            key: ObjectKey(_locale),
            startupLocale: _locale,
          ),
          _pumpSettleDuration);
      await tester.pumpAndSettle();

      // do the screenshot
      await ApplangaFlutter.I.captureScreenshotWithTag("main");

      await tester.pumpAndSettle(_pumpSettleDuration);

      // go to second page
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle(_pumpSettleDuration);

      // do the screenshot
      await ApplangaFlutter.I.captureScreenshotWithTag("secondPage");
      await tester.pumpAndSettle(_pumpSettleDuration);
    }
  });
}
