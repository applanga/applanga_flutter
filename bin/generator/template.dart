// parts took out from flutter_tools/lib/src/localizations/gen_l10n_templates.dart
// https://github.com/flutter/flutter/blob/5848a1620deaf00cfc31be9957a8388bd6894803/packages/flutter_tools/lib/src/localizations/gen_l10n_templates.dart

import 'generator.dart';

String generateAppLocalizationClass(
    String appLocalizationImport,
    String className,
    String baseLanguage,
    String? branchId,
    List<String>? baseGroups,
    List<String>? baseLanguages,
    Map<String, List<String>>? customLanguageFallback,
    bool getDynamicStrings,
    List<String> ids,
    List<String> getters,
    List<ALIcuMethod> icuMethods,
    bool useIntlImport,
    List<String> supportedLocalesDeclarations) {
  return """
import 'package:applanga_flutter/applanga_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
${useIntlImport ? "import 'package:intl/intl.dart' as intl;" : ''}
import '$appLocalizationImport';

// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unused_local_variable
// ignore_for_file: no_leading_underscores_for_local_identifiers
class $className extends AppLocalizations {
  final AppLocalizations _original;

  $className(locale)
      : _original = lookupAppLocalizations(locale),
        super(locale.toString());

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _${className}Delegate();
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];
  static Locale localeListResolutionCallback(locales, supportedLocales) =>
      ApplangaFlutter.localeListResolutionCallback(locales, supportedLocales);
      
  static const List<Locale> supportedLocales = <Locale>[
    Locale('$baseLanguage'),
    ${supportedLocalesDeclarations.where((e) => e != "Locale('$baseLanguage')").join(",\n")}
  ];
      
${getters.map((id) => """
  @override
  String get $id =>
    ApplangaFlutter.instance.getIcuString(
        '$id')?? _original.$id;
  
""").toList().join("\n")}

${icuMethods.map((method) => """
  @override
  String ${method.nameWithParams} {
    ${method.body}
    return ApplangaFlutter.instance.getIcuString(
            '${method.name}', 
            {${method.originalParams.entries.map((paramEntry) => '\'${paramEntry.key}\': ${paramEntry.value}').join(', ')}}
${method.formattedParams != null ? ",{${method.formattedParams!.entries.map((paramEntry) => '\'${paramEntry.key}\': ${paramEntry.value}').join(', ')}}" : ""})
            ?? _original.${method.name}(${method.originalParams.entries.map((paramEntry) => paramEntry.key).toList().join(", ")});
  }
""").toList().join("\n")} 

}

class _${className}Delegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _${className}Delegate();
  
  static const _keys = [${ids.map((id) => '\'$id\'').join(',\n')}];
  ${(baseGroups != null) ? "static const _groups = [${baseGroups.map((group) => '\'$group\'').join(',\n')}];" : ""}
  ${baseLanguages != null ? "static const _languages = [${baseLanguages.map((lang) => '\'$lang\'').join(',\n')}];" : ""}
  ${customLanguageFallback != null ? "static const _customLanguageFallback = {${customLanguageFallback.entries.map((entry) => '\'${entry.key}\': [${entry.value.map((lang) => '\'$lang\'').join(",")}]').join(",\n")}};" : ""}

  @override
  Future<AppLocalizations> load(Locale locale) async {
    var result = $className(locale);
    await ApplangaFlutter.instance.setMetaData(locale,'$baseLanguage', 
    ${branchId != null ? "'$branchId'" : "null"},
    _keys,
      ${baseGroups == null ? '' : 'groups: _groups,'}
      ${baseLanguages == null ? '' : 'languages: _languages,'}
      ${customLanguageFallback == null ? '' : 'customLanguageFallback: _customLanguageFallback,'}
      getDynamicStrings: $getDynamicStrings
      );
    await ApplangaFlutter.instance.loadLocaleAndUpdate(locale);
    return result;
  }

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.delegate.isSupported(locale);

  @override
  bool shouldReload(_${className}Delegate old) => false;
}
 
""";
}
