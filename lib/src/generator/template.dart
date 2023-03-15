import 'package:applanga_flutter/src/generator/generator.dart';

// parts took out from flutter_tools/lib/src/localizations/gen_l10n_templates.dart
// https://github.com/flutter/flutter/blob/5848a1620deaf00cfc31be9957a8388bd6894803/packages/flutter_tools/lib/src/localizations/gen_l10n_templates.dart

String generateAppLocalizationClass(
    String className,
    String baseLanguage,
    List<String>? baseGroups,
    List<String>? baseLanguages,
    List<String> ids,
    List<String> getters,
    List<ALIcuMethod> icuMethods,
    bool useIntlImport) {
  return """
import 'package:applanga_flutter/applanga_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
${useIntlImport ? "import 'package:intl/intl.dart' as intl;" : ''}

// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unused_local_variable
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
  static const List<Locale> supportedLocales =
      AppLocalizations.supportedLocales;
      
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

  @override
  Future<AppLocalizations> load(Locale locale) async {
    var result = $className(locale);
    await ApplangaFlutter.instance.setMetaData(locale,'$baseLanguage', 
    _keys,
      ${baseGroups == null ? '' : 'groups: _groups,'}
      ${baseLanguages == null ? '' : 'languages: _languages'}
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
