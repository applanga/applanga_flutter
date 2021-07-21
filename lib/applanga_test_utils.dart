import 'dart:convert';
import 'package:flutter_driver/flutter_driver.dart';

class ApplangaFlutterTestUtils  {

  late Function(String?,bool?,List<String>?) applangaScreenshotMethod;

  late Function(String) applangaSetLanguageMethod;



  ApplangaFlutterTestUtils(Function(String?,bool?,List<String>?) screenshotMethod,Function(String) setlanguageMethod)
  {
    applangaScreenshotMethod = screenshotMethod;
    applangaSetLanguageMethod = setlanguageMethod;
  }

  static Future<void> takeApplangaScreenshot(FlutterDriver driver,String tag,bool enableOcr, List<String> stringIds) async
  {
    var json =
    {
      'type':'applanga-screenshot',
      'tag': tag,
      'enableOcr': enableOcr,
      'stringIds': stringIds
    };
    var jsonString = jsonEncode(json);
    await driver.requestData(jsonString);
  }

  static void setApplangaLanguage(FlutterDriver driver,String lang)
  {
    var json =
    {
      'type':'applanga-setlanguage',
      'lang': lang
    };
    var jsonString = jsonEncode(json);
    driver.requestData(jsonString);
  }

  Future<String> checkForApplangaRequests(String request) async
  {
    if(request.contains("applanga-screenshot")) {
      Map<String, dynamic> data = jsonDecode(request);
      var tag = data["tag"];
      var enableOcr = data["enableOcr"];
      var stringIds = data["stringIds"];
      if(stringIds != null)
      {
        var convertedStringIds = new List<String>.from(stringIds);
        await applangaScreenshotMethod(tag,enableOcr,convertedStringIds);
        return "ok";
      }
      else
      {
        await applangaScreenshotMethod(tag,enableOcr,null);
        return "ok";
      }
    }
    else if(request.contains("applanga-setlanguage")) {
      Map<String, dynamic> data = jsonDecode(request);
      var lang = data["lang"];
      applangaSetLanguageMethod(lang);
      return "ok";
    }
    return "ok";
  }

}