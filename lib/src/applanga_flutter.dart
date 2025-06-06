import 'dart:async';
import 'dart:io' show Platform;

import 'package:applanga_flutter/applanga_flutter.dart';
import 'package:applanga_flutter/src/applanga_exception.dart';
import 'package:applanga_flutter/src/language/locale_list.dart';
import 'package:applanga_flutter/src/screenshot/string_position.dart';
import 'package:applanga_flutter/src/screenshot/translation_tuple.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/locale.dart' as intl_locale;
import 'package:synchronized/synchronized.dart';

export 'icu/icu_string.dart';

class ApplangaFlutter {
  static late final MethodChannel? _channel;
  static final ApplangaFlutter instance = ApplangaFlutter._internal();
  static final ApplangaFlutter I = instance;

  // ignore: close_sinks
  final StreamController<TranslationTuple> _translationStream =
      StreamController.broadcast(sync: true);

  final _notifyLock = Lock();

  final bool _isSupported = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  final Map<String, Map<String, String?>> _translationCache = {};
  final List<BuildContext> _currentScreenContextList = [];

  BuildContext? get _currentScreenContext =>
      _currentScreenContextList.isNotEmpty
          ? _currentScreenContextList.last
          : null;

  ApplangaInherited? get _applangaInherited {
    final context = _currentScreenContext;
    if (context == null) return null;
    try {
      return ApplangaInherited.of(context);
    } catch (_) {
      return null;
    }
  }

  String? _branchId;
  late LocaleList _currentLocaleList;

  bool _getDynamicStrings = false;

  LocaleList get currentLocaleList => _currentLocaleList;

  void setCurrentLocale(Locale locale) {
    _applangaSetLanguage(locale);
    currentLocaleList.changeLocale(locale);
  }

  bool _showIdMode = false;

  List<String> _defaultGroups = ['main'];
  List<String>? _defaultLanguages;
  List<String> _keys = [];

  List<String> get defaultLanguages {
    if (_defaultLanguages != null) {
      return _defaultLanguages!;
    } else {
      return [intl.Intl.getCurrentLocale().replaceAll("_", "-")];
    }
  }

  bool isInitialised = false;

  factory ApplangaFlutter() {
    return instance;
  }

  ApplangaFlutter._internal() {
    _init();
  }

  void _init() {
    if (!_isSupported) return;
    _channel = const MethodChannel('applanga_flutter');
    _channel!.invokeMethod('init');
    _compareSettingsFileBranchIdWithFlutterBranchId()
        .catchError((e) => throw e);
    _channel!.setMethodCallHandler((call) async {
      debugPrint("setMethodCallHandler, call: ${call.method}");
      if (call.method == 'getStringPositions') {
        return ALStringPosition.listToJsonString(
            _getStringPositions(_currentScreenContext));
      } else if (call.method == 'captureScreenshotFromOverlay') {
        String? tag = call.arguments;
        if (tag == null) {
          debugPrint("Screentag was null");
        } else {
          debugPrint("tag: $tag");
          try {
            await _captureScreenshotWithTagAndShowIdMode(tag);
          } catch (e, s) {
            debugPrint(e.toString());
            debugPrint(s.toString());
          }
        }
      }
    });
  }

  static Locale localeListResolutionCallback(locales, supportedLocales) {
    return LocaleList.localeListResolutionCallback(locales, supportedLocales);
  }

  /// You can register your state here to improve the screenshot experience.
  /// To get all string positions on your screen, applanga uses the latest
  /// registered state as top level widget. It's recommended to register your
  /// screens like HomeScreen or SettingsScreen. Consider Drawer as screen as
  /// well.
  void registerState(State<dynamic> state) {
    final newContextAdded = _setContext(state.context);
    if (newContextAdded) {
      String childSuffix = '';
      final scope = state.widget;
      if (scope is ApplangaScreenshotScope) {
        String childName = scope.childToStringShort();
        childSuffix = ", child: $childName";
      }
      debugPrint("applanga_flutter register state: "
          "${state.toStringShort()}$childSuffix");
    }
  }

