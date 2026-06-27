import 'package:flutter_test/flutter_test.dart';

import 'package:padlock_app/engine/grammar_engine.dart';

import 'package:padlock_app/models/sentence/sentence_state.dart';

import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';

import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/verbs/verbs.dart';

void main() {
  final grammarEngine = GrammarEngine();

  group('Simple', () {
    test('Present Simple - statement', () {
      final state = SentenceState(
        subject: he,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'He works.');
    });

    test('Past Simple - statement', () {
      final state = SentenceState(
        subject: he,
        verb: work,
        tense: Tense.past,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'He worked.');
    });

    test('Future Simple - statement', () {
      final state = SentenceState(
        subject: he,
        verb: work,
        tense: Tense.future,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'He will work.');
    });

    test('Present Simple - negative', () {
      final state = SentenceState(
        subject: he,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'He does not work.');
    });

    test('Past Simple - negative', () {
      final state = SentenceState(
        subject: he,
        verb: work,
        tense: Tense.past,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'He did not work.');
    });

    test('Future Simple - negative', () {
      final state = SentenceState(
        subject: he,
        verb: work,
        tense: Tense.future,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'He will not work.');
    });

    test('Present Simple - question', () {
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

    test('Past Simple - question', () {
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

    test('Future Simple - question', () {
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

    test('Present Simple - negative question', () {
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

    test('Past Simple - negative question', () {
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

    test('Future Simple - negative question', () {
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

    test('Present Simple - exclamation', () {
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

    test('Past Simple - exclamation', () {
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

    test('Future Simple - exclamation', () {
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

    test('Present Simple - imperative', () {
      final state = SentenceState(
        subject: you,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.imperative,
      );

      expect(grammarEngine.generate(state).text, 'Work.');
    });

    test('Present Simple - negative imperative', () {
      final state = SentenceState(
        subject: you,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.imperative,
      );

      expect(grammarEngine.generate(state).text, 'Do not work.');
    });

    test('Present Simple - plural subject', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They work.');
    });

    test('Past Simple - irregular verb', () {
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
  });

  group('Continuous', () {
    test('Present Continuous - statement', () {
      final state = SentenceState(
        subject: he,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'He is working.');
    });

    test('Past Continuous - statement', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.past,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They were working.');
    });

    test('Future Continuous - statement', () {
      final state = SentenceState(
        subject: he,
        verb: work,
        tense: Tense.future,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'He will be working.');
    });

    test('Present Continuous - negative', () {
      final state = SentenceState(
        subject: he,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'He is not working.');
    });

    test('Past Continuous - negative', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.past,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They were not working.');
    });

    test('Future Continuous - negative', () {
      final state = SentenceState(
        subject: he,
        verb: work,
        tense: Tense.future,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'He will not be working.');
    });

    test('Present Continuous - question', () {
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

    test('Past Continuous - question', () {
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

    test('Future Continuous - question', () {
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

    test('Present Continuous - negative question', () {
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

    test('Past Continuous - negative question', () {
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

    test('Future Continuous - negative question', () {
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

    test('Present Continuous - exclamation', () {
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

    test('Past Continuous - exclamation', () {
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

    test('Future Continuous - exclamation', () {
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

    test('Present Continuous - plural subject', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They are working.');
    });

    test('Present Continuous - irregular verb', () {
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
  });

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
      );

      expect(grammarEngine.generate(state).text, 'He will have been working.');
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
      );

      expect(grammarEngine.generate(state).text, 'Will he have been working?');
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
      );

      expect(grammarEngine.generate(state).text, 'He will have been working!');
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
      );

      expect(grammarEngine.generate(state).text, 'They had been going.');
    });
  });

  group('Polarity', () {
    test('Present Simple - positive', () {
      final state = SentenceState(
        subject: he,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'He works.');
    });

    test('Present Simple - negative', () {
      final state = SentenceState(
        subject: he,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'He does not work.');
    });

    test('Present Continuous - positive', () {
      final state = SentenceState(
        subject: he,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'He is working.');
    });

    test('Present Continuous - negative', () {
      final state = SentenceState(
        subject: he,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'He is not working.');
    });

    test('Present Perfect - positive', () {
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

    test('Present Perfect Continuous - positive', () {
      final state = SentenceState(
        subject: he,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.perfectContinuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'He has been working.');
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
      );

      expect(grammarEngine.generate(state).text, 'He has not been working.');
    });

    test('Past Simple - negative', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.past,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They did not work.');
    });

    test('Future Simple - negative', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.future,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They will not work.');
    });

    test('Past Continuous - negative', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.past,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They were not working.');
    });

    test('Future Continuous - negative', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.future,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They will not be working.');
    });

    test('Past Perfect - negative', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.past,
        aspect: Aspect.perfect,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They had not worked.');
    });

    test('Future Perfect - negative', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.future,
        aspect: Aspect.perfect,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They will not have worked.');
    });

    test('Past Perfect Continuous - negative', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.past,
        aspect: Aspect.perfectContinuous,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They had not been working.');
    });

    test('Future Perfect Continuous - negative', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.future,
        aspect: Aspect.perfectContinuous,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(
        grammarEngine.generate(state).text,
        'They will not have been working.',
      );
    });

    test('Present Perfect - irregular verb negative', () {
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
  });

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

      expect(grammarEngine.generate(state).text, 'Will he have been working?');
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

      expect(grammarEngine.generate(state).text, 'He will have been working!');
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

  group('Plural subjects', () {
    test('Present Simple', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They work.');
    });

    test('Past Simple', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.past,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They worked.');
    });

    test('Future Simple', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.future,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They will work.');
    });

    test('Present Continuous', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They are working.');
    });

    test('Past Continuous', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.past,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They were working.');
    });

    test('Future Continuous', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.future,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They will be working.');
    });

    test('Present Perfect', () {
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

    test('Past Perfect', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.past,
        aspect: Aspect.perfect,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They had worked.');
    });

    test('Future Perfect', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.future,
        aspect: Aspect.perfect,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They will have worked.');
    });

    test('Present Perfect Continuous', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.perfectContinuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They have been working.');
    });

    test('Past Perfect Continuous', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.past,
        aspect: Aspect.perfectContinuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They had been working.');
    });

    test('Future Perfect Continuous', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.future,
        aspect: Aspect.perfectContinuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(
        grammarEngine.generate(state).text,
        'They will have been working.',
      );
    });

    test('Present Simple question', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.question,
      );

      expect(grammarEngine.generate(state).text, 'Do they work?');
    });

    test('Present Continuous question', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.question,
      );

      expect(grammarEngine.generate(state).text, 'Are they working?');
    });

    test('Present Perfect question', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.perfect,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.question,
      );

      expect(grammarEngine.generate(state).text, 'Have they worked?');
    });

    test('Present Perfect Continuous question', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.perfectContinuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.question,
      );

      expect(grammarEngine.generate(state).text, 'Have they been working?');
    });

    test('Present Simple negative', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They do not work.');
    });

    test('Present Perfect negative', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.perfect,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They have not worked.');
    });

    test('Present Perfect Continuous negative', () {
      final state = SentenceState(
        subject: they,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.perfectContinuous,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(grammarEngine.generate(state).text, 'They have not been working.');
    });

    test('Present Simple exclamation', () {
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
  });
}
