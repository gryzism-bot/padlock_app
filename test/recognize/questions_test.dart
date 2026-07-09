import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/phrases/frequency_phrases.dart';
import 'package:padlock_app/data/subjects/adjectives/appearance.dart';
import 'package:padlock_app/data/subjects/adjectives/quality.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/travel.dart';
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

  group('Recognition Questions tests', () {});

  test('Can the young pilot travel tomorrow?', () {
    final state = engine.recognize('Can the young pilot travel tomorrow?');

    expectAgent(
      state,
      text: 'pilot',
      determiner: theDeterminer,
      adjective: young,
    );

    expect(state.object, isNull);

    expect(state.action, travel);

    expect(state.voice, Voice.active);

    expect(state.modal, can);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);

    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.timePhrase, tomorrowTimePhrase);
    expect(state.placePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('Will the new worker build a bridge tomorrow?', () {
    final state = engine.recognize(
      'Will the new worker build a bridge tomorrow?',
    );

    expectAgent(
      state,
      text: 'worker',
      determiner: theDeterminer,
      adjective: newAdjective,
    );

    expectObject(state, text: 'bridge', determiner: aDeterminer);

    expect(state.action, build);

    expect(state.voice, Voice.active);

    expect(state.modal, will);

    expect(state.tense, Tense.future);
    expect(state.aspect, Aspect.simple);

    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.timePhrase, tomorrowTimePhrase);
    expect(state.placePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('Does the new student travel every day?', () {
    final state = engine.recognize('Does the new student travel every day?');

    expectAgent(
      state,
      text: 'student',
      determiner: theDeterminer,
      adjective: newAdjective,
    );

    expect(state.object, isNull);

    expect(state.action, travel);

    expect(state.voice, Voice.active);

    expect(state.modal, noModal);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);

    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.frequencyPhrase, everyDayFrequencyPhrase);
    expect(state.placePhrase, isNull);
    expect(state.timePhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('Did the beautiful woman build a new house yesterday?', () {
    final state = engine.recognize(
      'Did the beautiful woman build a new house yesterday?',
    );

    expectAgent(
      state,
      text: 'woman',
      determiner: theDeterminer,
      adjective: beautiful,
    );

    expectObject(
      state,
      text: 'house',
      determiner: aDeterminer,
      adjective: newAdjective,
    );

    expect(state.action, build);

    expect(state.voice, Voice.active);

    expect(state.modal, noModal);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.simple);

    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.timePhrase, yesterdayTimePhrase);
    expect(state.placePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('Is the young engineer working at home?', () {
    final state = engine.recognize('Is the young engineer working at home?');

    expectAgent(
      state,
      text: 'engineer',
      determiner: theDeterminer,
      adjective: young,
    );

    expect(state.object, isNull);

    expect(state.action, work);

    expect(state.voice, Voice.active);

    expect(state.modal, noModal);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.continuous);

    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.placePhrase, homePlacePhrase);
    expect(state.timePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('Can the old workers build the new bridge every day?', () {
    final state = engine.recognize(
      'Can the old workers build the new bridge every day?',
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

    expect(state.voice, Voice.active);

    expect(state.modal, can);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);

    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.frequencyPhrase, everyDayFrequencyPhrase);
    expect(state.placePhrase, isNull);
    expect(state.timePhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('Did the beautiful woman travel to work yesterday?', () {
    final state = engine.recognize(
      'Did the beautiful woman travel to work yesterday?',
    );

    expectAgent(
      state,
      text: 'woman',
      determiner: theDeterminer,
      adjective: beautiful,
    );

    expect(state.object, isNull);

    expect(state.action, travel);

    expect(state.voice, Voice.active);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.simple);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.placePhrase, workPlacePhrase);
    expect(state.timePhrase, yesterdayTimePhrase);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('Can the beautiful teacher work at home every day?', () {
    final state = engine.recognize(
      'Can the beautiful teacher work at home every day?',
    );

    expectAgent(
      state,
      text: 'teacher',
      determiner: theDeterminer,
      adjective: beautiful,
    );

    expect(state.object, isNull);

    expect(state.action, work);

    expect(state.voice, Voice.active);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);

    expect(state.modal, can);
    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.placePhrase, homePlacePhrase);
    expect(state.frequencyPhrase, everyDayFrequencyPhrase);
    expect(state.timePhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });
}
