import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/adjectives/quality.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
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

  group('Recognition Passive tests', () {});

  test('The new houses have been built by the old workers yesterday', () {
    final state = engine.recognize(
      'The new houses have been built by the old workers yesterday.',
    );

    expectAgent(
      state,
      text: 'workers',
      determiner: theDeterminer,
      adjective: old,
    );

    expectObject(
      state,
      text: 'houses',
      determiner: theDeterminer,
      adjective: newAdjective,
    );

    expect(state.action, build);

    expect(state.voice, Voice.passive);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.perfect);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.timePhrase, yesterdayTimePhrase);
    expect(state.placePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('The new bridge was built yesterday', () {
    final state = engine.recognize('The new bridge was built yesterday.');

    expect(state.agent, isNull);

    expectObject(
      state,
      text: 'bridge',
      determiner: theDeterminer,
      adjective: newAdjective,
    );

    expect(state.action, build);

    expect(state.voice, Voice.passive);

    expect(state.modal, noModal);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.simple);

    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.timePhrase, yesterdayTimePhrase);
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

  test('Was the new bridge built by the old workers?', () {
    final state = engine.recognize(
      'Was the new bridge built by the old workers?',
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

    expect(state.modal, noModal);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.simple);

    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.timePhrase, isNull);
    expect(state.placePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('Has the new bridge been built by the old workers?', () {
    final state = engine.recognize(
      'Has the new bridge been built by the old workers?',
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

    expect(state.modal, noModal);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.perfect);

    expect(state.polarity, Polarity.positive);

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

  test('The new bridge had been built by the old workers yesterday', () {
    final state = engine.recognize(
      'The new bridge had been built by the old workers yesterday.',
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

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.perfect);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.timePhrase, yesterdayTimePhrase);
    expect(state.placePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('Had the new bridge been built by the old workers?', () {
    final state = engine.recognize(
      'Had the new bridge been built by the old workers?',
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

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.perfect);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.timePhrase, isNull);
    expect(state.placePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });
}
