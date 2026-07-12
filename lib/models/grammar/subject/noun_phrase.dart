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
  final List<Adjective> adjectives;

  final Map<Language, String> translations;

  const NounPhrase({
    required this.text,
    required this.person,
    required this.number,
    this.determiner,
    this.adjective,
    this.adjectives = const [],
    required this.translations,
  });

  List<Adjective> get adjectiveList {
    if (adjectives.isNotEmpty) {
      return adjectives;
    }

    if (adjective != null) {
      return [adjective!];
    }

    return const [];
  }

  bool get isPlural => number == Number.plural;

  bool get isPronoun => _pronounTexts.contains(text.toLowerCase());

  bool get canTakeModifiers => !isPronoun;

  bool get takesThirdPersonVerb =>
      person == Person.third && number == Number.singular;

  NounPhrase copyWith({
    Object? determiner = _unchanged,
    Object? adjective = _unchanged,
    List<Adjective>? adjectives,
  }) {
    return NounPhrase(
      text: text,
      person: person,
      number: number,
      determiner: identical(determiner, _unchanged)
          ? this.determiner
          : determiner as Determiner?,
      adjective: identical(adjective, _unchanged)
          ? this.adjective
          : adjective as Adjective?,
      adjectives: adjectives ?? this.adjectives,
      translations: translations,
    );
  }
}

const _unchanged = Object();

const _pronounTexts = {
  'i',
  'you',
  'he',
  'she',
  'it',
  'we',
  'they',
  'me',
  'him',
  'her',
  'us',
  'them',
  'myself',
  'yourself',
  'himself',
  'herself',
  'itself',
  'ourselves',
  'yourselves',
  'themselves',
  'someone',
  'anyone',
  'nobody',
  'everyone',
};
