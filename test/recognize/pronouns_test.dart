import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
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

  group('Recognition Modal', () {});

  test('I work', () {
    final state = engine.recognize('I work.');

    expectAgent(state, text: 'I');

    expect(state.action, work);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);
  });

  test('You work', () {
    final state = engine.recognize('You work.');

    expectAgent(state, text: 'you');

    expect(state.action, work);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);
  });

  test('He works', () {
    final state = engine.recognize('He works.');

    expectAgent(state, text: 'he');

    expect(state.action, work);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);
  });

  test('She works', () {
    final state = engine.recognize('She works.');

    expectAgent(state, text: 'she');

    expect(state.action, work);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);
  });

  test('It works', () {
    final state = engine.recognize('It works.');

    expectAgent(state, text: 'it');

    expect(state.action, work);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);
  });

  test('We work', () {
    final state = engine.recognize('We work.');

    expectAgent(state, text: 'we');

    expect(state.action, work);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);
  });

  test('They work', () {
    final state = engine.recognize('They work.');

    expectAgent(state, text: 'they');

    expect(state.action, work);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);
  });

  test('He built it', () {
    final state = engine.recognize('He built it.');

    expectAgent(state, text: 'he');

    expectObject(state, text: 'it');

    expect(state.action, build);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.simple);
  });

  test('They built it', () {
    final state = engine.recognize('They built it.');

    expectAgent(state, text: 'they');

    expectObject(state, text: 'it');

    expect(state.action, build);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.simple);
  });

  test('I am working', () {
    final state = engine.recognize('I am working.');

    expectAgent(state, text: 'I');

    expect(state.action, work);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.continuous);
  });

  test('You are working', () {
    final state = engine.recognize('You are working.');

    expectAgent(state, text: 'you');

    expect(state.action, work);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.continuous);
  });

  test('He is working', () {
    final state = engine.recognize('He is working.');

    expectAgent(state, text: 'he');

    expect(state.action, work);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.continuous);
  });

  test('We are working', () {
    final state = engine.recognize('We are working.');

    expectAgent(state, text: 'we');

    expect(state.action, work);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.continuous);
  });

  test('They have worked', () {
    final state = engine.recognize('They have worked.');

    expectAgent(state, text: 'they');

    expect(state.action, work);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.perfect);
  });

  test('He has worked', () {
    final state = engine.recognize('He has worked.');

    expectAgent(state, text: 'he');

    expect(state.action, work);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.perfect);
  });

  test('They had worked', () {
    final state = engine.recognize('They had worked.');

    expectAgent(state, text: 'they');

    expect(state.action, work);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.perfect);
  });

  test('I will work', () {
    final state = engine.recognize('I will work.');

    expectAgent(state, text: 'I');

    expect(state.action, work);

    expect(state.tense, Tense.future);
    expect(state.aspect, Aspect.simple);
  });

  test('He can work', () {
    final state = engine.recognize('He can work.');

    expectAgent(state, text: 'he');

    expect(state.action, work);

    expect(state.modal, can);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);
  });

  test('They should build it', () {
    final state = engine.recognize('They should build it.');

    expectAgent(state, text: 'they');

    expectObject(state, text: 'it');

    expect(state.action, build);

    expect(state.modal, should);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);
  });

  test('It was built', () {
    final state = engine.recognize('It was built.');

    expectObject(state, text: 'it');

    expect(state.agent, isNull);

    expect(state.action, build);

    expect(state.voice, Voice.passive);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.simple);
  });

  test('It was built by them', () {
    final state = engine.recognize('It was built by them.');

    expectObject(state, text: 'it');

    expectAgent(state, text: 'them');

    expect(state.action, build);

    expect(state.voice, Voice.passive);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.simple);
  });

  test('Does he work?', () {
    final state = engine.recognize('Does he work?');

    expectAgent(state, text: 'he');

    expect(state.action, work);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);
  });

  test('Do they work?', () {
    final state = engine.recognize('Do they work?');

    expectAgent(state, text: 'they');

    expect(state.action, work);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.simple);
  });

  test('Is she working?', () {
    final state = engine.recognize('Is she working?');

    expectAgent(state, text: 'she');

    expect(state.action, work);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.continuous);
  });

  test('Have they worked?', () {
    final state = engine.recognize('Have they worked?');

    expectAgent(state, text: 'they');

    expect(state.action, work);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.perfect);
  });

  test('Will we work?', () {
    final state = engine.recognize('Will we work?');

    expectAgent(state, text: 'we');

    expect(state.action, work);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.tense, Tense.future);
    expect(state.aspect, Aspect.simple);
  });

  test('I have been working', () {
    final state = engine.recognize('I have been working.');

    expectAgent(state, text: 'I');

    expect(state.action, work);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.perfectContinuous);
  });

  test('We have been working', () {
    final state = engine.recognize('We have been working.');

    expectAgent(state, text: 'we');

    expect(state.action, work);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.perfectContinuous);
  });

  test('He has been working', () {
    final state = engine.recognize('He has been working.');

    expectAgent(state, text: 'he');

    expect(state.action, work);

    expect(state.tense, Tense.present);
    expect(state.aspect, Aspect.perfectContinuous);
  });

  test('They had been working', () {
    final state = engine.recognize('They had been working.');

    expectAgent(state, text: 'they');

    expect(state.action, work);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.perfectContinuous);
  });

  test('Will they work?', () {
    final state = engine.recognize('Will they work?');

    expectAgent(state, text: 'they');

    expect(state.action, work);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.tense, Tense.future);
  });

  test('Can I work?', () {
    final state = engine.recognize('Can I work?');

    expectAgent(state, text: 'I');

    expect(state.action, work);

    expect(state.modal, can);

    expect(state.sentenceForm, SentenceForm.question);
  });

  test('Should we work?', () {
    final state = engine.recognize('Should we work?');

    expectAgent(state, text: 'we');

    expect(state.action, work);

    expect(state.modal, should);

    expect(state.sentenceForm, SentenceForm.question);
  });

  test('May he work?', () {
    final state = engine.recognize('May he work?');

    expectAgent(state, text: 'he');

    expect(state.action, work);

    expect(state.modal, may);

    expect(state.sentenceForm, SentenceForm.question);
  });

  test('I do not work', () {
    final state = engine.recognize('I do not work.');

    expectAgent(state, text: 'I');

    expect(state.action, work);

    expect(state.polarity, Polarity.negative);
  });

  test('He does not work', () {
    final state = engine.recognize('He does not work.');

    expectAgent(state, text: 'he');

    expect(state.action, work);

    expect(state.polarity, Polarity.negative);
  });

  test('They do not work', () {
    final state = engine.recognize('They do not work.');

    expectAgent(state, text: 'they');

    expect(state.action, work);

    expect(state.polarity, Polarity.negative);
  });

  test('I was working', () {
    final state = engine.recognize('I was working.');

    expectAgent(state, text: 'I');

    expect(state.action, work);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.continuous);
  });

  test('We were working', () {
    final state = engine.recognize('We were working.');

    expectAgent(state, text: 'we');

    expect(state.action, work);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.continuous);
  });

  test('They were working', () {
    final state = engine.recognize('They were working.');

    expectAgent(state, text: 'they');

    expect(state.action, work);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.continuous);
  });

  test('Was I working?', () {
    final state = engine.recognize('Was I working?');

    expectAgent(state, text: 'I');

    expect(state.action, work);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.continuous);
  });

  test('Were they working?', () {
    final state = engine.recognize('Were they working?');

    expectAgent(state, text: 'they');

    expect(state.action, work);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.continuous);
  });

  test('Have I been working?', () {
    final state = engine.recognize('Have I been working?');

    expectAgent(state, text: 'I');

    expect(state.action, work);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.aspect, Aspect.perfectContinuous);
  });

  test('Has he been working?', () {
    final state = engine.recognize('Has he been working?');

    expectAgent(state, text: 'he');

    expect(state.action, work);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.aspect, Aspect.perfectContinuous);
  });

  test('Had they been working?', () {
    final state = engine.recognize('Had they been working?');

    expectAgent(state, text: 'they');

    expect(state.action, work);

    expect(state.sentenceForm, SentenceForm.question);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.perfectContinuous);
  });
}
