import 'dart:convert';
import 'dart:io';

import 'package:applanga_flutter/src/applanga_exception.dart';
import 'package:applanga_flutter/src/generator/config.dart';
import 'package:path/path.dart' as path;

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
      stdout.writeln("-> .applanga.json created");
    } else {
      stdout.writeln("SKIPPED .applanga.json already created");
    }
  }

  void push(List<String> args) async {
    stdout.writeln("-> applanga_flutter:push");
    try {
      var process = await Process.start('applanga', ['push', ...args]);
      process.stdout.transform(utf8.decoder).forEach((line) {
        stdout.writeln(line);
      });
      process.stderr.transform(utf8.decoder).forEach((line) {
        stderr.writeln(line);
      });
      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        throw ApplangaCliException("applanga cli push failed.");
      }
    } on ApplangaCliNotFoundException {
      _printCliNotFoundErrorMsg();
    } catch (e) {
      if (e is ApplangaConfigException) {
        stdout.writeln(e.msg);
      } else {
        stdout
            .writeln("Something went wrong! Please contact applanga support.");
      }
    }
  }

  void pull(List<String> args) async {
    stdout.writeln("-> applanga_flutter:pull");
    try {
      var process = await Process.start('applanga', ['pull', ...args]);
      process.stdout.transform(utf8.decoder).forEach((line) {
        stdout.writeln(line);
      });
      process.stderr.transform(utf8.decoder).forEach((line) {
        stderr.writeln(line);
      });
      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        throw ApplangaCliException("applanga cli push failed.");
      }
    } on ApplangaCliNotFoundException {
      _printCliNotFoundErrorMsg();
    } catch (e) {
      if (e is ApplangaConfigException) {
        stdout.writeln(e.msg);
      } else {
        stdout
            .writeln("Something went wrong! Please contact applanga support.");
      }
    }
    if (_config.updateSettingsfilesOnPull) {
      stdout.writeln("-> automatic update settingsfiles on pull activated");
      await updateSettingsfiles();
    }
  }

  Future<void> updateSettingsfiles({List<String>? args}) async {
    stdout.writeln("-> applanga_flutter:updateSettingsfiles");
    try {
      var process = await Process.start(
          'applanga', ['updateSettingsfiles', ...args ?? []]);
      process.stdout.transform(utf8.decoder).forEach((line) {
        stdout.writeln(line);
      });
      process.stderr.transform(utf8.decoder).forEach((line) {
        stderr.writeln(line);
      });
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
        stdout.writeln((e as ApplangaFlutterException).msg);
      } else {
        stdout
            .writeln("Something went wrong! Please contact applanga support.");
      }
    }
  }

  Future<String> _getCliVersion() async {
    var versionProcess = await Process.start('applanga', ['--version']);
    StringBuffer versionBuffer = StringBuffer();
    versionProcess.stdout.transform(utf8.decoder).forEach((line) {
      versionBuffer.writeln(line);
    });
    await versionProcess.exitCode;
    if (exitCode != 0) throw ApplangaCliNotFoundException();
    String version = RegExp(r'\d+\.\d+\.\d+')
            .allMatches(versionBuffer.toString())
            .first
            .group(0) ??
        "unknown";
    return version;
  }

  static _printCliNotFoundErrorMsg() {
    stdout.writeln("> Applang CLI not installed!");
    stdout.writeln(
        "Please install Applanga's CLI according to the Documentation:");
    stdout
        .writeln("https://www.applanga.com/docs/integration-documentation/cli");
    stdout.writeln("");
    stdout.writeln("More info at the Applanga Flutter Documentation:");
    stdout.writeln(
        "https://www.applanga.com/docs/integration-documentation/flutter");
    stdout.writeln("\n");
  }
}
