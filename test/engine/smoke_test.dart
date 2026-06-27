import 'package:flutter_test/flutter_test.dart';

import 'package:padlock_app/engine/grammar_engine.dart';

import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/subjects/third_person/animals.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';

import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/data/verbs/work.dart';
import 'package:padlock_app/data/verbs/communication.dart';
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

    test('Dogs were running in the park yesterday', () {
      final state = SentenceState(
        subject: dog.toSubject(Number.plural),
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
        'Dogs were running in the park yesterday.',
      );
    });

    test('Teacher will teach at school tomorrow', () {
      final state = SentenceState(
        subject: teacher.toSubject(Number.singular),
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
        'Teacher will teach at school tomorrow.',
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

    test('Did dog run?', () {
      final state = SentenceState(
        subject: dog.toSubject(Number.singular),
        verb: run,
        tense: Tense.past,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.question,
      );

      expect(engine.generate(state).text, 'Did dog run?');
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

    test('Car does not work', () {
      final state = SentenceState(
        subject: car.toSubject(Number.singular),
        verb: work,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'Car does not work.');
    });

    test('Students did not study yesterday', () {
      final state = SentenceState(
        subject: student.toSubject(Number.plural),
        verb: study,
        tense: Tense.past,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.negative,
        sentenceForm: SentenceForm.statement,
        timePhrase: yesterday,
      );

      expect(engine.generate(state).text, 'Students did not study yesterday.');
    });

    test('He can drive', () {
      final state = SentenceState(
        subject: he,
        verb: cook,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.can,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'He can cook.');
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

    test('We must work', () {
      final state = SentenceState(
        subject: we,
        verb: work,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.must,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'We must work.');
    });

    test('Talk imperative', () {
      final state = SentenceState(
        subject: you,
        verb: talk,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.imperative,
      );

      expect(engine.generate(state).text, 'Talk.');
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

    test('Children have learned', () {
      final state = SentenceState(
        subject: child.toSubject(Number.plural),
        verb: learn,
        tense: Tense.present,
        aspect: Aspect.perfect,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'Children have learned.');
    });

    test('Mouse has gone', () {
      final state = SentenceState(
        subject: mouse.toSubject(Number.singular),
        verb: go,
        tense: Tense.present,
        aspect: Aspect.perfect,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'Mouse has gone.');
    });

    test('Teachers can travel to work', () {
      final state = SentenceState(
        subject: teacher.toSubject(Number.plural),
        verb: travel,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.can,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
        placePhrase: toWork,
      );

      expect(engine.generate(state).text, 'Teachers can travel to work.');
    });
  });
}
