import 'dart:async';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:applanga_flutter/applanga_flutter.dart';

class ApplangaLocalizationsDelegate extends LocalizationsDelegate<ApplangaLocalizations> {
  const ApplangaLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es', 'de'].contains(locale.languageCode);

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
      'fallback_example': 'This is english. Fallback1',
      'fallback_example2': 'This is english. Fallback2'
    },
    'es': {
      'title': 'Titulo',
      'hello_world': 'Hola Mundo!',
      'fallback_example': ''
    },
    'de': {
      'title': 'Titel',
      'hello_world': 'Hallo Welt!',
      'fallback_example': ''
    }
  };

  /// Actualises the key - string map with the strings from applanga's dashboard
  Future localizeMap() async{
    print(_localizedValues);
    _localizedValues = await ApplangaFlutter.localizeMap(_localizedValues);
    print(_localizedValues);
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