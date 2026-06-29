import 'package:flutter_test/flutter_test.dart';
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
import 'package:padlock_app/models/grammar/verb/modal.dart';
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
          subject: john.toSubject(Number.singular),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.can,
        ),
      );

      expect(sentence.text, 'John can work.');
    });

    test('Mary should study', () {
      final sentence = engine.generate(
        SentenceState(
          subject: mary.toSubject(Number.singular),
          verb: study,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.should,
        ),
      );

      expect(sentence.text, 'Mary should study.');
    });

    test('The dog must run', () {
      final sentence = engine.generate(
        SentenceState(
          subject: dog.toSubject(Number.singular, determiner: theDeterminer),
          verb: run,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.must,
        ),
      );

      expect(sentence.text, 'The dog must run.');
    });

    test('The students may learn', () {
      final sentence = engine.generate(
        SentenceState(
          subject: student.toSubject(Number.plural, determiner: theDeterminer),
          verb: learn,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.may,
        ),
      );

      expect(sentence.text, 'The students may learn.');
    });

    test('John might travel', () {
      final sentence = engine.generate(
        SentenceState(
          subject: john.toSubject(Number.singular),
          verb: travel,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.might,
        ),
      );

      expect(sentence.text, 'John might travel.');
    });

    test('Mary will work', () {
      final sentence = engine.generate(
        SentenceState(
          subject: mary.toSubject(Number.singular),
          verb: work,
          tense: Tense.future,
          aspect: Aspect.simple,
          modal: Modal.will,
        ),
      );

      expect(sentence.text, 'Mary will work.');
    });

    test('The teacher can teach at school', () {
      final sentence = engine.generate(
        SentenceState(
          subject: teacher.toSubject(
            Number.singular,
            determiner: theDeterminer,
          ),
          verb: teach,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.can,
          placePhrase: atSchool,
        ),
      );

      expect(sentence.text, 'The teacher can teach at school.');
    });

    test('John should work tomorrow', () {
      final sentence = engine.generate(
        SentenceState(
          subject: john.toSubject(Number.singular),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.should,
          timePhrase: tomorrow,
        ),
      );

      expect(sentence.text, 'John should work tomorrow.');
    });

    test('The dog cannot run', () {
      final sentence = engine.generate(
        SentenceState(
          subject: dog.toSubject(Number.singular, determiner: theDeterminer),
          verb: run,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.can,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'The dog cannot run.');
    });

    test('Mary should not study', () {
      final sentence = engine.generate(
        SentenceState(
          subject: mary.toSubject(Number.singular),
          verb: study,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.should,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'Mary should not study.');
    });

    test('Can John work?', () {
      final sentence = engine.generate(
        SentenceState(
          subject: john.toSubject(Number.singular),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.can,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Can John work?');
    });

    test('Should Mary study?', () {
      final sentence = engine.generate(
        SentenceState(
          subject: mary.toSubject(Number.singular),
          verb: study,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.should,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Should Mary study?');
    });

    test('Must the dog run?', () {
      final sentence = engine.generate(
        SentenceState(
          subject: dog.toSubject(Number.singular, determiner: theDeterminer),
          verb: run,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.must,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Must the dog run?');
    });

    test('The house can be built', () {
      final sentence = engine.generate(
        SentenceState(
          subject: house.toSubject(Number.singular, determiner: theDeterminer),
          verb: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.can,
        ),
      );

      expect(sentence.text, 'The house can be built.');
    });

    test('Should the house be built?', () {
      final sentence = engine.generate(
        SentenceState(
          subject: house.toSubject(Number.singular, determiner: theDeterminer),
          verb: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.should,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Should the house be built?');
    });

    test('The bridge must be built', () {
      final sentence = engine.generate(
        SentenceState(
          subject: bridge.toSubject(Number.singular, determiner: theDeterminer),
          verb: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.must,
        ),
      );

      expect(sentence.text, 'The bridge must be built.');
    });

    test('The students may travel tomorrow', () {
      final sentence = engine.generate(
        SentenceState(
          subject: student.toSubject(Number.plural, determiner: theDeterminer),
          verb: travel,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.may,
          timePhrase: tomorrow,
        ),
      );

      expect(sentence.text, 'The students may travel tomorrow.');
    });

    test('John might not work', () {
      final sentence = engine.generate(
        SentenceState(
          subject: john.toSubject(Number.singular),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.might,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'John might not work.');
    });

    test('The teacher will teach tomorrow', () {
      final sentence = engine.generate(
        SentenceState(
          subject: teacher.toSubject(
            Number.singular,
            determiner: theDeterminer,
          ),
          verb: teach,
          tense: Tense.future,
          aspect: Aspect.simple,
          modal: Modal.will,
          timePhrase: tomorrow,
        ),
      );

      expect(sentence.text, 'The teacher will teach tomorrow.');
    });
  });
}
