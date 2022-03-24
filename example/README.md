# ApplangaFlutter Example 

This is a tiny example to show case applanga_flutter.
If you run it directly with android or iOS you will notice that you have to integrate your applanga project first to have access to all applanga features.

For more complete info visit the [Applanga Flutter documentation](https://www.applanga.com/docs/integration-documentation/flutter).

## Push and pull new translations
This example is not connected to any applanga project yet. Follow the next steps.
### Add Access Token
Add your API-Token, which you can find in your project settings on your applanga dashboard, to the `pubspec.yaml` right below `applanga_flutter`.

E.g.:
```yaml
applanga_flutter:
  access_token: xxxx
```
### Push translations
Now you are able to push translations with the following command:

`flutter pub run applanga_flutter:push`

### Pull translations
If you now modify strings in other languages you can pull them with the following command:

`flutter pub run applanga_flutter:push`

## Over-The-Air (OTA) Translations
Over-The-Air translations are only working on iOS and Android at the moment.
To make them work you have to add the `applanga_settings.applanga` file from your project. Download it from the applanga dashboard via `Prepare Release`.

### Add Settings File for Android
The settings file should be located in: `example/android/app/src/main/res/raw`.
Let's say you just have downloaded it to your `~/Downloads` dir and your terminal location is the example folder. Execute the following to place your `applanga_settings.applanga` file correctly.

```
$ mkdir android/app/src/main/res/raw
$ mv ~/Downloads/applanga_settings.applanga android/app/src/main/res/raw/
```

You can find more info at [Android integration](https://www.applanga.com/docs/integration-documentation/android).

### Add Settings File for iOS
The settings file has to be inside your xcode project.
This can't be easily done via the command line. You have to open xcode and add the `applanga_settings.applanga` file to your project inside Runner. Do a `flutter pub get` first.

```
$ flutter pub get
$ open ios/Runner.xcworkspace/
```

You can find more info at [iOS integration](https://www.applanga.com/docs/integration-documentation/ios).