  /// You must dispose your registered states as well to prevent memory leaks
  /// and unexpected behaviors.
  void disposeState(State<dynamic> state) {
    debugPrint("applanga_flutter dispose state: ${state.toStringShort()}");
    _currentScreenContextList.remove(state.context);
  }

  /// The context is necessary to
  /// get the correct string positions for your screenshot upload.
  /// returns true if a context was (re)added
  /// returns false if nothing changed
  bool _setContext(BuildContext context) {
    // don't change the context if a complete tree rebuild was triggered
    // by applanga
    if (_notifyLock.locked) return false;

    // if last element is already the context just skip everything
    if (_currentScreenContextList.isNotEmpty &&
        _currentScreenContextList.last == context) {
      return false;
    }

    // if the context is already somewhere in the list, remove it and
    // add it as the last element
    if (_currentScreenContextList.contains(context)) {
      _currentScreenContextList.remove(context);
    }
    _currentScreenContextList.add(context);
    return true;
  }

  /// internal method to clean a language tag string
  String? _cleanLanguageString(String language) {
    final locale = intl_locale.Locale.tryParse(language);
    if (locale == null) {
      debugPrint("ApplangaFlutter locale not found: $language");
    }
    return locale?.toLanguageTag();
  }

  /// manually fetch latest localisation updates from applanga and applies them
  /// to the current cache
  /// [languages] are the languages which should be updated, default language
  /// is the current language
  /// [groups] are the groups which should be updated, default group is 'main'
  Future<bool> update({
    List<String>? languages,
    List<String>? groups,
  }) async {
    List<String>? parsedLocales;
    if (languages != null) {
      parsedLocales = [];
      for (final language in languages) {
        var cleanedLanguage = _cleanLanguageString(language);
        if (cleanedLanguage != null) {
          parsedLocales.add(cleanedLanguage);
        }
      }
    }
    var updateLanguages = parsedLocales ?? defaultLanguages;
    if (currentLocaleList.hasCurrentLocale()) {
      for (final currentLocale in currentLocaleList.list) {
        if (!updateLanguages.contains(currentLocale.toLanguageTag())) {
          updateLanguages.add(currentLocale.toLanguageTag());
        }
      }
    }

    bool success = await _update(languages: updateLanguages, groups: groups);

    // load strings only if locale is known
    if (currentLocaleList.hasCurrentLocale()) {
      await _loadLocale();
    }

    return success;
  }

  Future<bool> _update({List<String>? groups, List<String>? languages}) async {
    if (!_isSupported) return Future.value(false);
    List<String> updateGroups = groups ?? _defaultGroups;
    List<String> updateLanguages = languages ?? defaultLanguages;
    debugPrint(
        "_update with groups: $updateGroups, and languages: $updateLanguages");
    final success = await _channel!.invokeMethod('update', <String, dynamic>{
          'groups': updateGroups,
          'languages': updateLanguages,
        }) ??
        false;
    for (final language in updateLanguages) {
      if (_translationCache[language] == null) {
        // mark this languages as natively updated
        _translationCache[language] = {};
      }
    }
    return success;
  }

  /// Sets meta data only once. It triggers an update if there hasn't been one
  /// for the default languages yet.
  Future<void> setMetaData(
      Locale locale, String baseLanguage, String? branchId, List<String> keys,
      {List<String>? groups,
      List<String>? languages,
      Map<String, List<String>>? customLanguageFallback,
      bool getDynamicStrings = false}) async {
    if (!isInitialised) {
      if (groups != null) {
        _defaultGroups = groups;
      }
      var defaultLanguages = <String>[];
      if (languages != null) {
        for (var language in languages) {
          var cleanedLanguage = _cleanLanguageString(language);
          if (cleanedLanguage != null) {
            defaultLanguages.add(cleanedLanguage);
          }
        }
        if (defaultLanguages.isNotEmpty) {
          _defaultLanguages = defaultLanguages;
        }
      }
      _currentLocaleList = LocaleList(locale, baseLanguage,
          customLanguageFallback: customLanguageFallback);
      _branchId = branchId;
      _getDynamicStrings = getDynamicStrings;
      _keys = keys;

      // add current language if it's not set for default languages
      var updateLanguages = defaultLanguages;
      for (var language in _currentLocaleList.listAsLocaleStrings) {
        if (!updateLanguages.contains(language)) {
          updateLanguages.add(language);
        }
      }

      if (!updateLanguages.any((lang) => _translationCache.containsKey(lang))) {
        await _update(groups: _defaultGroups, languages: updateLanguages);
      }
      isInitialised = true;
    }
  }

