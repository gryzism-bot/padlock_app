import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/grammar/subject/determiner.dart';
import 'package:padlock_app/models/language.dart';
import 'number.dart';
import 'person.dart';

//(Subject)
class NounPhrase {
  final String text;

  final Person person;
  final Number number;

  final Determiner? determiner;

  final Adjective? adjective;

  final Map<Language, String> translations;

  const NounPhrase({
    required this.text,
    required this.person,
    required this.number,
    this.determiner,
    this.adjective,
    required this.translations,
  });

  bool get isPlural => number == Number.plural;

  bool get takesThirdPersonVerb =>
      person == Person.third && number == Number.singular;
}
