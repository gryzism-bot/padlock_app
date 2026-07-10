import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/verbs/essential.dart';

void main() {
  group('Configuration law map', () {
    test('recipient-capable verbs are also object-capable', () {
      final offenders = verbs
          .where((verb) => verb.takesRecipient && !verb.takesObject)
          .map((verb) => verb.infinitive)
          .toList();

      expect(offenders, isEmpty);
    });
  });
}
