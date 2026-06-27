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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
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
          voice: Voice.active,
        );

        expect(grammarEngine.generate(state).text, 'He is going.');
      });
    });
  });
}
