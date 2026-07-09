import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/cooking.dart';
import 'package:padlock_app/data/verbs/education.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/data/verbs/sport.dart' as sport;
import 'package:padlock_app/data/verbs/travel.dart' as travel_data;
import 'package:padlock_app/data/verbs/work.dart' hide sell;
import 'package:padlock_app/engine/recognition_engine.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/grammar/voice.dart';

import 'helpers.dart';

void main() {
  final engine = RecognitionEngine();

  group('Recognition Irregular verbs', () {
    test('John went home yesterday', () {
      final state = engine.recognize('John went home yesterday.');

      expectAgent(state, text: 'john');
      expect(state.action, go);
      expect(state.tense, Tense.past);
      expect(state.aspect, Aspect.simple);
      expect(state.placePhrase, homePlacePhrase);
      expect(state.timePhrase, yesterdayTimePhrase);
    });

    test('Mary has eaten', () {
      final state = engine.recognize('Mary has eaten.');

      expectAgent(state, text: 'mary');
      expect(state.action, eat);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.perfect);
    });

    test('The dog ran', () {
      final state = engine.recognize('The dog ran.');

      expectAgent(state, text: 'dog', determiner: theDeterminer);
      expect(state.action, run);
      expect(state.tense, Tense.past);
      expect(state.aspect, Aspect.simple);
    });

    test('John has written', () {
      final state = engine.recognize('John has written.');

      expectAgent(state, text: 'john');
      expect(state.action, write);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.perfect);
    });

    test('Mary drank yesterday', () {
      final state = engine.recognize('Mary drank yesterday.');

      expectAgent(state, text: 'mary');
      expect(state.action, drink);
      expect(state.tense, Tense.past);
      expect(state.timePhrase, yesterdayTimePhrase);
    });

    test('John has driven', () {
      final state = engine.recognize('John has driven.');

      expectAgent(state, text: 'john');
      expect(state.action, drive);
      expect(state.aspect, Aspect.perfect);
    });

    test('The teacher spoke', () {
      final state = engine.recognize('The teacher spoke.');

      expectAgent(state, text: 'teacher', determiner: theDeterminer);
      expect(state.action, speak);
      expect(state.tense, Tense.past);
    });

    test('Mary found the dog', () {
      final state = engine.recognize('Mary found the dog.');

      expectAgent(state, text: 'mary');
      expectObject(state, text: 'dog', determiner: theDeterminer);
      expect(state.action, findVerb);
      expect(state.tense, Tense.past);
    });

    test('John has taken', () {
      final state = engine.recognize('John has taken.');

      expectAgent(state, text: 'john');
      expect(state.action, take);
      expect(state.aspect, Aspect.perfect);
    });

    test('John has done', () {
      final state = engine.recognize('John has done.');

      expectAgent(state, text: 'john');
      expect(state.action, doVerb);
      expect(state.aspect, Aspect.perfect);
    });

    test('The house was built by John', () {
      final state = engine.recognize('The house was built by John.');

      expectObject(state, text: 'house', determiner: theDeterminer);
      expectAgent(state, text: 'john');
      expect(state.action, build);
      expect(state.voice, Voice.passive);
      expect(state.tense, Tense.past);
    });

    test('John can swim', () {
      final state = engine.recognize('John can swim.');

      expectAgent(state, text: 'john');
      expect(state.action, swim);
      expect(state.modal, can);
    });

    test('Mary has seen', () {
      final state = engine.recognize('Mary has seen.');

      expectAgent(state, text: 'mary');
      expect(state.action, see);
      expect(state.aspect, Aspect.perfect);
    });

    test('Mary has had', () {
      final state = engine.recognize('Mary has had.');

      expectAgent(state, text: 'mary');
      expect(state.action, have);
      expect(state.aspect, Aspect.perfect);
    });

    test('Cat got John at home', () {
      final state = engine.recognize('Cat got John at home.');

      expectAgent(state, text: 'cat');
      expectObject(state, text: 'john');
      expect(state.action, get);
      expect(state.tense, Tense.past);
      expect(state.placePhrase, homePlacePhrase);
    });

    test(
      'John has been',
      () {
        final state = engine.recognize('John has been.');

        expectAgent(state, text: 'john');
        expect(state.action, be);
        expect(state.aspect, Aspect.perfect);
      },
      skip: 'Lexical BE after HAVE is still parsed as a helper stack',
    );

    test(
      'John read yesterday',
      () {
        final state = engine.recognize('John read yesterday.');

        expectAgent(state, text: 'john');
        expect(state.action, read);
        expect(state.tense, Tense.past);
        expect(state.timePhrase, yesterdayTimePhrase);
      },
      skip: 'READ present/past homograph needs phrase-aware tense inference',
    );

    test('Broader irregular data recognizes past simple forms', () {
      final cases = [
        (
          sentence: 'Mary left yesterday.',
          action: travel_data.leave,
          agent: 'mary',
          agentDeterminer: null,
          object: null,
        ),
        (
          sentence: 'The manager led.',
          action: lead,
          agent: 'manager',
          agentDeterminer: theDeterminer,
          object: null,
        ),
        (
          sentence: 'John threw the ball.',
          action: sport.throwVerb,
          agent: 'john',
          agentDeterminer: null,
          object: 'ball',
        ),
        (
          sentence: 'Mary caught the ball.',
          action: sport.catchVerb,
          agent: 'mary',
          agentDeterminer: null,
          object: 'ball',
        ),
        (
          sentence: 'John hit the ball.',
          action: sport.hit,
          agent: 'john',
          agentDeterminer: null,
          object: 'ball',
        ),
        (
          sentence: 'John won.',
          action: sport.win,
          agent: 'john',
          agentDeterminer: null,
          object: null,
        ),
        (
          sentence: 'The glass froze.',
          action: freeze,
          agent: 'glass',
          agentDeterminer: theDeterminer,
          object: null,
        ),
        (
          sentence: 'The bird flew.',
          action: fly,
          agent: 'bird',
          agentDeterminer: theDeterminer,
          object: null,
        ),
        (
          sentence: 'John drove the car.',
          action: drive,
          agent: 'john',
          agentDeterminer: null,
          object: 'car',
        ),
        (
          sentence: 'Mary rode the bicycle.',
          action: ride,
          agent: 'mary',
          agentDeterminer: null,
          object: 'bicycle',
        ),
        (
          sentence: 'The child fell.',
          action: fall,
          agent: 'child',
          agentDeterminer: theDeterminer,
          object: null,
        ),
        (
          sentence: 'The teacher stood.',
          action: stand,
          agent: 'teacher',
          agentDeterminer: theDeterminer,
          object: null,
        ),
        (
          sentence: 'The teacher sat.',
          action: sit,
          agent: 'teacher',
          agentDeterminer: theDeterminer,
          object: null,
        ),
        (
          sentence: 'The cat lay.',
          action: lie,
          agent: 'cat',
          agentDeterminer: theDeterminer,
          object: null,
        ),
      ];

      for (final entry in cases) {
        final state = engine.recognize(entry.sentence);

        expectAgent(
          state,
          text: entry.agent,
          determiner: entry.agentDeterminer,
        );
        if (entry.object != null) {
          expectObject(state, text: entry.object!, determiner: theDeterminer);
        } else {
          expect(state.object, isNull);
        }
        expect(state.action, entry.action);
        expect(state.tense, Tense.past);
        expect(state.aspect, Aspect.simple);
      }
    });

    test('Broader irregular data recognizes past participles', () {
      final cases = [
        (
          sentence: 'John has thrown.',
          action: sport.throwVerb,
          agent: 'john',
          agentDeterminer: null,
        ),
        (
          sentence: 'John has swum.',
          action: swim,
          agent: 'john',
          agentDeterminer: null,
        ),
        (
          sentence: 'The bird has flown.',
          action: fly,
          agent: 'bird',
          agentDeterminer: theDeterminer,
        ),
        (
          sentence: 'Mary has ridden.',
          action: ride,
          agent: 'mary',
          agentDeterminer: null,
        ),
        (
          sentence: 'The child has fallen.',
          action: fall,
          agent: 'child',
          agentDeterminer: theDeterminer,
        ),
        (
          sentence: 'The cat has lain.',
          action: lie,
          agent: 'cat',
          agentDeterminer: theDeterminer,
        ),
      ];

      for (final entry in cases) {
        final state = engine.recognize(entry.sentence);

        expectAgent(
          state,
          text: entry.agent,
          determiner: entry.agentDeterminer,
        );
        expect(state.action, entry.action);
        expect(state.tense, Tense.present);
        expect(state.aspect, Aspect.perfect);
      }
    });

    test('Irregular verb recognizes every tense and aspect cell', () {
      final cases = [
        (sentence: 'John writes.', tense: Tense.present, aspect: Aspect.simple),
        (sentence: 'John wrote.', tense: Tense.past, aspect: Aspect.simple),
        (
          sentence: 'John will write.',
          tense: Tense.future,
          aspect: Aspect.simple,
        ),
        (
          sentence: 'John is writing.',
          tense: Tense.present,
          aspect: Aspect.continuous,
        ),
        (
          sentence: 'John was writing.',
          tense: Tense.past,
          aspect: Aspect.continuous,
        ),
        (
          sentence: 'John will be writing.',
          tense: Tense.future,
          aspect: Aspect.continuous,
        ),
        (
          sentence: 'John has written.',
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
        (
          sentence: 'John had written.',
          tense: Tense.past,
          aspect: Aspect.perfect,
        ),
        (
          sentence: 'John will have written.',
          tense: Tense.future,
          aspect: Aspect.perfect,
        ),
        (
          sentence: 'John has been writing.',
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
        ),
        (
          sentence: 'John had been writing.',
          tense: Tense.past,
          aspect: Aspect.perfectContinuous,
        ),
        (
          sentence: 'John will have been writing.',
          tense: Tense.future,
          aspect: Aspect.perfectContinuous,
        ),
      ];

      for (final entry in cases) {
        final state = engine.recognize(entry.sentence);

        expectAgent(state, text: 'john');
        expect(state.action, write);
        expect(state.tense, entry.tense);
        expect(state.aspect, entry.aspect);
      }
    });

    test(
      'Popular irregular verbs recognize through every tense and aspect',
      () {
        final verbs = [
          go,
          come,
          eat,
          drink,
          run,
          swim,
          fly,
          see,
          take,
          give,
          buy,
          speak,
          fall,
          stand,
          sit,
          begin,
          breakVerb,
          know,
          make,
          get,
          sleep,
          meet,
          sell,
          sport.throwVerb,
          sport.catchVerb,
          sport.win,
          travel_data.leave,
          drive,
          ride,
          teach,
        ];

        for (final verb in verbs) {
          for (final tense in Tense.values) {
            for (final aspect in Aspect.values) {
              final sentence = _expectedActiveSentence(verb, tense, aspect);
              final state = engine.recognize(sentence);

              expectAgent(state, text: 'john');
              expect(state.action, verb, reason: sentence);
              expect(state.tense, tense, reason: sentence);
              expect(state.aspect, aspect, reason: sentence);
            }
          }
        }
      },
    );
  });
}

String _expectedActiveSentence(Verb verb, Tense tense, Aspect aspect) {
  final chain = switch ((tense, aspect)) {
    (Tense.present, Aspect.simple) => verb.presentThirdPerson,
    (Tense.past, Aspect.simple) => verb.pastSimple,
    (Tense.future, Aspect.simple) => 'will ${verb.infinitive}',
    (Tense.present, Aspect.continuous) => 'is ${verb.ingForm}',
    (Tense.past, Aspect.continuous) => 'was ${verb.ingForm}',
    (Tense.future, Aspect.continuous) => 'will be ${verb.ingForm}',
    (Tense.present, Aspect.perfect) => 'has ${verb.pastParticiple}',
    (Tense.past, Aspect.perfect) => 'had ${verb.pastParticiple}',
    (Tense.future, Aspect.perfect) => 'will have ${verb.pastParticiple}',
    (Tense.present, Aspect.perfectContinuous) => 'has been ${verb.ingForm}',
    (Tense.past, Aspect.perfectContinuous) => 'had been ${verb.ingForm}',
    (Tense.future, Aspect.perfectContinuous) =>
      'will have been ${verb.ingForm}',
  };

  return 'John $chain.';
}
