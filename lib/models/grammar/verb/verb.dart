import 'package:padlock_app/models/language.dart';

class Verb {
  final String infinitive;
  final String presentThirdPerson;
  final String pastSimple;
  final String pastParticiple;
  final String ingForm;
  //only for Recognition Engine
  final bool takesObject;
  final bool takesRecipient;
  final bool takesAddressee;
  final bool takesCompanion;
  final bool takesTopic;
  final bool takesBeneficiary;
  final bool takesSource;
  final bool takesObjectComplement;

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
    this.takesObject = false,
    this.takesRecipient = false,
    this.takesAddressee = false,
    this.takesCompanion = false,
    this.takesTopic = false,
    this.takesBeneficiary = false,
    this.takesSource = false,
    this.takesObjectComplement = false,
    required this.translations,
  });
}
