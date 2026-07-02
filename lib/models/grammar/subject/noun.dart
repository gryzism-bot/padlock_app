import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/grammar/subject/determiner.dart';
import 'package:padlock_app/models/language.dart';
import 'number.dart';
import 'person.dart';
import 'noun_phrase.dart';

class Noun {
  final String singular;
  final String plural;

  final Map<Language, String> singularTranslations;
  final Map<Language, String> pluralTranslations;

  const Noun({
    required this.singular,
    required this.plural,
    required this.singularTranslations,
    required this.pluralTranslations,
  });

  NounPhrase toNounPhrase(
    Number number, {
    Determiner? determiner,
    Adjective? adjective,
  }) {
    return NounPhrase(
      text: number == Number.singular ? singular : plural,

      person: Person.third,
      number: number,

      determiner: determiner,
      adjective: adjective,

      translations: number == Number.singular
          ? singularTranslations
          : pluralTranslations,
    );
  }
}
