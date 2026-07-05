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

    test('The old doctor worked at home yesterday', () {
      final state = engine.recognize(
        'The old doctor worked at home yesterday.',
      );

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

    test('The old car will be built tomorrow', () {
      final state = engine.recognize('The old car will be built tomorrow.');

      expect(state.agent, isNull);

      expectObject(
        state,
        text: 'car',
        determiner: theDeterminer,
        adjective: old,
      );

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
}