  /// This method should be called when the locale changes.
  /// It triggers an applanga update if it hasn't already
  /// [locale] is the current locale
  ///
  /// Don't call this by yourself
  ///
  Future<void> loadLocaleAndUpdate(Locale locale) async {
    setCurrentLocale(locale);
    final language = _currentLocaleList.localeAsString;
    if (!_isSupported) return;

    if (!_translationCache.keys.contains(language)) {
      // load locale
      await _loadLocale();
      await _update(languages: currentLocaleList.listAsLocaleStrings);
    }
    // load locale (again after an update)
    await _loadLocale();
  }

  Future<void> _loadLocale() async {
    if (!_isSupported) return Future.value();
    if (!currentLocaleList.hasCurrentLocale()) {
      throw ApplangaFlutterException(
          "loading locale failed: No current Locale is set.");
    }
    Map<dynamic, dynamic> localeMap;

    if (_getDynamicStrings) {
      localeMap = await _channel!.invokeMethod("localizedStringsForLanguages",
          currentLocaleList.listAsLocaleStrings);
      // update keys here
      _keys = {
        ...localeMap.values
            .expand((map) => map.keys.map((key) => key.toString())),
        ..._keys
      }.toSet().toList().cast<String>();
    } else {
      Map<String, String?> emptyStringKeyMap = {
        for (final key in _keys) key: null
      };

      Map<String, Map<String, String?>> map = {
        for (var lang in currentLocaleList.listAsLocaleStrings)
          lang: emptyStringKeyMap
      };

      localeMap = await _channel!.invokeMethod("localizeMap", map);
    }
    // reset cache for all locales
    for (var key in _translationCache.keys) {
      _translationCache[key] = {};
    }
    // set the current locale
    _translationCache[currentLocaleList.localeAsString] = {};

    for (var key in _keys) {
      String? localisedString;
      for (final lang in currentLocaleList.listAsLocaleStrings) {
        final String? translation = localeMap[lang][key];
        if (translation != null && translation.isNotEmpty) {
          localisedString = translation;
          break;
        }
      }
      if (localisedString != null) {
        _translationCache[currentLocaleList.localeAsString]![key] =
            localisedString;
      }
    }
    await _notifyChanges();
  }

  Future<List<TranslationTuple>> _notifyAndInterceptTranslations() async {
    final tuples = <TranslationTuple>[];
    var sub = _translationStream.stream.listen((tuple) {
      tuples.add(tuple);
    });
    await _notifyChanges();
    await sub.cancel();
    return tuples;
  }

  Future<bool> _notifyChanges() async {
    return await _notifyLock.synchronized(() async {
      if (_applangaInherited == null) return false;
      try {
        await _applangaInherited!.rebuild();
        return true;
      } catch (_) {
        return false;
      }
    });
  }

  @Deprecated(
      'Use [getTranslation] instead. Will be removed in next major update.')
  String? getIcuString(String key,
      [Map<String, Object>? args, Map<String, String>? formattedArgs]) {
    return getTranslation(key, args: args, formattedArgs: formattedArgs);
  }

