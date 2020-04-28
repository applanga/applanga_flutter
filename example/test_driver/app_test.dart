// Imports the Flutter Driver API.
//flutter drive --target=test_driver/app.dart to run the tests
import 'dart:developer';
import 'package:flutter_driver/flutter_driver.dart' as drive;
import 'package:test/test.dart';
import 'applanga_test_utils.dart';
void main() {
  group('Applanga Tests', () {

    drive.FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await drive.FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

      test('takeScreenShot', () async {

      await Future.delayed(const Duration(seconds: 1), (){});

      var stringIds = new List<String>();

      stringIds.add("draftModeLabel");

      stringIds.add("showScreenShotMenu");

      driver.requestData(ApplangaFlutterTestUtils.takeApplangaScreenshot("IOS-ocrDisabled2", false, stringIds));

      await Future.delayed(const Duration(seconds: 3), (){});

    });
  });
}