import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/verbs/education.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/data/verbs/work.dart';
import 'package:padlock_app/engine/recognition_engine.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/voice.dart';

import 'helpers.dart';

void main() {
  final engine = RecognitionEngine();

  group('Recognition Exclamations', () {
    test('John works!', () {
      final state = engine.recognize('John works!');

      expectAgent(state, text: 'john');
      expect(state.action, work);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.simple);
      expect(state.sentenceForm, SentenceForm.exclamation);
    });

    test('The dog is running!', () {
      final state = engine.recognize('The dog is running!');

      expectAgent(state, text: 'dog', determiner: theDeterminer);
      expect(state.action, run);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.continuous);
      expect(state.sentenceForm, SentenceForm.exclamation);
    });

    test('Mary studied yesterday!', () {
      final state = engine.recognize('Mary studied yesterday!');

      expectAgent(state, text: 'mary');
      expect(state.action, study);
      expect(state.tense, Tense.past);
      expect(state.aspect, Aspect.simple);
      expect(state.timePhrase, yesterdayTimePhrase);
      expect(state.sentenceForm, SentenceForm.exclamation);
    });

    test('These dogs have learned!', () {
      final state = engine.recognize('These dogs have learned!');

      expectAgent(state, text: 'dogs', determiner: theseDeterminer);
      expect(state.action, learn);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.perfect);
      expect(state.sentenceForm, SentenceForm.exclamation);
    });

    test('That house will be built by John!', () {
      final state = engine.recognize('That house will be built by John!');

      expectObject(state, text: 'house', determiner: thatDeterminer);
      expectAgent(state, text: 'john');
      expect(state.action, build);
      expect(state.voice, Voice.passive);
      expect(state.modal, will);
      expect(state.tense, Tense.future);
      expect(state.sentenceForm, SentenceForm.exclamation);
    });

    test('Our students must study!', () {
      final state = engine.recognize('Our students must study!');

      expectAgent(state, text: 'students', determiner: ourDeterminer);
      expect(state.action, study);
      expect(state.modal, must);
      expect(state.sentenceForm, SentenceForm.exclamation);
    });

    test('No student worked yesterday!', () {
      final state = engine.recognize('No student worked yesterday!');

      expectAgent(state, text: 'student', determiner: noDeterminer);
      expect(state.action, work);
      expect(state.tense, Tense.past);
      expect(state.timePhrase, yesterdayTimePhrase);
      expect(state.sentenceForm, SentenceForm.exclamation);
    });

    test('The dog did not run yesterday!', () {
      final state = engine.recognize('The dog did not run yesterday!');

      expectAgent(state, text: 'dog', determiner: theDeterminer);
      expect(state.action, run);
      expect(state.tense, Tense.past);
      expect(state.polarity, Polarity.negative);
      expect(state.timePhrase, yesterdayTimePhrase);
      expect(state.sentenceForm, SentenceForm.exclamation);
    });

    test(
      'Recognized plural noun text is preserved',
      () {
        final state = engine.recognize('These dogs have learned!');

        expect(state.agent!.text, 'dogs');
        expect(state.agent!.number, Number.singular);
      },
      skip: 'Plural noun number inference is not implemented yet',
    );
  });
}
