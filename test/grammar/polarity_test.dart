import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/third_person/animals.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/verbs/education.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/data/verbs/work.dart';

import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/voice.dart';

import 'package:padlock_app/models/sentence/sentence_state.dart';

import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';

import 'package:padlock_app/data/verbs/essential.dart';

void main() {
  final engine = GrammarEngine();

  group('Polarity', () {
    test('John does not work', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'John does not work.');
    });

    test('Mary did not study yesterday', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: study,
          tense: Tense.past,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
          timePhrase: yesterdayTimePhrase,
        ),
      );

      expect(sentence.text, 'Mary did not study yesterday.');
    });

    test('The dog is not running', () {
      final sentence = engine.generate(
        SentenceState(
          agent: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
          action: run,
          tense: Tense.present,
          aspect: Aspect.continuous,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'The dog is not running.');
    });

    test('John was not working', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.past,
          aspect: Aspect.continuous,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'John was not working.');
    });

    test('Mary has not learned', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: learn,
          tense: Tense.present,
          aspect: Aspect.perfect,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'Mary has not learned.');
    });

    test('The students have not studied', () {
      final sentence = engine.generate(
        SentenceState(
          agent: student.toNounPhrase(Number.plural, determiner: theDeterminer),
          action: study,
          tense: Tense.present,
          aspect: Aspect.perfect,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'The students have not studied.');
    });

    test('John will not work tomorrow', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.future,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
          modal: will,
          timePhrase: tomorrowTimePhrase,
        ),
      );

      expect(sentence.text, 'John will not work tomorrow.');
    });

    test('The teacher should not teach', () {
      final sentence = engine.generate(
        SentenceState(
          agent: teacher.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: teach,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: should,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'The teacher should not teach.');
    });

    test('The dog cannot run', () {
      final sentence = engine.generate(
        SentenceState(
          agent: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
          action: run,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: can,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'The dog cannot run.');
    });

    test('The house was not built', () {
      final sentence = engine.generate(
        SentenceState(
          object: house.toNounPhrase(Number.singular, determiner: theDeterminer),
          action: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'The house was not built.');
    });

    test('The houses were not built', () {
      final sentence = engine.generate(
        SentenceState(
          object: house.toNounPhrase(Number.plural, determiner: theDeterminer),
          action: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'The houses were not built.');
    });

    test('John has not been working', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'John has not been working.');
    });

    test('The children are not studying', () {
      final sentence = engine.generate(
        SentenceState(
          agent: child.toNounPhrase(Number.plural),
          action: study,
          tense: Tense.present,
          aspect: Aspect.continuous,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'Children are not studying.');
    });

    test('John does not work at school', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
          placePhrase: schoolPlacePhrase,
        ),
      );

      expect(sentence.text, 'John does not work at school.');
    });

    test('Mary did not travel yesterday', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: travel,
          tense: Tense.past,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
          timePhrase: yesterdayTimePhrase,
        ),
      );

      expect(sentence.text, 'Mary did not travel yesterday.');
    });

    test('The teacher may not travel', () {
      final sentence = engine.generate(
        SentenceState(
          agent: teacher.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: travel,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: may,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'The teacher may not travel.');
    });

    test('The bridge must not be built', () {
      final sentence = engine.generate(
        SentenceState(
          object: bridge.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: must,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'The bridge must not be built.');
    });

    test('The mouse has not gone', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mouse.toNounPhrase(Number.singular, determiner: theDeterminer),
          action: go,
          tense: Tense.present,
          aspect: Aspect.perfect,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'The mouse has not gone.');
    });

    test('Students do not study', () {
      final sentence = engine.generate(
        SentenceState(
          agent: student.toNounPhrase(Number.plural),
          action: study,
          tense: Tense.present,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'Students do not study.');
    });

    test('The dog was not running yesterday', () {
      final sentence = engine.generate(
        SentenceState(
          agent: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
          action: run,
          tense: Tense.past,
          aspect: Aspect.continuous,
          polarity: Polarity.negative,
          timePhrase: yesterdayTimePhrase,
        ),
      );

      expect(sentence.text, 'The dog was not running yesterday.');
    });
  });
}
