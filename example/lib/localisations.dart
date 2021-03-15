import 'dart:async';
import 'package:applanga_flutter/applanga_flutter.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ApplangaLocalizationsDelegate extends LocalizationsDelegate<ApplangaLocalizations> {
  const ApplangaLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'de'].contains(locale.languageCode);

  @override
  Future<ApplangaLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return new SynchronousFuture<ApplangaLocalizations>(new ApplangaLocalizations(locale));
  }

  @override
  bool shouldReload(ApplangaLocalizationsDelegate old) => false;
}

class ApplangaLocalizations {
  ApplangaLocalizations(this.locale);

  final Locale locale;

  static ApplangaLocalizations of(BuildContext context) {
    return Localizations.of<ApplangaLocalizations>(context, ApplangaLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Title',
      'hello_world': 'Hello World!',
      'showScreenShotMenu': 'Not Working',
      'hideScreenShotMenu': 'Not Working',
      'draftModeLabel': 'Not Working',
      'takeProgramaticScreenshot': 'Not Working',
      'secondPageTitle': 'Not Working'
    },
    'de': {
      'title': 'Title',
      'hello_world': 'Hello World!',
      'showScreenShotMenu': 'Not Working',
      'hideScreenShotMenu': 'Not Working',
      'draftModeLabel': 'Not Working',
      'takeProgramaticScreenshot': 'Not Working',
      'secondPageTitle': 'Not Working'
    }
  };

  /// Actualises the key - string map with the strings from applanga's dashboard
  Future localizeMap() async{
    print(this.locale.languageCode);
    print("Before Localisation: " + _localizedValues.toString());
    _localizedValues = await ApplangaFlutter.localizeMap(_localizedValues);
    print("After Localisation: " + _localizedValues.toString());

    Map<String, String> allLocalisations = await ApplangaFlutter.localizedStringsForCurrentLanguage();
    print("All texts length: " + allLocalisations.length.toString());
    allLocalisations.forEach((key,value)=>{
      print("KEY: " + key + " value: " + value)
    });
  }


  ///Returns the string value for current language. If it does not exists
  ///fallback to english.
  String get(String key) {
    var translatedString;

    translatedString = _localizedValues[locale.languageCode][key];
    //print("key : '$key', lang : '${locale.languageCode}', value : '$translatedString'");
    if(translatedString == null) {
      translatedString = _localizedValues['en'][key]; //fallback
      //print("key : '$key', lang : 'en', value : '$translatedString'");
    }

    return translatedString == null ? "NULL! key : $key" : translatedString;
  }

  String getHelloWorld(){
    return get("hello_world");
  }
}