  /// returns the most actual resolved by arguments icu string
  /// [defaultValue] is the default value if the key is not found on Applanga
  /// [key] is the string key
  /// [args] is a Map of arguments for that icu string
  /// [result]
  String? getTranslation(String key,
      {String? defaultValue,
      Map<String, Object>? args,
      Map<String, String>? formattedArgs}) {
    String? result;
    if (!_isSupported) {
      result = null;
    } else if (_showIdMode) {
      result = key;
    } else {
      final value =
          _translationCache[currentLocaleList.locale.toLanguageTag()]?[key];
      if (value == null) {
        result = null;
      } else if (args == null) {
        result = value;
      } else {
        final icuString = IcuString(key, value);
        result = icuString.getTranslation(args, formattedArgs);
      }
    }

    result ??= defaultValue;

    //debugPrint(
    //    "getIcuString: $key, $result, ${_translationStream.hasListener}");
    if (_translationStream.hasListener) {
      _translationStream.sink.add(TranslationTuple(key, result));
    }

    if (result == null) {
      debugPrint("ApplangaFlutter: Translation for key $key not found. "
          "If you are using dynamic strings, make sure to add it to your "
          "Applanga dashboard and turn on dynamic strings in your pubspec.yaml "
          "file.");
    }
    return result;
  }

  /// shows a draft mode dialog to enable applanga's draft mode
  Future<void> showDraftModeDialog() async {
    if (!_isSupported) return;
    await _channel!.invokeMethod('showDraftModeDialog');
  }

  /// shows the screenshot menu
  /// if [visible] is true it will show the screenshot menu, otherwise it will
  /// disappear
  Future<void> setScreenShotMenuVisible(bool visible) async {
    if (!_isSupported) return;
    return await _channel!
        .invokeMethod(visible ? 'showScreenShotMenu' : 'hideScreenShotMenu');
  }

  /// enables applanga's show id mode
  Future<void> setShowIdModeEnabled(bool enabled) async {
    if (!_isSupported) return;
    if (_showIdMode == enabled) return;
    _showIdMode = enabled;
    await _channel!.invokeMethod(
        'setShowIdModeEnabled', <String, dynamic>{'enabled': enabled});
    if (currentLocaleList.hasCurrentLocale()) {
      await _loadLocale();
    }
  }

  /// This is an internal method to keep the flutter locale in sync
  /// with applanga's native sdk
  Future<void> _applangaSetLanguage(Locale? locale) {
    if (!_isSupported || locale == null) {
      return Future.value(null);
    }
    return _channel!.invokeMethod(
        'setLanguage', <String, dynamic>{'lang': locale.toLanguageTag()});
  }

  Future<void> _captureScreenshotWithTagAndShowIdMode(String tag) async {
    debugPrint("captureScreenshotWithTagAndShowIdMode, tag: $tag");
    var isAbleToNotify = await _notifyChanges();

    if (isAbleToNotify) {
      await setShowIdModeEnabled(true);
      var showIdModePositions = _getStringPositions(_currentScreenContext);
      var showIdModeElementTree =
          _getElementTree(_currentScreenContext).toString();
      await _captureScreenshot(tag, stringPos: showIdModePositions);

      await setShowIdModeEnabled(false);
      var actualStringPos = _getStringPositions(_currentScreenContext);
      var actualElementTree = _getElementTree(_currentScreenContext).toString();

      if (showIdModeElementTree == actualElementTree) {
        var actualTranslations = await _notifyAndInterceptTranslations();
        var mergedPositions = mergePositions(
            showIdModePositions, actualStringPos, actualTranslations);
        await _captureScreenshot(tag, stringPos: mergedPositions);
      } else {
        var actualStringIds =
            ALStringPosition.listToStringIdList(showIdModePositions);
        await _captureScreenshot(tag,
            stringIds: actualStringIds, stringPos: actualStringPos);
      }
    } else {
      var actualStringPos = _getStringPositions(_currentScreenContext);
      debugPrint(
          'Add Applanga Widget on top of your view Hierarchy for better Screenshot results.');
      await _captureScreenshot(tag, stringPos: actualStringPos);
    }
  }

