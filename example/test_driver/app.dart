import 'package:applanga_flutter/applanga_flutter.dart';
import 'package:applanga_flutter/applanga_test_utils.dart';
import 'package:applanga_flutter_example/main.dart' as app;
import 'package:flutter_driver/driver_extension.dart';

void main() {
  var applangaTestUtil = ApplangaFlutterTestUtils(
      ApplangaFlutter.captureScreenshotWithTag, ApplangaFlutter.setLanguage);

  enableFlutterDriverExtension(handler: (payload) async {
    return applangaTestUtil.checkForApplangaRequests(payload);
  });

  app.main();
}
