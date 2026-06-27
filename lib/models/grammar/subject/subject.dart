import 'package:padlock_app/models/grammar/subject/determiner.dart';
import 'package:padlock_app/models/language.dart';
import 'number.dart';
import 'person.dart';

class Subject {
  final String text;

  final Person person;
  final Number number;

  final Determiner? determiner;

  final Map<Language, String> translations;

  const Subject({
    required this.text,
    required this.person,
    required this.number,
    this.determiner,
    required this.translations,
  });

  bool get isPlural => number == Number.plural;

  bool get takesThirdPersonVerb =>
      person == Person.third && number == Number.singular;
}
