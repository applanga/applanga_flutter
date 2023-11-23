import 'dart:convert';
import 'dart:io';

import 'package:applanga_flutter/src/applanga_exception.dart';
import 'package:intl/locale.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart' as yaml;

import '../utils.dart';

class ApplangaConfig {
  static const _l10nSupportedConfigs = [
    'arb-dir',
    'template-arb-file',
    'output-localization-file',
    'synthetic-package',
    'output-dir'
  ];

  String get _rootDirPath => Directory.current.path;

  String get originAppLocalizationsClassPath => path.join(_rootDirPath,
      '$_flutterAutoGeneratedOutputDir/$_flutterAutoGeneratedLocalizationFile');

  late String _originAppLocalizationImport;

  String get originAppLocalizationImport => _originAppLocalizationImport;

  String get originAppLocalizationsBaseLanguageClassPath => path.join(
      _rootDirPath,
      '$_flutterAutoGeneratedOutputDir/$_flutterAutoGeneratedLocalizationFileBaseLanguage');

  String _destinationPath = 'lib/generated';
  String _destinationClassFileName = 'applanga_localizations.dart';
  String _className = 'ApplangaLocalizations';

  String get className => _className;

  late String _arbDir;

  String get arbDir => _arbDir;

  late String _arbTemplateFileName;

  String get arbTemplateFileName => _arbTemplateFileName;

  String get arbTemplateFilePath =>
      path.join(_rootDirPath, arbDir, _arbTemplateFileName);

  late String _flutterAutoGeneratedLocalizationFile;

  late String _flutterAutoGeneratedOutputDir;

  late String _flutterAutoGeneratedLocalizationFileBaseLanguage;

  late String _packageName;

  late String _accessToken;

  String get accessToken => _accessToken;

  Map<String, List<String>>? _customLanguageFallback;

  Map<String, List<String>>? get customLanguageFallback =>
      _customLanguageFallback;

  String? _branchId;

  String? get branchId => _branchId;

  List<String>? _updateGroups;

  List<String>? get updateGroups => _updateGroups;

  List<String>? _updateLanguages;

  List<String>? get updateLanguages => _updateLanguages;

  bool _updateSettingsfilesOnPull = true;

  bool get updateSettingsfilesOnPull => _updateSettingsfilesOnPull;

  String _baseLanguage = 'en';

  String get baseLanguage => _baseLanguage;

  String get destinationAppLocalizationsClassPath =>
      path.join(_rootDirPath, _destinationPath, _destinationClassFileName);

  String get applangaJson => """
{
  "app": {
    "access_token": "$accessToken",
    "base_language": "$baseLanguage",
    ${_branchId != null ? "\"branch_id\": \"$_branchId\"," : ""}
    "pull": {
      "target": [
"""
      //{
      //  "language": "$baseLanguage",
      //  "export_empty": true,
      //  "file_format": "arb",
      //  "path": "$arbDir/$arbTemplateFileName"
      //},
      """
        {
          "includeMetadata": false,
          "exclude_languages": ["$baseLanguage"],
          "file_format": "arb",
          "path": "$arbDir/${replaceArbFileNameWithApplangaLocalePlaceholder(arbTemplateFileName)}"
        }
      ]
    },
    "push": {
      "source": [
"""
      //{
      //  "file_format": "arb",
      //  "path": "$arbDir/${replaceArbFileNameWithApplangaLocalePlaceholder(arbTemplateFileName)}"
      //}
      """  
        {
          "file_format": "arb",
          "language": "$baseLanguage",
          "path": "$arbDir/$arbTemplateFileName"
        }
      ]
    }
  }
}
""";
  static final ApplangaConfig _instance = ApplangaConfig._internal();

  factory ApplangaConfig() => _instance;

  ApplangaConfig._internal() {
    parsePubspec();
    parseL10n();
  }

  bool isCurrentApplangaJsonUpToDate(File applangaJsonFile) {
    Map<String, Object?>? applangaJson;
    try {
      applangaJson = json.decode(applangaJsonFile.readAsStringSync());
      if (applangaJson!["app"] is! Map) {
        // if it has no app object return here already
        throw Exception();
      }
    } catch (e) {
      Utils.errorWriteLn("applanga json not valid.");
      return false;
    }

    Map<String, Object?> app = applangaJson["app"] as Map<String, Object?>;

    String? accessToken;
    try {
      accessToken = app["access_token"] as String;
    } catch (e) {
      /* ignore */
    }

    String? branchId;
    try {
      branchId = app["branch_id"] as String;
    } catch (e) {
      /* ignore */
    }

    if (_accessToken != accessToken) {
      Utils.writeLn("access token pubspec.yaml: $_accessToken");
      Utils.writeLn("access token .applanga.json: $accessToken");
      Utils.actionWriteLn("access token mismatching.");
      return false;
    }

    if (_branchId != branchId) {
      Utils.writeLn("branch id pubspec.yaml: $_branchId");
      Utils.writeLn("branch id .applanga.json: $branchId");
      Utils.actionWriteLn("branch id mismatching.");
      return false;
    }
    return true;
  }

