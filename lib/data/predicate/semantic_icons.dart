enum SemanticIcon {
  arrowDown,
  arrowIn,
  arrowOut,
  arrowUp,
  activity,
  book,
  complement,
  crowd,
  euro,
  fist,
  foot,
  grabbingHand,
  hand,
  hands,
  language,
  lightbulb,
  object,
  openHand,
  pen,
  person,
  subject,
}

class PredicateSemanticIconProfile {
  final List<SemanticIcon> icons;
  final int? outputCount;

  const PredicateSemanticIconProfile({required this.icons, this.outputCount});
}

const _verbIconProfiles = <String, PredicateSemanticIconProfile>{
  // Choose two semantic icons here; the UI maps these names to Phosphor.
  'be': PredicateSemanticIconProfile(
    icons: [SemanticIcon.person, SemanticIcon.complement],
    outputCount: 2,
  ),
  'buy': PredicateSemanticIconProfile(
    icons: [SemanticIcon.hand, SemanticIcon.euro],
  ),
  'come': PredicateSemanticIconProfile(
    icons: [SemanticIcon.foot, SemanticIcon.arrowDown],
  ),
  'get': PredicateSemanticIconProfile(
    icons: [SemanticIcon.grabbingHand, SemanticIcon.arrowIn],
  ),
  'give': PredicateSemanticIconProfile(
    icons: [SemanticIcon.openHand, SemanticIcon.arrowOut],
  ),
  'go': PredicateSemanticIconProfile(
    icons: [SemanticIcon.foot, SemanticIcon.arrowOut],
  ),
  'learn': PredicateSemanticIconProfile(
    icons: [SemanticIcon.book, SemanticIcon.arrowIn],
  ),
  'leave': PredicateSemanticIconProfile(
    icons: [SemanticIcon.foot, SemanticIcon.arrowUp],
  ),
  'make': PredicateSemanticIconProfile(
    icons: [SemanticIcon.openHand, SemanticIcon.arrowOut],
  ),
  'need': PredicateSemanticIconProfile(
    icons: [SemanticIcon.hands, SemanticIcon.arrowIn],
  ),
  'play': PredicateSemanticIconProfile(
    icons: [SemanticIcon.activity, SemanticIcon.arrowOut],
  ),
  'speak': PredicateSemanticIconProfile(
    icons: [SemanticIcon.language, SemanticIcon.arrowOut],
  ),
  'study': PredicateSemanticIconProfile(
    icons: [SemanticIcon.book, SemanticIcon.subject],
  ),
  'want': PredicateSemanticIconProfile(
    icons: [SemanticIcon.fist, SemanticIcon.arrowIn],
  ),
  'write': PredicateSemanticIconProfile(
    icons: [SemanticIcon.pen, SemanticIcon.arrowDown],
  ),
};

PredicateSemanticIconProfile predicateSemanticIconProfileFor({
  required String infinitive,
  required List<String> influenceKeys,
}) {
  return _verbIconProfiles[infinitive] ??
      PredicateSemanticIconProfile(
        icons: _fallbackIconsForInfluences(influenceKeys),
      );
}

int predicateSemanticOutputCount({
  required String infinitive,
  required List<String> influenceKeys,
  required PredicateSemanticIconProfile profile,
}) {
  if (profile.outputCount != null) {
    return profile.outputCount!;
  }

  if (infinitive == 'be') {
    return 2;
  }

  return influenceKeys.length;
}

List<SemanticIcon> _fallbackIconsForInfluences(List<String> influenceKeys) {
  if (influenceKeys.contains('recipient')) {
    return const [SemanticIcon.hand, SemanticIcon.arrowOut];
  }
  if (influenceKeys.contains('object')) {
    return const [SemanticIcon.lightbulb, SemanticIcon.object];
  }
  if (influenceKeys.contains('complement')) {
    return const [SemanticIcon.person, SemanticIcon.complement];
  }
  if (influenceKeys.contains('activity')) {
    return const [SemanticIcon.activity, SemanticIcon.arrowOut];
  }
  if (influenceKeys.contains('subject')) {
    return const [SemanticIcon.book, SemanticIcon.subject];
  }
  if (influenceKeys.contains('language')) {
    return const [SemanticIcon.language, SemanticIcon.arrowOut];
  }
  if (influenceKeys.contains('destination')) {
    return const [SemanticIcon.foot, SemanticIcon.arrowOut];
  }

  return const [SemanticIcon.lightbulb, SemanticIcon.arrowOut];
}
