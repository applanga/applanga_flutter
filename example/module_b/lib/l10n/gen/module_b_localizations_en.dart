// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'module_b_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ModuleBLocalizationsEn extends ModuleBLocalizations {
  ModuleBLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome => 'Welcome to Module B!';

  @override
  String get description =>
      'This is a sample module demonstrating how to implement modular localizations in Flutter.';
}
