import 'package:applanga_flutter/applanga_flutter.dart';
import 'package:example/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:example/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  const pumpSettleDuration = Duration(milliseconds: 3500);

  testWidgets('Take all screenshots with ApplangaWidget',
      (WidgetTester tester) async {
    for (var locale in AppLocalizations.supportedLocales) {
      await tester.pumpWidget(
          MyApp(
            key: ObjectKey(locale),
            startupLocale: locale,
          ),
          duration: pumpSettleDuration);
      await tester.pumpAndSettle();

      // do the screenshot
      await ApplangaFlutter.I.captureScreenshotWithTag("main");

      await tester.pumpAndSettle(pumpSettleDuration);

      // go to second page
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle(pumpSettleDuration);

      // do the screenshot
      await ApplangaFlutter.I.captureScreenshotWithTag("secondPage");
      await tester.pumpAndSettle(pumpSettleDuration);
    }
  });
}
