import 'package:flutter_driver/driver_extension.dart';
import 'package:applanga_flutter_test_app/main.dart' as app;
import 'package:applanga_flutter/applanga_flutter.dart';
import 'applanga_test_utils.dart';
void main() {

  var applangaTestUtil = ApplangaFlutterTestUtils(ApplangaFlutter.captureScreenshotWithTag);

  enableFlutterDriverExtension(handler: (payload) async {
    applangaTestUtil.checkForApplangaRequests(payload);
    return "";
  });

  app.main();

}