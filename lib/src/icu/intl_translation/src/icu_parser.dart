// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Contains a parser for ICU format plural/gender/select format for localized
/// messages. See extract_to_arb.dart and make_hardcoded_translation.dart.

import 'package:applanga_flutter/src/icu/icu_types.dart';
import 'package:petitparser/petitparser.dart';

/// This defines a grammar for ICU MessageFormat syntax. Usage is
///       new IcuParser.message.parse(<string>).value;
/// The "parse" method will return a Success or Failure object which responds
/// to "value".
class IcuParser {
  Parser get openCurly => char('{');

  Parser get closeCurly => char('}');

  Parser get quotedCurly => (string("'{'") | string("'}'")).map((x) => x[1]);

  Parser get icuEscapedText => quotedCurly | twoSingleQuotes;

  Parser get curly => (openCurly | closeCurly);

  Parser get notAllowedInIcuText => curly | char('<');

  Parser get icuText => notAllowedInIcuText.neg();

  Parser get notAllowedInNormalText => char('{');

  Parser get normalText => notAllowedInNormalText.neg();

  Parser get messageText => (icuEscapedText | icuText)
      .plus()
      .flatten()
      .map((result) => IcuLiteralElement(result));

  Parser get nonIcuMessageText =>
      normalText.plus().flatten().map((result) => IcuLiteralElement(result));

  Parser get twoSingleQuotes => string("''").map((x) => "'");

  Parser get number => digit().plus().flatten().trim().map(int.parse);

  Parser get id => (letter() & (word() | char('_')).star()).flatten().trim();

  Parser get comma => char(',').trim();

  /// Given a list of possible keywords, return a rule that accepts any of them.
  /// e.g., given ["male", "female", "other"], accept any of them.
  Parser asKeywords(List<String> list) =>
      list.map(string).cast<Parser>().reduce((a, b) => a | b).flatten().trim();

  Parser get pluralKeyword => asKeywords(
      ['=0', '=1', '=2', 'zero', 'one', 'two', 'few', 'many', 'other']);

  Parser get genderKeyword => asKeywords(['female', 'male', 'other']);

  var interiorText = undefined();

  Parser get preface => (openCurly & id & comma).map((values) => values[1]);

  Parser get pluralLiteral => string('plural');

  Parser get pluralClause => (pluralKeyword &
          openCurly &
          interiorText &
          closeCurly)
      .trim()
      .map((result) => IcuOption(
          result[0],
          List<IcuBaseElement>.from(
              result[2] is List ? result[2] : [result[2]])));

  Parser get plural =>
      preface & pluralLiteral & comma & pluralClause.plus() & closeCurly;

  Parser get intlPlural => plural.map((values) =>
      IcuPluralElement(values.first, List<IcuOption>.from(values[3])));

  Parser get selectLiteral => string('select');

  Parser get genderClause => (genderKeyword &
          openCurly &
          interiorText &
          closeCurly)
      .trim()
      .map((result) => IcuOption(
          result[0],
          List<IcuBaseElement>.from(
              result[2] is List ? result[2] : [result[2]])));

  Parser get gender =>
      preface & selectLiteral & comma & genderClause.plus() & closeCurly;

  Parser get intlGender => gender.map((values) =>
      IcuGenderElement(values.first, List<IcuOption>.from(values[3])));

  Parser get selectClause => (id & openCurly & interiorText & closeCurly)
      .trim()
      .map((values) => IcuOption(
          values.first,
          List<IcuBaseElement>.from(
              values[2] is List ? values[2] : [values[2]])));

  Parser get generalSelect =>
      preface & selectLiteral & comma & selectClause.plus() & closeCurly;

  Parser get intlSelect => generalSelect.map((values) =>
      IcuSelectElement(values.first, List<IcuOption>.from(values[3])));

  Parser get pluralOrGenderOrSelect => intlPlural | intlGender | intlSelect;

  Parser get contents => pluralOrGenderOrSelect | parameter | messageText;

  Parser get simpleText => (nonIcuMessageText | parameter).plus();

  Parser get empty => epsilon().map((_) => IcuLiteralElement(''));

  Parser get parameter => (openCurly & id & closeCurly)
      .map((param) => IcuArgumentElement(param[1]));

  Parser get icuMessage =>
      (((nonIcuMessageText | parameter).plus() &
              pluralOrGenderOrSelect &
              (nonIcuMessageText | parameter | pluralOrGenderOrSelect).star()) |
          (pluralOrGenderOrSelect | nonIcuMessageText | parameter).plus()) |
      pluralOrGenderOrSelect |
      simpleText |
      empty;

  IcuParser() {
    // There is a cycle here, so we need the explicit set to avoid
    // infinite recursion.
    interiorText.set(contents.plus() | empty);
  }
}
