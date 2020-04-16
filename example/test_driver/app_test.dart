// Imports the Flutter Driver API.
import 'package:flutter_driver/flutter_driver.dart' as drive;
import 'package:test/test.dart';

void main() {
  group('Applanga Tests', () {
    // First, define the Finders and use them to locate widgets from the
    // test suite. Note: the Strings provided to the `byValueKey` method must
    // be the same as the Strings we used for the Keys in step 1.

    final screenShotButton = drive.find.byValueKey('screenShot');

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
      // First, tap the button.
      await Future.delayed(const Duration(seconds: 3), (){});
      await driver.tap(screenShotButton);
      await Future.delayed(const Duration(seconds: 3), (){});
      // Then, verify the counter text is incremented by 1.
     // expect(await driver.getText(counterTextFinder), "1");
    });
  });
}