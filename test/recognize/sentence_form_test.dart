import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/verbs/education.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/data/verbs/work.dart';
import 'package:padlock_app/engine/recognition_engine.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/voice.dart';

import 'helpers.dart';

void main() {
  final engine = RecognitionEngine();

  group('Recognition Sentence forms', () {
    test('Statement', () {
      final state = engine.recognize('John works.');

      expectAgent(state, text: 'john');
      expect(state.action, work);
      expect(state.sentenceForm, SentenceForm.statement);
    });

    test('Question', () {
      final state = engine.recognize('Does John work?');

      expectAgent(state, text: 'john');
      expect(state.action, work);
      expect(state.sentenceForm, SentenceForm.question);
    });

    test('Exclamation', () {
      final state = engine.recognize('John works!');

      expectAgent(state, text: 'john');
      expect(state.action, work);
      expect(state.sentenceForm, SentenceForm.exclamation);
    });

    test('Negative statement', () {
      final state = engine.recognize('Mary does not study.');

      expectAgent(state, text: 'mary');
      expect(state.action, study);
      expect(state.polarity, Polarity.negative);
      expect(state.sentenceForm, SentenceForm.statement);
    });

    test('Negative question', () {
      final state = engine.recognize('Does Mary not study?');

      expectAgent(state, text: 'mary');
      expect(state.action, study);
      expect(state.polarity, Polarity.negative);
      expect(state.sentenceForm, SentenceForm.question);
    });

    test('Negative exclamation', () {
      final state = engine.recognize('The dog is not running!');

      expectAgent(state, text: 'dog', determiner: theDeterminer);
      expect(state.action, run);
      expect(state.aspect, Aspect.continuous);
      expect(state.polarity, Polarity.negative);
      expect(state.sentenceForm, SentenceForm.exclamation);
    });

    test('Passive statement', () {
      final state = engine.recognize('The house was built.');

      expectObject(state, text: 'house', determiner: theDeterminer);
      expect(state.action, build);
      expect(state.voice, Voice.passive);
      expect(state.sentenceForm, SentenceForm.statement);
    });

    test('Passive question', () {
      final state = engine.recognize('Was the house built?');

      expectObject(state, text: 'house', determiner: theDeterminer);
      expect(state.action, build);
      expect(state.voice, Voice.passive);
      expect(state.sentenceForm, SentenceForm.question);
    });

    test('Passive exclamation', () {
      final state = engine.recognize('The bridge will be built!');

      expectObject(state, text: 'bridge', determiner: theDeterminer);
      expect(state.action, build);
      expect(state.voice, Voice.passive);
      expect(state.modal, will);
      expect(state.sentenceForm, SentenceForm.exclamation);
    });

    test('Modal question', () {
      final state = engine.recognize('Can the teacher teach?');

      expectAgent(state, text: 'teacher', determiner: theDeterminer);
      expect(state.action, teach);
      expect(state.modal, can);
      expect(state.sentenceForm, SentenceForm.question);
    });

    test('Modal exclamation', () {
      final state = engine.recognize('The teacher must teach!');

      expectAgent(state, text: 'teacher', determiner: theDeterminer);
      expect(state.action, teach);
      expect(state.modal, must);
      expect(state.sentenceForm, SentenceForm.exclamation);
    });

    test('Plural question', () {
      final state = engine.recognize('Do the students study?');

      expectAgent(state, text: 'students', determiner: theDeterminer);
      expect(state.action, study);
      expect(state.sentenceForm, SentenceForm.question);
    });

    test('Perfect question', () {
      final state = engine.recognize('Has John learned?');

      expectAgent(state, text: 'john');
      expect(state.action, learn);
      expect(state.aspect, Aspect.perfect);
      expect(state.sentenceForm, SentenceForm.question);
    });

    test('Passive negative statement', () {
      final state = engine.recognize('The house was not built.');

      expectObject(state, text: 'house', determiner: theDeterminer);
      expect(state.action, build);
      expect(state.voice, Voice.passive);
      expect(state.polarity, Polarity.negative);
      expect(state.sentenceForm, SentenceForm.statement);
    });

    test('Passive negative question', () {
      final state = engine.recognize('Was the house not built?');

      expectObject(state, text: 'house', determiner: theDeterminer);
      expect(state.action, build);
      expect(state.voice, Voice.passive);
      expect(state.polarity, Polarity.negative);
      expect(state.sentenceForm, SentenceForm.question);
    });

    test('Passive modal negative question', () {
      final state = engine.recognize('Should the bridge not be built?');

      expectObject(state, text: 'bridge', determiner: theDeterminer);
      expect(state.action, build);
      expect(state.voice, Voice.passive);
      expect(state.modal, should);
      expect(state.polarity, Polarity.negative);
      expect(state.sentenceForm, SentenceForm.question);
    });

    test('Question with object', () {
      final state = engine.recognize('Did Mary find the dog?');

      expectAgent(state, text: 'mary');
      expectObject(state, text: 'dog', determiner: theDeterminer);
      expect(state.action, findVerb);
      expect(state.tense, Tense.past);
      expect(state.sentenceForm, SentenceForm.question);
    });

    test('Imperative', () {
      final state = engine.recognize('Work.');

      expect(state.action, work);
      expect(state.sentenceForm, SentenceForm.imperative);
    }, skip: 'Imperative recognition is not implemented yet');
  });
}
