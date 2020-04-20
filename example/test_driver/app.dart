import 'package:flutter_driver/driver_extension.dart';
import 'package:applanga_flutter_test_app/main.dart' as app;
import 'package:applanga_flutter/applanga_flutter.dart';

void main() {

  Future<String> dataHandler(String msg) async {

      if(msg.contains("applanga-"))
      {
          msg = msg.replaceAll("applanga-", "");
          ApplangaFlutter.captureScreenshotWithTag(msg);
      }

  }

  // This line enables the extension.
  enableFlutterDriverExtension(handler: dataHandler);

  // Call the `main()` function of the app, or call `runApp` with
  // any widget you are interested in testing.
  app.main();

}