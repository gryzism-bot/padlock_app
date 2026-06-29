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

  group('Continuous tense', () {
    test('John is working', () {
      final sentence = engine.generate(
        SentenceState(
          subject: john.toSubject(Number.singular),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.continuous,
        ),
      );

      expect(sentence.text, 'John is working.');
    });

    test('The dog is running', () {
      final sentence = engine.generate(
        SentenceState(
          subject: dog.toSubject(Number.singular, determiner: theDeterminer),
          verb: run,
          tense: Tense.present,
          aspect: Aspect.continuous,
        ),
      );

      expect(sentence.text, 'The dog is running.');
    });

    test('The students are studying', () {
      final sentence = engine.generate(
        SentenceState(
          subject: student.toSubject(Number.plural, determiner: theDeterminer),
          verb: study,
          tense: Tense.present,
          aspect: Aspect.continuous,
        ),
      );

      expect(sentence.text, 'The students are studying.');
    });

    test('Mary was working yesterday', () {
      final sentence = engine.generate(
        SentenceState(
          subject: mary.toSubject(Number.singular),
          verb: work,
          tense: Tense.past,
          aspect: Aspect.continuous,
          timePhrase: yesterday,
        ),
      );

      expect(sentence.text, 'Mary was working yesterday.');
    });

    test('The dogs were running', () {
      final sentence = engine.generate(
        SentenceState(
          subject: dog.toSubject(Number.plural, determiner: theDeterminer),
          verb: run,
          tense: Tense.past,
          aspect: Aspect.continuous,
        ),
      );

      expect(sentence.text, 'The dogs were running.');
    });

    test('John will be working', () {
      final sentence = engine.generate(
        SentenceState(
          subject: john.toSubject(Number.singular),
          verb: work,
          tense: Tense.future,
          aspect: Aspect.continuous,
          modal: Modal.will,
        ),
      );

      expect(sentence.text, 'John will be working.');
    });

    test('The teacher is teaching at school', () {
      final sentence = engine.generate(
        SentenceState(
          subject: teacher.toSubject(
            Number.singular,
            determiner: theDeterminer,
          ),
          verb: teach,
          tense: Tense.present,
          aspect: Aspect.continuous,
          placePhrase: atSchool,
        ),
      );

      expect(sentence.text, 'The teacher is teaching at school.');
    });

    test('John is not working', () {
      final sentence = engine.generate(
        SentenceState(
          subject: john.toSubject(Number.singular),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.continuous,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'John is not working.');
    });

    test('The students are not studying', () {
      final sentence = engine.generate(
        SentenceState(
          subject: student.toSubject(Number.plural, determiner: theDeterminer),
          verb: study,
          tense: Tense.present,
          aspect: Aspect.continuous,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'The students are not studying.');
    });

    test('Is John working?', () {
      final sentence = engine.generate(
        SentenceState(
          subject: john.toSubject(Number.singular),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.continuous,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Is John working?');
    });

    test('Are the dogs running?', () {
      final sentence = engine.generate(
        SentenceState(
          subject: dog.toSubject(Number.plural, determiner: theDeterminer),
          verb: run,
          tense: Tense.present,
          aspect: Aspect.continuous,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Are the dogs running?');
    });

    test('Was Mary working yesterday?', () {
      final sentence = engine.generate(
        SentenceState(
          subject: mary.toSubject(Number.singular),
          verb: work,
          tense: Tense.past,
          aspect: Aspect.continuous,
          timePhrase: yesterday,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Was Mary working yesterday?');
    });

    test('John is working!', () {
      final sentence = engine.generate(
        SentenceState(
          subject: john.toSubject(Number.singular),
          verb: work,
          tense: Tense.present,
          aspect: Aspect.continuous,
          sentenceForm: SentenceForm.exclamation,
        ),
      );

      expect(sentence.text, 'John is working!');
    });

    test('The bridge is being built', () {
      final sentence = engine.generate(
        SentenceState(
          subject: bridge.toSubject(Number.singular, determiner: theDeterminer),
          verb: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.continuous,
        ),
      );

      expect(sentence.text, 'The bridge is being built.');
    });

    test('The houses were being built', () {
      final sentence = engine.generate(
        SentenceState(
          subject: house.toSubject(Number.plural, determiner: theDeterminer),
          verb: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.continuous,
        ),
      );

      expect(sentence.text, 'The houses were being built.');
    });

    // Future buildSentence()

    test('The bridge is not being built', () {
      final sentence = engine.generate(
        SentenceState(
          subject: bridge.toSubject(Number.singular, determiner: theDeterminer),
          verb: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.continuous,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'The bridge is not being built.');
    });

    test('Is the bridge not being built?', () {
      final sentence = engine.generate(
        SentenceState(
          subject: bridge.toSubject(Number.singular, determiner: theDeterminer),
          verb: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.continuous,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Is the bridge not being built?');
    });

    test('Was the house being built by John?', () {
      final sentence = engine.generate(
        SentenceState(
          subject: house.toSubject(Number.singular, determiner: theDeterminer),
          verb: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.continuous,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Was the house being built by John?');
    });
  });
}
