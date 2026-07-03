import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/phrases/frequency_phrases.dart';
import 'package:padlock_app/data/subjects/adjectives/appearance.dart';
import 'package:padlock_app/data/subjects/adjectives/quality.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/data/verbs/work.dart';
import 'package:padlock_app/engine/recognition_engine.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/grammar/subject/determiner.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

void main() {
  final engine = RecognitionEngine();

  void expectAgent(
    SentenceState state, {
    required String text,
    Determiner? determiner,
    Adjective? adjective,
  }) {
    expect(state.agent, isNotNull);
    expect(state.agent!.text, text);
    expect(state.agent!.determiner, determiner);
    expect(state.agent!.adjective, adjective);
  }

  void expectObject(
    SentenceState state, {
    required String text,
    Determiner? determiner,
    Adjective? adjective,
  }) {
    expect(state.object, isNotNull);
    expect(state.object!.text, text);
    expect(state.object!.determiner, determiner);
    expect(state.object!.adjective, adjective);
  }

  group('Recognition Smoke', () {
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

      expect(state.placePhrase, workPlacePhrase);
      expect(state.frequencyPhrase, everyDayFrequencyPhrase);
      expect(state.timePhrase, isNull);
      expect(state.mannerPhrase, isNull);
    });

    test('Has the old dog learned at home?', () {
      final state = engine.recognize('Has the old dog learned at home?');

      expectAgent(
        state,
        text: 'dog',
        determiner: theDeterminer,
        adjective: old,
      );

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
  });
}
