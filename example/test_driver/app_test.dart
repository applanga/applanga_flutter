import 'package:applanga_flutter/applanga_test_utils.dart';
import 'package:flutter_driver/flutter_driver.dart';
//import 'package:flutter_test/flutter_test.dart';
import 'package:test/test.dart';

void main() {
  group('Applanga App', () {
    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('takeScreenShots', () async {
      //allow time for app to init
      // await Future.delayed(const Duration(seconds: 2), () {});

      //set the sdk language to german so that the screenshots are attached to the german language in the applanga dashboard
      ApplangaFlutterTestUtils.setApplangaLanguage(driver, "en");

      //manually add the string ids for this view
      var stringIds = List<String>();
      stringIds.add("draftModeLabel");
      stringIds.add("showScreenShotMenu");

      //upload a screenshot with the tag "Page-1", OCR disabled and the string ids manually set
     // await ApplangaFlutterTestUtils.takeApplangaScreenshot(
      //    driver, "Page-1", false, null);
      await ApplangaFlutterTestUtils.takeApplangaScreenshot(
          driver, "Page-1", false, stringIds);

//open the second view
    //driver.tap(drive.find.byValueKey("OpenSecondPage"));
    //await Future.delayed(const Duration(seconds: 1), () {});

//take a screenshot with the tag "Page-2", OCR disabled and no string ids manually passed
    //await ApplangaFlutterTestUtils.takeApplangaScreenshot(
    //    driver, "Page-2", false, null);
    });
  });
}
