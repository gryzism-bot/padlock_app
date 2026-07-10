import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/phrases/frequency_phrases.dart';
import 'package:padlock_app/data/phrases/manner_phrases.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/adjectives/appearance.dart';
import 'package:padlock_app/data/subjects/adjectives/emotions.dart';
import 'package:padlock_app/data/subjects/adjectives/quality.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/sport.dart' as sport;
import 'package:padlock_app/data/verbs/work.dart' hide clean;
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

    test('Lexical HAVE can stand as the one predicate', () {
      final state = engine.recognize('John has.');

      expectAgent(state, text: 'John');
      expect(state.action, have);
      expect(state.aspect, Aspect.simple);
      expect(state.tense, Tense.present);
    });

    test('Lexical DO can stand as the one predicate', () {
      final state = engine.recognize('Mary does.');

      expectAgent(state, text: 'Mary');
      expect(state.action, doVerb);
      expect(state.aspect, Aspect.simple);
      expect(state.tense, Tense.present);
    });

    test('Lexical BE recognizes noun complement', () {
      final state = engine.recognize('John is a doctor.');

      expectAgent(state, text: 'John');
      expect(state.action, be);
      expectComplement(state, text: 'doctor', determiner: aDeterminer);
      expect(state.aspect, Aspect.simple);
      expect(state.tense, Tense.present);
    });

    test('Lexical BE recognizes adjective complement', () {
      final state = engine.recognize('Mary was happy.');

      expectAgent(state, text: 'Mary');
      expect(state.action, be);
      expect(state.adjectiveComplement, happy);
      expect(state.aspect, Aspect.simple);
      expect(state.tense, Tense.past);
    });

    test('Lexical BE lets adjective homographs beat verb after BE', () {
      final state = engine.recognize('I am clean.');

      expectAgent(state, text: 'I');
      expect(state.action, be);
      expect(state.adjectiveComplement, clean);
      expect(state.aspect, Aspect.simple);
      expect(state.tense, Tense.present);
    });

    test('Lexical BE recognizes perfect adjective complement', () {
      final state = engine.recognize('John has been happy.');

      expectAgent(state, text: 'John');
      expect(state.action, be);
      expect(state.adjectiveComplement, happy);
      expect(state.aspect, Aspect.perfect);
      expect(state.tense, Tense.present);
    });

    test('Lexical BE question keeps subject out of complement', () {
      final state = engine.recognize('Is the young doctor happy?');

      expectAgent(
        state,
        text: 'doctor',
        determiner: theDeterminer,
        adjective: young,
      );
      expect(state.action, be);
      expect(state.adjectiveComplement, happy);
      expect(state.sentenceForm, SentenceForm.question);
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
      expect(state.passiveFocus, PassiveFocus.object);
      expectObject(state, text: 'bridge', determiner: theDeterminer);
      expectAgent(state, text: 'them');
      expect(state.action, build);
    });

    test('Passive subject becomes object, not active agent', () {
      final state = engine.recognize('The new bridge was built.');

      expect(state.voice, Voice.passive);
      expect(state.passiveFocus, PassiveFocus.object);
      expect(state.agent, isNull);
      expectObject(
        state,
        text: 'bridge',
        determiner: theDeterminer,
        adjective: newAdjective,
      );
    });

    test('Bare noun homograph yields to later passive predicate', () {
      final state = engine.recognize('Book was given to Mary by John.');

      expectObject(state, text: 'book');
      expectRecipient(state, text: 'mary');
      expectAgent(state, text: 'john');
      expect(state.action, give);
      expect(state.voice, Voice.passive);
      expect(state.passiveFocus, PassiveFocus.object);
    });

    test('Plural noun homograph yields to later passive predicate', () {
      final state = engine.recognize('Trains were built by them.');

      expectObject(state, text: 'trains');
      expectAgent(state, text: 'them');
      expect(state.action, build);
      expect(state.voice, Voice.passive);
      expect(state.passiveFocus, PassiveFocus.object);
    });

    test('Known proper nouns reconstruct their canonical data casing', () {
      final state = engine.recognize('John gave Mary a book.');

      expect(state.agent!.text, 'John');
      expect(state.recipient!.text, 'Mary');
      expect(state.action, give);
    });

    test('By manner phrase does not imply passive voice', () {
      final state = engine.recognize('John worked by hand.');

      expectAgent(state, text: 'john');
      expect(state.action, work);
      expect(state.voice, Voice.active);
      expect(state.agent!.text, isNot('hand'));
      expect(state.mannerPhrase, byHandMannerPhrase);
    });

    test('Recipient slot is recognized in active give frame', () {
      final state = engine.recognize('John gave Mary a book.');

      expectAgent(state, text: 'john');
      expectRecipient(state, text: 'mary');
      expectObject(state, text: 'book', determiner: aDeterminer);
      expect(state.action, give);
      expect(state.voice, Voice.active);
      expect(state.passiveFocus, isNull);
    });

    test('Expanded ditransitive data recognizes active recipient frame', () {
      final state = engine.recognize('John bought Mary a book.');

      expectAgent(state, text: 'john');
      expectRecipient(state, text: 'mary');
      expectObject(state, text: 'book', determiner: aDeterminer);
      expect(state.action, buy);
      expect(state.voice, Voice.active);
      expect(state.passiveFocus, isNull);
    });

    test('Recipient slot can be followed by object without determiner', () {
      final state = engine.recognize('John gave Mary books.');

      expectAgent(state, text: 'john');
      expectRecipient(state, text: 'mary');
      expectObject(state, text: 'books');
      expect(state.action, give);
      expect(state.voice, Voice.active);
    });

    test('Recipient boundary can include its own determiner and adjective', () {
      final state = engine.recognize('John gave the old teacher books.');

      expectAgent(state, text: 'john');
      expectRecipient(
        state,
        text: 'teacher',
        determiner: theDeterminer,
        adjective: old,
      );
      expectObject(state, text: 'books');
      expect(state.action, give);
      expect(state.voice, Voice.active);
    });

    test('Passive object focus recognizes recipient as to phrase', () {
      final state = engine.recognize('A book was given to Mary by John.');

      expectObject(state, text: 'book', determiner: aDeterminer);
      expectRecipient(state, text: 'mary');
      expectAgent(state, text: 'john');
      expect(state.action, give);
      expect(state.voice, Voice.passive);
      expect(state.passiveFocus, PassiveFocus.object);
    });

    test('Passive recipient focus recognizes object after verb chain', () {
      final state = engine.recognize('Mary was given a book by John.');

      expectRecipient(state, text: 'mary');
      expectObject(state, text: 'book', determiner: aDeterminer);
      expectAgent(state, text: 'john');
      expect(state.action, give);
      expect(state.voice, Voice.passive);
      expect(state.passiveFocus, PassiveFocus.recipient);
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

    test('Question subject excludes the multi-word predicate head', () {
      final state = engine.recognize('Do the old workers play football?');

      expectAgent(
        state,
        text: 'workers',
        determiner: theDeterminer,
        adjective: old,
      );
      expect(state.agent!.text, isNot('workers play'));
      expect(state.action, sport.playFootball);
      expect(state.sentenceForm, SentenceForm.question);
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

    test(
      'Negative question excludes NOT from multi-word predicate subject',
      () {
        final state = engine.recognize('Can Mary not play football?');

        expectAgent(state, text: 'Mary');
        expect(state.action, sport.playFootball);
        expect(state.polarity, Polarity.negative);
        expect(state.sentenceForm, SentenceForm.question);
      },
    );

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
