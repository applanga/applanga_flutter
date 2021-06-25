# applanga_flutter

A Flutter plugin for [Applanga](https://applanga.com).

For a sample Usage see the example project included in this repo.

### Usage

#### Installation

To use this plugin, add `applanga_flutter` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

##### Applanga settings file

1. Download the *Applanga Settings File* for your app from the Applanga Project Overview by clicking the ***[Prepare Release]*** button and then clicking ***[Get Settings File]***.
2. Add the *Applanga Settings File* to your Android modules resources res/raw directory
3. Also Add the *Applanga Settings File* to your iOS modules main target. To do this open the ios module in Xcode and drag the settings file into the project. Make sure to tick the target you want it applied to.


##### iOS: Be aware to add the supported languages to the info.plist. [Find more here](https://flutter.io/tutorials/internationalization/).

##### iOS: Add the following dependancy to your podfile located at ProjectRoot/ios/PodFile

`pod 'Applanga'`

#### Import

`import 'package:applanga_flutter/applanga_flutter.dart';`

#### Methods

**Note**: *The Flutter to native bridge is asynchronous. So all Methods are asynchronous calls.*

##### ApplangaFlutter.getString("string\_key", "default\_message")

If *string\_key* does not exists, *default\_message* gets uploaded (see topic *String Upload*).

##### ApplangaFlutter.getUpdate()
Fetches changes from the dashboard and updates the local Applanga Database. You have to rerender your UI to see latest changes. Be aware that due to our CDN-Caching it can take up to 15 minutes to be able to fetch new translations.

##### ApplangaFlutter.localizedStringsForCurrentLanguage()

Returns a Map<String,String> containing the keys and values of all strings for this language. This method is slow, so it would be best to use it when the app starts and then use the result to get strings from later on.

##### ApplangaFlutter.localizeMap(map)

```dart
ApplangaFlutter.localizeMap(
	{
		"en": {
			"hello_world": "Hello World"
		},
		"de" : {
			"hello_world": "Hallo Welt"
		}
	}
);
```

`ApplangaFlutter.localizeMap(map)` returns the same map but with the actual Applanga localizations.

#### String Upload
Strings from `ApplangaFlutter.getString(String, String)` and Strings which are located in the map of `ApplangaFlutter.localizeMap(map)`, will be uploaded if the app is in debug mode and fulfill one of the two points: They are non existent on the Applanga Dashboard or the target text is empty.
##### Debug mode for iOS
Open your ios/\*.xcodeproj or ios/\*.xcworkspace in XCode and run your app.

##### Debug mode for Android
Open Android Studio, File - Open. android/ directory. Run "Debug 'app'".

#### Draft Mode and Screenshot Menu

Applanga [Draft Mode](https://www.applanga.com/docs/translation-management-dashboard/draft_on-device-testing) can be be activate with a multitouch gesture which works out of the box on iOS builds but for Android you need to forward input events to the SDK which can be done in a custom main Activity like so:

```kotlin
class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }

    override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
        com.applanga.applangaflutter.ApplangaFlutterPlugin.dispatchTouchEvent(ev, this)
        return super.dispatchTouchEvent(ev)
    }
}
```

To trigger the [Draft Mode](https://www.applanga.com/docs/translation-management-dashboard/draft_on-device-testing) dialog via code you can call `ApplangaFlutter.showDraftModeDialog();`

Once in draft mode you can show or hide the screenshot menu by swiping down with 2 fingers or via code like this `ApplangaFlutter.setScreenShotMenuVisible(bool);`

For string positions to be properly connected on the screenshots you need to annotate each widget to provide the individual BuildContext to Applanga va `setScreenTag` and if you also want the text properly linked to an ID on Applanga you need to provide a matchin `Key` on each `Text` Widget as shown in teh example below.

```dart
class ExampleRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    setScreenTag(context, "ExampleRoute");
    return Scaffold(
      appBar: AppBar(
        title: Text(Localization.of(context).loc_key_1, key: Key("loc_key_1")),
      ),
      body: Wrap(
      children: [
        RaisedButton(
          child: Text(Localization.of(context).loc_key_1, key: Key("loc_key_1")),
          onPressed: () {...}
        ),
        RaisedButton(
          child: Text(Localization.of(context).loc_key_2, key: Key("loc_key_2")),
          onPressed: () {...}
        )
        ],
      ),
    );
  }
}
```
#### Automating screenshot upload

By using tests and a test runner like [flutter_driver](https://api.flutter.dev/flutter/flutter_driver/flutter_driver-library.html) you can automate the taking and uploading of screenshots from your Apps. In the example project, in the test_driver folder you can see how we setup an automatic screenshot flow including 2 views.

In the driver app wrapper 'test_driver/app.dart' you can see that we first initialise the Applanga test utils and then we use them to decode messages in the driver handler like so:

```dart
void main() {

  var applangaTestUtil = ApplangaFlutterTestUtils(ApplangaFlutter.captureScreenshotWithTag, ApplangaFlutter.setLanguage);

  enableFlutterDriverExtension(handler: (payload) async {
    applangaTestUtil.checkForApplangaRequests(payload);
  });

  app.main();

}
```

Then in the test running file 'test_driver/app_test.dart', we have a test that takes 2 screenshots, the first with additional string IDs manually passed, the second without enabled. By default OCR should always be disabled since its accuracy may vary and may conflict with widget annotation but if you can not annotate your widgets via `setScreenTag` it can be used as a fallback option.

```dart
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

        //take a screenshot with the tag "Page-2", OCR disabled and no string ids manually passed
        await ApplangaFlutterTestUtils.takeApplangaScreenshot(driver,"Page-2", false, null);

      });
```

### Legacy support

If you are using a version of flutter below 1.20.0 then please use version 0.0.12 of the applanga flutter plugin
