import 'package:applanga_flutter/src/icu/icu_types.dart';
import 'package:applanga_flutter/src/icu/intl_translation/src/icu_parser.dart';
import 'package:intl/intl.dart';
import 'package:petitparser/petitparser.dart';

IcuParser parser = IcuParser();

class IcuString {
  final String key;
  final String value;
  late final List<IcuBaseElement>? parsedContent;

  IcuString(this.key, this.value) {
    parsedContent = parseContent();
  }

  IcuString.fromJson(Map<String, dynamic> json)
      : key = json['key'],
        value = json['value'];

  Map<String, dynamic> toJson() => {'key': key, 'value': value};

  String? getTranslation(Map<String, Object> args,
      [Map<String, String>? formattedArgs]) {
    if (parsedContent == null) return null;
    var result = '';
    for (final element in parsedContent!) {
      switch (element.type) {
        case IcuElementType.literal:
          result += element.value;
          break;
        case IcuElementType.argument:
          result += formattedArgs?[element.value]?.toString() ??
              args[element.value]?.toString() ??
              '';
          break;
        case IcuElementType.plural:
          final pluralElement = element as IcuPluralElement;
          Map<String, String> pluralOptions =
              _normalizePluralOptions(pluralElement, args, formattedArgs);

          result += Intl.pluralLogic(args[element.value]! as num,
              zero: pluralOptions['zero'],
              one: pluralOptions['one'],
              two: pluralOptions['two'],
              few: pluralOptions['few'],
              many: pluralOptions['many'],
              other: pluralOptions['other'] ?? '');
          break;
        case IcuElementType.gender:
          final genderElement = element as IcuGenderElement;
          Map<String, String> genderOptions =
              _normalizeGenderOptions(genderElement, args, formattedArgs);

          result += Intl.genderLogic(args[element.value]! as String,
              male: genderOptions['male'],
              female: genderOptions['female'],
              other: genderOptions['other'] ?? '');
          break;
        case IcuElementType.select:
          final selectElement = element as IcuSelectElement;
          Map<String, String> options =
              _normalizeSelectOptions(selectElement, args, formattedArgs);
          result += Intl.selectLogic(args[element.value]!, options);
          break;
      }
    }
    return result;
  }

  Map<String, String> _normalizePluralOptions(IcuPluralElement pluralElement,
      Map<String, Object> args, Map<String, String>? formattedArgs) {
    final result = <String, String>{};
    for (final option in pluralElement.options) {
      final optionString = insertArgsToOption(option, args, formattedArgs);
      switch (option.name) {
        case "zero":
        case "=0":
          result["zero"] = optionString;
          break;
        case "one":
        case "=1":
          result["one"] = optionString;
          break;
        case "two":
        case "=2":
          result["two"] = optionString;
          break;
        case "few":
          result["few"] = optionString;
          break;
        case "many":
          result["many"] = optionString;
          break;
        case "other":
          result["other"] = optionString;
          break;
      }
    }
    return result;
  }

  _normalizeGenderOptions(IcuGenderElement genderElement,
      Map<String, Object> args, Map<String, String>? formattedArgs) {
    final result = <String, String>{};
    for (final option in genderElement.options) {
      final optionString = insertArgsToOption(option, args, formattedArgs);
      result[option.name] = optionString;
    }
    return result;
  }

  _normalizeSelectOptions(IcuSelectElement selectElement,
      Map<String, Object> args, Map<String, String>? formattedArgs) {
    final result = <String, String>{};
    for (final option in selectElement.options) {
      final optionString = insertArgsToOption(option, args, formattedArgs);
      result[option.name] = optionString;
    }
    return result;
  }

  String insertArgsToOption(IcuOption option, Map<String, Object> args,
      Map<String, String>? formattedArgs) {
    var result = '';
    for (final element in option.value) {
      switch (element.type) {
        case IcuElementType.literal:
          result += element.value;
          break;
        case IcuElementType.argument:
          result += formattedArgs?[element.value]?.toString() ??
              args[element.value]?.toString() ??
              '';
          break;
        default:
          break;
      }
    }
    return result;
  }

  List<IcuArgument> getArgs(List<IcuBaseElement> elements) {
    final result = <IcuArgument>[];

    // add to list but avoid duplicates
    void addArg(IcuArgument icuArgument) {
      if (!result.contains(icuArgument)) {
        result.add(icuArgument);
      }
    }

    // add all arguments from options to list
    // calls getArgs recursively as it's a nested structure
    void addArgFromOptions(List<IcuOption> options) {
      for (final option in options) {
        final arguments = getArgs(option.value);
        for (final argument in arguments) {
          addArg(argument);
        }
      }
    }

    for (final element in elements) {
      switch (element.type) {
        case IcuElementType.literal:
          break;
        case IcuElementType.plural:
          addArg(IcuArgument(element.value));
          addArgFromOptions((element as IcuPluralElement).options);
          break;
        case IcuElementType.gender:
          addArg(IcuArgument(element.value));
          addArgFromOptions((element as IcuGenderElement).options);
          break;
        case IcuElementType.select:
          addArg(IcuArgument(element.value));
          addArgFromOptions((element as IcuSelectElement).options);
          break;
        case IcuElementType.argument:
          addArg(IcuArgument(element.value));
          break;
      }
    }
    return result;
  }

  List<IcuBaseElement>? parseContent() {
    var parser = IcuParser();
    var parsed = parser.icuMessage
        .map((result) => List<IcuBaseElement>.from(
            // we have to flatten the list(s)
            (result is List ? result : [result])
                .expand((r) => r is List ? r : [r])
                .toList()))
        .parse(value);
    if (parsed is Success) {
      return parsed.value;
    } else {
      return null;
    }
  }
}
