import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/phrases/frequency_phrases.dart';
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

  group('Recognition invariants', () {
    test('DO support is never recognized as the lexical action', () {
      final state = engine.recognize('Does he work?');

      expectAgent(state, text: 'he');
      expect(state.action, work);
      expect(state.action, isNot(doVerb));
      expect(state.sentenceForm, SentenceForm.question);
    });

    test('HAVE auxiliary is never recognized as the lexical action', () {
      final state = engine.recognize('Have they worked?');

      expectAgent(state, text: 'they');
      expect(state.action, work);
      expect(state.action, isNot(have));
      expect(state.aspect, Aspect.perfect);
    });

    test(
      'BE helper is never recognized as action when lexical verb follows',
      () {
        final state = engine.recognize('Had they been working?');

        expectAgent(state, text: 'they');
        expect(state.action, work);
        expect(state.action, isNot(be));
        expect(state.tense, Tense.past);
        expect(state.aspect, Aspect.perfectContinuous);
      },
    );

    test('Passive by phrase becomes agent, not active object', () {
      final state = engine.recognize('The bridge was built by them.');

      expect(state.voice, Voice.passive);
      expectObject(state, text: 'bridge', determiner: theDeterminer);
      expectAgent(state, text: 'them');
      expect(state.action, build);
    });

    test('Passive subject becomes object, not active agent', () {
      final state = engine.recognize('The new bridge was built.');

      expect(state.voice, Voice.passive);
      expect(state.agent, isNull);
      expectObject(
        state,
        text: 'bridge',
        determiner: theDeterminer,
        adjective: newAdjective,
      );
    });

    test('Question subject excludes the leading auxiliary', () {
      final state = engine.recognize('Did the old worker build a bridge?');

      expectAgent(
        state,
        text: 'worker',
        determiner: theDeterminer,
        adjective: old,
      );
      expect(state.agent!.text, isNot('did the old worker'));
      expectObject(state, text: 'bridge', determiner: aDeterminer);
      expect(state.action, build);
    });

    test('Phrase tokens are not swallowed into active object', () {
      final state = engine.recognize(
        'The beautiful teacher does not work at school every day.',
      );

      expectAgent(
        state,
        text: 'teacher',
        determiner: theDeterminer,
        adjective: beautiful,
      );
      expect(state.object, isNull);
      expect(state.placePhrase, schoolPlacePhrase);
      expect(state.frequencyPhrase, everyDayFrequencyPhrase);
      expect(state.polarity, Polarity.negative);
    });

    test('Phrase tokens are not swallowed into transitive object', () {
      final state = engine.recognize(
        'The old worker built a bridge yesterday.',
      );

      expectAgent(
        state,
        text: 'worker',
        determiner: theDeterminer,
        adjective: old,
      );
      expectObject(state, text: 'bridge', determiner: aDeterminer);
      expect(state.object!.text, isNot('bridge yesterday'));
      expect(state.timePhrase, yesterdayTimePhrase);
    });

    test('Passive perfect continuous keeps lexical build, not helper be', () {
      final state = engine.recognize(
        'Had the new bridge been being built by them?',
      );

      expect(state.voice, Voice.passive);
      expect(state.action, build);
      expect(state.action, isNot(be));
      expect(state.aspect, Aspect.perfectContinuous);
      expect(state.tense, Tense.past);
      expectObject(
        state,
        text: 'bridge',
        determiner: theDeterminer,
        adjective: newAdjective,
      );
      expectAgent(state, text: 'them');
    });

    test('Negative question preserves polarity and lexical action', () {
      final state = engine.recognize('Does he not work?');

      expectAgent(state, text: 'he');
      expect(state.action, work);
      expect(state.action, isNot(doVerb));
      expect(state.polarity, Polarity.negative);
      expect(state.sentenceForm, SentenceForm.question);
    });

    test('Passive question object excludes helper stack', () {
      final state = engine.recognize('Was the new bridge built by them?');

      expect(state.voice, Voice.passive);
      expectObject(
        state,
        text: 'bridge',
        determiner: theDeterminer,
        adjective: newAdjective,
      );
      expect(state.object!.text, isNot('the new bridge built'));
      expectAgent(state, text: 'them');
      expect(state.action, build);
    });

    test('Phrase recognition does not change one-predicate identity', () {
      final state = engine.recognize(
        'The beautiful teacher learned at school yesterday every day.',
      );

      expect(state.action, learn);
      expect(state.placePhrase, schoolPlacePhrase);
      expect(state.timePhrase, yesterdayTimePhrase);
      expect(state.frequencyPhrase, everyDayFrequencyPhrase);
      expect(state.object, isNull);
    });
  });
}
