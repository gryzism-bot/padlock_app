import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/phrases/frequency_phrases.dart';
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

  group('Recognition Active Perfect tests', () {});
  test('The new teacher has not learned at work yesterday', () {
    final state = engine.recognize(
      'The new teacher has not learned at work yesterday.',
    );

    expectAgent(
      state,
      text: 'teacher',
      determiner: theDeterminer,
      adjective: newAdjective,
    );

    expect(state.object, isNull);

    expect(state.action, learn);

    expect(state.voice, Voice.active);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.perfect);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.negative);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.placePhrase, workPlacePhrase);
    expect(state.timePhrase, yesterdayTimePhrase);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('Has the old dog learned at home?', () {
    final state = engine.recognize('Has the old dog learned at home?');

    expectAgent(state, text: 'dog', determiner: theDeterminer, adjective: old);

    expect(state.object, isNull);

    expect(state.action, learn);

    expect(state.voice, Voice.active);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.perfect);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.placePhrase, homePlacePhrase);
    expect(state.timePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('The young student has learned at home every day', () {
    final state = engine.recognize(
      'The young student has learned at home every day.',
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

    expect(state.modal, noModal);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.perfect);

    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.placePhrase, homePlacePhrase);
    expect(state.frequencyPhrase, everyDayFrequencyPhrase);
    expect(state.timePhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('The old worker had built a bridge', () {
    final state = engine.recognize('The old worker had built a bridge.');

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
    expect(state.aspect, Aspect.perfect);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.placePhrase, isNull);
    expect(state.timePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });

  test('Had the old worker built a bridge?', () {
    final state = engine.recognize('Had the old worker built a bridge?');

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
    expect(state.aspect, Aspect.perfect);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.placePhrase, isNull);
    expect(state.timePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });
}
