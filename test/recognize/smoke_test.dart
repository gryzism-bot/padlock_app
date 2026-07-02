import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/work.dart';
import 'package:padlock_app/engine/recognition_engine.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/voice.dart';

void main() {
  final engine = RecognitionEngine();

  group('Recognition Smoke', () {
    test('John works', () {
      final state = engine.recognize('John works.');

      expect(state.agent?.text, 'John');
      expect(state.action, work);
      expect(state.object, isNull);

      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.simple);

      expect(state.modal, noModal);
      expect(state.polarity, Polarity.positive);

      expect(state.voice, Voice.active);
      expect(state.sentenceForm, SentenceForm.statement);
    });

    test('John worked', () {
      final state = engine.recognize('John worked.');

      expect(state.agent?.text, 'John');
      expect(state.action, work);

      expect(state.tense, Tense.past);
      expect(state.aspect, Aspect.simple);

      expect(state.voice, Voice.active);
    });

    test('John has worked', () {
      final state = engine.recognize('John has worked.');

      expect(state.agent?.text, 'John');
      expect(state.action, work);

      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.perfect);

      expect(state.modal, noModal);
      expect(state.voice, Voice.active);
    });

    test('John is working', () {
      final state = engine.recognize('John is working.');

      expect(state.agent?.text, 'John');
      expect(state.action, work);

      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.continuous);

      expect(state.voice, Voice.active);
    });

    test('John has been working', () {
      final state = engine.recognize('John has been working.');

      expect(state.agent?.text, 'John');
      expect(state.action, work);

      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.perfectContinuous);

      expect(state.voice, Voice.active);
    });

    test('John can work', () {
      final state = engine.recognize('John can work.');

      expect(state.agent?.text, 'John');
      expect(state.action, work);

      expect(state.modal, can);
      expect(state.voice, Voice.active);
    });

    test('John does not work', () {
      final state = engine.recognize('John does not work.');

      expect(state.agent?.text, 'John');
      expect(state.action, work);

      expect(state.polarity, Polarity.negative);
      expect(state.voice, Voice.active);
    });

    test('The house was built', () {
      final state = engine.recognize('The house was built.');

      expect(state.object?.text, 'house');
      expect(state.agent, isNull);

      expect(state.action, build);

      expect(state.voice, Voice.passive);

      expect(state.tense, Tense.past);
      expect(state.aspect, Aspect.simple);
    });

    test('The house was built by John', () {
      final state = engine.recognize('The house was built by John.');

      expect(state.object?.text, 'house');
      expect(state.agent?.text, 'John');

      expect(state.action, build);

      expect(state.voice, Voice.passive);
    });

    test('John worked at home yesterday', () {
      final state = engine.recognize('John worked at home yesterday.');

      expect(state.agent?.text, 'John');
      expect(state.action, work);

      expect(state.placePhrase, home);
      expect(state.timePhrase, yesterday);
    });
  });
}
