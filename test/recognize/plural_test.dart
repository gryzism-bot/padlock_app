import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
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

  group('Recognition Plural', () {
    test('Dogs work', () {
      final state = engine.recognize('Dogs work.');

      expectAgent(state, text: 'dogs');
      expect(state.action, work);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.simple);
    });

    test('The students studied yesterday', () {
      final state = engine.recognize('The students studied yesterday.');

      expectAgent(state, text: 'students', determiner: theDeterminer);
      expect(state.action, study);
      expect(state.tense, Tense.past);
      expect(state.timePhrase, yesterdayTimePhrase);
    });

    test('Teachers are working', () {
      final state = engine.recognize('Teachers are working.');

      expectAgent(state, text: 'teachers');
      expect(state.action, work);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.continuous);
    });

    test('Children have learned', () {
      final state = engine.recognize('Children have learned.');

      expectAgent(state, text: 'children');
      expect(state.action, learn);
      expect(state.aspect, Aspect.perfect);
    });

    test('The houses were built', () {
      final state = engine.recognize('The houses were built.');

      expectObject(state, text: 'houses', determiner: theDeterminer);
      expect(state.action, build);
      expect(state.voice, Voice.passive);
      expect(state.tense, Tense.past);
    });

    test('Dogs can run', () {
      final state = engine.recognize('Dogs can run.');

      expectAgent(state, text: 'dogs');
      expect(state.action, run);
      expect(state.modal, can);
    });

    test('The teachers should work', () {
      final state = engine.recognize('The teachers should work.');

      expectAgent(state, text: 'teachers', determiner: theDeterminer);
      expect(state.action, work);
      expect(state.modal, should);
    });

    test('Dogs do not run', () {
      final state = engine.recognize('Dogs do not run.');

      expectAgent(state, text: 'dogs');
      expect(state.action, run);
      expect(state.polarity, Polarity.negative);
    });

    test('Do dogs work?', () {
      final state = engine.recognize('Do dogs work?');

      expectAgent(state, text: 'dogs');
      expect(state.action, work);
      expect(state.sentenceForm, SentenceForm.question);
    });

    test('Were the houses built?', () {
      final state = engine.recognize('Were the houses built?');

      expectObject(state, text: 'houses', determiner: theDeterminer);
      expect(state.action, build);
      expect(state.voice, Voice.passive);
      expect(state.sentenceForm, SentenceForm.question);
    });

    test('These dogs are running', () {
      final state = engine.recognize('These dogs are running.');

      expectAgent(state, text: 'dogs', determiner: theseDeterminer);
      expect(state.action, run);
      expect(state.aspect, Aspect.continuous);
    });

    test('Our students have studied', () {
      final state = engine.recognize('Our students have studied.');

      expectAgent(state, text: 'students', determiner: ourDeterminer);
      expect(state.action, study);
      expect(state.aspect, Aspect.perfect);
    });

    test('Some children may travel', () {
      final state = engine.recognize('Some children may travel.');

      expectAgent(state, text: 'children', determiner: someDeterminer);
      expect(state.action, travel);
      expect(state.modal, may);
    });

    test('Many teachers work at school', () {
      final state = engine.recognize('Many teachers work at school.');

      expectAgent(state, text: 'teachers', determiner: manyDeterminer);
      expect(state.action, work);
      expect(state.placePhrase, schoolPlacePhrase);
    });

    test('The children have not learned', () {
      final state = engine.recognize('The children have not learned.');

      expectAgent(state, text: 'children', determiner: theDeterminer);
      expect(state.action, learn);
      expect(state.aspect, Aspect.perfect);
      expect(state.polarity, Polarity.negative);
    });

    test(
      'Plural noun number is inferred from recognized noun text',
      () {
        final state = engine.recognize('Dogs work.');

        expect(state.agent!.number, Number.plural);
      },
      skip: 'Plural noun number inference is not implemented yet',
    );
  });
}
