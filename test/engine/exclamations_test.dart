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

  group('Exclamation', () {
    test('John works!', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: work,
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
          agent: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
          action: run,
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
          agent: mary.toNounPhrase(Number.singular),
          action: study,
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
          agent: dog.toNounPhrase(Number.plural, determiner: theseDeterminer),
          action: learn,
          tense: Tense.present,
          aspect: Aspect.perfect,
          sentenceForm: SentenceForm.exclamation,
        ),
      );

      expect(sentence.text, 'These dogs have learned!');
    });

    test('That house will be built by John!', () {
      final state = SentenceState(
        agent: john.toNounPhrase(Number.singular),
        object: house.toNounPhrase(Number.singular, determiner: thatDeterminer),
        action: build,
        tense: Tense.future,
        aspect: Aspect.simple,
        voice: Voice.passive,
        sentenceForm: SentenceForm.exclamation,
      );

      expect(engine.generate(state).text, 'That house will be built by John!');
    });

    test('Our students must study!', () {
      final sentence = engine.generate(
        SentenceState(
          agent: student.toNounPhrase(Number.plural, determiner: ourDeterminer),
          action: study,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: must,
          sentenceForm: SentenceForm.exclamation,
        ),
      );

      expect(sentence.text, 'Our students must study!');
    });

    test('This teacher can travel!', () {
      final sentence = engine.generate(
        SentenceState(
          agent: teacher.toNounPhrase(
            Number.singular,
            determiner: thisDeterminer,
          ),
          action: travel,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: can,
          sentenceForm: SentenceForm.exclamation,
        ),
      );

      expect(sentence.text, 'This teacher can travel!');
    });

    test('Every child has learned!', () {
      final sentence = engine.generate(
        SentenceState(
          agent: child.toNounPhrase(
            Number.singular,
            determiner: everyDeterminer,
          ),
          action: learn,
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
          agent: student.toNounPhrase(
            Number.singular,
            determiner: noDeterminer,
          ),
          action: work,
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
          agent: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
          action: run,
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
