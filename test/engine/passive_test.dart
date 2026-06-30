import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';

import 'package:padlock_app/engine/grammar_engine.dart';

import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';

import 'package:padlock_app/data/verbs/work.dart';

void main() {
  final engine = GrammarEngine();

  group('Passive voice', () {
    test('Passive renders object as subject with determiner', () {
      final state = SentenceState(
        agent: john.toNounPhrase(Number.singular),
        object: house.toNounPhrase(Number.singular, determiner: theDeterminer),
        action: build,
        tense: Tense.present,
        aspect: Aspect.simple,
        voice: Voice.passive,
      );

      expect(engine.generate(state).text, 'The house is built by John.');
    });

    test('Passive renders plural object with determiner', () {
      final state = SentenceState(
        agent: worker.toNounPhrase(Number.plural),
        object: bridge.toNounPhrase(Number.plural, determiner: theDeterminer),
        action: build,
        tense: Tense.past,
        aspect: Aspect.simple,
        voice: Voice.passive,
      );

      expect(engine.generate(state).text, 'The bridges were built by workers.');
    });

    test('Passive renders agent determiner', () {
      final state = SentenceState(
        agent: worker.toNounPhrase(Number.plural, determiner: theDeterminer),
        object: bridge.toNounPhrase(Number.singular, determiner: theDeterminer),
        action: build,
        tense: Tense.past,
        aspect: Aspect.simple,
        voice: Voice.passive,
      );

      expect(
        engine.generate(state).text,
        'The bridge was built by the workers.',
      );
    });
    test('A house is built by John', () {
      final state = SentenceState(
        agent: john.toNounPhrase(Number.singular),
        object: house.toNounPhrase(Number.singular, determiner: aDeterminer),
        action: build,
        tense: Tense.present,
        aspect: Aspect.simple,
        voice: Voice.passive,
      );

      expect(engine.generate(state).text, 'A house is built by John.');
    });

    test('The houses are built by John', () {
      final state = SentenceState(
        agent: john.toNounPhrase(Number.singular),
        object: house.toNounPhrase(Number.plural, determiner: theDeterminer),
        action: build,
        tense: Tense.present,
        aspect: Aspect.simple,
        voice: Voice.passive,
      );

      expect(engine.generate(state).text, 'The houses are built by John.');
    });

    test('The bridge was built by the workers', () {
      final state = SentenceState(
        agent: worker.toNounPhrase(Number.plural, determiner: theDeterminer),
        object: bridge.toNounPhrase(Number.singular, determiner: theDeterminer),
        action: build,
        tense: Tense.past,
        aspect: Aspect.simple,
        voice: Voice.passive,
      );

      expect(
        engine.generate(state).text,
        'The bridge was built by the workers.',
      );
    });

    test('The bridges were built by the workers', () {
      final state = SentenceState(
        agent: worker.toNounPhrase(Number.plural, determiner: theDeterminer),
        object: bridge.toNounPhrase(Number.plural, determiner: theDeterminer),
        action: build,
        tense: Tense.past,
        aspect: Aspect.simple,
        voice: Voice.passive,
      );

      expect(
        engine.generate(state).text,
        'The bridges were built by the workers.',
      );
    });

    test('A bridge will be built by workers', () {
      final state = SentenceState(
        agent: worker.toNounPhrase(Number.plural),
        object: bridge.toNounPhrase(Number.singular, determiner: aDeterminer),
        action: build,
        tense: Tense.future,
        aspect: Aspect.simple,
        voice: Voice.passive,
      );

      expect(engine.generate(state).text, 'A bridge will be built by workers.');
    });

    test('The house is being built by John', () {
      final state = SentenceState(
        agent: john.toNounPhrase(Number.singular),
        object: house.toNounPhrase(Number.singular, determiner: theDeterminer),
        action: build,
        tense: Tense.present,
        aspect: Aspect.continuous,
        voice: Voice.passive,
      );

      expect(engine.generate(state).text, 'The house is being built by John.');
    });

    test('The bridge was being built by the workers', () {
      final state = SentenceState(
        agent: worker.toNounPhrase(Number.plural, determiner: theDeterminer),
        object: bridge.toNounPhrase(Number.singular, determiner: theDeterminer),
        action: build,
        tense: Tense.past,
        aspect: Aspect.continuous,
        voice: Voice.passive,
      );

      expect(
        engine.generate(state).text,
        'The bridge was being built by the workers.',
      );
    });

    test('The house has been built by John', () {
      final state = SentenceState(
        agent: john.toNounPhrase(Number.singular),
        object: house.toNounPhrase(Number.singular, determiner: theDeterminer),
        action: build,
        tense: Tense.present,
        aspect: Aspect.perfect,
        voice: Voice.passive,
      );

      expect(engine.generate(state).text, 'The house has been built by John.');
    });

    test('The bridge had been built by the workers', () {
      final state = SentenceState(
        agent: worker.toNounPhrase(Number.plural, determiner: theDeterminer),
        object: bridge.toNounPhrase(Number.singular, determiner: theDeterminer),
        action: build,
        tense: Tense.past,
        aspect: Aspect.perfect,
        voice: Voice.passive,
      );

      expect(
        engine.generate(state).text,
        'The bridge had been built by the workers.',
      );
    });

    test('The bridge will have been built by the workers', () {
      final state = SentenceState(
        agent: worker.toNounPhrase(Number.plural, determiner: theDeterminer),
        object: bridge.toNounPhrase(Number.singular, determiner: theDeterminer),
        action: build,
        tense: Tense.future,
        aspect: Aspect.perfect,
        voice: Voice.passive,
      );

      expect(
        engine.generate(state).text,
        'The bridge will have been built by the workers.',
      );
    });

    test('The house has not been built by John', () {
      final state = SentenceState(
        agent: john.toNounPhrase(Number.singular),
        object: house.toNounPhrase(Number.singular, determiner: theDeterminer),
        action: build,
        tense: Tense.present,
        aspect: Aspect.perfect,
        polarity: Polarity.negative,
        voice: Voice.passive,
      );

      expect(
        engine.generate(state).text,
        'The house has not been built by John.',
      );
    });

    test('Was the house built by John?', () {
      final state = SentenceState(
        agent: john.toNounPhrase(Number.singular),
        object: house.toNounPhrase(Number.singular, determiner: theDeterminer),
        action: build,
        tense: Tense.past,
        aspect: Aspect.simple,
        sentenceForm: SentenceForm.question,
        voice: Voice.passive,
      );

      expect(engine.generate(state).text, 'Was the house built by John?');
    });

    test('Should bridge be built by the workers?', () {
      final state = SentenceState(
        agent: worker.toNounPhrase(Number.plural),
        object: bridge.toNounPhrase(Number.singular),
        action: build,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: should,
        sentenceForm: SentenceForm.question,
        voice: Voice.passive,
      );

      expect(
        engine.generate(state).text,
        'Should bridge be built by workers?',
      );
    });

    test('A bridge should be built by workers', () {
      final state = SentenceState(
        agent: worker.toNounPhrase(Number.plural),
        object: bridge.toNounPhrase(Number.singular, determiner: aDeterminer),
        action: build,
        tense: Tense.present,
        aspect: Aspect.simple,
        modal: should,
        voice: Voice.passive,
      );

      expect(
        engine.generate(state).text,
        'A bridge should be built by workers.',
      );
    });

    test('The bridge must have been built by workers', () {
      final state = SentenceState(
        agent: worker.toNounPhrase(Number.plural, determiner: theDeterminer),
        object: bridge.toNounPhrase(Number.singular, determiner: theDeterminer),
        action: build,
        tense: Tense.present,
        aspect: Aspect.perfect,
        modal: must,
        voice: Voice.passive,
      );

      expect(
        engine.generate(state).text,
        'The bridge must have been built by the workers.',
      );
    });

    test('The houses have been built by the workers', () {
      final state = SentenceState(
        agent: worker.toNounPhrase(Number.plural, determiner: theDeterminer),
        object: house.toNounPhrase(Number.plural, determiner: theDeterminer),
        action: build,
        tense: Tense.present,
        aspect: Aspect.perfect,
        voice: Voice.passive,
      );

      expect(
        engine.generate(state).text,
        'The houses have been built by the workers.',
      );
    });

    test('The houses were being built by workers', () {
      final state = SentenceState(
        agent: worker.toNounPhrase(Number.plural),
        object: house.toNounPhrase(Number.plural, determiner: theDeterminer),
        action: build,
        tense: Tense.past,
        aspect: Aspect.continuous,
        voice: Voice.passive,
      );

      expect(
        engine.generate(state).text,
        'The houses were being built by workers.',
      );
    });
  });
}
