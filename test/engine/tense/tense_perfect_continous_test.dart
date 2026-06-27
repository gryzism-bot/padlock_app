import 'package:flutter_test/flutter_test.dart';

import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/models/grammar/voice.dart';

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
    group('Perfect Continuous', () {
      test('Present Perfect Continuous - statement', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
          voice: Voice.active,
        );

        expect(grammarEngine.generate(state).text, 'He has been working.');
      });

      test('Past Perfect Continuous - statement', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.past,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
          voice: Voice.active,
        );

        expect(grammarEngine.generate(state).text, 'He had been working.');
      });

      test('Future Perfect Continuous - statement', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.future,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
          voice: Voice.active,
        );

        expect(
          grammarEngine.generate(state).text,
          'He will have been working.',
        );
      });

      test('Present Perfect Continuous - negative', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.statement,
          voice: Voice.active,
        );

        expect(grammarEngine.generate(state).text, 'He has not been working.');
      });

      test('Past Perfect Continuous - negative', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.past,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.statement,
          voice: Voice.active,
        );

        expect(grammarEngine.generate(state).text, 'He had not been working.');
      });

      test('Future Perfect Continuous - negative', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.future,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.statement,
          voice: Voice.active,
        );

        expect(
          grammarEngine.generate(state).text,
          'He will not have been working.',
        );
      });

      test('Present Perfect Continuous - question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.question,
          voice: Voice.active,
        );

        expect(grammarEngine.generate(state).text, 'Has he been working?');
      });

      test('Past Perfect Continuous - question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.past,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.question,
          voice: Voice.active,
        );

        expect(grammarEngine.generate(state).text, 'Had he been working?');
      });

      test('Future Perfect Continuous - question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.future,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.question,
          voice: Voice.active,
        );

        expect(
          grammarEngine.generate(state).text,
          'Will he have been working?',
        );
      });

      test('Present Perfect Continuous - negative question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
          voice: Voice.active,
        );

        expect(grammarEngine.generate(state).text, 'Has he not been working?');
      });

      test('Past Perfect Continuous - negative question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.past,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
          voice: Voice.active,
        );

        expect(grammarEngine.generate(state).text, 'Had he not been working?');
      });

      test('Future Perfect Continuous - negative question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.future,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
          voice: Voice.active,
        );

        expect(
          grammarEngine.generate(state).text,
          'Will he not have been working?',
        );
      });

      test('Present Perfect Continuous - exclamation', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.exclamation,
          voice: Voice.active,
        );

        expect(grammarEngine.generate(state).text, 'He has been working!');
      });

      test('Past Perfect Continuous - exclamation', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.past,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.exclamation,
          voice: Voice.active,
        );

        expect(grammarEngine.generate(state).text, 'He had been working!');
      });

      test('Future Perfect Continuous - exclamation', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.future,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.exclamation,
          voice: Voice.active,
        );

        expect(
          grammarEngine.generate(state).text,
          'He will have been working!',
        );
      });

      test('Present Perfect Continuous - plural subject', () {
        final state = SentenceState(
          subject: they,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
          voice: Voice.active,
        );

        expect(grammarEngine.generate(state).text, 'They have been working.');
      });

      test('Present Perfect Continuous - irregular verb', () {
        final state = SentenceState(
          subject: he,
          verb: go,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
          voice: Voice.active,
        );

        expect(grammarEngine.generate(state).text, 'He has been going.');
      });

      test('Past Perfect Continuous - irregular verb', () {
        final state = SentenceState(
          subject: they,
          verb: go,
          tense: Tense.past,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
          voice: Voice.active,
        );

        expect(grammarEngine.generate(state).text, 'They had been going.');
      });
    });
  });
}
