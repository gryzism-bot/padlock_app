import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/adjectives/appearance.dart';
import 'package:padlock_app/data/subjects/adjectives/quality.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/work.dart';
import 'package:padlock_app/engine/recognition_engine.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/voice.dart';

import '../helpers.dart';

void main() {
  final engine = RecognitionEngine();

  group('Recognition Active Simple tests', () {});
  test('The old doctor worked at home yesterday', () {
    final state = engine.recognize('The old doctor worked at home yesterday.');

    expectAgent(
      state,
      text: 'doctor',
      determiner: theDeterminer,
      adjective: old,
    );

    expect(state.object, isNull);

    expect(state.action, work);

    expect(state.voice, Voice.active);

    expect(state.modal, noModal);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.simple);

    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.placePhrase, homePlacePhrase);
    expect(state.timePhrase, yesterdayTimePhrase);
    expect(state.frequencyPhrase, isNull);
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

  test('The young student learned at home yesterday', () {
    final state = engine.recognize(
      'The young student learned at home yesterday.',
    );

    expectAgent(
      state,
      text: 'student',
      determiner: theDeterminer,
      adjective: young,
    );

    expect(state.object, isNull);

    expect(state.action, learn);

    expect(state.voice, Voice.active);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.simple);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.placePhrase, homePlacePhrase);
    expect(state.timePhrase, yesterdayTimePhrase);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('The old workers built the new bridge yesterday', () {
    final state = engine.recognize(
      'The old workers built the new bridge yesterday.',
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

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.simple);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.timePhrase, yesterdayTimePhrase);
    expect(state.placePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('The beautiful chef can learn at work tomorrow', () {
    final state = engine.recognize(
      'The beautiful chef can learn at work tomorrow.',
    );

    expectAgent(
      state,
      text: 'chef',
      determiner: theDeterminer,
      adjective: beautiful,
    );

    expect(state.object, isNull);

    expect(state.action, learn);

    expect(state.voice, Voice.active);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);

    expect(state.modal, can);
    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.placePhrase, workPlacePhrase);
    expect(state.timePhrase, tomorrowTimePhrase);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });
}
