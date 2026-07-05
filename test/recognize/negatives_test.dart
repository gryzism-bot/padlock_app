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

import 'helpers.dart';

void main() {
  final engine = RecognitionEngine();

  group('Recognition Negatives tests', () {});

  test('The beautiful teacher does not work at school', () {
    final state = engine.recognize(
      'The beautiful teacher does not work at school.',
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

    expect(state.modal, noModal);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);

    expect(state.polarity, Polarity.negative);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.timePhrase, isNull);
    expect(state.placePhrase, schoolPlacePhrase);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('Did the old worker not build the new bridge?', () {
    final state = engine.recognize(
      'Did the old worker not build the new bridge?',
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

    expect(state.modal, noModal);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.simple);

    expect(state.polarity, Polarity.negative);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.timePhrase, isNull);
    expect(state.placePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('The bridge was not built', () {
    final state = engine.recognize('The bridge was not built.');

    expect(state.agent, isNull);

    expectObject(state, text: 'bridge', determiner: theDeterminer);

    expect(state.action, build);

    expect(state.voice, Voice.passive);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.simple);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.negative);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.placePhrase, isNull);
    expect(state.timePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('The bridge has not been built', () {
    final state = engine.recognize('The bridge has not been built.');

    expect(state.agent, isNull);

    expectObject(state, text: 'bridge', determiner: theDeterminer);

    expect(state.action, build);

    expect(state.voice, Voice.passive);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.perfect);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.negative);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.placePhrase, isNull);
    expect(state.timePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('The bridge will not be built', () {
    final state = engine.recognize('The bridge will not be built.');

    expect(state.agent, isNull);

    expectObject(state, text: 'bridge', determiner: theDeterminer);

    expect(state.action, build);

    expect(state.voice, Voice.passive);

    expect(state.tense, Tense.future);
    expect(state.aspect, Aspect.simple);

    expect(state.modal, will);
    expect(state.polarity, Polarity.negative);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.placePhrase, isNull);
    expect(state.timePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
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

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);

    expect(state.modal, can);
    expect(state.polarity, Polarity.negative);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.placePhrase, isNull);
    expect(state.timePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('Has the new bridge not been built?', () {
    final state = engine.recognize('Has the new bridge not been built?');

    expect(state.agent, isNull);

    expectObject(
      state,
      text: 'bridge',
      determiner: theDeterminer,
      adjective: newAdjective,
    );

    expect(state.action, build);

    expect(state.voice, Voice.passive);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.perfect);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.negative);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.placePhrase, isNull);
    expect(state.timePhrase, isNull);
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

    expect(state.tense, Tense.future);
    expect(state.aspect, Aspect.simple);

    expect(state.modal, will);
    expect(state.polarity, Polarity.negative);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.timePhrase, tomorrowTimePhrase);
    expect(state.placePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });
}
