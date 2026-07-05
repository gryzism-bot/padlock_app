import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/phrases/frequency_phrases.dart';
import 'package:padlock_app/data/subjects/adjectives/appearance.dart';
import 'package:padlock_app/data/subjects/adjectives/quality.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
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

  group('Recognition Modal', () {});

  test('The beautiful woman can travel to work every day', () {
    final state = engine.recognize(
      'The beautiful woman can travel to work every day.',
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

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);

    expect(state.modal, can);
    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.placePhrase, workPlacePhrase);
    expect(state.frequencyPhrase, everyDayFrequencyPhrase);
    expect(state.timePhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('Every young student can travel to work every day', () {
    final state = engine.recognize(
      'Every young student can travel to work every day.',
    );

    expectAgent(
      state,
      text: 'student',
      determiner: everyDeterminer,
      adjective: young,
    );

    expect(state.object, isNull);

    expect(state.action, travel);

    expect(state.voice, Voice.active);

    expect(state.modal, can);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);

    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.placePhrase, workPlacePhrase);
    expect(state.frequencyPhrase, everyDayFrequencyPhrase);
    expect(state.timePhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('The beautiful woman will build a new house tomorrow', () {
    final state = engine.recognize(
      'The beautiful woman will build a new house tomorrow.',
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

    expect(state.modal, will);

    expect(state.tense, Tense.future);
    expect(state.aspect, Aspect.simple);

    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.timePhrase, tomorrowTimePhrase);
    expect(state.placePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

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

  test('The old workers can build a new house', () {
    final state = engine.recognize('The old workers can build a new house.');

    expectAgent(
      state,
      text: 'workers',
      determiner: theDeterminer,
      adjective: old,
    );

    expectObject(
      state,
      text: 'house',
      determiner: aDeterminer,
      adjective: newAdjective,
    );

    expect(state.action, build);

    expect(state.voice, Voice.active);

    expect(state.modal, can);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);

    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.timePhrase, isNull);
    expect(state.placePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('The old car will be built tomorrow', () {
    final state = engine.recognize('The old car will be built tomorrow.');

    expect(state.agent, isNull);

    expectObject(state, text: 'car', determiner: theDeterminer, adjective: old);

    expect(state.action, build);

    expect(state.voice, Voice.passive);

    expect(state.modal, will);

    expect(state.tense, Tense.future);
    expect(state.aspect, Aspect.simple);

    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.timePhrase, tomorrowTimePhrase);
    expect(state.placePhrase, isNull);
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

    expect(state.timePhrase, isNull);
    expect(state.placePhrase, isNull);
    expect(state.frequencyPhrase, everyDayFrequencyPhrase);
    expect(state.mannerPhrase, isNull);
  });

  test('Can the old worker not build the new bridge?', () {
    final state = engine.recognize(
      'Can the old worker not build the new bridge?',
    );

    expectAgent(
      state,
      text: 'worker',
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

    expect(state.polarity, Polarity.negative);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.timePhrase, isNull);
    expect(state.placePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('Will the new bridge be built by the old workers tomorrow?', () {
    final state = engine.recognize(
      'Will the new bridge be built by the old workers tomorrow?',
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

    expect(state.voice, Voice.passive);

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

  test('Will the new bridge not be built tomorrow?', () {
    final state = engine.recognize(
      'Will the new bridge not be built tomorrow?',
    );

    expect(state.agent, isNull);

    expectObject(
      state,
      text: 'bridge',
      determiner: theDeterminer,
      adjective: newAdjective,
    );

    expect(state.action, build);

    expect(state.voice, Voice.passive);

    expect(state.modal, will);

    expect(state.tense, Tense.future);
    expect(state.aspect, Aspect.simple);

    expect(state.polarity, Polarity.negative);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.timePhrase, tomorrowTimePhrase);
    expect(state.placePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });
}
