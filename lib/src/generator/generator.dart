import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:applanga_flutter/src/applanga_exception.dart';
import 'package:applanga_flutter/src/generator/config.dart';
import 'package:applanga_flutter/src/generator/template.dart';
import 'package:dart_style/dart_style.dart' show DartFormatter;

class ApplangaGenerator {
  late final ApplangaConfig config = ApplangaConfig();

  generate() {
    try {
      _generateLocalizationClass();
    } catch (e) {
      if (e is ApplangaConfigException) {
        stdout.writeln(e.msg);
      } else {
        Utils.errorWriteLn(e.toString());
        Utils.errorWriteLn(
            "Something went wrong! Please contact applanga support.");
      }
    }
  }

  _generateLocalizationClass() {
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
      visitor.ids,
      visitor.getter,
      visitor.formattingList,
      visitor.useIntlImport,
    );
    final formatter = DartFormatter();
    generatedFile.writeAsStringSync(formatter.format(dartCode));
    stdout.writeln("${generatedFile.absolute} generated successfully!");
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
  List<String> ids = [];
  List<String> getter = [];
  List<MethodDeclaration> methods = [];

  @override
  visitMethodDeclaration(MethodDeclaration node) {
    // ast ist not resolved so we check the type by it's toString method
    if (node.isAbstract && node.returnType?.toString() == "String") {
      ids.add(node.name.toString());
      if (node.isGetter) {
        getter.add(node.name.toString());
      } else {
        methods.add(node);
      }
    }
  }
}
