import 'package:padlock_app/models/language.dart';

class Verb {
  final String infinitive;
  final String presentThirdPerson;
  final String pastSimple;
  final String pastParticiple;
  final String ingForm;

  /// go, come, travel, arrive, leave...
  final bool usesDestinationPlace;

  final Map<Language, String> translations;

  const Verb({
    required this.infinitive,
    required this.presentThirdPerson,
    required this.pastSimple,
    required this.pastParticiple,
    required this.ingForm,
    this.usesDestinationPlace = false,
    required this.translations,
  });
}
