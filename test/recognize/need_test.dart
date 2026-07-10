import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart' as modals;
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/verbs/essential.dart' as verbs;
import 'package:padlock_app/engine/recognition_engine.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';

import 'helpers.dart';

void main() {
  final engine = RecognitionEngine();

  group('Recognition Need', () {
    test('John needs the book', () {
      final state = engine.recognize('John needs the book.');

      expectAgent(state, text: 'john');
      expectObject(state, text: 'book', determiner: theDeterminer);
      expect(state.action, verbs.need);
      expect(state.modal, modals.noModal);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.simple);
      expect(state.polarity, Polarity.positive);
      expect(state.sentenceForm, SentenceForm.statement);
    });

    test('Mary needed a book yesterday', () {
      final state = engine.recognize('Mary needed a book yesterday.');

      expectAgent(state, text: 'mary');
      expectObject(state, text: 'book', determiner: aDeterminer);
      expect(state.action, verbs.need);
      expect(state.modal, modals.noModal);
      expect(state.tense, Tense.past);
      expect(state.aspect, Aspect.simple);
      expect(state.timePhrase, yesterdayTimePhrase);
    });

    test('John does not need a book', () {
      final state = engine.recognize('John does not need a book.');

      expectAgent(state, text: 'john');
      expectObject(state, text: 'book', determiner: aDeterminer);
      expect(state.action, verbs.need);
      expect(state.modal, modals.noModal);
      expect(state.polarity, Polarity.negative);
      expect(state.sentenceForm, SentenceForm.statement);
    });

    test('Does John need a book?', () {
      final state = engine.recognize('Does John need a book?');

      expectAgent(state, text: 'john');
      expectObject(state, text: 'book', determiner: aDeterminer);
      expect(state.action, verbs.need);
      expect(state.modal, modals.noModal);
      expect(state.sentenceForm, SentenceForm.question);
    });

    test('John need not work', () {
      final state = engine.recognize('John need not work.');

      expectAgent(state, text: 'john');
      expect(state.object, isNull);
      expect(state.action, verbs.work);
      expect(state.modal, modals.need);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.simple);
      expect(state.polarity, Polarity.negative);
      expect(state.sentenceForm, SentenceForm.statement);
    });

    test('Need John work?', () {
      final state = engine.recognize('Need John work?');

      expectAgent(state, text: 'john');
      expect(state.object, isNull);
      expect(state.action, verbs.work);
      expect(state.modal, modals.need);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.simple);
      expect(state.sentenceForm, SentenceForm.question);
    });
  });
}
