import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/predicate/fixed_object_frames.dart';
import 'package:padlock_app/data/predicate/predicate_paths.dart';
import 'package:padlock_app/data/predicate/verb_influence.dart';
import 'package:padlock_app/data/verbs/essential.dart';

void main() {
  group('Configuration law map', () {
    List<PredicateInfluence> influencesFor(String infinitive) {
      return predicateInfluencesFor(
        verbs.singleWhere((verb) => verb.infinitive == infinitive),
      );
    }

    test('recipient-capable verbs are also object-capable', () {
      final offenders = verbs
          .where((verb) => verb.takesRecipient && !verb.takesObject)
          .map((verb) => verb.infinitive)
          .toList();

      expect(offenders, isEmpty);
    });

    test('transitive and ditransitive wakes are grammar frame laws', () {
      final influences = influencesFor('give');

      expect(
        influences.where(
          (influence) =>
              influence.key == 'object' &&
              influence.source == PredicateInfluenceSource.grammarFrame,
        ),
        isNotEmpty,
      );
      expect(
        influences.where(
          (influence) =>
              influence.key == 'recipient' &&
              influence.source == PredicateInfluenceSource.grammarFrame,
        ),
        isNotEmpty,
      );
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

    test('companion wakes are predicate property laws', () {
      final influences = influencesFor('work');

      expect(
        influences.where(
          (influence) =>
              influence.key == 'companion' &&
              influence.source == PredicateInfluenceSource.predicateProperty,
        ),
        isNotEmpty,
      );
    });

    test('destination-capable verbs expose destination influence', () {
      final offenders = verbs
          .where((verb) => verb.usesDestinationPlace)
          .where(
            (verb) => predicateInfluencesFor(
              verb,
            ).every((influence) => influence.key != 'destination'),
          )
          .map((verb) => verb.infinitive)
          .toList();

      expect(offenders, isEmpty);
    });

    test('destination wakes are predicate property laws', () {
      final influences = influencesFor('go');

      expect(
        influences.where(
          (influence) =>
              influence.key == 'destination' &&
              influence.source == PredicateInfluenceSource.predicateProperty,
        ),
        isNotEmpty,
      );
    });

    test('fixed object frames are predicate property laws', () {
      final expectedLabels = {
        'play': 'activity',
        'learn': 'subject',
        'study': 'subject',
        'teach': 'subject',
        'speak': 'language',
        'read': 'text',
        'write': 'text',
        'use': 'tool',
        'watch': 'media',
        'drive': 'vehicle',
        'ride': 'vehicle',
        'open': 'openable',
        'close': 'openable',
      };

      for (final entry in expectedLabels.entries) {
        final action = verbs.singleWhere(
          (verb) => verb.infinitive == entry.key,
        );

        expect(fixedObjectFrameLabel(action), entry.value);
        expect(fixedObjectChoicesFor(action), isNotEmpty);
        expect(
          predicateInfluencesFor(action).where(
            (influence) =>
                influence.key == entry.value &&
                influence.source == PredicateInfluenceSource.predicateProperty,
          ),
          isNotEmpty,
        );
      }
    });

    test('authored predicate paths surface as predicate influences', () {
      for (final unlocks in guidedPredicateUnlocks) {
        final influences = predicateInfluencesFor(unlocks.verb);
        final influenceKeys = influences.map((influence) => influence.key);

        for (final path in unlocks.paths) {
          final expectedKey = switch (path.kind) {
            PredicatePathKind.directObject =>
              fixedObjectFrameLabel(unlocks.verb) ?? 'object',
            PredicatePathKind.toRightAction => 'right-action',
            PredicatePathKind.toRecipient => 'recipient',
            PredicatePathKind.toAddressee => 'addressee',
            PredicatePathKind.withCompanion => 'companion',
            PredicatePathKind.toDestination => 'destination',
            PredicatePathKind.aboutTopic => 'topic',
            PredicatePathKind.forBeneficiary => 'beneficiary',
            PredicatePathKind.fromSource => 'source',
            PredicatePathKind.placePhrase => 'place',
            PredicatePathKind.timePhrase => 'time',
            PredicatePathKind.frequencyPhrase => 'frequency',
            PredicatePathKind.mannerPhrase => 'manner',
          };

          expect(
            influenceKeys,
            contains(expectedKey),
            reason: '${unlocks.verb.infinitive} ${path.kind}',
          );
        }
      }
    });
  });
}
