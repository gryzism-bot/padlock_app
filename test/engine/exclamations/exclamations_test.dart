import 'package:flutter_test/flutter_test.dart';
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

    group('Exclamation', () {
    test('John works!', () {
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

    test('The dog is running!', () {
      final sentence = engine.generate(
        SentenceState(
          subject: dog.toSubject(
            Number.singular,
            determiner: theDeterminer,
          ),
          verb: run,
          tense: Tense.present,
          aspect: Aspect.continuous,
          sentenceForm: SentenceForm.exclamation,
        ),
      );

      expect(sentence.text, 'The dog is running!');
    });

    test('Mary studied yesterday!', () {
      final sentence = engine.generate(
        SentenceState(
          subject: mary.toSubject(Number.singular),
          verb: study,
          tense: Tense.past,
          aspect: Aspect.simple,
          timePhrase: yesterday,
          sentenceForm: SentenceForm.exclamation,
        ),
      );

      expect(sentence.text, 'Mary studied yesterday!');
    });

    test('These dogs have learned!', () {
      final sentence = engine.generate(
        SentenceState(
          subject: dog.toSubject(
            Number.plural,
            determiner: theseDeterminer,
          ),
          verb: learn,
          tense: Tense.present,
          aspect: Aspect.perfect,
          sentenceForm: SentenceForm.exclamation,
        ),
      );

      expect(sentence.text, 'These dogs have learned!');
    });

    test('That house will be built!', () {
      final sentence = engine.generate(
        SentenceState(
          subject: house.toSubject(
            Number.singular,
            determiner: thatDeterminer,
          ),
          verb: build,
          tense: Tense.future,
          aspect: Aspect.simple,
          voice: Voice.passive,
          sentenceForm: SentenceForm.exclamation,
        ),
      );

      expect(sentence.text, 'That house will be built!');
    });

    test('Our students must study!', () {
      final sentence = engine.generate(
        SentenceState(
          subject: student.toSubject(
            Number.plural,
            determiner: ourDeterminer,
          ),
          verb: study,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.must,
          sentenceForm: SentenceForm.exclamation,
        ),
      );

      expect(sentence.text, 'Our students must study!');
    });

    test('This teacher can travel!', () {
      final sentence = engine.generate(
        SentenceState(
          subject: teacher.toSubject(
            Number.singular,
            determiner: thisDeterminer,
          ),
          verb: travel,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.can,
          sentenceForm: SentenceForm.exclamation,
        ),
      );

      expect(sentence.text, 'This teacher can travel!');
    });

    test('Every child has learned!', () {
      final sentence = engine.generate(
        SentenceState(
          subject: child.toSubject(
            Number.singular,
            determiner: everyDeterminer,
          ),
          verb: learn,
          tense: Tense.present,
          aspect: Aspect.perfect,
          sentenceForm: SentenceForm.exclamation,
        ),
      );

      expect(sentence.text, 'Every child has learned!');
    });

    test('No student worked yesterday!', () {
      final sentence = engine.generate(
        SentenceState(
          subject: student.toSubject(
            Number.singular,
            determiner: noDeterminer,
          ),
          verb: work,
          tense: Tense.past,
          aspect: Aspect.simple,
          timePhrase: yesterday,
          sentenceForm: SentenceForm.exclamation,
        ),
      );

      expect(sentence.text, 'No student worked yesterday!');
    });

    test('The dog did not run yesterday!', () {
      final sentence = engine.generate(
        SentenceState(
          subject: dog.toSubject(
            Number.singular,
            determiner: theDeterminer,
          ),
          verb: run,
          tense: Tense.past,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
          timePhrase: yesterday,
          sentenceForm: SentenceForm.exclamation,
        ),
      );

      expect(sentence.text, 'The dog did not run yesterday!');
    });
  });
}
