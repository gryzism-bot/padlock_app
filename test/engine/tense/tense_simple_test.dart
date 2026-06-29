import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/third_person/animals.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/verbs/education.dart';
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

  group('Simple tense', () {
    test('John works', () {
      final sentence = engine.generate(
        SentenceState(
          subject: john.toSubject(Number.singular),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'John works.');
    });

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

    test('The teacher teaches at school', () {
      final sentence = engine.generate(
        SentenceState(
          subject: teacher.toSubject(
            Number.singular,
            determiner: theDeterminer,
          ),
          verb: teach,
          tense: Tense.present,
          aspect: Aspect.simple,
          placePhrase: atSchool,
        ),
      );

      expect(sentence.text, 'The teacher teaches at school.');
    });

    test('Mary worked yesterday', () {
      final sentence = engine.generate(
        SentenceState(
          subject: mary.toSubject(Number.singular),
          verb: work,
          tense: Tense.past,
          aspect: Aspect.simple,
          timePhrase: yesterday,
        ),
      );

      expect(sentence.text, 'Mary worked yesterday.');
    });

    test('The students studied yesterday', () {
      final sentence = engine.generate(
        SentenceState(
          subject: student.toSubject(
            Number.plural,
            determiner: theDeterminer,
          ),
          verb: study,
          tense: Tense.past,
          aspect: Aspect.simple,
          timePhrase: yesterday,
        ),
      );

      expect(sentence.text, 'The students studied yesterday.');
    });

    test('John will work tomorrow', () {
      final sentence = engine.generate(
        SentenceState(
          subject: john.toSubject(Number.singular),
          verb: work,
          tense: Tense.future,
          aspect: Aspect.simple,
          modal: Modal.will,
          timePhrase: tomorrow,
        ),
      );

      expect(sentence.text, 'John will work tomorrow.');
    });

    test('John does not work', () {
      final sentence = engine.generate(
        SentenceState(
          subject: john.toSubject(Number.singular),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'John does not work.');
    });

    test('Dogs do not work', () {
      final sentence = engine.generate(
        SentenceState(
          subject: dog.toSubject(Number.plural),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'Dogs do not work.');
    });

    test('Mary did not study yesterday', () {
      final sentence = engine.generate(
        SentenceState(
          subject: mary.toSubject(Number.singular),
          verb: study,
          tense: Tense.past,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
          timePhrase: yesterday,
        ),
      );

      expect(sentence.text, 'Mary did not study yesterday.');
    });

    test('Does John work?', () {
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

    test('Do the students study?', () {
      final sentence = engine.generate(
        SentenceState(
          subject: student.toSubject(
            Number.plural,
            determiner: theDeterminer,
          ),
          verb: study,
          tense: Tense.present,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Do the students study?');
    });

    test('Did Mary work yesterday?', () {
      final sentence = engine.generate(
        SentenceState(
          subject: mary.toSubject(Number.singular),
          verb: work,
          tense: Tense.past,
          aspect: Aspect.simple,
          timePhrase: yesterday,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Did Mary work yesterday?');
    });

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

    test('The house was built', () {
      final sentence = engine.generate(
        SentenceState(
          subject: house.toSubject(
            Number.singular,
            determiner: theDeterminer,
          ),
          verb: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'The house was built.');
    });

    test('The houses were built', () {
      final sentence = engine.generate(
        SentenceState(
          subject: house.toSubject(
            Number.plural,
            determiner: theDeterminer,
          ),
          verb: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'The houses were built.');
    });

    test('Was the house built?', () {
      final sentence = engine.generate(
        SentenceState(
          subject: house.toSubject(
            Number.singular,
            determiner: theDeterminer,
          ),
          verb: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Was the house built?');
    });

    test('Can the house be built?', () {
      final sentence = engine.generate(
        SentenceState(
          subject: house.toSubject(
            Number.singular,
            determiner: theDeterminer,
          ),
          verb: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: Modal.can,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Can the house be built?');
    });

    // Future buildSentence()

    test('The house was not built', () {
      final sentence = engine.generate(
        SentenceState(
          subject: house.toSubject(
            Number.singular,
            determiner: theDeterminer,
          ),
          verb: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'The house was not built.');
    });

    test('Was the house not built?', () {
      final sentence = engine.generate(
        SentenceState(
          subject: house.toSubject(
            Number.singular,
            determiner: theDeterminer,
          ),
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

    test('Should the bridge not be built?', () {
      final sentence = engine.generate(
        SentenceState(
          subject: bridge.toSubject(
            Number.singular,
            determiner: theDeterminer,
          ),
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

    test('Mary found the dog', () {
      final sentence = engine.generate(
        SentenceState(
          subject: mary.toSubject(Number.singular),
          verb: findVerb,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'Mary found the dog.');
    });

    test('Did Mary find the dog?', () {
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

    test('The house was built by John', () {
      final sentence = engine.generate(
        SentenceState(
          subject: house.toSubject(
            Number.singular,
            determiner: theDeterminer,
          ),
          verb: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'The house was built by John.');
    });
  });
}