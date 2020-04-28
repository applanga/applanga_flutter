import 'dart:convert';

class ApplangaFlutterTestUtils  {

  Function(String,bool,List<String>) applangaScreenshotMethod;

  ApplangaFlutterTestUtils(Function(String,bool,List<String>) screenshotMethod)
  {
    applangaScreenshotMethod = screenshotMethod;
  }

  static String takeApplangaScreenshot(String tag,bool enableOcr, List<String> stringIds)
  {
      var json =
      {
        'type':'applanga-screenshot',
        'tag': tag,
        'enableOcr': enableOcr,
        'stringIds': stringIds
      };

      var jsonString = jsonEncode(json);

      print("Created Json: " + jsonString);

      return jsonString;
  }

  void checkForApplangaRequests(String request)
  {

    if(!request.contains("applanga-screenshot")) {
      return;
    }

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

}