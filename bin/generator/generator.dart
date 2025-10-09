import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:applanga_flutter/src/applanga_exception.dart';
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

class ALIcuMethod {
  final String nameWithParams;
  final String name;
  final Map<String, String> originalParams;
  final Map<String, String>? formattedParams;
  final String body;

  ALIcuMethod({
    required this.nameWithParams,
    required this.name,
    required this.originalParams,
    required this.body,
    this.formattedParams,
  });
}

class LocalizationBaseLangVisitor extends SimpleAstVisitor {
  final RegExp _formatVarRegex = RegExp("\\.format\\((.*)\\)");

  List<String> ids = [];
  List<String> getter = [];
  List<ALIcuMethod> formattingList = [];
  bool _useIntlImport = false;

  LocalizationBaseLangVisitor();

  bool get useIntlImport => _useIntlImport;

  @override
  visitMethodDeclaration(MethodDeclaration node) {
    final superClassName =
        (node.parent as ClassDeclaration).extendsClause?.superclass.toString();
    if ("AppLocalizations" != superClassName) {
      return;
    }
    // ast ist not resolved so we check the type by it's toString method
    if (node.returnType?.toString() == "String") {
      Map<String, String> originalParams = {};
      Map<String, String>? formattedParams;
      ids.add(node.name.toString());
      if (node.isGetter) {
        getter.add(node.name.toString());
      } else {
        for (final param in node.parameters!.parameters) {
          String? paramName = param.name?.toString();
          if (paramName != null) {
            originalParams.putIfAbsent(paramName, () => paramName);
          }
        }
        if (node.body is BlockFunctionBody) {
          String formattingLines = '';
          final blockBody = node.body as BlockFunctionBody;
          for (final statement in blockBody.block.statements) {
            if (statement is VariableDeclarationStatement) {
              formattingLines += statement.toString();
              final newParam =
                  statement.variables.variables.first.name.toString();
              RegExpMatch? match = _formatVarRegex
                  .firstMatch(statement.variables.variables.first.toString());
              final oldParam = match?.group(1);
              if (oldParam != null) {
                formattedParams ??= {};
                formattedParams[oldParam] = newParam;
              }
            }
          }
          formattingList.add(ALIcuMethod(
              nameWithParams:
                  "${node.name.toString()}${node.parameters.toString()}",
              name: node.name.toString(),
              body: formattingLines,
              originalParams: originalParams,
              formattedParams: formattedParams));
          if (formattingLines.contains("intl.")) {
            _useIntlImport = true;
          }
        }
      }
    }
  }
}

class LocalizationClassVisitor extends SimpleAstVisitor {
  final List<String> supportedLocalesDeclarations = [];

  @override
  visitFieldDeclaration(FieldDeclaration node) {
    if (node.fields.variables.first.name.toString() == "supportedLocales") {
      final list = node.fields.variables.first.initializer as ListLiteral;
      for (final element in list.elements) {
        supportedLocalesDeclarations.add(element.toString());
      }
    }
    return super.visitFieldDeclaration(node);
  }
}
