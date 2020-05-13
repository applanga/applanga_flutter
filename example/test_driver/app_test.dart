// Imports the Flutter Driver API.
//flutter drive --target=test_driver/app.dart to run the tests
import 'dart:developer';
import 'package:flutter_driver/flutter_driver.dart' as drive;
import 'package:test/test.dart';
import 'package:applanga_flutter/applanga_test_utils.dart';
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

      test('takeScreenShots', () async {



        //allow time for app to init
        await Future.delayed(const Duration(seconds: 2), (){});

        //set the sdk language to german so that the screenshots are attached to the german language in the applanga dashboard
        ApplangaFlutterTestUtils.setApplangaLanguage(driver,"de");

        //manually add the string ids for this view
        var stringIds = new List<String>();
        stringIds.add("draftModeLabel");
        stringIds.add("showScreenShotMenu");

        //upload a screenshot with the tag "Page-1", OCR disabled and the string ids manually set
        await ApplangaFlutterTestUtils.takeApplangaScreenshot(driver,"Page-1", false, stringIds);

        //open the second view
        driver.tap(drive.find.byValueKey("OpenSecondPage"));
        await Future.delayed(const Duration(seconds: 1), (){});

        //take a screenshot with the tag "Page-2", OCR enabled and no string ids manually passed
        await ApplangaFlutterTestUtils.takeApplangaScreenshot(driver,"Page-2", true,null);

      });
  });
}