  List<ALStringPosition> mergePositions(
      List<ALStringPosition> showIdModePositions,
      List<ALStringPosition> actualPositions,
      List<TranslationTuple> actualTranslations) {
    assert(!_showIdMode);
    final mergedPositions = <ALStringPosition>[];

    for (int i = 0; i < actualPositions.length; i++) {
      var key = showIdModePositions[i].key!;
      var value = actualPositions[i].value;
      final isValidKeyValuePair = actualTranslations
          .where((translation) =>
              translation.key == key && translation.value == value)
          .isNotEmpty;

      if (isValidKeyValuePair) {
        mergedPositions.add(actualPositions[i].copyWith(
            key: key,
            value: _translationCache[currentLocaleList.locale.toLanguageTag()]![
                key]));
      } else {
        mergedPositions.add(actualPositions[i]);
      }
    }
    return mergedPositions;
  }

  /// captures a screenshot
  /// A [tag] is needed for a screenshot upload
  /// [useOcr] is
  Future<void> captureScreenshotWithTag(String tag,
      {List<String>? stringIds}) async {
    if (!_isSupported) return;

    if (stringIds == null) {
      await _captureScreenshotWithTagAndShowIdMode(tag);
    } else {
      await _captureScreenshot(tag,
          stringIds: stringIds,
          stringPos: _getStringPositions(_currentScreenContext));
    }
  }

  Future<void> _captureScreenshot(String tag,
      {List<String>? stringIds, List<ALStringPosition>? stringPos}) async {
    if (!_isSupported) return Future.value();
    String? stringPosAsString;
    if (stringPos != null) {
      stringPosAsString = ALStringPosition.listToJsonString(stringPos);
    }
    await _channel!.invokeMethod('takeScreenshotWithTag', <String, dynamic>{
      'tag': tag,
      'stringIds': stringIds ?? const [],
      'stringPos': stringPosAsString ?? ''
    });
  }

  List<ALStringPosition> _getStringPositions(BuildContext? context) {
    List<ALStringPosition> positions = [];
    void visitor(Element element) {
      if (element.widget is Text) {
        ALStringPosition spos =
            ALStringPosition.byElementContext(element, context!, _showIdMode);
        positions.add(spos);
      }
      element.visitChildren(visitor);
    }

    if (context == null) {
      throw ApplangaFlutterContextException();
    } else {
      try {
        context.visitChildElements(visitor);
      } on TypeError {
        throw ApplangaFlutterContextException();
      }
    }
    return positions;
  }

  String _getElementTree(BuildContext? context) {
    List<String> tree = [];
    void visitor(Element element) {
      tree.add(
          "${element.hashCode.toString()} ${element.runtimeType.toString()}");
      element.visitChildren(visitor);
    }

    if (context == null) {
      debugPrint("ApplangaFlutter: Context is not set. "
          "Failure while collecting string positions for screenshot.");
      debugPrint(StackTrace.current.toString());
    } else {
      context.visitChildElements(visitor);
    }
    return tree.join(', ');
  }

  /// returns the current set branch. The branch is set with the settings file
  /// or when you have enabled the Draft Mode you can change your branch at
  /// runtime.
  Future<void> _compareSettingsFileBranchIdWithFlutterBranchId() async {
    String? settingsFileBranchId =
        await _channel!.invokeMethod("getSettingsFileBranchId");
    if (_branchId == settingsFileBranchId) {
      return;
    } else if (_branchId != null && settingsFileBranchId == null) {
      throw ApplangaConfigException(
          "ApplangaFlutter: The Applanga settings file does not specify any branch. "
          "Re-download your settings file for the correct branch.");
    } else if (_branchId == null && settingsFileBranchId != null) {
      throw ApplangaConfigException(
          "ApplangaFlutter: The Applanga settings file is linked with a branch. "
          "Add you branch to your pubspec.yaml as stated in the applanga_flutter documentation.");
    } else if (_branchId != settingsFileBranchId) {
      throw ApplangaConfigException(
          "ApplangaFlutter: The Applanga settings file is linked with a different "
          "branch than the branch defined in pubspec.yaml. You should keep both "
          "branch id's in sync");
    }
  }
}
