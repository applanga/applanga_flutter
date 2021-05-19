import 'dart:io';

import 'package:applanga_flutter_example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:applanga_flutter_example/main.dart' as app;

import 'package:applanga_flutter/applanga_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Take Applanga Screenshots', (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle();
      sleep(Duration(seconds: 1));

      //Check localisation is working
      expect(checkTextWidgetText(tester, 'title', "Title"), true);
      expect(
          checkTextWidgetText(tester, 'draftModeLabel', "Not Working"), true);
      expect(
          checkTextWidgetText(
              tester, 'showScreenShotMenu', "Show screenshot menu"),
          true);
      expect(checkTextWidgetText(tester, 'hideScreenShotMenu', "Not Working"),
          true);
      expect(
          checkTextWidgetText(
              tester, 'takeProgramaticScreenshot', "Not Working"),
          true);

      //Take screenshots
      await ApplangaFlutter.captureScreenshotWithTag(
          "integration test page 1b");

      //open second page
      await tester.tap(find.byKey(Key("OpenSecondPage")));
      await tester.pumpAndSettle();
      sleep(Duration(seconds: 1));

      // take screenshot
      await ApplangaFlutter.captureScreenshotWithTag(
          "integration test page 2b");

      sleep(Duration(seconds: 5));
    });
  });
}

bool checkTextWidgetText(
    WidgetTester tester, String key, String expectedValue) {
  final Text theText = tester.widget(find.byKey(Key(key)));
  return theText.data == expectedValue;
}
