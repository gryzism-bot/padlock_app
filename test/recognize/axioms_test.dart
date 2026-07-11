import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/frequency_phrases.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/adjectives/appearance.dart';
import 'package:padlock_app/data/subjects/adjectives/quality.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart';
import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/education.dart';
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

  group('Recognition axioms', () {
    test('Question punctuation reconstructs question form', () {
      final state = engine.recognize('Does he work?');

      expect(state.sentenceForm, SentenceForm.question);
      expectAgent(state, text: 'he');
      expect(state.action, work);
    });

    test('DO support reconstructs present simple without becoming action', () {
      final state = engine.recognize('Does he work?');

      expect(state.action, work);
      expect(state.action, isNot(doVerb));
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.simple);
    });

    test('DID support reconstructs past simple without becoming action', () {
      final state = engine.recognize('Did the old worker build a bridge?');

      expectAgent(
        state,
        text: 'worker',
        determiner: theDeterminer,
        adjective: old,
      );
      expectObject(state, text: 'bridge', determiner: aDeterminer);
      expect(state.action, build);
      expect(state.action, isNot(doVerb));
      expect(state.tense, Tense.past);
      expect(state.aspect, Aspect.simple);
    });

    test('Modal reconstructs modal and leaves lexical action intact', () {
      final state = engine.recognize('They should build it.');

      expectAgent(state, text: 'they');
      expectObject(state, text: 'it');
      expect(state.modal, should);
      expect(state.action, build);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.simple);
    });

    test('CANNOT reconstructs can plus negative polarity', () {
      final state = engine.recognize('John cannot play football.');

      expectAgent(state, text: 'John');
      expect(state.modal, can);
      expect(state.polarity, Polarity.negative);
      expect(state.action, play);
      expect(state.object, football);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.simple);
    });

    test('HAVE auxiliary reconstructs perfect aspect', () {
      final state = engine.recognize('They have worked.');

      expectAgent(state, text: 'they');
      expect(state.action, work);
      expect(state.action, isNot(have));
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.perfect);
    });

    test('HAVE BEEN reconstructs perfect continuous aspect', () {
      final state = engine.recognize('They have been working.');

      expectAgent(state, text: 'they');
      expect(state.action, work);
      expect(state.action, isNot(be));
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.perfectContinuous);
    });

    test('BE auxiliary reconstructs continuous aspect', () {
      final state = engine.recognize('The beautiful teacher is teaching.');

      expectAgent(
        state,
        text: 'teacher',
        determiner: theDeterminer,
        adjective: beautiful,
      );
      expect(state.action, teach);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.continuous);
    });

    test('BE plus past participle reconstructs passive voice', () {
      final state = engine.recognize('The new bridge was built.');

      expectObject(
        state,
        text: 'bridge',
        determiner: theDeterminer,
        adjective: newAdjective,
      );
      expect(state.agent, isNull);
      expect(state.action, build);
      expect(state.voice, Voice.passive);
      expect(state.tense, Tense.past);
      expect(state.aspect, Aspect.simple);
    });

    test('BEEN BEING reconstructs passive perfect continuous', () {
      final state = engine.recognize(
        'Has the new bridge been being built by them?',
      );

      expectObject(
        state,
        text: 'bridge',
        determiner: theDeterminer,
        adjective: newAdjective,
      );
      expectAgent(state, text: 'them');
      expect(state.action, build);
      expect(state.voice, Voice.passive);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.perfectContinuous);
      expect(state.sentenceForm, SentenceForm.question);
    });

    test('BEEN plus past participle reconstructs passive perfect', () {
      final state = engine.recognize(
        'The new bridge will have been built by John.',
      );

      expectObject(
        state,
        text: 'bridge',
        determiner: theDeterminer,
        adjective: newAdjective,
      );
      expectAgent(state, text: 'John');
      expect(state.action, build);
      expect(state.voice, Voice.passive);
      expect(state.tense, Tense.future);
      expect(state.aspect, Aspect.perfect);
    });

    test('NOT reconstructs negative polarity', () {
      final state = engine.recognize('He does not work.');

      expectAgent(state, text: 'he');
      expect(state.action, work);
      expect(state.polarity, Polarity.negative);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.simple);
    });

    test('Phrase slots reconstruct independently of participants', () {
      final state = engine.recognize(
        'The beautiful teacher learned at school yesterday every day.',
      );

      expectAgent(
        state,
        text: 'teacher',
        determiner: theDeterminer,
        adjective: beautiful,
      );
      expect(state.object, isNull);
      expect(state.action, learn);
      expect(state.placePhrase, schoolPlacePhrase);
      expect(state.timePhrase, yesterdayTimePhrase);
      expect(state.frequencyPhrase, everyDayFrequencyPhrase);
    });

    test('Fronted frequency phrase stays outside the subject', () {
      final state = engine.recognize('Always you speak.');

      expectAgent(state, text: 'you');
      expect(state.action, speak);
      expect(state.frequencyPhrase, alwaysFrequencyPhrase);
    });
  });
}
