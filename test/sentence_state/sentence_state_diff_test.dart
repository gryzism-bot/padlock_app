import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/subjects/adjectives/colors.dart';
import 'package:padlock_app/data/subjects/adjectives/size.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart'
    as fixed_object;
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart'
    as object_data;
import 'package:padlock_app/data/subjects/third_person/people.dart'
    as people_data;
import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/education.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';
import 'package:padlock_app/models/sentence/sentence_state_diff.dart';

void main() {
  group('SentenceStateDiff', () {
    test('treats identical states as solved', () {
      const state = SentenceState(
        agent: you,
        action: learn,
        tense: Tense.present,
        aspect: Aspect.simple,
      );

      final diff = SentenceStateDiff.between(current: state, target: state);

      expect(diff.isSolved, isTrue);
      expect(diff.remainingMoves, 0);
      expect(diff.fields, isEmpty);
    });

    test('reports basic predicate, object, and tense differences', () {
      const current = SentenceState(
        agent: you,
        action: learn,
        tense: Tense.present,
        aspect: Aspect.simple,
      );
      final target = SentenceState(
        agent: you,
        action: read,
        object: object_data.book.toNounPhrase(Number.singular),
        tense: Tense.future,
        aspect: Aspect.simple,
      );

      final diff = SentenceStateDiff.between(current: current, target: target);

      expect(diff.isSolved, isFalse);
      expect(diff.remainingMoves, 3);
      expect(diff.differingFields, [
        SentenceStateField.action,
        SentenceStateField.object,
        SentenceStateField.tense,
      ]);
      expect(diff.diffFor(SentenceStateField.action)?.current, 'learn');
      expect(diff.diffFor(SentenceStateField.action)?.target, 'read');
    });

    test('treats noun modifiers as part of noun field identity', () {
      final current = SentenceState(
        agent: you,
        action: read,
        object: object_data.book.toNounPhrase(Number.singular),
        tense: Tense.present,
        aspect: Aspect.simple,
      );
      final target = SentenceState(
        agent: you,
        action: read,
        object: object_data.book.toNounPhrase(
          Number.singular,
          determiner: theDeterminer,
          adjectives: const [big, white],
        ),
        tense: Tense.present,
        aspect: Aspect.simple,
      );

      final diff = SentenceStateDiff.between(current: current, target: target);

      expect(diff.remainingMoves, 1);
      expect(diff.differs(SentenceStateField.object), isTrue);
      expect(diff.diffFor(SentenceStateField.object)?.target, contains('the'));
      expect(diff.diffFor(SentenceStateField.object)?.target, contains('big'));
      expect(
        diff.diffFor(SentenceStateField.object)?.target,
        contains('white'),
      );
    });

    test('reports right-hand chain fields independently', () {
      const current = SentenceState(
        agent: you,
        action: learn,
        tense: Tense.present,
        aspect: Aspect.simple,
      );
      final target = SentenceState(
        agent: you,
        action: learn,
        object: fixed_object.english,
        companion: people_data.mary.toNounPhrase(Number.singular),
        rightAction: speak,
        tense: Tense.present,
        aspect: Aspect.simple,
      );

      final diff = SentenceStateDiff.between(current: current, target: target);

      expect(diff.remainingMoves, 3);
      expect(
        diff.differingFields,
        containsAll([
          SentenceStateField.object,
          SentenceStateField.companion,
          SentenceStateField.rightAction,
        ]),
      );
      expect(diff.diffFor(SentenceStateField.rightAction)?.target, 'speak');
    });

    test('goal wrapper exposes solved and remaining move checks', () {
      final target = SentenceState(
        agent: people_data.mary.toNounPhrase(Number.singular),
        action: teach,
        object: fixed_object.english,
        tense: Tense.present,
        aspect: Aspect.simple,
      );
      const current = SentenceState(
        agent: you,
        action: learn,
        tense: Tense.present,
        aspect: Aspect.simple,
      );

      final goal = SentenceStateGoal(target);

      expect(goal.isSolvedBy(current), isFalse);
      expect(goal.remainingMovesFrom(current), 3);
      expect(goal.isSolvedBy(target), isTrue);
    });

    test('tracks passive display and modal fields', () {
      final current = SentenceState(
        agent: you,
        action: see,
        object: people_data.mary.toNounPhrase(Number.singular),
        tense: Tense.past,
        aspect: Aspect.simple,
      );
      final target = SentenceState(
        agent: you,
        action: see,
        object: people_data.mary.toNounPhrase(Number.singular),
        voice: Voice.passive,
        passiveFocus: PassiveFocus.object,
        showPassiveAgent: false,
        modal: should,
        polarity: Polarity.negative,
        tense: Tense.past,
        aspect: Aspect.simple,
      );

      final diff = SentenceStateDiff.between(current: current, target: target);

      expect(
        diff.differingFields,
        containsAll([
          SentenceStateField.voice,
          SentenceStateField.passiveFocus,
          SentenceStateField.showPassiveAgent,
          SentenceStateField.modal,
          SentenceStateField.polarity,
        ]),
      );
      expect(diff.diffFor(SentenceStateField.modal)?.target, 'should');
    });
  });
}
