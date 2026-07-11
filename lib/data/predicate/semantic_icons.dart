class PredicateIconSlot {
  final String materialIcon;
  final String assetPath;

  const PredicateIconSlot({required this.materialIcon, this.assetPath = ''});
}

class MaterialIconKey {
  static const accountTreeOutlined = 'account_tree_outlined';
  static const arrowDownward = 'arrow_downward';
  static const arrowForward = 'arrow_forward';
  static const arrowUpward = 'arrow_upward';
  static const backHandOutlined = 'back_hand_outlined';
  static const callReceived = 'call_received';
  static const directionsWalk = 'directions_walk';
  static const editOutlined = 'edit_outlined';
  static const euro = 'euro';
  static const frontHandOutlined = 'front_hand_outlined';
  static const groupsOutlined = 'groups_outlined';
  static const handshakeOutlined = 'handshake_outlined';
  static const inventory2Outlined = 'inventory_2_outlined';
  static const lightbulbOutline = 'lightbulb_outline';
  static const menuBookOutlined = 'menu_book_outlined';
  static const panToolAltOutlined = 'pan_tool_alt_outlined';
  static const panToolOutlined = 'pan_tool_outlined';
  static const personOutline = 'person_outline';
  static const recordVoiceOverOutlined = 'record_voice_over_outlined';
  static const schoolOutlined = 'school_outlined';
  static const sportsSoccer = 'sports_soccer';

  const MaterialIconKey._();
}

class PredicateSemanticIconProfile {
  final List<PredicateIconSlot> icons;
  final int? outputCount;

  const PredicateSemanticIconProfile({required this.icons, this.outputCount});
}

