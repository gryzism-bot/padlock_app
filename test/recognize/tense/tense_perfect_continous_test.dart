import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
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

  test('The old worker has been building the new bridge', () {
    final state = engine.recognize(
      'The old worker has been building the new bridge.',
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

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.perfectContinuous);
  });

  test('Has the old worker been building the new bridge?', () {
    final state = engine.recognize(
      'Has the old worker been building the new bridge?',
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

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.perfectContinuous);

    expect(state.sentenceForm, SentenceForm.question);
  });

  test('The old worker has not been building the new bridge', () {
    final state = engine.recognize(
      'The old worker has not been building the new bridge.',
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

    expect(state.aspect, Aspect.perfectContinuous);

    expect(state.polarity, Polarity.negative);
  });

  test('The old workers had been building the new bridge', () {
    final state = engine.recognize(
      'The old workers had been building the new bridge.',
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

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.perfectContinuous);
  });

  test('Had the old workers been building the new bridge?', () {
    final state = engine.recognize(
      'Had the old workers been building the new bridge?',
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

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.perfectContinuous);

    expect(state.sentenceForm, SentenceForm.question);
  });

  test('The old workers had not been building the new bridge', () {
    final state = engine.recognize(
      'The old workers had not been building the new bridge.',
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

    expect(state.polarity, Polarity.negative);
  });

  test('The beautiful chef will have been working at home', () {
    final state = engine.recognize(
      'The beautiful chef will have been working at home.',
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
  });

  test('Will the beautiful chef have been working at home?', () {
    final state = engine.recognize(
      'Will the beautiful chef have been working at home?',
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

    expect(state.sentenceForm, SentenceForm.question);
  });

  test('The beautiful chef will not have been working at home', () {
    final state = engine.recognize(
      'The beautiful chef will not have been working at home.',
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

    expect(state.polarity, Polarity.negative);

    expect(state.placePhrase, homePlacePhrase);
  });

  test('The new bridge has been being built', () {
    final state = engine.recognize('The new bridge has been being built.');

    expectObject(
      state,
      text: 'bridge',
      determiner: theDeterminer,
      adjective: newAdjective,
    );

    expect(state.agent, isNull);

    expect(state.action, build);

    expect(state.voice, Voice.passive);

    expect(state.aspect, Aspect.perfectContinuous);
  });

  test('Has the new bridge been being built?', () {
    final state = engine.recognize('Has the new bridge been being built?');

    expectObject(
      state,
      text: 'bridge',
      determiner: theDeterminer,
      adjective: newAdjective,
    );

    expect(state.agent, isNull);

    expect(state.action, build);

    expect(state.voice, Voice.passive);

    expect(state.aspect, Aspect.perfectContinuous);

    expect(state.sentenceForm, SentenceForm.question);
  });

  test('The new bridge had been being built by the old workers', () {
    final state = engine.recognize(
      'The new bridge had been being built by the old workers.',
    );

    expectObject(
      state,
      text: 'bridge',
      determiner: theDeterminer,
      adjective: newAdjective,
    );

    expectAgent(
      state,
      text: 'workers',
      determiner: theDeterminer,
      adjective: old,
    );

    expect(state.action, build);

    expect(state.voice, Voice.passive);

    expect(state.tense, Tense.past);

    expect(state.aspect, Aspect.perfectContinuous);
  });

  test('Had the new bridge been being built by the old workers?', () {
    final state = engine.recognize(
      'Had the new bridge been being built by the old workers?',
    );

    expectObject(
      state,
      text: 'bridge',
      determiner: theDeterminer,
      adjective: newAdjective,
    );

    expectAgent(
      state,
      text: 'workers',
      determiner: theDeterminer,
      adjective: old,
    );

    expect(state.action, build);

    expect(state.voice, Voice.passive);

    expect(state.tense, Tense.past);

    expect(state.aspect, Aspect.perfectContinuous);

    expect(state.sentenceForm, SentenceForm.question);
  });
}
