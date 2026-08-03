import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/phrases/manner_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/education.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

void main() {
  group('SentenceState.copyWith', () {
    test('preserves fields that are not mentioned', () {
      final original = SentenceState(
        agent: you,
        action: learn,
        object: english,
        rightAction: speak,
        rightParticle: upMannerPhrase,
        mannerPhrase: carefullyMannerPhrase,
        timePhrase: todayTimePhrase,
        tense: Tense.present,
        aspect: Aspect.simple,
      );

      final changed = original.copyWith(action: teach);

      expect(changed.agent, you);
      expect(changed.action, teach);
      expect(changed.object, english);
      expect(changed.rightAction, speak);
      expect(changed.rightParticle, upMannerPhrase);
      expect(changed.mannerPhrase, carefullyMannerPhrase);
      expect(changed.timePhrase, todayTimePhrase);
      expect(changed.tense, Tense.present);
      expect(changed.aspect, Aspect.simple);
    });

    test('can explicitly clear nullable fields', () {
      final original = SentenceState(
        agent: you,
        action: learn,
        object: english,
        rightAction: speak,
        rightParticle: upMannerPhrase,
        mannerPhrase: carefullyMannerPhrase,
        timePhrase: todayTimePhrase,
        tense: Tense.present,
        aspect: Aspect.simple,
      );

      final changed = original.copyWith(
        object: null,
        rightAction: null,
        rightParticle: null,
        mannerPhrase: null,
        timePhrase: null,
      );

      expect(changed.agent, you);
      expect(changed.action, learn);
      expect(changed.object, isNull);
      expect(changed.rightAction, isNull);
      expect(changed.rightParticle, isNull);
      expect(changed.mannerPhrase, isNull);
      expect(changed.timePhrase, isNull);
    });
  });
}
