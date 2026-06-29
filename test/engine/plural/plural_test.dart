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

  group('Plural', () {
    test('Dogs work', () {
      final sentence = engine.generate(
        SentenceState(
          subject: dog.toSubject(Number.plural),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'Dogs work.');
    });

    test('The dogs work', () {
      final sentence = engine.generate(
        SentenceState(
          subject: dog.toSubject(Number.plural, determiner: theDeterminer),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'The dogs work.');
    });

    test('Students study', () {
      final sentence = engine.generate(
        SentenceState(
          subject: student.toSubject(Number.plural),
          verb: study,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'Students study.');
    });

    test('The students studied yesterday', () {
      final sentence = engine.generate(
        SentenceState(
          subject: student.toSubject(Number.plural, determiner: theDeterminer),
          verb: study,
          tense: Tense.past,
          aspect: Aspect.simple,
          timePhrase: yesterday,
        ),
      );

      expect(sentence.text, 'The students studied yesterday.');
    });

    test('Teachers are working', () {
      final sentence = engine.generate(
        SentenceState(
          subject: teacher.toSubject(Number.plural),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.continuous,
        ),
      );

      expect(sentence.text, 'Teachers are working.');
    });

    test('Children have learned', () {
      final sentence = engine.generate(
        SentenceState(
          subject: child.toSubject(Number.plural),
          verb: learn,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'Children have learned.');
    });

    test('The houses were built', () {
      final sentence = engine.generate(
        SentenceState(
          subject: house.toSubject(Number.plural, determiner: theDeterminer),
          verb: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'The houses were built.');
    });

    test('Dogs can run', () {
      final sentence = engine.generate(
        SentenceState(
          subject: dog.toSubject(Number.plural),
          verb: run,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.can,
        ),
      );

      expect(sentence.text, 'Dogs can run.');
    });

    test('The teachers should work', () {
      final sentence = engine.generate(
        SentenceState(
          subject: teacher.toSubject(Number.plural, determiner: theDeterminer),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.should,
        ),
      );

      expect(sentence.text, 'The teachers should work.');
    });

    test('Dogs do not run', () {
      final sentence = engine.generate(
        SentenceState(
          subject: dog.toSubject(Number.plural),
          verb: run,
          tense: Tense.present,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'Dogs do not run.');
    });

    test('The students did not study yesterday', () {
      final sentence = engine.generate(
        SentenceState(
          subject: student.toSubject(Number.plural, determiner: theDeterminer),
          verb: study,
          tense: Tense.past,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
          timePhrase: yesterday,
        ),
      );

      expect(sentence.text, 'The students did not study yesterday.');
    });

    test('Do dogs work?', () {
      final sentence = engine.generate(
        SentenceState(
          subject: dog.toSubject(Number.plural),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Do dogs work?');
    });

    test('Were the houses built?', () {
      final sentence = engine.generate(
        SentenceState(
          subject: house.toSubject(Number.plural, determiner: theDeterminer),
          verb: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Were the houses built?');
    });

    test('Should the teachers work?', () {
      final sentence = engine.generate(
        SentenceState(
          subject: teacher.toSubject(Number.plural, determiner: theDeterminer),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.should,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Should the teachers work?');
    });

    test('These dogs are running', () {
      final sentence = engine.generate(
        SentenceState(
          subject: dog.toSubject(Number.plural, determiner: theseDeterminer),
          verb: run,
          tense: Tense.present,
          aspect: Aspect.continuous,
        ),
      );

      expect(sentence.text, 'These dogs are running.');
    });

    test('Our students have studied', () {
      final sentence = engine.generate(
        SentenceState(
          subject: student.toSubject(Number.plural, determiner: ourDeterminer),
          verb: study,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'Our students have studied.');
    });

    test('Some children may travel', () {
      final sentence = engine.generate(
        SentenceState(
          subject: child.toSubject(Number.plural, determiner: someDeterminer),
          verb: travel,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.may,
        ),
      );

      expect(sentence.text, 'Some children may travel.');
    });

    test('Many teachers work at school', () {
      final sentence = engine.generate(
        SentenceState(
          subject: teacher.toSubject(Number.plural, determiner: manyDeterminer),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          placePhrase: atSchool,
        ),
      );

      expect(sentence.text, 'Many teachers work at school.');
    });

    test('The dogs were running yesterday', () {
      final sentence = engine.generate(
        SentenceState(
          subject: dog.toSubject(Number.plural, determiner: theDeterminer),
          verb: run,
          tense: Tense.past,
          aspect: Aspect.continuous,
          timePhrase: yesterday,
        ),
      );

      expect(sentence.text, 'The dogs were running yesterday.');
    });

    test('The children have not learned', () {
      final sentence = engine.generate(
        SentenceState(
          subject: child.toSubject(Number.plural, determiner: theDeterminer),
          verb: learn,
          tense: Tense.present,
          aspect: Aspect.perfect,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'The children have not learned.');
    });
  });
}
