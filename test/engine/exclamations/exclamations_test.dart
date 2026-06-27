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
    group('Exclamations', () {
      test('Present Simple exclamation', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.exclamation,
        );

        expect(grammarEngine.generate(state).text, 'He works!');
      });

      test('Past Simple exclamation', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.past,
          aspect: Aspect.simple,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.exclamation,
        );

        expect(grammarEngine.generate(state).text, 'He worked!');
      });

      test('Future Simple exclamation', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.future,
          aspect: Aspect.simple,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.exclamation,
        );

        expect(grammarEngine.generate(state).text, 'He will work!');
      });

      test('Present Continuous exclamation', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.continuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.exclamation,
        );

        expect(grammarEngine.generate(state).text, 'He is working!');
      });

      test('Past Continuous exclamation', () {
        final state = SentenceState(
          subject: they,
          verb: work,
          tense: Tense.past,
          aspect: Aspect.continuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.exclamation,
        );

        expect(grammarEngine.generate(state).text, 'They were working!');
      });

      test('Future Continuous exclamation', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.future,
          aspect: Aspect.continuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.exclamation,
        );

        expect(grammarEngine.generate(state).text, 'He will be working!');
      });

      test('Present Perfect exclamation', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.exclamation,
        );

        expect(grammarEngine.generate(state).text, 'He has worked!');
      });

      test('Past Perfect exclamation', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.past,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.exclamation,
        );

        expect(grammarEngine.generate(state).text, 'He had worked!');
      });

      test('Future Perfect exclamation', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.future,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.exclamation,
        );

        expect(grammarEngine.generate(state).text, 'He will have worked!');
      });

      test('Present Perfect Continuous exclamation', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.exclamation,
        );

        expect(grammarEngine.generate(state).text, 'He has been working!');
      });

      test('Past Perfect Continuous exclamation', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.past,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.exclamation,
        );

        expect(grammarEngine.generate(state).text, 'He had been working!');
      });

      test('Future Perfect Continuous exclamation', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.future,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.exclamation,
        );

        expect(
          grammarEngine.generate(state).text,
          'He will have been working!',
        );
      });

      test('Present Simple exclamation - plural subject', () {
        final state = SentenceState(
          subject: they,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.exclamation,
        );

        expect(grammarEngine.generate(state).text, 'They work!');
      });

      test('Present Perfect exclamation - irregular verb', () {
        final state = SentenceState(
          subject: he,
          verb: go,
          tense: Tense.present,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.exclamation,
        );

        expect(grammarEngine.generate(state).text, 'He has gone!');
      });

      test('Present Perfect Continuous exclamation - irregular verb', () {
        final state = SentenceState(
          subject: he,
          verb: go,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.exclamation,
        );

        expect(grammarEngine.generate(state).text, 'He has been going!');
      });
    });
  });
}
