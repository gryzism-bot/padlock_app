import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/third_person/animals.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/verbs/education.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/data/verbs/travel.dart';
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

  group('Questions', () {
    test('Does John work?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Does John work?');
    });

    test('Do students study?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: student.toNounPhrase(Number.plural),
          action: study,
          tense: Tense.present,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Do students study?');
    });

    test('Did Mary work yesterday?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.past,
          aspect: Aspect.simple,
          timePhrase: yesterdayTimePhrase,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Did Mary work yesterday?');
    });

    test('Is the dog running?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
          action: run,
          tense: Tense.present,
          aspect: Aspect.continuous,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Is the dog running?');
    });

    test('Are the dogs running?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: dog.toNounPhrase(Number.plural, determiner: theDeterminer),
          action: run,
          tense: Tense.present,
          aspect: Aspect.continuous,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Are the dogs running?');
    });

    test('Has John learned?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: learn,
          tense: Tense.present,
          aspect: Aspect.perfect,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Has John learned?');
    });

    test('Have the students studied?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: student.toNounPhrase(Number.plural, determiner: theDeterminer),
          action: study,
          tense: Tense.present,
          aspect: Aspect.perfect,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Have the students studied?');
    });

    test('Will Mary travel tomorrow?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: travel,
          tense: Tense.future,
          aspect: Aspect.simple,
          modal: will,
          timePhrase: tomorrowTimePhrase,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Will Mary travel tomorrow?');
    });

    test('Can the teacher work?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: teacher.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: can,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Can the teacher work?');
    });

    test('Should the students study?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: student.toNounPhrase(Number.plural, determiner: theDeterminer),
          action: study,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: should,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Should the students study?');
    });

    test('Does John not work?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Does John not work?');
    });

    test('Did Mary not study yesterday?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: study,
          tense: Tense.past,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
          timePhrase: yesterdayTimePhrase,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Did Mary not study yesterday?');
    });

    test('Is the dog not running?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
          action: run,
          tense: Tense.present,
          aspect: Aspect.continuous,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Is the dog not running?');
    });

    test('Can the dog not run?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
          action: run,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: can,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Can the dog not run?');
    });

    test('Was the house built?', () {
      final sentence = engine.generate(
        SentenceState(
          object: house.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Was the house built?');
    });

    test('Were the houses built?', () {
      final sentence = engine.generate(
        SentenceState(
          object: house.toNounPhrase(Number.plural, determiner: theDeterminer),
          action: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Were the houses built?');
    });

    test('Can the house be built?', () {
      final sentence = engine.generate(
        SentenceState(
          object: house.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: can,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Can the house be built?');
    });

    // Expected to fail until unified buildSentence()

    test('Was the house not built?', () {
      final sentence = engine.generate(
        SentenceState(
          object: house.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Was the house not built?');
    });

    test('Should the bridge not be built by cats?', () {
      final sentence = engine.generate(
        SentenceState(
          object: bridge.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: build,
          agent: cat.toNounPhrase(Number.plural),
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: should,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Should the bridge not be built by cats?');
    });

    test('Did Mary find the dog?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          object: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
          action: findVerb,
          tense: Tense.past,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Did Mary find the dog?');
    });
  });
}
