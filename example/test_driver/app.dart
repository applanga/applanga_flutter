import 'package:flutter_driver/driver_extension.dart';
import 'package:applanga_flutter_test_app/main.dart' as app;
import 'package:applanga_flutter/applanga_flutter.dart';
import 'package:applanga_flutter/applanga_test_utils.dart';

void main() {

  var applangaTestUtil = ApplangaFlutterTestUtils(ApplangaFlutter.captureScreenshotWithTag, ApplangaFlutter.setLanguage);

  enableFlutterDriverExtension(handler: (payload) async {
    await applangaTestUtil.checkForApplangaRequests(payload);
    return "";
  });

  app.main();

}
