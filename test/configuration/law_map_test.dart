import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/predicate/verb_influence.dart';
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

    test('companion-capable verbs expose companion influence', () {
      final offenders = verbs
          .where((verb) => verb.takesCompanion)
          .where(
            (verb) => predicateInfluencesFor(
              verb,
            ).every((influence) => influence.key != 'companion'),
          )
          .map((verb) => verb.infinitive)
          .toList();

      expect(offenders, isEmpty);
    });
  });
}
