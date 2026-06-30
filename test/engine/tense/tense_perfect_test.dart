import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
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

  group('Perfect tense', () {
    test('John has worked', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'John has worked.');
    });

    test('Dogs have worked', () {
      final sentence = engine.generate(
        SentenceState(
          agent: dog.toNounPhrase(Number.plural),
          action: work,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'Dogs have worked.');
    });

    test('Mary had studied yesterday', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: study,
          tense: Tense.past,
          aspect: Aspect.perfect,
          timePhrase: yesterday,
        ),
      );

      expect(sentence.text, 'Mary had studied yesterday.');
    });

    test('The students had studied', () {
      final sentence = engine.generate(
        SentenceState(
          agent: student.toNounPhrase(Number.plural, determiner: theDeterminer),
          action: study,
          tense: Tense.past,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'The students had studied.');
    });

    test('John will have worked', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.future,
          aspect: Aspect.perfect,
          modal: will,
        ),
      );

      expect(sentence.text, 'John will have worked.');
    });

    test('The dog has run', () {
      final sentence = engine.generate(
        SentenceState(
          agent: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
          action: run,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'The dog has run.');
    });

    test('John has not worked', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.present,
          aspect: Aspect.perfect,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'John has not worked.');
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

    test('Has John worked?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.present,
          aspect: Aspect.perfect,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Has John worked?');
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

    test('John has worked!', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
          tense: Tense.present,
          aspect: Aspect.perfect,
          sentenceForm: SentenceForm.exclamation,
        ),
      );

      expect(sentence.text, 'John has worked!');
    });

    test('The house has been built', () {
      final sentence = engine.generate(
        SentenceState(
          object: house.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'The house has been built.');
    });

    test('The houses had been built', () {
      final sentence = engine.generate(
        SentenceState(
          object: house.toNounPhrase(Number.plural, determiner: theDeterminer),
          action: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'The houses had been built.');
    });

    test('Has the house been built?', () {
      final sentence = engine.generate(
        SentenceState(
          object: house.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.perfect,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Has the house been built?');
    });

    // Future buildSentence()

    test('The house has not been built', () {
      final sentence = engine.generate(
        SentenceState(
          object: house.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.perfect,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'The house has not been built.');
    });

    test('Has the house not been built?', () {
      final sentence = engine.generate(
        SentenceState(
          object: house.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.perfect,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Has the house not been built?');
    });

    test('Should the bridge not have been built?', () {
      final sentence = engine.generate(
        SentenceState(
          object: bridge.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
          ),
          action: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.perfect,
          modal: should,
          polarity: Polarity.negative,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Should the bridge not have been built?');
    });

    test('Mary has found the dog', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: findVerb,
          object: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'Mary has found the dog.');
    });

    test('Has Mary found the dog?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: findVerb,
          object: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
          tense: Tense.present,
          aspect: Aspect.perfect,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Has Mary found the dog?');
    });

    test('The house has been built by John', () {
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
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'The house has been built by John.');
    });
  });
}
