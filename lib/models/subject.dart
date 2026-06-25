class Subject {
  final String text;

  final bool isThirdPerson;
  final bool isPlural;

  const Subject({
    required this.text,
    required this.isThirdPerson,
    required this.isPlural,
  });

  bool get takesThirdPersonVerb => isThirdPerson && !isPlural;

  bool get takesAre => isPlural || text == 'You';

  bool get takesIs => !takesAre;

  bool get takesHave => isPlural || text == 'I' || text == 'You';

  bool get takesHas => !takesHave;
}
