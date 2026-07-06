import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/phrases/frequency_phrases.dart';
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

  group('Recognition Active Continuous tests', () {});

  test('The young engineer is working at work now', () {
    final state = engine.recognize(
      'The young engineer is working at work now.',
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

    expect(state.modal, noModal);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.continuous);

    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.placePhrase, workPlacePhrase);
    expect(state.timePhrase, nowTimePhrase);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('The beautiful chef has been working at home since yesterday', () {
    final state = engine.recognize(
      'The beautiful chef has been working at home yesterday.',
    );

    expectAgent(
      state,
      text: 'chef',
      determiner: theDeterminer,
      adjective: beautiful,
    );

    expect(state.object, isNull);

    expect(state.action, work);

    expect(state.voice, Voice.active);

    expect(state.modal, noModal);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.perfectContinuous);

    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.placePhrase, homePlacePhrase);
    expect(state.timePhrase, yesterdayTimePhrase);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('The young worker is working at home', () {
    final state = engine.recognize('The young worker is working at home.');

    expectAgent(
      state,
      text: 'worker',
      determiner: theDeterminer,
      adjective: young,
    );

    expect(state.object, isNull);

    expect(state.action, work);

    expect(state.voice, Voice.active);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.continuous);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.placePhrase, homePlacePhrase);
    expect(state.timePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('The old worker was building a bridge', () {
    final state = engine.recognize('The old worker was building a bridge.');

    expectAgent(
      state,
      text: 'worker',
      determiner: theDeterminer,
      adjective: old,
    );

    expectObject(state, text: 'bridge', determiner: aDeterminer);

    expect(state.action, build);

    expect(state.voice, Voice.active);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.continuous);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.placePhrase, isNull);
    expect(state.timePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('Was the old worker building a bridge?', () {
    final state = engine.recognize('Was the old worker building a bridge?');

    expectAgent(
      state,
      text: 'worker',
      determiner: theDeterminer,
      adjective: old,
    );

    expectObject(state, text: 'bridge', determiner: aDeterminer);

    expect(state.action, build);

    expect(state.voice, Voice.active);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.continuous);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.placePhrase, isNull);
    expect(state.timePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('The old worker had been building a bridge', () {
    final state = engine.recognize(
      'The old worker had been building a bridge.',
    );

    expectAgent(
      state,
      text: 'worker',
      determiner: theDeterminer,
      adjective: old,
    );

    expectObject(state, text: 'bridge', determiner: aDeterminer);

    expect(state.action, build);

    expect(state.voice, Voice.active);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.perfectContinuous);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.placePhrase, isNull);
    expect(state.timePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('The old workers have been building the new bridge every day', () {
    final state = engine.recognize(
      'The old workers have been building the new bridge every day.',
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

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.perfectContinuous);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.frequencyPhrase, everyDayFrequencyPhrase);
    expect(state.timePhrase, isNull);
    expect(state.placePhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('Had the old workers not been building the bridge?', () {
    final state = engine.recognize(
      'Had the old workers not been building the bridge?',
    );

    expectAgent(
      state,
      text: 'workers',
      determiner: theDeterminer,
      adjective: old,
    );

    expectObject(state, text: 'bridge', determiner: theDeterminer);

    expect(state.action, build);

    expect(state.voice, Voice.active);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.perfectContinuous);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.negative);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.timePhrase, isNull);
    expect(state.placePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });
}
