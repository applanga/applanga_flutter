import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

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

class LocalizationBaseLangVisitor extends RecursiveAstVisitor {
  final RegExp _formatVarRegex = RegExp("\\.format\\((.*)\\)");

  List<String> ids = [];
  List<String> getter = [];
  List<ALIcuMethod> formattingList = [];
  bool _useIntlImport = false;

  LocalizationBaseLangVisitor();

  bool get useIntlImport => _useIntlImport;

  @override
  visitMethodDeclaration(MethodDeclaration node) {
    final superClassName = node
        .thisOrAncestorOfType<ClassDeclaration>()
        ?.extendsClause
        ?.superclass
        .toString();
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

class LocalizationClassVisitor extends RecursiveAstVisitor {
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
