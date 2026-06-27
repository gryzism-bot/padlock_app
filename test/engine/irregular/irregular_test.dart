import 'package:flutter_test/flutter_test.dart';

import 'package:padlock_app/engine/grammar_engine.dart';

import 'package:padlock_app/models/sentence/sentence_state.dart';

import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';

import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/verbs/essential.dart';

void main() {
  final grammarEngine = GrammarEngine();

  group('placeholder', () {
    group('Irregular verbs', () {
      test('Go - Present Simple', () {
        final state = SentenceState(
          subject: he,
          verb: go,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'He goes.');
      });

      test('Go - Past Simple', () {
        final state = SentenceState(
          subject: he,
          verb: go,
          tense: Tense.past,
          aspect: Aspect.simple,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'He went.');
      });

      test('Go - Future Simple', () {
        final state = SentenceState(
          subject: he,
          verb: go,
          tense: Tense.future,
          aspect: Aspect.simple,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'He will go.');
      });

      test('Go - Present Continuous', () {
        final state = SentenceState(
          subject: he,
          verb: go,
          tense: Tense.present,
          aspect: Aspect.continuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'He is going.');
      });

      test('Go - Past Continuous', () {
        final state = SentenceState(
          subject: he,
          verb: go,
          tense: Tense.past,
          aspect: Aspect.continuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'He was going.');
      });

      test('Go - Future Continuous', () {
        final state = SentenceState(
          subject: he,
          verb: go,
          tense: Tense.future,
          aspect: Aspect.continuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'He will be going.');
      });

      test('Go - Present Perfect', () {
        final state = SentenceState(
          subject: he,
          verb: go,
          tense: Tense.present,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'He has gone.');
      });

      test('Go - Past Perfect', () {
        final state = SentenceState(
          subject: he,
          verb: go,
          tense: Tense.past,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'He had gone.');
      });

      test('Go - Future Perfect', () {
        final state = SentenceState(
          subject: he,
          verb: go,
          tense: Tense.future,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'He will have gone.');
      });

      test('Go - Present Perfect Continuous', () {
        final state = SentenceState(
          subject: he,
          verb: go,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'He has been going.');
      });

      test('Go - Past Perfect Continuous', () {
        final state = SentenceState(
          subject: he,
          verb: go,
          tense: Tense.past,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'He had been going.');
      });

      test('Go - Future Perfect Continuous', () {
        final state = SentenceState(
          subject: he,
          verb: go,
          tense: Tense.future,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'He will have been going.');
      });

      test('Go - Present Perfect question', () {
        final state = SentenceState(
          subject: he,
          verb: go,
          tense: Tense.present,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Has he gone?');
      });

      test('Go - Present Perfect negative', () {
        final state = SentenceState(
          subject: he,
          verb: go,
          tense: Tense.present,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'He has not gone.');
      });

      test('Go - Future Perfect Continuous question', () {
        final state = SentenceState(
          subject: he,
          verb: go,
          tense: Tense.future,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Will he have been going?');
      });

      test('Go - Future Perfect Continuous negative', () {
        final state = SentenceState(
          subject: he,
          verb: go,
          tense: Tense.future,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.statement,
        );

        expect(
          grammarEngine.generate(state).text,
          'He will not have been going.',
        );
      });

      test('Go - Present Simple plural', () {
        final state = SentenceState(
          subject: they,
          verb: go,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'They go.');
      });

      test('Go - Present Continuous plural', () {
        final state = SentenceState(
          subject: they,
          verb: go,
          tense: Tense.present,
          aspect: Aspect.continuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'They are going.');
      });

      test('Go - Present Perfect plural', () {
        final state = SentenceState(
          subject: they,
          verb: go,
          tense: Tense.present,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'They have gone.');
      });
    });
  });
}
