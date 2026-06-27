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
    group('Perfect', () {
      test('Present Perfect - statement', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'He has worked.');
      });

      test('Past Perfect - statement', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.past,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'He had worked.');
      });

      test('Future Perfect - statement', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.future,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'He will have worked.');
      });

      test('Present Perfect - negative', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'He has not worked.');
      });

      test('Past Perfect - negative', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.past,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'He had not worked.');
      });

      test('Future Perfect - negative', () {
        final state = SentenceState(
          subject: he,
          verb: work,
          tense: Tense.future,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'He will not have worked.');
      });

      test('Present Perfect - question', () {
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

      test('Past Perfect - question', () {
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

      test('Future Perfect - question', () {
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

      test('Present Perfect - negative question', () {
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

      test('Past Perfect - negative question', () {
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

      test('Future Perfect - negative question', () {
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

      test('Present Perfect - exclamation', () {
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

      test('Past Perfect - exclamation', () {
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

      test('Future Perfect - exclamation', () {
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

      test('Present Perfect - plural subject', () {
        final state = SentenceState(
          subject: they,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'They have worked.');
      });

      test('Present Perfect - irregular verb', () {
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

      test('Past Perfect - irregular verb', () {
        final state = SentenceState(
          subject: they,
          verb: go,
          tense: Tense.past,
          aspect: Aspect.perfect,
          modal: Modal.none,
          polarity: Polarity.positive,
          sentenceForm: SentenceForm.statement,
        );

        expect(grammarEngine.generate(state).text, 'They had gone.');
      });
    });
  });
}
