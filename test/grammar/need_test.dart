import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart' as modals;
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/verbs/essential.dart' as verbs;
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

void main() {
  final engine = GrammarEngine();

  group('Need', () {
    test('Lexical need renders object frame', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: verbs.need,
          object: book.toNounPhrase(Number.singular, determiner: theDeterminer),
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'John needs the book.');
    });

    test('Lexical need keeps regular past form', () {
      final sentence = engine.generate(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: verbs.need,
          object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
          tense: Tense.past,
          aspect: Aspect.simple,
          timePhrase: yesterdayTimePhrase,
        ),
      );

      expect(sentence.text, 'Mary needed a book yesterday.');
    });

    test('Lexical need uses do-support for negatives', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: verbs.need,
          object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
          tense: Tense.present,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'John does not need a book.');
    });

    test('Lexical need uses do-support for questions', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: verbs.need,
          object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
          tense: Tense.present,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Does John need a book?');
    });

    test('Semi-modal need renders negative bare infinitive', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: verbs.work,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: modals.need,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, 'John need not work.');
    });

    test('Semi-modal need renders question bare infinitive', () {
      final sentence = engine.generate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: verbs.work,
          tense: Tense.present,
          aspect: Aspect.simple,
          modal: modals.need,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Need John work?');
    });
  });
}
