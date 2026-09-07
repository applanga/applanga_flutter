import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:applanga_flutter/src/applanga_exception.dart';
import 'package:applanga_flutter/src/generator/localization_visitors.dart';
import 'package:dart_style/dart_style.dart' show DartFormatter;
import 'package:pub_semver/pub_semver.dart';

import '../utils.dart';
import 'config.dart';
import 'template.dart';

class ApplangaGenerator {
  late final ApplangaConfig config = ApplangaConfig();

  void generate() {
    try {
      _generateLocalizationClass();
    } catch (e) {
      if (e is ApplangaConfigException) {
        Utils.errorWriteLn(e.msg);
      } else {
        Utils.errorWriteLn(e.toString());
        Utils.errorWriteLn(
            "Something went wrong! Run `flutter gen-l10n` and try again, otherwise please get in touch with applanga support.");
      }
    }
  }

  void _generateLocalizationClass() {
    final abstractVisitor = LocalizationClassVisitor();
    final abstractFile = File(config.originAppLocalizationsClassPath);
    final abstractParsedString =
        parseString(content: abstractFile.readAsStringSync());

    for (var element in abstractParsedString.unit.declarations) {
      element.visitChildren(abstractVisitor);
    }

    final visitor = LocalizationBaseLangVisitor();
    final file = File(config.originAppLocalizationsBaseLanguageClassPath);
    final parsedString = parseString(content: file.readAsStringSync());

    for (var element in parsedString.unit.declarations) {
      element.visitChildren(visitor);
    }

    final generatedFile = File(config.destinationAppLocalizationsClassPath)
      ..createSync(recursive: true);
    final dartCode = generateAppLocalizationClass(
        config.originAppLocalizationImport,
        config.className,
        config.baseLanguage,
        config.branchId,
        config.updateGroups,
        config.updateLanguages,
        config.customLanguageFallback,
        config.getDynamicStrings,
        visitor.ids,
        visitor.getter,
        visitor.formattingList,
        visitor.useIntlImport,
        abstractVisitor.supportedLocalesDeclarations);
    final formatter = DartFormatter(languageVersion: Version(3, 6, 0));
    generatedFile.writeAsStringSync(formatter.format(dartCode));
    Utils.successWriteLn("${generatedFile.absolute} generated successfully!");
  }
}
