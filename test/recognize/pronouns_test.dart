import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/work.dart';
import 'package:padlock_app/engine/recognition_engine.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
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

  test('Object pronouns recognize object case', () {
    final cases = [
      (sentence: 'He saw me.', agent: 'he', object: 'me'),
      (sentence: 'He saw you.', agent: 'he', object: 'you'),
      (sentence: 'She saw him.', agent: 'she', object: 'him'),
      (sentence: 'He saw her.', agent: 'he', object: 'her'),
      (sentence: 'He saw it.', agent: 'he', object: 'it'),
      (sentence: 'He saw us.', agent: 'he', object: 'us'),
      (sentence: 'He saw them.', agent: 'he', object: 'them'),
    ];

    for (final entry in cases) {
      final state = engine.recognize(entry.sentence);

      expectAgent(state, text: entry.agent);
      expectObject(state, text: entry.object);
      expect(state.action, see);
      expect(state.tense, Tense.past);
      expect(state.aspect, Aspect.simple);
    }
  });

  test('Passive agents recognize object-case pronouns', () {
    final cases = [
      (sentence: 'It was built by me.', agent: 'me'),
      (sentence: 'It was built by you.', agent: 'you'),
      (sentence: 'It was built by him.', agent: 'him'),
      (sentence: 'It was built by her.', agent: 'her'),
      (sentence: 'It was built by it.', agent: 'it'),
      (sentence: 'It was built by us.', agent: 'us'),
      (sentence: 'It was built by them.', agent: 'them'),
    ];

    for (final entry in cases) {
      final state = engine.recognize(entry.sentence);

      expectObject(state, text: 'it');
      expectAgent(state, text: entry.agent);
      expect(state.action, build);
      expect(state.voice, Voice.passive);
      expect(state.tense, Tense.past);
      expect(state.aspect, Aspect.simple);
    }
  });

  test('Recipient pronouns recognize object case', () {
    final cases = [
      (sentence: 'He gave me a book.', agent: 'he', recipient: 'me'),
      (sentence: 'He gave you a book.', agent: 'he', recipient: 'you'),
      (sentence: 'She gave him a book.', agent: 'she', recipient: 'him'),
      (sentence: 'He gave her a book.', agent: 'he', recipient: 'her'),
      (sentence: 'He gave it a book.', agent: 'he', recipient: 'it'),
      (sentence: 'He gave us a book.', agent: 'he', recipient: 'us'),
      (sentence: 'He gave them a book.', agent: 'he', recipient: 'them'),
    ];

    for (final entry in cases) {
      final state = engine.recognize(entry.sentence);

      expectAgent(state, text: entry.agent);
      expectRecipient(state, text: entry.recipient);
      expectObject(state, text: 'book', determiner: aDeterminer);
      expect(state.action, give);
      expect(state.tense, Tense.past);
      expect(state.aspect, Aspect.simple);
    }
  });

  test('Passive ditransitive pronouns recognize focus and case', () {
    final objectFocus = engine.recognize('A book was given to me by him.');
    final recipientFocus = engine.recognize('I was given a book by him.');

    expectObject(objectFocus, text: 'book', determiner: aDeterminer);
    expectRecipient(objectFocus, text: 'me');
    expectAgent(objectFocus, text: 'him');
    expect(objectFocus.voice, Voice.passive);
    expect(objectFocus.passiveFocus, PassiveFocus.object);

    expectRecipient(recipientFocus, text: 'I');
    expectObject(recipientFocus, text: 'book', determiner: aDeterminer);
    expectAgent(recipientFocus, text: 'him');
    expect(recipientFocus.voice, Voice.passive);
    expect(recipientFocus.passiveFocus, PassiveFocus.recipient);
  });
}
