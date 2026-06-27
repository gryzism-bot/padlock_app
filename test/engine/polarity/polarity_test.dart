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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
        );

        expect(
          grammarEngine.generate(state).text,
          'They will not have worked.',
        );
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
          voice: Voice.active,
        );

        expect(
          grammarEngine.generate(state).text,
          'They had not been working.',
        );
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
          voice: Voice.active,
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
          voice: Voice.active,
        );

        expect(grammarEngine.generate(state).text, 'He has not gone.');
      });
    });
  });
}
