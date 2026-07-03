import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/third_person/animals.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/cooking.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/data/verbs/work.dart';

import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/voice.dart';

import 'package:padlock_app/models/sentence/sentence_state.dart';

import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';

import 'package:padlock_app/data/verbs/essential.dart';

void main() {
  final engine = GrammarEngine();

  group('Irregular verbs', () {
    test('John went home yesterday', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: go,
          tense: Tense.past,
          aspect: Aspect.simple,
          placePhrase: homePlacePhrase,
          timePhrase: yesterdayTimePhrase,
        ),
      );

      expect(sentence.text, 'John went home yesterday.');
    });

    test('Mary has eaten', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: eat,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'Mary has eaten.');
    });

    test('The dog ran', () {
      final sentence = engine.generate(
        SentenceState(
          agent: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
          action: run,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'The dog ran.');
    });

    test('John has written', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: write,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'John has written.');
    });

    test('Mary drank yesterday', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: drink,
          tense: Tense.past,
          aspect: Aspect.simple,
          timePhrase: yesterdayTimePhrase,
        ),
      );

      expect(sentence.text, 'Mary drank yesterday.');
    });

    test('John has driven', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: drive,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'John has driven.');
    });

    test('The teacher spoke', () {
      final sentence = engine.generate(
        SentenceState(
          agent: teacher.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: speak,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'The teacher spoke.');
    });

    test('Mary found the dog', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: findVerb,
          object: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'Mary found the dog.');
    });

    test('John has taken', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: take,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'John has taken.');
    });

    test('The child slept', () {
      final sentence = engine.generate(
        SentenceState(
          agent: child.toNounPhrase(Number.singular),
          action: sleep,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'Child slept.');
    });

    test('John knew', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: know,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'John knew.');
    });

    test('Mary has bought', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: buy,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'Mary has bought.');
    });

    test('The house was built', () {
      final state = SentenceState(
        agent: john.toNounPhrase(Number.singular),
        object: house.toNounPhrase(Number.singular, determiner: theDeterminer),
        action: build,
        tense: Tense.past,
        aspect: Aspect.simple,
        voice: Voice.passive,
      );

      expect(engine.generate(state).text, 'The house was built by John.');
    });

    test('John has done', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: doVerb,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'John has done.');
    });

    test('Mary came yesterday', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: come,
          tense: Tense.past,
          aspect: Aspect.simple,
          timePhrase: yesterdayTimePhrase,
        ),
      );

      expect(sentence.text, 'Mary came yesterday.');
    });

    test('The boy began', () {
      final sentence = engine.generate(
        SentenceState(
          agent: boy.toNounPhrase(Number.singular),
          action: begin,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'Boy began.');
    });

    test('The glass broke', () {
      final sentence = engine.generate(
        SentenceState(
          agent: glass.toNounPhrase(Number.singular),
          action: breakVerb,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'Glass broke.');
    });

    test('John can swim', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: swim,
          modal: can,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'John can swim.');
    });

    test('Mary has seen', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: see,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'Mary has seen.');
    });

    test('The choir sang', () {
      final sentence = engine.generate(
        SentenceState(
          agent: choir.toNounPhrase(Number.singular),
          action: sing,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'Choir sang.');
    });

    test('John has been', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: be,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'John has been.');
    });

    test('Mary has had', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: have,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'Mary has had.');
    });

    test('Cat got John at home.', () {
      final sentence = engine.generate(
        SentenceState(
          agent: cat.toNounPhrase(Number.singular),
          action: get,
          object: john.toNounPhrase(Number.singular),
          tense: Tense.past,
          aspect: Aspect.simple,
          placePhrase: homePlacePhrase,
        ),
      );

      expect(sentence.text, 'Cat got John at home.');
    });

    test('John read yesterday', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: read,
          tense: Tense.past,
          aspect: Aspect.simple,
          timePhrase: yesterdayTimePhrase,
        ),
      );

      expect(sentence.text, 'John read yesterday.');
    });
  });
}