const _verbIconProfiles = <String, PredicateSemanticIconProfile>{
  // Fill assetPath when a Noun Project/custom SVG replaces a Material icon.
  'be': PredicateSemanticIconProfile(
    icons: [
      PredicateIconSlot(materialIcon: MaterialIconKey.personOutline),
      PredicateIconSlot(materialIcon: MaterialIconKey.accountTreeOutlined),
    ],
    outputCount: 2,
  ),
  'buy': PredicateSemanticIconProfile(
    icons: [
      PredicateIconSlot(materialIcon: MaterialIconKey.frontHandOutlined),
      PredicateIconSlot(materialIcon: MaterialIconKey.euro),
    ],
  ),
  'come': PredicateSemanticIconProfile(
    icons: [
      PredicateIconSlot(materialIcon: MaterialIconKey.directionsWalk),
      PredicateIconSlot(materialIcon: MaterialIconKey.arrowDownward),
    ],
  ),
  'get': PredicateSemanticIconProfile(
    icons: [
      PredicateIconSlot(materialIcon: MaterialIconKey.panToolAltOutlined),
      PredicateIconSlot(materialIcon: MaterialIconKey.callReceived),
    ],
  ),
  'give': PredicateSemanticIconProfile(
    icons: [
      PredicateIconSlot(materialIcon: MaterialIconKey.panToolOutlined),
      PredicateIconSlot(materialIcon: MaterialIconKey.arrowForward),
    ],
  ),
  'go': PredicateSemanticIconProfile(
    icons: [
      PredicateIconSlot(materialIcon: MaterialIconKey.directionsWalk),
      PredicateIconSlot(materialIcon: MaterialIconKey.arrowForward),
    ],
  ),
  'learn': PredicateSemanticIconProfile(
    icons: [
      PredicateIconSlot(materialIcon: MaterialIconKey.menuBookOutlined),
      PredicateIconSlot(materialIcon: MaterialIconKey.callReceived),
    ],
  ),
  'leave': PredicateSemanticIconProfile(
    icons: [
      PredicateIconSlot(materialIcon: MaterialIconKey.directionsWalk),
      PredicateIconSlot(materialIcon: MaterialIconKey.arrowUpward),
    ],
  ),
  'make': PredicateSemanticIconProfile(
    icons: [
      PredicateIconSlot(materialIcon: MaterialIconKey.panToolOutlined),
      PredicateIconSlot(materialIcon: MaterialIconKey.arrowForward),
    ],
  ),
  'need': PredicateSemanticIconProfile(
    icons: [
      PredicateIconSlot(materialIcon: MaterialIconKey.handshakeOutlined),
      PredicateIconSlot(materialIcon: MaterialIconKey.callReceived),
    ],
  ),
  'play': PredicateSemanticIconProfile(
    icons: [
      PredicateIconSlot(materialIcon: MaterialIconKey.sportsSoccer),
      PredicateIconSlot(materialIcon: MaterialIconKey.arrowForward),
    ],
  ),
  'speak': PredicateSemanticIconProfile(
    icons: [
      PredicateIconSlot(materialIcon: MaterialIconKey.recordVoiceOverOutlined),
      PredicateIconSlot(materialIcon: MaterialIconKey.arrowForward),
    ],
  ),
  'study': PredicateSemanticIconProfile(
    icons: [
      PredicateIconSlot(materialIcon: MaterialIconKey.menuBookOutlined),
      PredicateIconSlot(materialIcon: MaterialIconKey.schoolOutlined),
    ],
  ),
  'want': PredicateSemanticIconProfile(
    icons: [
      PredicateIconSlot(materialIcon: MaterialIconKey.backHandOutlined),
      PredicateIconSlot(materialIcon: MaterialIconKey.callReceived),
    ],
  ),
  'write': PredicateSemanticIconProfile(
    icons: [
      PredicateIconSlot(materialIcon: MaterialIconKey.editOutlined),
      PredicateIconSlot(materialIcon: MaterialIconKey.arrowDownward),
    ],
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

List<PredicateIconSlot> _fallbackIconsForInfluences(
  List<String> influenceKeys,
) {
  if (influenceKeys.contains('recipient')) {
    return const [
      PredicateIconSlot(materialIcon: MaterialIconKey.frontHandOutlined),
      PredicateIconSlot(materialIcon: MaterialIconKey.arrowForward),
    ];
  }
  if (influenceKeys.contains('object')) {
    return const [
      PredicateIconSlot(materialIcon: MaterialIconKey.lightbulbOutline),
      PredicateIconSlot(materialIcon: MaterialIconKey.inventory2Outlined),
    ];
  }
  if (influenceKeys.contains('complement')) {
    return const [
      PredicateIconSlot(materialIcon: MaterialIconKey.personOutline),
      PredicateIconSlot(materialIcon: MaterialIconKey.accountTreeOutlined),
    ];
  }
  if (influenceKeys.contains('activity')) {
    return const [
      PredicateIconSlot(materialIcon: MaterialIconKey.sportsSoccer),
      PredicateIconSlot(materialIcon: MaterialIconKey.arrowForward),
    ];
  }
  if (influenceKeys.contains('subject')) {
    return const [
      PredicateIconSlot(materialIcon: MaterialIconKey.menuBookOutlined),
      PredicateIconSlot(materialIcon: MaterialIconKey.schoolOutlined),
    ];
  }
  if (influenceKeys.contains('language')) {
    return const [
      PredicateIconSlot(materialIcon: MaterialIconKey.recordVoiceOverOutlined),
      PredicateIconSlot(materialIcon: MaterialIconKey.arrowForward),
    ];
  }
  if (influenceKeys.contains('destination')) {
    return const [
      PredicateIconSlot(materialIcon: MaterialIconKey.directionsWalk),
      PredicateIconSlot(materialIcon: MaterialIconKey.arrowForward),
    ];
  }

  return const [
    PredicateIconSlot(materialIcon: MaterialIconKey.lightbulbOutline),
    PredicateIconSlot(materialIcon: MaterialIconKey.arrowForward),
  ];
}
