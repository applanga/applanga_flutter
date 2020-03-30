# applanga_flutter

A Flutter plugin for [Applanga](https://applanga.com).

For a sample Usage see the example.

*Note*: This plugin is still under development, and some APIs might not be available yet. [Feedback](https://github.com/applanga/applanga_flutter/issues) and [Pull Requests](https://github.com/applanga/applanga_flutter/pulls) are most welcome!

### Usage

#### Installation

To use this plugin, add `applanga_flutter` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

##### Applanga settings file

1. Download the *Applanga Settings File* for your app from the Applanga App Overview by clicking the ***[Prepare Release]*** button and then clicking ***[Get Settings File]***.
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

##### ApplangaFlutter.localizeMap(map) (recommended)

```
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

#### Draft Mode and screeshot menu

To trigger the draft mode activation dialog you can call `ApplangaFlutter.showDraftModeDialog();`

Once in draft mode you can show or hide the screenshot menu like so `ApplangaFlutter.setScreenShotMenuVisible(bool);`

You can also take screenshot programmatically with the method `ApplangaFlutter.captureScreenshotWithTag(string tag);`                 


##### NOTE: Screenshots collect the values of strings on screen using server side OCR, so will not be 100% accurate in some cases. 
