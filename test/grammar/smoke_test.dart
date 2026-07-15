import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/subjects/adjectives/quality.dart';
import 'package:padlock_app/data/verbs/education.dart';

import 'package:padlock_app/engine/grammar_engine.dart';

import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/subjects/third_person/animals.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';

import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/data/verbs/travel.dart';
import 'package:padlock_app/data/verbs/cooking.dart' as cooking_data;

import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';

void main() {
  final engine = GrammarEngine();

  group('420 Smoke test', () {
    test('John has worked at home today', () {
      final state = SentenceState(
        agent: john.toNounPhrase(Number.singular),
        action: work,
        tense: Tense.present,
        aspect: Aspect.perfect,
        modal: noModal,
        voice: Voice.active,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
        placePhrase: homePlacePhrase,
        timePhrase: todayTimePhrase,
      );

      expect(engine.generate(state).text, 'John has worked at home today.');
    });

    test('The dog was running in the park yesterday', () {
      final state = SentenceState(
        agent: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
        action: run,
        tense: Tense.past,
        aspect: Aspect.continuous,
        modal: noModal,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
        voice: Voice.active,
        placePhrase: parkPlacePhrase,
        timePhrase: yesterdayTimePhrase,
      );

      expect(
        engine.generate(state).text,
        'The dog was running to the park yesterday.',
      );
    });

    test('This teacher will teach at school tomorrow', () {
      final state = SentenceState(
        agent: teacher.toNounPhrase(
          Number.singular,
          determiner: thisDeterminer,
        ),
        action: teach,
        tense: Tense.future,
        aspect: Aspect.simple,
        modal: noModal,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
        placePhrase: schoolPlacePhrase,
        timePhrase: tomorrowTimePhrase,
        voice: Voice.active,
      );

      expect(
        engine.generate(state).text,
        'This teacher will teach at school tomorrow.',
      );
    });

    test('Cats have been sleeping at home', () {
      final state = SentenceState(
        agent: cat.toNounPhrase(Number.plural),
        action: sleep,
        tense: Tense.present,
        aspect: Aspect.perfectContinuous,
        modal: noModal,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
        voice: Voice.active,
        placePhrase: homePlacePhrase,
      );

      expect(engine.generate(state).text, 'Cats have been sleeping at home.');
    });

    test('Does Mary know?', () {
      final state = SentenceState(
        agent: mary.toNounPhrase(Number.singular),
        action: know,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: noModal,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.question,
        voice: Voice.active,
      );

      expect(engine.generate(state).text, 'Does Mary know?');
    });

    test('Did the dog run?', () {
      final state = SentenceState(
        agent: dog.toNounPhrase(Number.singular, determiner: theDeterminer),
        action: run,
        tense: Tense.past,
        aspect: Aspect.simple,
        modal: noModal,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.question,
        voice: Voice.active,
      );

      expect(engine.generate(state).text, 'Did the dog run?');
    });

    test('Will John come tomorrow?', () {
      final state = SentenceState(
        agent: john.toNounPhrase(Number.singular),
        action: come,
        tense: Tense.future,
        aspect: Aspect.simple,
        modal: noModal,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.question,
        voice: Voice.active,
        timePhrase: tomorrowTimePhrase,
      );

      expect(engine.generate(state).text, 'Will John come tomorrow?');
    });

    test('That car does not work', () {
      final state = SentenceState(
        agent: car.toNounPhrase(Number.singular, determiner: thatDeterminer),
        action: work,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: noModal,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
        voice: Voice.active,
      );

      expect(engine.generate(state).text, 'That car does not work.');
    });

    test('Our students did not study yesterday', () {
      final state = SentenceState(
        agent: student.toNounPhrase(Number.plural, determiner: ourDeterminer),
        action: study,
        tense: Tense.past,
        aspect: Aspect.simple,
        modal: noModal,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
        voice: Voice.active,
        timePhrase: yesterdayTimePhrase,
      );

      expect(
        engine.generate(state).text,
        'Our students did not study yesterday.',
      );
    });

    test('He can drive', () {
      final state = SentenceState(
        agent: he,
        action: drive,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: can,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
        voice: Voice.active,
      );

      expect(engine.generate(state).text, 'He can drive.');
    });

    test('She should study', () {
      final state = SentenceState(
        agent: she,
        action: study,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: should,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
        voice: Voice.active,
      );

      expect(engine.generate(state).text, 'She should study.');
    });

    test('Some dogs must work', () {
      final state = SentenceState(
        agent: dog.toNounPhrase(Number.plural, determiner: someDeterminer),
        action: work,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: must,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
        voice: Voice.active,
      );

      expect(engine.generate(state).text, 'Some dogs must work.');
    });

    test('Cook imperative', () {
      final state = SentenceState(
        agent: you,
        action: cooking_data.cook,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: noModal,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.imperative,
        voice: Voice.active,
      );

      expect(engine.generate(state).text, 'Cook.');
    });

    test('You run!', () {
      final state = SentenceState(
        agent: you,
        action: run,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: noModal,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.exclamation,
        voice: Voice.active,
      );

      expect(engine.generate(state).text, 'You run!');
    });

    test('Every new child has learned', () {
      final state = SentenceState(
        agent: child.toNounPhrase(
          Number.singular,
          determiner: everyDeterminer,
          adjective: newAdjective,
        ),
        action: learn,
        tense: Tense.present,
        aspect: Aspect.perfect,
        modal: noModal,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
        voice: Voice.active,
      );

      expect(engine.generate(state).text, 'Every new child has learned.');
    });

    test('The mouse has gone', () {
      final state = SentenceState(
        agent: mouse.toNounPhrase(Number.singular, determiner: theDeterminer),
        action: go,
        tense: Tense.present,
        aspect: Aspect.perfect,
        modal: noModal,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
        voice: Voice.active,
      );

      expect(engine.generate(state).text, 'The mouse has gone.');
    });

    test('Any teacher can travel to work', () {
      final state = SentenceState(
        agent: teacher.toNounPhrase(Number.singular, determiner: anyDeterminer),
        action: travel,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: can,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
        voice: Voice.active,
        placePhrase: workPlacePhrase,
      );

      expect(engine.generate(state).text, 'Any teacher can travel to work.');
    });
  });
}
