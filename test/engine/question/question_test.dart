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
    group('Questions', () {
      test('Present Simple question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Does he work?');
      });

      test('Past Simple question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.past,
          aspect: Aspect.simple,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Did he work?');
      });

      test('Future Simple question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.future,
          aspect: Aspect.simple,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Will he work?');
      });

      test('Present Continuous question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.continuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Is he working?');
      });

      test('Past Continuous question', () {
        final state = SentenceState(
          subject: they,
          verb: work,
          tense: Tense.past,
          aspect: Aspect.continuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Were they working?');
      });

      test('Future Continuous question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.future,
          aspect: Aspect.continuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Will he be working?');
      });

      test('Present Perfect question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Has he worked?');
      });

      test('Past Perfect question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.past,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Had he worked?');
      });

      test('Future Perfect question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.future,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Will he have worked?');
      });

      test('Present Perfect Continuous question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Has he been working?');
      });

      test('Past Perfect Continuous question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.past,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Had he been working?');
      });

      test('Future Perfect Continuous question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.future,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.question,
        );

        expect(
          grammarEngine.generate(state).text,
          'Will he have been working?',
        );
      });

      test('Present Simple negative question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Does he not work?');
      });

      test('Past Simple negative question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.past,
          aspect: Aspect.simple,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Did he not work?');
      });

      test('Future Simple negative question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.future,
          aspect: Aspect.simple,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Will he not work?');
      });

      test('Present Continuous negative question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.continuous,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Is he not working?');
      });

      test('Past Continuous negative question', () {
        final state = SentenceState(
          subject: they,
          verb: work,
          tense: Tense.past,
          aspect: Aspect.continuous,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Were they not working?');
      });

      test('Future Continuous negative question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.future,
          aspect: Aspect.continuous,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Will he not be working?');
      });

      test('Present Perfect negative question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Has he not worked?');
      });

      test('Past Perfect negative question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.past,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Had he not worked?');
      });

      test('Future Perfect negative question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.future,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Will he not have worked?');
      });

      test('Present Perfect Continuous negative question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Has he not been working?');
      });

      test('Past Perfect Continuous negative question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.past,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        );

        expect(grammarEngine.generate(state).text, 'Had he not been working?');
      });

      test('Future Perfect Continuous negative question', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.future,
          aspect: Aspect.perfectContinuous,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        );

        expect(
          grammarEngine.generate(state).text,
          'Will he not have been working?',
        );
      });
    });
  });
}
