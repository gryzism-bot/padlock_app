import '../language.dart';

class Subject {
  final String text;

  final bool isThirdPerson;
  final bool isPlural;
  final Map<Language, String> translations;

  const Subject({
    required this.text,
    required this.isThirdPerson,
    required this.isPlural,
    required this.translations,
  });

  bool get takesThirdPersonVerb => isThirdPerson && !isPlural;

  bool get takesAre => isPlural || text == 'You';

  bool get takesIs => !takesAre;

  bool get takesHave => isPlural || text == 'I' || text == 'You';

  bool get takesHas => !takesHave;
}