  void parsePubspec() {
    final pubspecFile = getPubspec();
    if (pubspecFile == null) {
      throw ApplangaConfigException("pubspec.yaml not found.");
    }
    Utils.actionWriteLn("pubspec.yaml parsing: ${pubspecFile.path}");
    var pubspecYaml = yaml.loadYaml(pubspecFile.readAsStringSync());

    // check if flutter localization generation is turned on
    var flutterConfig = pubspecYaml['flutter'];
    if (!(flutterConfig['generate'] ?? false)) {
      throw ApplangaConfigException(
          "Applanga works with flutters localization generator.\n"
          "It's not turned on for '${pubspecYaml["name"]}'.\n"
          "Check out the docs: "
          "https://www.applanga.com/docs/integration-documentation/flutter");
    }
    // check applanga configs
    var applangaConfig = pubspecYaml['applanga_flutter'];
    if (applangaConfig == null) {
      throw ApplangaConfigException(
          "No applanga_flutter config found in pubspec.yaml.");
    }

    var packageName = pubspecYaml["name"];
    if (packageName != null && packageName is String) {
      _packageName = packageName;
    } else {
      throw ApplangaConfigException("name is not set.");
    }

    var accessToken = applangaConfig["access_token"];
    if (accessToken != null && accessToken is String) {
      _accessToken = accessToken;
    } else {
      throw ApplangaConfigException("access_token is not set.");
    }

    var updateSettingsfilesOnPullTmp =
        applangaConfig["update_settingsfiles_on_pull"];
    if (updateSettingsfilesOnPullTmp is bool) {
      _updateSettingsfilesOnPull = updateSettingsfilesOnPullTmp;
    }

    var groups = applangaConfig["update_groups"];
    if (groups != null && groups is yaml.YamlList) {
      _updateGroups = List<String>.from(groups.value);
    }

    var languages = applangaConfig["update_languages"];
    if (languages != null && languages is yaml.YamlList) {
      _updateLanguages = List<String>.from(languages.value);
    }

    var className = applangaConfig["class_name"];
    if (className is String) {
      _className = className;
    }

    var classFileName = applangaConfig["class_filename"];
    if (classFileName is String) {
      _destinationClassFileName = classFileName;
    }

    var outputDir = applangaConfig["output_dir"];
    if (outputDir is String) {
      _destinationPath = outputDir;
    }

    var branchId = applangaConfig["branch_id"];
    if (branchId is String) {
      _branchId = branchId;
    }

    var customLanguageFallback = applangaConfig["custom_language_fallback"];
    if (customLanguageFallback is yaml.YamlMap) {
      _customLanguageFallback =
          customLanguageFallback.map<String, List<String>>((key, value) {
        return MapEntry(key, List<String>.from(value.value));
      });
    }
  }

