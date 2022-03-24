// Import the test package and Counter class
import 'package:applanga_flutter/applanga_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('icu translations', () {
    group('plurals', () {
      test('Should return the correct translations, count: 0', () {
        String pluralString =
            "{count, plural,=0{no apples left} =1{only one apple left}=2{exact two apples left}few{{count} apples left, only a few}many{so many: {count} apples left}other{bunch of apples left: {count}}}";
        String pluralString2 =
            "{count, plural,zero{no apples left} one{only one apple left} two{exact two apples left}few{{count} apples left, only a few}many{so many: {count} apples left}other{bunch of apples left: {count}}}";
        final icuString1 = IcuString("pluralString", pluralString);
        final icuString2 = IcuString("pluralString2", pluralString2);
        expect(
            icuString1.getTranslation({
              'count': 0,
            }),
            'no apples left');
        expect(
            icuString2.getTranslation({
              'count': 0,
            }),
            'no apples left');
      });
      test('Should return the correct translations, count: 1', () {
        String pluralString =
            "{count, plural,=0{no apples left} =1{only {count} apple left}=2{exact two apples left}few{{count} apples left, only a few}many{so many: {count} apples left}other{bunch of apples left: {count}}}";
        String pluralString2 =
            "{count, plural,zero{no apples left} one{only {count} apple left} two{exact two apples left}few{{count} apples left, only a few}many{so many: {count} apples left}other{bunch of apples left: {count}}}";
        final icuString1 = IcuString("pluralString", pluralString);
        final icuString2 = IcuString("pluralString2", pluralString2);

        expect(
            icuString1.getTranslation({
              'count': 1,
            }),
            'only 1 apple left');
        expect(
            icuString2.getTranslation({
              'count': 1,
            }),
            'only 1 apple left');
      });

      test('Should return the correct translations, count: 2', () {
        String pluralString =
            "{count, plural,=0{no apples left} =1{only one apple left}=2{exact two apples left}few{{count} apples left, only a few}many{so many: {count} apples left}other{bunch of apples left: {count}}}";
        String pluralString2 =
            "{count, plural,zero{no apples left} one{only one apple left} two{exact two apples left}few{{count} apples left, only a few}many{so many: {count} apples left}other{bunch of apples left: {count}}}";
        final icuString1 = IcuString("pluralString", pluralString);
        final icuString2 = IcuString("pluralString2", pluralString2);

        expect(
            icuString1.getTranslation({
              'count': 2,
            }),
            'exact two apples left');
        expect(
            icuString2.getTranslation({
              'count': 2,
            }),
            'exact two apples left');
      });

      test('Should insert argument correctly', () {
        String pluralString =
            "{count, plural,=0{no apples left for {name}} =1{only one apple left}=2{exact two apples left}few{{count} apples left, only a few}many{so many: {count} apples left}other{bunch of apples left: {count}}}";
        String pluralString2 =
            "{count, plural,zero{no apples left for {name}} one{only one apple left} two{exact two apples left}few{{count} apples left, only a few}many{so many: {count} apples left}other{bunch of apples left: {count}}}";
        final icuString1 = IcuString("pluralString", pluralString);
        final icuString2 = IcuString("pluralString2", pluralString2);

        expect(icuString1.getTranslation({'count': 0, 'name': 'you'}),
            'no apples left for you');
        expect(icuString2.getTranslation({'count': 0, 'name': 'you'}),
            'no apples left for you');
      });
    });
    group('gender', () {
      test('Should return the correct translations: male', () {
        String genderString =
            '{gender, select, male {one man} female {one woman} other {one person}}';
        final icuString = IcuString("genderString", genderString);
        expect(
            icuString.getTranslation({
              'gender': 'male',
            }),
            'one man');
      });
      test('Should return the correct translations: female', () {
        String genderString =
            '{gender, select, male {one man} female {one woman} other {one person}}';
        final icuString = IcuString("genderString", genderString);
        expect(
            icuString.getTranslation({
              'gender': 'female',
            }),
            'one woman');
      });
      test('Should return the correct translations: other', () {
        String genderString =
            '{gender, select, male {one man} female {one woman} other {one person}}';
        final icuString = IcuString("genderString", genderString);
        expect(
            icuString.getTranslation({
              'gender': 'other',
            }),
            'one person');
      });
      test('Should insert arguments', () {
        String genderString =
            '{gender, select, male {you are {name} {gender}} female {one woman} other {one person}}';
        final icuString = IcuString("genderString", genderString);
        expect(
            icuString.getTranslation({
              'gender': 'male',
              'name': 'a cool',
            }),
            'you are a cool male');
      });
    });
    group('select', () {
      test('Should return the correct translations: apple', () {
        String selectString =
            '{fruitType, select, apple{{fruitType} is nice} banana{monkeys love {fruitType}s} cherry{{fruitType} is red} other{{fruitType} are interesing as well}}';
        final icuString = IcuString("selectString", selectString);
        expect(
            icuString.getTranslation({
              'fruitType': 'apple',
            }),
            'apple is nice');
      });
      test('Should return the correct translations: banana', () {
        String selectString =
            '{fruitType, select, apple{{fruitType} is nice} banana{monkeys love {fruitType}s} cherry{{fruitType} is red} other{{fruitType} are interesing as well}}';
        final icuString = IcuString("selectString", selectString);
        expect(
            icuString.getTranslation({
              'fruitType': 'banana',
            }),
            'monkeys love bananas');
      });
      test('Should insert arguments', () {
        String selectString =
            '{fruitType, select, apple{{name} likes {fruitType}} banana{monkeys love {fruitType}s} cherry{{fruitType} is red} other{{fruitType} are interesing as well for {name}}}';
        final icuString = IcuString("selectString", selectString);
        expect(icuString.getTranslation({'fruitType': 'other', 'name': 'you'}),
            'other are interesing as well for you');
      });
    });
    group("combined", () {
      test('should resolve plural in normal argument string', () {
        String s =
            "{name} has {count, plural,=0{no cats} =1{one cat} other{{count} cats}} !";

        final icuString = IcuString("s", s);
        expect(icuString.getTranslation({'count': 0, 'name': 'He'}),
            'He has no cats !');
      });
      test('should resolve combined string with two plurals ', () {
        String s =
            "{name} has {count, plural,=0{no cats} =1{one cat} other{{count} cats}}, {dogCount, plural,=0{no dogs} =1{one dog} other{{dogCount} dogs}}!";
        final icuString = IcuString("s", s);
        expect(
            icuString.getTranslation({'count': 0, 'dogCount': 1, 'name': 'He'}),
            'He has no cats, one dog!');
      });
    });
    group("special formats", () {
      test('empty string should return empty string', () {
        String s = '';
        final icuString = IcuString('s', s);
        expect(icuString.getTranslation({}), '');
      });

      test('malformed plural icu string', () {
        String s = '{plural,=0{no cats} =1{one cat} other{{count} cats}}';
        final icuString = IcuString('s', s);
        expect(icuString.getTranslation({}), '');
      });
    });
  });
}
