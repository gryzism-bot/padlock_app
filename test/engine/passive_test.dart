import 'package:flutter_test/flutter_test.dart';

import 'package:padlock_app/engine/grammar_engine.dart';

import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';

import 'package:padlock_app/data/verbs/work.dart';

import 'package:padlock_app/data/phrases/time_phrases.dart';

void main() {
  final engine = GrammarEngine();

  group('Passive', () {
    test('The house is built', () {
      final state = SentenceState(
        subject: house.toSubject(Number.singular, determiner: theDeterminer),
        verb: build,
        voice: Voice.passive,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'The house is built.');
    });

    test('The houses are built', () {
      final state = SentenceState(
        subject: house.toSubject(Number.plural, determiner: theDeterminer),
        verb: build,
        voice: Voice.passive,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'The houses are built.');
    });

    test('The house was built yesterday', () {
      final state = SentenceState(
        subject: house.toSubject(Number.singular, determiner: theDeterminer),
        verb: build,
        voice: Voice.passive,
        tense: Tense.past,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
        timePhrase: yesterday,
      );

      expect(engine.generate(state).text, 'The house was built yesterday.');
    });

    test('The houses were built yesterday', () {
      final state = SentenceState(
        subject: house.toSubject(Number.plural, determiner: theDeterminer),
        verb: build,
        voice: Voice.passive,
        tense: Tense.past,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
        timePhrase: yesterday,
      );

      expect(engine.generate(state).text, 'The houses were built yesterday.');
    });

    test('The house will be built', () {
      final state = SentenceState(
        subject: house.toSubject(Number.singular, determiner: theDeterminer),
        verb: build,
        voice: Voice.passive,
        tense: Tense.future,
        aspect: Aspect.simple,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'The house will be built.');
    });

    test('The house has been built', () {
      final state = SentenceState(
        subject: house.toSubject(Number.singular, determiner: theDeterminer),
        verb: build,
        voice: Voice.passive,
        tense: Tense.present,
        aspect: Aspect.perfect,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'The house has been built.');
    });

    test('The houses have been built', () {
      final state = SentenceState(
        subject: house.toSubject(Number.plural, determiner: theDeterminer),
        verb: build,
        voice: Voice.passive,
        tense: Tense.present,
        aspect: Aspect.perfect,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'The houses have been built.');
    });

    test('The house had been built', () {
      final state = SentenceState(
        subject: house.toSubject(Number.singular, determiner: theDeterminer),
        verb: build,
        voice: Voice.passive,
        tense: Tense.past,
        aspect: Aspect.perfect,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'The house had been built.');
    });

    test('The house is being built', () {
      final state = SentenceState(
        subject: house.toSubject(Number.singular, determiner: theDeterminer),
        verb: build,
        voice: Voice.passive,
        tense: Tense.present,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'The house is being built.');
    });

    test('The houses are being built', () {
      final state = SentenceState(
        subject: house.toSubject(Number.plural, determiner: theDeterminer),
        verb: build,
        voice: Voice.passive,
        tense: Tense.present,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'The houses are being built.');
    });

    test('The house was being built', () {
      final state = SentenceState(
        subject: house.toSubject(Number.singular, determiner: theDeterminer),
        verb: build,
        voice: Voice.passive,
        tense: Tense.past,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'The house was being built.');
    });

    test('The houses were being built', () {
      final state = SentenceState(
        subject: house.toSubject(Number.plural, determiner: theDeterminer),
        verb: build,
        voice: Voice.passive,
        tense: Tense.past,
        aspect: Aspect.continuous,
        modal: Modal.none,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'The houses were being built.');
    });

    test('Can the house be built?', () {
      final state = SentenceState(
        subject: house.toSubject(Number.singular, determiner: theDeterminer),
        verb: build,
        voice: Voice.passive,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.can,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.question,
      );

      expect(engine.generate(state).text, 'Can the house be built?');
    });

    test('The house should be built', () {
      final state = SentenceState(
        subject: house.toSubject(Number.singular, determiner: theDeterminer),
        verb: build,
        voice: Voice.passive,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: Modal.should,
        polarity: Polarity.positive,
        sentenceForm: SentenceForm.statement,
      );

      expect(engine.generate(state).text, 'The house should be built.');
    });
  });
}
