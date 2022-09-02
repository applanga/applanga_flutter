[![pub package](https://img.shields.io/pub/v/applanga_flutter.svg)](https://pub.dev/packages/applanga_flutter) [![pub points](https://badges.bar/applanga_flutter/pub%20points)](https://pub.dev/packages/applanga_flutter/score)

# Applanga SDK for Flutter 

## Table of Contents

  - [Basic Usage](#Basic-Usage)
    - [Applanga CLI installation](#Applanga-CLI-installation)
    - [Localization preparation](#Localization-preparation)
    - [Pull & Push new translations](#Pull-&-Push-new-translations)
  - [Optional Over the Air Updates](#Over-the-Air-Updates)
    - [Add Applanga's settings file](#Add-Applanga's-settings-file)
    - [Generate and replace AppLocalizationsClass with ApplangaLocalizationsClass](#Generate-and-replace-AppLocalizationsClass-with-ApplangaLocalizationsClass)
    - [Draft Mode and Screenshot Menu](#Draft-Mode-and-Screenshot-Menu)
    - [Automating screenshot upload](#Automating-screenshot-upload)
    - [Automatic settings files update]('Automatic-settings-files-update)
***

## Basic Usage

The basic usage of applanga with your flutter project does not need any changes in your code base nor any complex setup.
You are able to have all your most actual translations at build time. If you also want your most actual translations at runtime for e.g. already published apps follow the basic usage steps and then go on with [Optional Over the Air Updates](#Over-the-Air-Updates).

### Applanga CLI installation
For the Applanga Command Line Interface (CLI) installation please refer to the official documentation: [https://www.applanga.com/docs/integration-documentation/cli](https://www.applanga.com/docs/integration-documentation/cli).

There is no need to initialize your project via the Applanga CLI for flutter, applanga_flutter will handle that for you. You can customize your CLI config `.applanga.json` at anytime. Follow the steps of [Localization preparation](#Localization-preparation) to get started.
### Localization preparation 

`applanga_flutter` works smoothly with the `flutter_localizations` package. Use the [official internationalization guide](https://flutter.dev/docs/development/accessibility-and-localization/internationalization) to add `flutter_localizations` and `intl` to your dependencies. Enable the generator in your `pubspec.yaml` and add the `l10n.yaml` file and add your first `.arb` file for your base language. E.g.:

file: `lib/l10n/app_en.arb`
```json
{
 "@@locale":"en",

}
```

Add the localizations delegate to your MaterialApp
```dart
const MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: MyApp(),
)
```

Add your API Token to the bottom of your `pubspec.yaml`
```yaml
applanga_flutter:
  access_token: xxxxxxxxxxxxxxxx
```
You can get your API Token on the on the dashboard from your project settings. The token is needed for pulling and pushing new translations. Read more in the next section.

### Pull & Push new translations
To be able to perform a push or pull command you will have to setup [Applanga CLI](https://www.applanga.com/docs/integration-documentation/cli) first. 

Execute `flutter pub run applanga_flutter:pull` from your shell and the package will download all new strings from all languages and add them to the corresponding arb files.

Execute `flutter pub run applanga_flutter:push` from your shell and the package will upload all newly added strings from the arb files to the applanga dashboard.

By default your base language `.arb` file is the single source of truth. So an `pull` will get and save all translations for all languages except the base language into corresponding arb files. A `push` will update only strings from the base language which are not uploaded yet to the dashboard.
With this configuration a `flutter pub run applanga_flutter:push --force` is recommended. All translations for the base language and its meta-data (important for icu strings) are uploaded and updated.
You can change that `push` and `pull` behavior in your `.applanga.json`.
## Over the Air Updates

Over the air updates are optional and available for android and iOS.

##### iOS: Be aware to add the supported languages to the info.plist. [Find more here](https://flutter.io/tutorials/internationalization/).


### Add Applanga's settings file

1. Download the *Applanga Settings File* for your app from the Applanga Project Overview by clicking the ***[Prepare Release]*** button and then clicking ***[Get Settings File]***.
2. Add the *Applanga Settings File* to your Android modules resources res/raw directory
3. Also Add the *Applanga Settings File* to your iOS modules main target. To do this open the iOS module in Xcode and drag the settings file into the project. Make sure to tick the target you want it applied to.

### Generate and replace AppLocalizationsClass with ApplangaLocalizationsClass

Generate the `ApplangaLocalizationsClass`

`flutter pub run applanga_flutter:generate`

Add the class to your MaterialApp and replace the old delegate & locales:
```dart
`import 'package:applanga_flutter/applanga_flutter.dart';`

const MaterialApp(
  localizationsDelegates: ApplangaLocalizations.localizationsDelegates,
  supportedLocales: ApplangaLocalizations.supportedLocales,
  home: MyApp(),
),
```

You can get your translations as usual: `AppLocalizations.of(context)!.helloWorld)`

### ApplangaWidget
It's recommended to place the ApplangaWidget as a top-level widget to your WidgetTree. It will notify all sub widgets if over-the-air translations have changed asynchronously. It is also recommended for a better screenshot experience.

```dart
void main() async {
  runApp(
    const ApplangaWidget(child: MyApp()),
  );
}
```

### Default Languages
By default applanga's OTA strings are pulled lazily at runtime. If the user changes the
app language, applanga fetches all new translations for the selected language. This can result in an
unexpected visual behavior for the user if there are significant new translation changes coming in
with a short delay.
If you have e.g. a custom language switcher it can be a good idea to fetch all common languages on
app start before a user action to avoid a delay when fetching strings lazily.

Add your default languages to your `pubspec.yaml`, e.g.:

```yaml
applanga_flutter:
  ...
  update_languages: [en, en_US, es, es_CL]
```

### Default Groups
If you use groups, you can define all default groups which should
be downloaded at app start. By default only `main` will be fetched.

We are following the same pattern as for `update_languages`:

```yaml
applanga_flutter:
  ...
  update_groups: [main, chapter1, chapter2]
```

### Manual OTA update
ApplangaFlutter is fetching all new translations once on app start for your default languages and default groups. 
You can also programmatically start a new update and define your languages or groups for it.

```dart
// with custom language & groups
ApplangaFlutter.update({languages: ['en_US'], groups: ['main', 'chapter2']);

// default update call using default languages and default groups
ApplangaFlutter.update();
```

### Draft Mode 

##### Note: Draft Mode is only available for Android and iOS

Applanga's [Draft Mode](https://www.applanga.com/docs/translation-management-dashboard/draft_on-device-testing) can be be activated with a multi touch gesture which works out of the box on iOS builds but for Android you need to forward input events to the SDK which can be done in a custom MainActivity like so:

```kotlin
class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }

    override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
        com.applanga.applanga_flutter.ApplangaFlutterPlugin.dispatchTouchEvent(ev, this)
        return super.dispatchTouchEvent(ev)
    }
}
```

Add the following permission inside the manifest tag in your AndroidManifest:

```xml
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
```

To trigger the [Draft Mode](https://www.applanga.com/docs/translation-management-dashboard/draft_on-device-testing) dialog via code you can call `ApplangaFlutter.showDraftModeDialog();` 

### Screenshot Menu

##### Note: Screenshot Menu is only available for Android and iOS - enable Draft Mode first


Once in draft mode you can show or hide the screenshot menu by swiping down with 2 fingers or via code like this `ApplangaFlutter.setScreenShotMenuVisible(bool);`


Applanga will detect every string and it's position inside the latest `ApplangaScreenshotScope` or `ApplangaScreenshotScopeMixin`.
In order to get good and clean screenshots make sure to wrap all your screens or widgets with either `ApplangaScreenshotScope` widget or add `ApplangaScreenshotScopeMixin` to your state as shown in the examples below and as shown in the example app from this repository.

Use `ApplangaScreenshotScope`:
```dart
class MyDrawer extends StatelessWidget{
    ...
    @override
    Widget build(BuildContext context) {
        return ApplangaScreenshotScope(child: Drawer(
            ...
        );
    }
}
```


Or add `ApplangaScreenshotScopeMixin` to your screen's state:

```dart
class _HomeScreenState extends State<HomeScreen> with ApplangaScreenshotScopeMixin {
    // ...
}
```

With this approach we get the translations and string positions for each string.
With our reverse text matching we connect each translation to a corresponding string id on the dashboard.

For a even better screenshot experience use [ApplangaWidget](#ApplangaWidget).
With ApplangaWidget on top of your widget tree the SDK will take two screenshots: One with all the string keys instead of translations and one with translations.
This improves the string position detection (no more reverse text matching) and enables you the option to debug your screens where a string is placed - even dynamically set strings.

We definitely recommend to use `ApplangaWidget` and `ApplangaScreenshotScope` (or `ApplangaScreenshotScopeMixin`).
### Automating screenshot upload

Running [flutter integration tests](https://flutter.dev/docs/testing/integration-tests) you can capture screenshots as simple as:

```dart
await ApplangaFlutter.I.captureScreenshotWithTag("main");
```

Please read [Screenshot Menu](#screenshot-menu) to improve string position collection for your screenshot. The example contains an integration test which showcases the usage of the automatic screenshot.


### Show ID Mode
Enabling Applanga's show id mode will return translation keys instead of the actual translations. This is good for debugging string positions and it is used to improve the screenshot string detection on the screen.

```dart
await ApplangaFlutter.I.setShowIdModeEnabled(true);
// or
await ApplangaFlutter.I.setShowIdModeEnabled(false);
```

### Automatic settings files update
This is automatically enabled after doing a pull request. To do this manually use the following command:

`flutter pub run applanga_flutter:update_settingsfiles`

To disable the automatic behavior add this to your `pubspec.yaml`:

```yaml
applanga_flutter:
  access_token: xxxx
  update_settingsfiles_on_pull: false 
```

For over-the-air updates the applanga settings file is needed. It contains the most actual translations for all languages from the dashboard.
It's good practice to have it updated before an app release.
Applanga only fetches new translations.
If the settings file is up-to-date the first (automatic) ApplangaFlutter.update will result in a very lightweight get request.
If the settings file is an old one -> the fetch request will contain a lot more info.
