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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
        );

        expect(
          grammarEngine.generate(state).text,
          'They have not been working.',
        );
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
          voice: Voice.active,
        );

        expect(grammarEngine.generate(state).text, 'They work!');
      });
    });
  });
}
