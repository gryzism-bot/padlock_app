import 'package:padlock_app/models/language.dart';
import 'number.dart';
import 'person.dart';
import 'subject.dart';

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

  Subject toSubject(Number number) {
    return Subject(
      text: number == Number.singular ? singular : plural,
      person: Person.third,
      number: number,
      translations: number == Number.singular
          ? singularTranslations
          : pluralTranslations,
    );
  }
}