  void parseL10n() {
    final l10nYamlFile = getL10nYaml();
    if (l10nYamlFile == null) {
      throw ApplangaConfigException("l10n.yaml not found.");
    }
    final yaml.YamlMap l10nYaml =
        yaml.loadYaml(l10nYamlFile.readAsStringSync());
    final foundConfigs = l10nYaml.keys;

    // check if there is an unsupported l10n.yaml config left then throw an exception
    if (foundConfigs
        .any((element) => !_l10nSupportedConfigs.contains(element))) {
      throw ApplangaConfigException("Unsupported l10n.yaml config found:"
          " ${foundConfigs.where((element) => !_l10nSupportedConfigs.contains(element)).toList().join(", ")}."
          " Please contact Applanga support.");
    }

    var arbDir = l10nYaml['arb-dir'];
    if (arbDir != null && arbDir is String) {
      _arbDir = arbDir;
    } else {
      throw ApplangaConfigException("arb-dir is not set in l10n.yaml");
    }

    var templateArbFile = l10nYaml['template-arb-file'];
    if (templateArbFile != null && templateArbFile is String) {
      _arbTemplateFileName = templateArbFile;
    } else {
      throw ApplangaConfigException(
          "template-arb-file is not set in l10n.yaml");
    }

    var baseLanguage = _getBaseLanguageFromTemplateArb();
    if (baseLanguage != null) {
      _baseLanguage = baseLanguage;
    } else {
      throw ApplangaConfigException("@@locale is not set in $templateArbFile");
    }

    var outputLocalizationFile = l10nYaml['output-localization-file'];
    if (outputLocalizationFile != null && outputLocalizationFile is String) {
      _flutterAutoGeneratedLocalizationFile = outputLocalizationFile;
    } else {
      throw ApplangaConfigException(
          "output-localization-file is not set in l10n.yaml");
    }

    var outputDir = l10nYaml['output-dir'];
    var syntheticPackage = l10nYaml['synthetic-package'];

    // the output dir is only set if the synthetic package is set to false
    // that's according to the flutter l10n documentation
    // https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
    if (syntheticPackage != null &&
        syntheticPackage is bool &&
        syntheticPackage == false &&
        outputDir != null &&
        outputDir is String) {
      _flutterAutoGeneratedOutputDir = outputDir;
      // the auto generated file resides in the current package
      _originAppLocalizationImport =
          "package:$_packageName/${_removeLibPrefix(_flutterAutoGeneratedOutputDir)}/$_flutterAutoGeneratedLocalizationFile";
    } else {
      // the auto generated file resides in the flutter_gen synthetic package
      _flutterAutoGeneratedOutputDir = ".dart_tool/flutter_gen/gen_l10n";
      _originAppLocalizationImport =
          'package:flutter_gen/gen_l10n/$_flutterAutoGeneratedLocalizationFile';
    }

    try {
      _flutterAutoGeneratedLocalizationFileBaseLanguage =
          "${_flutterAutoGeneratedLocalizationFile.split('.')[0]}_$_baseLanguage.dart";
      if (!File(originAppLocalizationsBaseLanguageClassPath).existsSync()) {
        throw Exception();
      }
    } catch (_) {
      throw ApplangaConfigException('Could not locate auto generated file for '
          'base language: $_baseLanguage. Try to run `flutter gen-l10n` first.');
    }
  }

  File? getPubspec() {
    var pubspecFilePath = path.join(_rootDirPath, 'pubspec.yaml');
    var pubspecFile = File(pubspecFilePath);
    return pubspecFile.existsSync() ? pubspecFile : null;
  }

  File? getL10nYaml() {
    var filePath = path.join(_rootDirPath, 'l10n.yaml');
    var file = File(filePath);
    return file.existsSync() ? file : null;
  }

  String? _getBaseLanguageFromTemplateArb() {
    var file = File(arbTemplateFilePath);
    Map<String, Object?> arbMap;
    try {
      arbMap = json.decode(file.readAsStringSync()) as Map<String, Object?>;
    } on FormatException catch (e) {
      throw ApplangaConfigException(
        'The arb file ${file.path} has the following formatting issue: \n'
        '${e.toString()}',
      );
    }
    var localeString = arbMap['@@locale'] as String?;
    if (localeString == null) {
      final regex = RegExp(r"_([\w-]+).arb$");
      if (regex.hasMatch(arbTemplateFileName)) {
        final matches = regex.allMatches(arbTemplateFileName);
        if (matches.isNotEmpty && matches.first.group(1) != null) {
          localeString = matches.first.group(1)!;
          final locale = Locale.tryParse(matches.first.group(1)!);
          if (locale == null) {
            localeString = null;
          }
        }
      }
    }
    return localeString;
  }

  String replaceArbFileNameWithApplangaLocalePlaceholder(String fileName) {
    for (int index = 0; index < fileName.length; index++) {
      if (fileName[index] == '_') {
        var localeString =
            fileName.substring(index + 1, fileName.length - '.arb'.length);
        if (localeString == baseLanguage) {
          return "${fileName.substring(0, index + 1)}<language>${fileName.substring(index + 1 + localeString.length)}";
        }
      }
    }
    throw ApplangaConfigException(
        "Baselanguage $baseLanguage not found in filename: $fileName");
  }

  /// Gets arb file for the given locale.
  File? getArbFileForLocale({
    String locale = "en",
    /* String arbDir =""*/
  }) {
    var arbDir = path.join(_rootDirPath, 'lib/l10n');
    var arbFilePath = path.join(arbDir, 'intl_$locale.arb');
    var arbFile = File(arbFilePath);

    return arbFile.existsSync() ? arbFile : null;
  }

  String _removeLibPrefix(String path) {
    // this method removes the lib prefix from the path
    // this is necessary because the flutter import notation does not require
    // the lib prefix but the l10n.yaml output dir notation does
    const String libPrefix = "lib/";
    if (path.startsWith(libPrefix)) {
      return path.substring(libPrefix.length);
    }
    return path;
  }
}