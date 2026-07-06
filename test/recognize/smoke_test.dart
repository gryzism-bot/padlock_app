import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/frequency_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/adjectives/appearance.dart';
import 'package:padlock_app/data/subjects/adjectives/quality.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
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

  group('Recognition Smoke', () {
    test('The young engineer should not be working at home today', () {
      final state = engine.recognize(
        'The young engineer should not be working at home today.',
      );

      expectAgent(
        state,
        text: 'engineer',
        determiner: theDeterminer,
        adjective: young,
      );

      expect(state.object, isNull);

      expect(state.action, work);

      expect(state.voice, Voice.active);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.continuous);

      expect(state.modal, should);
      expect(state.polarity, Polarity.negative);

      expect(state.placePhrase, homePlacePhrase);
      expect(state.timePhrase, todayTimePhrase);
    });

    test('The beautiful teacher may have learned at school yesterday', () {
      final state = engine.recognize(
        'The beautiful teacher may have learned at school yesterday.',
      );

      expectAgent(
        state,
        text: 'teacher',
        determiner: theDeterminer,
        adjective: beautiful,
      );

      expect(state.object, isNull);

      expect(state.action, learn);

      expect(state.voice, Voice.active);
      expect(state.aspect, Aspect.perfect);
      expect(state.tense, Tense.present);

      expect(state.modal, may);

      expect(state.placePhrase, schoolPlacePhrase);
      expect(state.timePhrase, yesterdayTimePhrase);
    });

    test('The old workers must build the new bridge tomorrow', () {
      final state = engine.recognize(
        'The old workers must build the new bridge tomorrow.',
      );

      expectAgent(
        state,
        text: 'workers',
        determiner: theDeterminer,
        adjective: old,
      );

      expectObject(
        state,
        text: 'bridge',
        determiner: theDeterminer,
        adjective: newAdjective,
      );

      expect(state.action, build);

      expect(state.modal, must);

      expect(state.timePhrase, tomorrowTimePhrase);
    });

    test('The new bridge should be built tomorrow', () {
      final state = engine.recognize(
        'The new bridge should be built tomorrow.',
      );

      expectObject(
        state,
        text: 'bridge',
        determiner: theDeterminer,
        adjective: newAdjective,
      );

      expect(state.agent, isNull);

      expect(state.action, build);

      expect(state.voice, Voice.passive);
      expect(state.modal, should);

      expect(state.timePhrase, tomorrowTimePhrase);
    });

    test('Should the young worker build the new bridge tomorrow?', () {
      final state = engine.recognize(
        'Should the young worker build the new bridge tomorrow?',
      );

      expectAgent(
        state,
        text: 'worker',
        determiner: theDeterminer,
        adjective: young,
      );

      expectObject(
        state,
        text: 'bridge',
        determiner: theDeterminer,
        adjective: newAdjective,
      );

      expect(state.modal, should);

      expect(state.sentenceForm, SentenceForm.question);

      expect(state.timePhrase, tomorrowTimePhrase);
    });

    test('Can the beautiful teacher not work at home?', () {
      final state = engine.recognize(
        'Can the beautiful teacher not work at home?',
      );

      expectAgent(
        state,
        text: 'teacher',
        determiner: theDeterminer,
        adjective: beautiful,
      );

      expect(state.action, work);

      expect(state.modal, can);
      expect(state.polarity, Polarity.negative);

      expect(state.placePhrase, homePlacePhrase);

      expect(state.sentenceForm, SentenceForm.question);
    });

    test('The old bridge has not been built by the young workers', () {
      final state = engine.recognize(
        'The old bridge has not been built by the young workers.',
      );

      expectObject(
        state,
        text: 'bridge',
        determiner: theDeterminer,
        adjective: old,
      );

      expectAgent(
        state,
        text: 'workers',
        determiner: theDeterminer,
        adjective: young,
      );

      expect(state.action, build);

      expect(state.voice, Voice.passive);
      expect(state.aspect, Aspect.perfect);

      expect(state.polarity, Polarity.negative);
    });

    test('Every beautiful student can travel to work every day', () {
      final state = engine.recognize(
        'Every beautiful student can travel to work every day.',
      );

      expectAgent(
        state,
        text: 'student',
        determiner: everyDeterminer,
        adjective: beautiful,
      );

      expect(state.object, isNull);

      expect(state.action, travel);

      expect(state.modal, can);

      expect(state.placePhrase, workPlacePhrase);
      expect(state.frequencyPhrase, everyDayFrequencyPhrase);
    });

    test('Had the old workers been building the new bridge yesterday?', () {
      final state = engine.recognize(
        'Had the old workers been building the new bridge yesterday?',
      );

      expectAgent(
        state,
        text: 'workers',
        determiner: theDeterminer,
        adjective: old,
      );

      expectObject(
        state,
        text: 'bridge',
        determiner: theDeterminer,
        adjective: newAdjective,
      );

      expect(state.action, build);

      expect(state.aspect, Aspect.perfectContinuous);
      expect(state.tense, Tense.past);

      expect(state.sentenceForm, SentenceForm.question);

      expect(state.timePhrase, yesterdayTimePhrase);
    });

    test('Will the beautiful chef have been working at home tomorrow?', () {
      final state = engine.recognize(
        'Will the beautiful chef have been working at home tomorrow?',
      );

      expectAgent(
        state,
        text: 'chef',
        determiner: theDeterminer,
        adjective: beautiful,
      );

      expect(state.object, isNull);

      expect(state.action, work);

      expect(state.modal, will);

      expect(state.aspect, Aspect.perfectContinuous);

      expect(state.placePhrase, homePlacePhrase);
      expect(state.timePhrase, tomorrowTimePhrase);

      expect(state.sentenceForm, SentenceForm.question);
    });

    test('The beautiful chef will have been working at home tomorrow.', () {
      final state = engine.recognize(
        'The beautiful chef will have been working at home tomorrow.',
      );

      expectAgent(
        state,
        text: 'chef',
        determiner: theDeterminer,
        adjective: beautiful,
      );

      expect(state.object, isNull);

      expect(state.action, work);

      expect(state.modal, will);

      expect(state.aspect, Aspect.perfectContinuous);

      expect(state.placePhrase, homePlacePhrase);
      expect(state.timePhrase, tomorrowTimePhrase);

      expect(state.sentenceForm, SentenceForm.statement);
    });
  });
}
