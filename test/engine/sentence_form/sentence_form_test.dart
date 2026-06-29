import 'package:flutter_test/flutter_test.dart';
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

import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/verbs/essential.dart';

void main() {
  final engine = GrammarEngine();

  group('Sentence forms', () {
    test('Statement', () {
      final sentence = engine.generate(
        SentenceState(
          subject: john.toSubject(Number.singular),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.statement,
        ),
      );

      expect(sentence.text, 'John works.');
    });

    test('Question', () {
      final sentence = engine.generate(
        SentenceState(
          subject: john.toSubject(Number.singular),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Does John work?');
    });

    test('Exclamation', () {
      final sentence = engine.generate(
        SentenceState(
          subject: john.toSubject(Number.singular),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.exclamation,
        ),
      );

      expect(sentence.text, 'John works!');
    });

    test('Imperative', () {
      final sentence = engine.generate(
        SentenceState(
          subject: you,
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.imperative,
        ),
      );

      expect(sentence.text, 'Work.');
    });

    test('Negative statement', () {
      final sentence = engine.generate(
        SentenceState(
          subject: mary.toSubject(Number.singular),
          verb: study,
          tense: Tense.present,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.statement,
        ),
      );

      expect(sentence.text, 'Mary does not study.');
    });

    test('Negative question', () {
      final sentence = engine.generate(
        SentenceState(
          subject: mary.toSubject(Number.singular),
          verb: study,
          tense: Tense.present,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Does Mary not study?');
    });

    test('Negative exclamation', () {
      final sentence = engine.generate(
        SentenceState(
          subject: dog.toSubject(Number.singular, determiner: theDeterminer),
          verb: run,
          tense: Tense.present,
          aspect: Aspect.continuous,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.exclamation,
        ),
      );

      expect(sentence.text, 'The dog is not running!');
    });

    test('Passive statement', () {
      final sentence = engine.generate(
        SentenceState(
          subject: house.toSubject(Number.singular, determiner: theDeterminer),
          verb: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.statement,
        ),
      );

      expect(sentence.text, 'The house was built.');
    });

    test('Passive question', () {
      final sentence = engine.generate(
        SentenceState(
          subject: house.toSubject(Number.singular, determiner: theDeterminer),
          verb: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Was the house built?');
    });

    test('Passive exclamation', () {
      final sentence = engine.generate(
        SentenceState(
          subject: bridge.toSubject(Number.singular, determiner: theDeterminer),
          verb: build,
          voice: Voice.passive,
          tense: Tense.future,
          aspect: Aspect.simple,
          modal: Modal.will,
          sentenceForm: SentenceForm.exclamation,
        ),
      );

      expect(sentence.text, 'The bridge will be built!');
    });

    test('Modal question', () {
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
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Can the teacher teach?');
    });

    test('Modal exclamation', () {
      final sentence = engine.generate(
        SentenceState(
          subject: teacher.toSubject(
            Number.singular,
            determiner: theDeterminer,
          ),
          verb: teach,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.must,
          sentenceForm: SentenceForm.exclamation,
        ),
      );

      expect(sentence.text, 'The teacher must teach!');
    });

    test('Plural question', () {
      final sentence = engine.generate(
        SentenceState(
          subject: student.toSubject(Number.plural, determiner: theDeterminer),
          verb: study,
          tense: Tense.present,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Do the students study?');
    });

    test('Perfect question', () {
      final sentence = engine.generate(
        SentenceState(
          subject: john.toSubject(Number.singular),
          verb: learn,
          tense: Tense.present,
          aspect: Aspect.perfect,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Has John learned?');
    });

    // Future unified buildSentence()

    test('Passive negative statement', () {
      final sentence = engine.generate(
        SentenceState(
          subject: house.toSubject(Number.singular, determiner: theDeterminer),
          verb: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.statement,
        ),
      );

      expect(sentence.text, 'The house was not built.');
    });

    test('Passive negative question', () {
      final sentence = engine.generate(
        SentenceState(
          subject: house.toSubject(Number.singular, determiner: theDeterminer),
          verb: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Was the house not built?');
    });

    test('Passive modal negative question', () {
      final sentence = engine.generate(
        SentenceState(
          subject: bridge.toSubject(Number.singular, determiner: theDeterminer),
          verb: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.should,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Should the bridge not be built?');
    });

    test('Question with object', () {
      final sentence = engine.generate(
        SentenceState(
          subject: mary.toSubject(Number.singular),
          verb: findVerb,
          tense: Tense.past,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Did Mary find the dog?');
    });
  });
}
