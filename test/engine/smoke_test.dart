import 'package:flutter_test/flutter_test.dart';

import 'package:padlock_app/engine/grammar_engine.dart';

import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/subjects/third_person/animals.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';

import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/data/verbs/work.dart';
import 'package:padlock_app/data/verbs/cooking.dart';

import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';

void main() {
  final engine = GrammarEngine();

  group('Smoke', () {
    test('John has worked at home today', () {
      final state = SentenceState(
        subject: john.toSubject(Number.singular),
        verb: work,
        tense: Tense.present,
        aspect: Aspect.perfect,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
        placePhrase: atHome,
        timePhrase: today,
      );

      expect(engine.generate(state).text, 'John has worked at home today.');
    });

    test('The dog was running in the park yesterday', () {
      final state = SentenceState(
        subject: dog.toSubject(Number.singular, determiner: theDeterminer),
        verb: run,
        tense: Tense.past,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
        placePhrase: inThePark,
        timePhrase: yesterday,
      );

      expect(
        engine.generate(state).text,
        'The dog was running in the park yesterday.',
      );
    });

    test('This teacher will teach at school tomorrow', () {
      final state = SentenceState(
        subject: teacher.toSubject(Number.singular, determiner: thisDeterminer),
        verb: teach,
        tense: Tense.future,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
        placePhrase: atSchool,
        timePhrase: tomorrow,
      );

      expect(
        engine.generate(state).text,
        'This teacher will teach at school tomorrow.',
      );
    });

    test('Cats have been sleeping at home', () {
      final state = SentenceState(
        subject: cat.toSubject(Number.plural),
        verb: sleep,
        tense: Tense.present,
        aspect: Aspect.perfectContinuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
        placePhrase: atHome,
      );

      expect(engine.generate(state).text, 'Cats have been sleeping at home.');
    });

    test('Does Mary know?', () {
      final state = SentenceState(
        subject: mary.toSubject(Number.singular),
        verb: know,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.question,
      );

      expect(engine.generate(state).text, 'Does Mary know?');
    });

    test('Did the dog run?', () {
      final state = SentenceState(
        subject: dog.toSubject(Number.singular, determiner: theDeterminer),
        verb: run,
        tense: Tense.past,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.question,
      );

      expect(engine.generate(state).text, 'Did the dog run?');
    });

    test('Will John come tomorrow?', () {
      final state = SentenceState(
        subject: john.toSubject(Number.singular),
        verb: come,
        tense: Tense.future,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.question,
        timePhrase: tomorrow,
      );

      expect(engine.generate(state).text, 'Will John come tomorrow?');
    });

    test('That car does not work', () {
      final state = SentenceState(
        subject: car.toSubject(Number.singular, determiner: thatDeterminer),
        verb: work,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'That car does not work.');
    });

    test('Our students did not study yesterday', () {
      final state = SentenceState(
        subject: student.toSubject(Number.plural, determiner: ourDeterminer),
        verb: study,
        tense: Tense.past,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
        timePhrase: yesterday,
      );

      expect(
        engine.generate(state).text,
        'Our students did not study yesterday.',
      );
    });

    test('He can drive', () {
      final state = SentenceState(
        subject: he,
        verb: drive,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.can,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'He can drive.');
    });

    test('She should study', () {
      final state = SentenceState(
        subject: she,
        verb: study,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.should,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'She should study.');
    });

    test('Some dogs must work', () {
      final state = SentenceState(
        subject: dog.toSubject(Number.plural, determiner: someDeterminer),
        verb: work,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.must,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'Some dogs must work.');
    });

    test('Cook imperative', () {
      final state = SentenceState(
        subject: you,
        verb: cook,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.imperative,
      );

      expect(engine.generate(state).text, 'Cook.');
    });

    test('You run!', () {
      final state = SentenceState(
        subject: you,
        verb: run,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.exclamation,
      );

      expect(engine.generate(state).text, 'You run!');
    });

    test('Each child has learned', () {
      final state = SentenceState(
        subject: child.toSubject(Number.singular, determiner: eachDeterminer),
        verb: learn,
        tense: Tense.present,
        aspect: Aspect.perfect,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'Each child has learned.');
    });

    test('The mouse has gone', () {
      final state = SentenceState(
        subject: mouse.toSubject(Number.singular, determiner: theDeterminer),
        verb: go,
        tense: Tense.present,
        aspect: Aspect.perfect,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'The mouse has gone.');
    });

    test('Any teacher can travel to work', () {
      final state = SentenceState(
        subject: teacher.toSubject(Number.singular, determiner: anyDeterminer),
        verb: travel,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.can,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
        placePhrase: toWork,
      );

      expect(engine.generate(state).text, 'Any teacher can travel to work.');
    });
  });
}
