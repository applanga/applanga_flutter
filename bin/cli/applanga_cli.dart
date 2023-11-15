import 'dart:io';

import 'package:applanga_flutter/src/applanga_exception.dart';
import 'package:path/path.dart' as path;

import '../generator/config.dart';
import '../utils.dart';

class ApplangaCli {
  late final ApplangaConfig _config = ApplangaConfig();
  final File _applangaJson =
      File(path.join(Directory.current.path, '.applanga.json'));

  ApplangaCli._();

  static Future<ApplangaCli> createAsync() async {
    var instance = ApplangaCli._();
    if (!await _isApplangaCliInstalled()) {
      _printCliNotFoundErrorMsg();
      throw ApplangaCliNotFoundException();
    }
    await instance._createApplangaJsonIfNotExistent();
    return instance;
  }

  static Future<bool> _isApplangaCliInstalled() async {
    var process = await Process.start('command', ['applanga']);
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      return false;
    }
    return true;
  }

  Future<void> _createApplangaJsonIfNotExistent() async {
    if (!_applangaJson.existsSync()) {
      _applangaJson.createSync();
      _applangaJson.writeAsStringSync(_config.applangaJson);
      Utils.successWriteLn(".applanga.json created");
    } else {
      if (!_config.isCurrentApplangaJsonUpToDate(_applangaJson)) {
        throw ApplangaConfigException(
            "Applanga configurations in pubspec.yaml and .applanga.json are mismatching. Delete .applanga.json to recreate it.");
      } else {
        Utils.writeLn("\nSKIPPED .applanga.json already created");
      }
    }
  }

  void push(List<String> args) async {
    Utils.actionWriteLn("applanga_flutter:push");
    try {
      var process = await Process.start('applanga', ['push', ...args]);
      Utils.forwardProcessOutput(process);
      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        throw ApplangaCliException("applanga cli push failed.");
      }
    } on ApplangaCliNotFoundException {
      _printCliNotFoundErrorMsg();
    } catch (e) {
      if (e is ApplangaConfigException) {
        Utils.errorWriteLn(e.msg);
      } else {
        Utils.errorWriteLn(
            "Something went wrong! Please contact applanga support.");
      }
    }
  }

  void pull(List<String> args) async {
    Utils.actionWriteLn("applanga_flutter:pull");
    try {
      var process = await Process.start('applanga', ['pull', ...args]);
      Utils.forwardProcessOutput(process);
      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        throw ApplangaCliException("applanga cli push failed.");
      }
    } on ApplangaCliNotFoundException {
      _printCliNotFoundErrorMsg();
    } catch (e) {
      if (e is ApplangaConfigException) {
        Utils.errorWriteLn(e.msg);
      } else {
        Utils.errorWriteLn(
            "Something went wrong! Please contact applanga support.");
      }
    }
    if (_config.updateSettingsfilesOnPull) {
      Utils.actionWriteLn("automatic update settingsfiles on pull activated");
      await updateSettingsfiles();
    }
  }

  Future<void> updateSettingsfiles({List<String>? args}) async {
    Utils.actionWriteLn("applanga_flutter:updateSettingsfiles");
    try {
      var process = await Process.start(
          'applanga', ['updateSettingsfiles', ...args ?? []]);
      Utils.forwardProcessOutput(process);
      final exitCode = await process.exitCode;
      switch (exitCode) {
        case 0:
          break;
        case 2:
          String currentVersion = await _getCliVersion();
          throw ApplangaCliOutdatedException(
              currentVersion: currentVersion, minVersion: "1.0.72");
        default:
          throw ApplangaCliException(
              "applanga cli updateSettingsfiles failed.");
      }
    } on ApplangaCliNotFoundException {
      _printCliNotFoundErrorMsg();
    } catch (e) {
      if (e is ApplangaConfigException || e is ApplangaCliOutdatedException) {
        Utils.errorWriteLn((e as ApplangaFlutterException).msg);
      } else {
        Utils.errorWriteLn(
            "Something went wrong! Please contact applanga support.");
      }
    }
  }

  Future<String> _getCliVersion() async {
    var versionProcess = await Process.start('applanga', ['--version']);
    StringBuffer versionBuffer = StringBuffer();
    Utils.forwardProcessOutput(versionProcess);
    await versionProcess.exitCode;
    if (exitCode != 0) throw ApplangaCliNotFoundException();
    String version = RegExp(r'\d+\.\d+\.\d+')
            .allMatches(versionBuffer.toString())
            .first
            .group(0) ??
        "unknown";
    return version;
  }

  static void _printCliNotFoundErrorMsg() {
    Utils.errorWriteLn("> Applang CLI not installed!");
    Utils.errorWriteLn(
        "Please install Applanga's CLI according to the Documentation:");
    Utils.errorWriteLn(
        "https://www.applanga.com/docs/integration-documentation/cli");
    Utils.errorWriteLn("");
    Utils.errorWriteLn("More info at the Applanga Flutter Documentation:");
    Utils.errorWriteLn(
        "https://www.applanga.com/docs/integration-documentation/flutter");
    Utils.errorWriteLn("\n");
  }
}
