import '../language.dart';
import 'Number.dart';
import 'person.dart';

class Subject {
  final String text;

  final Person person;
  final Number number;

  final Map<Language, String> translations;

  const Subject({
    required this.text,
    required this.person,
    required this.number,
    required this.translations,
  });

  bool get isPlural => number == Number.plural;

  bool get takesThirdPersonVerb =>
      person == Person.third && number == Number.singular;
}
