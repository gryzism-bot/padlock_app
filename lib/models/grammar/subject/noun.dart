import 'package:padlock_app/models/grammar/subject/determiner.dart';
import 'package:padlock_app/models/language.dart';
import 'number.dart';
import 'person.dart';
import 'subject.dart';

class Noun {
  final String singular;
  final String plural;

  final Map<Language, String> singularTranslations;
  final Map<Language, String> pluralTranslations;

  final Determiner? determiner;

  const Noun({
    required this.singular,
    required this.plural,
    required this.singularTranslations,
    required this.pluralTranslations,
    this.determiner,
  });

  Subject toSubject(Number number, {Determiner? determiner}) {
    return Subject(
      text: number == Number.singular ? singular : plural,
      person: Person.third,
      number: number,
      determiner: determiner,
      translations: number == Number.singular
          ? singularTranslations
          : pluralTranslations,
    );
  }
}
