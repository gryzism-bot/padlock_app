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
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';

import 'package:padlock_app/data/verbs/essential.dart';

void main() {
  final engine = GrammarEngine();

  group('Modal verbs', () {
    test('John can work', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: can,
        ),
      );

      expect(sentence.text, 'John can work.');
    });

    test('Mary should study', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: study,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: should,
        ),
      );

      expect(sentence.text, 'Mary should study.');
    });

    test('The dog must run', () {
      final sentence = engine.generate(
        SentenceState(
          agent: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
          action: run,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: must,
        ),
      );

      expect(sentence.text, 'The dog must run.');
    });

    test('The students may learn', () {
      final sentence = engine.generate(
        SentenceState(
          agent: student.toNounPhrase(Number.plural, determiner: theDeterminer),
          action: learn,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: may,
        ),
      );

      expect(sentence.text, 'The students may learn.');
    });

    test('John might travel', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: travel,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: might,
        ),
      );

      expect(sentence.text, 'John might travel.');
    });

    test('Mary will work', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.future,
          aspect: Aspect.simple,
          modal: will,
        ),
      );

      expect(sentence.text, 'Mary will work.');
    });

    test('The teacher can teach at school', () {
      final sentence = engine.generate(
        SentenceState(
          agent: teacher.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: teach,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: can,
          placePhrase: school,
        ),
      );

      expect(sentence.text, 'The teacher can teach at school.');
    });

    test('John should work tomorrow', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: should,
          timePhrase: tomorrow,
        ),
      );

      expect(sentence.text, 'John should work tomorrow.');
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

    test('Mary should not study', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: study,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: should,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'Mary should not study.');
    });

    test('Can John work?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: can,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Can John work?');
    });

    test('Should Mary study?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: study,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: should,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Should Mary study?');
    });

    test('Must the dog run?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
          action: run,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: must,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Must the dog run?');
    });

    test('The house can be built', () {
      final sentence = engine.generate(
        SentenceState(
          object: house.toNounPhrase(Number.singular, determiner: theDeterminer),
          action: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: can,
        ),
      );

      expect(sentence.text, 'The house can be built.');
    });

    test('Should the house be built?', () {
      final sentence = engine.generate(
        SentenceState(
          object: house.toNounPhrase(Number.singular, determiner: theDeterminer),
          action: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: should,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Should the house be built?');
    });

    test('The bridge must be built', () {
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
        ),
      );

      expect(sentence.text, 'The bridge must be built.');
    });

    test('The students may travel tomorrow', () {
      final sentence = engine.generate(
        SentenceState(
          agent: student.toNounPhrase(Number.plural, determiner: theDeterminer),
          action: travel,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: may,
          timePhrase: tomorrow,
        ),
      );

      expect(sentence.text, 'The students may travel tomorrow.');
    });

    test('John might not work', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: might,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'John might not work.');
    });

    test('The teacher will teach tomorrow', () {
      final sentence = engine.generate(
        SentenceState(
          agent: teacher.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: teach,
          tense: Tense.future,
          aspect: Aspect.simple,
          modal: will,
          timePhrase: tomorrow,
        ),
      );

      expect(sentence.text, 'The teacher will teach tomorrow.');
    });
  });
}
