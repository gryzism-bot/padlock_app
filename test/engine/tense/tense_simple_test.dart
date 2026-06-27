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
        voice: Voice.active,
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
        voice: Voice.active,
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
        voice: Voice.active,
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
        voice: Voice.active,
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
        voice: Voice.active,
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
        voice: Voice.active,
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
        voice: Voice.active,
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
        voice: Voice.active,
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
        voice: Voice.active,
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
        voice: Voice.active,
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
        voice: Voice.active,
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
        voice: Voice.active,
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
        voice: Voice.active,
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
        voice: Voice.active,
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
        voice: Voice.active,
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
        voice: Voice.active,
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
        voice: Voice.active,
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
        voice: Voice.active,
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
        voice: Voice.active,
      );

      expect(grammarEngine.generate(state).text, 'He went.');
    });
  });
}
