import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
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
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';

import 'package:padlock_app/data/verbs/essential.dart';

void main() {
  final engine = GrammarEngine();

  group('Perfect Continuous tense', () {
    test('John has been working', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
        ),
      );

      expect(sentence.text, 'John has been working.');
    });

    test('The students have been studying', () {
      final sentence = engine.generate(
        SentenceState(
          agent: student.toNounPhrase(Number.plural, determiner: theDeterminer),
          action: study,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
        ),
      );

      expect(sentence.text, 'The students have been studying.');
    });

    test('Mary had been working', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.past,
          aspect: Aspect.perfectContinuous,
        ),
      );

      expect(sentence.text, 'Mary had been working.');
    });

    test('The teachers had been teaching', () {
      final sentence = engine.generate(
        SentenceState(
          agent: teacher.toNounPhrase(Number.plural, determiner: theDeterminer),
          action: teach,
          tense: Tense.past,
          aspect: Aspect.perfectContinuous,
        ),
      );

      expect(sentence.text, 'The teachers had been teaching.');
    });

    test('John will have been working', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.future,
          aspect: Aspect.perfectContinuous,
          modal: will,
        ),
      );

      expect(sentence.text, 'John will have been working.');
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

    test('The students have not been studying', () {
      final sentence = engine.generate(
        SentenceState(
          agent: student.toNounPhrase(Number.plural, determiner: theDeterminer),
          action: study,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'The students have not been studying.');
    });

    test('Has John been working?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Has John been working?');
    });

    test('Have the students been studying?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: student.toNounPhrase(Number.plural, determiner: theDeterminer),
          action: study,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Have the students been studying?');
    });

    test('John has been working!', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          sentenceForm: SentenceForm.exclamation,
        ),
      );

      expect(sentence.text, 'John has been working!');
    });

    test('The teacher has been teaching at school', () {
      final sentence = engine.generate(
        SentenceState(
          agent: teacher.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: teach,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          placePhrase: school,
        ),
      );

      expect(sentence.text, 'The teacher has been teaching at school.');
    });

    // Future GrammarEngine

    test('The house has been being built', () {
      final sentence = engine.generate(
        SentenceState(
          object: house.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
        ),
      );

      expect(sentence.text, 'The house has been being built.');
    });

    test('The houses had been being built', () {
      final sentence = engine.generate(
        SentenceState(
          object: house.toNounPhrase(Number.plural, determiner: theDeterminer),
          action: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.perfectContinuous,
        ),
      );

      expect(sentence.text, 'The houses had been being built.');
    });

    test('Has the house been being built?', () {
      final sentence = engine.generate(
        SentenceState(
          object: house.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Has the house been being built?');
    });

    test('The house has not been being built', () {
      final sentence = engine.generate(
        SentenceState(
          object: house.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'The house has not been being built.');
    });

    test('Has the house not been being built?', () {
      final sentence = engine.generate(
        SentenceState(
          object: house.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Has the house not been being built?');
    });

    test('Should the bridge not have been being built?', () {
      final sentence = engine.generate(
        SentenceState(
          object: bridge.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          modal: should,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Should the bridge not have been being built?');
    });

    test('Mary has been finding the dog', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: findVerb,
          object: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
        ),
      );

      expect(sentence.text, 'Mary has been finding the dog.');
    });

    test('Has Mary been finding the dog?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: findVerb,
          object: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Has Mary been finding the dog?');
    });

    test('The house has been being built by John', () {
      final sentence = engine.generate(
        SentenceState(
          object: house.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: build,
          agent: john.toNounPhrase(Number.singular),
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
        ),
      );

      expect(sentence.text, 'The house has been being built by John.');
    });
  });
}
