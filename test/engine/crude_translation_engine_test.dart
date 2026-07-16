import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/engine/crude_translation_engine.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

void main() {
  final grammar = GrammarEngine();
  const translator = CrudeTranslationEngine();

  String translate(SentenceState state) {
    final sentence = grammar.generate(state).text;
    return translator.translateSentence(
      renderedSentence: sentence,
      state: state,
    );
  }

  group('Crude Polish translation', () {
    test('distinguishes singular and plural you', () {
      final singular = translate(
        const SentenceState(
          agent: you,
          action: learn,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );
      final plural = translate(
        const SentenceState(
          agent: youPlural,
          action: learn,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(singular, '(Ty) (uczysz się.)');
      expect(plural, '(Wy) (uczycie się.)');
    });

    test('renders played with a finite Polish past gloss', () {
      final translated = translate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: play,
          object: football,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(translated, contains('(grał)'));
      expect(translated, contains('(piłka nożna.)'));
    });

    test('renders had with a finite Polish past gloss', () {
      final translated = translate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: have,
          object: book.toNounPhrase(Number.singular),
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(translated, contains('(miał)'));
    });

    test('renders did with a finite Polish past gloss', () {
      final translated = translate(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: doVerb,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(translated, '(Jan) (zrobił.)');
    });

    test('keeps plural you visible in past-tense verb glosses', () {
      final translated = translate(
        const SentenceState(
          agent: youPlural,
          action: play,
          object: football,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(translated, contains('(Wy)'));
      expect(translated, contains('(graliście/grałyście)'));
    });
  });
}
