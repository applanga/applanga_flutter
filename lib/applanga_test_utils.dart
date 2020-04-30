import 'dart:convert';
import 'package:flutter_driver/flutter_driver.dart';

class ApplangaFlutterTestUtils  {

  Function(String,bool,List<String>) applangaScreenshotMethod;

  Function(String) applangaSetLanguageMethod;



  ApplangaFlutterTestUtils(Function(String,bool,List<String>) screenshotMethod,Function(String) setlanguageMethod)
  {
    applangaScreenshotMethod = screenshotMethod;
    applangaSetLanguageMethod = setlanguageMethod;
  }

  static void takeApplangaScreenshot(FlutterDriver driver,String tag,bool enableOcr, List<String> stringIds)
  {
    var json =
    {
      'type':'applanga-screenshot',
      'tag': tag,
      'enableOcr': enableOcr,
      'stringIds': stringIds
    };
    var jsonString = jsonEncode(json);
    driver.requestData(jsonString);
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

  void checkForApplangaRequests(String request)
  {
    if(request.contains("applanga-screenshot")) {
      Map<String, dynamic> data = jsonDecode(request);
      var tag = data["tag"];
      var enableOcr = data["enableOcr"];
      var stringIds = data["stringIds"];
      if(stringIds != null)
      {
        var convertedStringIds = new List<String>.from(stringIds);
        applangaScreenshotMethod(tag,enableOcr,convertedStringIds);
      }
      else
      {
        applangaScreenshotMethod(tag,enableOcr,null);
      }
    }
    else if(request.contains("applanga-setlanguage")) {
      Map<String, dynamic> data = jsonDecode(request);
      var lang = data["lang"];
      applangaSetLanguageMethod(lang);
    }
  }

}