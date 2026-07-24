part of '../home_screen.dart';

String _collapsedRailHint(String title) {
  return 'Click to open $title choices.';
}

typedef _RailTitleBuilder = String Function(ConfigurationState configuration);
typedef _RailHintBuilder = String Function(ConfigurationState configuration);
typedef _RailStatePredicate = bool Function(SentenceState state);
typedef _RailValueBuilder = String Function(SentenceState state);
typedef _RailSurfaceBuilder =
    String? Function(ConfigurationState configuration);
typedef _RailSuggestionsBuilder =
    List<ConfigurationSuggestion> Function(ConfigurationCompassSlot slot);

class _RailPolicy {
  final ConfigurationCompassSlot slot;
  final _RailTitleBuilder title;
  final _RailHintBuilder unlockHint;
  final bool isControlled;
  final _RailStatePredicate canRenderCollapsedWhen;
  final _RailStatePredicate canRenderWhenEmpty;
  final _RailSurfaceBuilder surfaceMarker;
  final _RailTitleBuilder? participantLabel;
  final _RailValueBuilder? participantValue;
  final _RailStatePredicate? participantAwakeWhen;
  final _RailStatePredicate? participantFilledWhen;

  const _RailPolicy({
    required this.slot,
    required this.title,
    required this.unlockHint,
    required this.isControlled,
    required this.canRenderCollapsedWhen,
    required this.canRenderWhenEmpty,
    this.surfaceMarker = _noRailSurfaceMarker,
    this.participantLabel,
    this.participantValue,
    this.participantAwakeWhen,
    this.participantFilledWhen,
  });

  bool canRenderCollapsed(ConfigurationState configuration) {
    return canRenderCollapsedWhen(configuration.sentenceState);
  }

  bool shouldRender(
    ConfigurationState configuration,
    List<ConfigurationSuggestion> suggestions,
  ) {
    return suggestions.isNotEmpty ||
        canRenderWhenEmpty(configuration.sentenceState);
  }

  _ParticipantDoor? participantDoor(ConfigurationState configuration) {
    final valueBuilder = participantValue;
    final filledWhen = participantFilledWhen;
    if (valueBuilder == null || filledWhen == null) {
      return null;
    }

    return _ParticipantDoor(
      label: participantLabel?.call(configuration) ?? title(configuration),
      value: valueBuilder(configuration.sentenceState),
      status: _participantStatus(
        isAwake:
            participantAwakeWhen?.call(configuration.sentenceState) ??
            canRenderCollapsed(configuration),
        isFilled: filledWhen(configuration.sentenceState),
      ),
      slot: slot,
    );
  }
}

_RailPolicy _railPolicy(ConfigurationCompassSlot slot) {
  final policy = _railPolicies[slot];
  if (policy == null) {
    throw StateError('Missing rail policy for $slot');
  }

  return policy;
}

List<_VisibleCompassSlot> _visibleRailSections({
  required ConfigurationState configuration,
  required Set<ConfigurationCompassSlot> expandedRails,
  required _RailSuggestionsBuilder suggestionsForSlot,
}) {
  final sections = <_VisibleCompassSlot>[];

  for (final slot in ConfigurationCompassSlot.values.where(_isBodyRailSlot)) {
    final policy = _railPolicy(slot);
    final canToggle = policy.isControlled;
    final isExpanded = !canToggle || expandedRails.contains(slot);

    if (canToggle && !isExpanded) {
      if (!policy.canRenderCollapsed(configuration)) {
        continue;
      }

      sections.add(
        _VisibleCompassSlot(
          slot,
          const [],
          title: policy.title(configuration),
          unlockHint: policy.unlockHint(configuration),
          surfaceMarker: policy.surfaceMarker(configuration),
          isExpanded: false,
          canToggle: true,
        ),
      );
      continue;
    }

    final suggestions = suggestionsForSlot(slot);
    if (!policy.shouldRender(configuration, suggestions)) {
      continue;
    }

    sections.add(
      _VisibleCompassSlot(
        slot,
        suggestions,
        title: policy.title(configuration),
        unlockHint: policy.unlockHint(configuration),
        surfaceMarker: policy.surfaceMarker(configuration),
        isExpanded: isExpanded,
        canToggle: canToggle,
      ),
    );
  }

  return sections;
}

String? _noRailSurfaceMarker(ConfigurationState configuration) => null;

bool _isBodyRailSlot(ConfigurationCompassSlot slot) {
  return slot != ConfigurationCompassSlot.voice &&
      slot != ConfigurationCompassSlot.modal &&
      slot != ConfigurationCompassSlot.passiveFocus &&
      slot != ConfigurationCompassSlot.passiveAgent;
}

String _fixedObjectTitle(ConfigurationState configuration) {
  return _fixedObjectSlotTitle(configuration) ?? 'Object';
}

String _fixedObjectDeterminerTitle(ConfigurationState configuration) {
  return '${_fixedObjectTitle(configuration)} determiner';
}

String _fixedObjectAdjectiveTitle(ConfigurationState configuration) {
  return '${_fixedObjectTitle(configuration)} adjective';
}

String _objectUnlockHint(ConfigurationState configuration) {
  final state = configuration.sentenceState;
  final owner = _railBoundTailOwner(state);
  final fixedLabel = fixedObjectFrameLabel(owner);

  if (fixedLabel == null) {
    return 'Choose a verb that can take an object, like build, give, need, see, or use.';
  }

  return 'Choose a fixed $fixedLabel for ${owner.infinitive}.';
}

String _objectModifierUnlockHint(ConfigurationState configuration) {
  final state = configuration.sentenceState;
  final owner = _railBoundTailOwner(state);

  if (hasFixedObjectFrame(owner) && !fixedObjectFrameAllowsModifiers(owner)) {
    return '${owner.infinitive} fixed ${fixedObjectFrameLabel(owner)} choices stay bare.';
  }

  return 'Choose an object first. Noun phrase modifiers wake after a noun exists.';
}

List<_ParticipantDoor> _coreParticipantDoors(ConfigurationState configuration) {
  final state = configuration.sentenceState;
  return [
    _ParticipantDoor(
      label: 'predicate',
      value: state.action.infinitive,
      status: _ParticipantDoorStatus.filled,
    ),
    _ParticipantDoor(
      label: 'subject',
      value: _nounTraceText(state.agent),
      status: state.agent == null
          ? _ParticipantDoorStatus.asleep
          : _ParticipantDoorStatus.filled,
    ),
    for (final slot in _coreParticipantRailSlots)
      _railPolicy(slot).participantDoor(configuration)!,
  ];
}

const _coreParticipantRailSlots = [
  ConfigurationCompassSlot.object,
  ConfigurationCompassSlot.objectComplement,
  ConfigurationCompassSlot.objectAdjectiveComplement,
  ConfigurationCompassSlot.recipient,
  ConfigurationCompassSlot.addressee,
  ConfigurationCompassSlot.companion,
  ConfigurationCompassSlot.destination,
  ConfigurationCompassSlot.topic,
  ConfigurationCompassSlot.beneficiary,
  ConfigurationCompassSlot.rightAction,
  ConfigurationCompassSlot.passiveAgentNoun,
  ConfigurationCompassSlot.complement,
  ConfigurationCompassSlot.adjectiveComplement,
];

_ParticipantDoorStatus _participantStatus({
  required bool isAwake,
  required bool isFilled,
}) {
  if (isFilled) {
    return _ParticipantDoorStatus.filled;
  }

  return isAwake ? _ParticipantDoorStatus.awake : _ParticipantDoorStatus.asleep;
}

Verb _railBoundTailOwner(SentenceState state) {
  return state.rightAction ?? state.action;
}

final Map<ConfigurationCompassSlot, _RailPolicy> _railPolicies = {
  ConfigurationCompassSlot.action: _RailPolicy(
    slot: ConfigurationCompassSlot.action,
    title: (_) => 'Verb',
    unlockHint: (_) => 'No open move from here.',
    isControlled: false,
    canRenderCollapsedWhen: (_) => false,
    canRenderWhenEmpty: (_) => true,
  ),
  ConfigurationCompassSlot.object: _RailPolicy(
    slot: ConfigurationCompassSlot.object,
    title: _fixedObjectTitle,
    unlockHint: _objectUnlockHint,
    surfaceMarker: (_) => '-',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        _railBoundTailOwner(state).takesObject ||
        hasFixedObjectFrame(_railBoundTailOwner(state)),
    canRenderWhenEmpty: (state) => state.object != null,
    participantLabel: _coreObjectDoorLabel,
    participantValue: (state) => _nounTraceText(state.object),
    participantFilledWhen: (state) => state.object != null,
  ),
  ConfigurationCompassSlot.objectDeterminer: _RailPolicy(
    slot: ConfigurationCompassSlot.objectDeterminer,
    title: _fixedObjectDeterminerTitle,
    unlockHint: _objectModifierUnlockHint,
    isControlled: true,
    canRenderCollapsedWhen: _objectModifiersCanWake,
    canRenderWhenEmpty: _objectModifiersCanWake,
  ),
  ConfigurationCompassSlot.objectAdjective: _RailPolicy(
    slot: ConfigurationCompassSlot.objectAdjective,
    title: _fixedObjectAdjectiveTitle,
    unlockHint: _objectModifierUnlockHint,
    isControlled: true,
    canRenderCollapsedWhen: _objectModifiersCanWake,
    canRenderWhenEmpty: _objectModifiersCanWake,
  ),
  ConfigurationCompassSlot.objectComplement: _RailPolicy(
    slot: ConfigurationCompassSlot.objectComplement,
    title: (_) => 'Object complement',
    unlockHint: (_) =>
        'Choose a verb like make or call, then choose an object first.',
    surfaceMarker: (_) => '-',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        (state.action.takesObjectComplement && state.object != null) ||
        state.objectComplement != null,
    canRenderWhenEmpty: (state) => state.objectComplement != null,
    participantLabel: (_) => 'object complement',
    participantValue: (state) => _nounTraceText(state.objectComplement),
    participantAwakeWhen: (state) =>
        state.action.takesObjectComplement || state.objectComplement != null,
    participantFilledWhen: (state) => state.objectComplement != null,
  ),
  ConfigurationCompassSlot.objectComplementDeterminer: _RailPolicy(
    slot: ConfigurationCompassSlot.objectComplementDeterminer,
    title: (_) => 'Object complement determiner',
    unlockHint: (_) =>
        'Choose an object noun complement first. Object complement modifiers wake after that noun exists.',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.objectComplement?.canTakeModifiers ?? false,
    canRenderWhenEmpty: (state) =>
        state.objectComplement?.canTakeModifiers ?? false,
  ),
  ConfigurationCompassSlot.objectComplementAdjective: _RailPolicy(
    slot: ConfigurationCompassSlot.objectComplementAdjective,
    title: (_) => 'Object complement adjective',
    unlockHint: (_) =>
        'Choose an object noun complement first. Object complement modifiers wake after that noun exists.',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.objectComplement?.canTakeModifiers ?? false,
    canRenderWhenEmpty: (state) =>
        state.objectComplement?.canTakeModifiers ?? false,
  ),
  ConfigurationCompassSlot.objectAdjectiveComplement: _RailPolicy(
    slot: ConfigurationCompassSlot.objectAdjectiveComplement,
    title: (_) => 'Object adjective complement',
    unlockHint: (_) =>
        'Choose a verb like make or call, then choose an object first.',
    surfaceMarker: (_) => '-',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        (state.action.takesObjectComplement && state.object != null) ||
        state.objectAdjectiveComplement != null,
    canRenderWhenEmpty: (state) => state.objectAdjectiveComplement != null,
    participantLabel: (_) => 'object adjective complement',
    participantValue: (state) =>
        state.objectAdjectiveComplement?.text ?? 'none',
    participantAwakeWhen: (state) =>
        state.action.takesObjectComplement ||
        state.objectAdjectiveComplement != null,
    participantFilledWhen: (state) => state.objectAdjectiveComplement != null,
  ),
  ConfigurationCompassSlot.recipient: _RailPolicy(
    slot: ConfigurationCompassSlot.recipient,
    title: (_) => 'Recipient',
    unlockHint: (_) =>
        'Choose a ditransitive verb like give, tell, teach, write, or buy, then keep an object active.',
    surfaceMarker: (_) => 'to/for/-',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        (state.action.takesRecipient && state.object != null) ||
        state.recipient != null,
    canRenderWhenEmpty: (state) => state.recipient != null,
    participantLabel: (_) => 'recipient',
    participantValue: (state) => _nounTraceText(state.recipient),
    participantAwakeWhen: (state) =>
        state.action.takesRecipient || state.recipient != null,
    participantFilledWhen: (state) => state.recipient != null,
  ),
  ConfigurationCompassSlot.recipientDeterminer: _RailPolicy(
    slot: ConfigurationCompassSlot.recipientDeterminer,
    title: (_) => 'Recipient determiner',
    unlockHint: (_) =>
        'Choose a recipient first. Recipient modifiers wake after that noun exists.',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.recipient?.canTakeModifiers ?? false,
    canRenderWhenEmpty: (state) => state.recipient?.canTakeModifiers ?? false,
  ),
  ConfigurationCompassSlot.recipientAdjective: _RailPolicy(
    slot: ConfigurationCompassSlot.recipientAdjective,
    title: (_) => 'Recipient adjective',
    unlockHint: (_) =>
        'Choose a recipient first. Recipient modifiers wake after that noun exists.',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.recipient?.canTakeModifiers ?? false,
    canRenderWhenEmpty: (state) => state.recipient?.canTakeModifiers ?? false,
  ),
  ConfigurationCompassSlot.addressee: _RailPolicy(
    slot: ConfigurationCompassSlot.addressee,
    title: (_) => 'Addressee',
    unlockHint: (_) =>
        'Choose a verb that can speak, talk, or write to someone.',
    surfaceMarker: (_) => 'to',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        _railBoundTailOwner(state).takesAddressee || state.addressee != null,
    canRenderWhenEmpty: (state) => state.addressee != null,
    participantLabel: (_) => 'addressee',
    participantValue: (state) => _nounTraceText(state.addressee),
    participantFilledWhen: (state) => state.addressee != null,
  ),
  ConfigurationCompassSlot.addresseeDeterminer: _RailPolicy(
    slot: ConfigurationCompassSlot.addresseeDeterminer,
    title: (_) => 'Addressee determiner',
    unlockHint: (_) =>
        'Choose an addressee first. Addressee modifiers wake after that noun exists.',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.addressee?.canTakeModifiers ?? false,
    canRenderWhenEmpty: (state) => state.addressee?.canTakeModifiers ?? false,
  ),
  ConfigurationCompassSlot.addresseeAdjective: _RailPolicy(
    slot: ConfigurationCompassSlot.addresseeAdjective,
    title: (_) => 'Addressee adjective',
    unlockHint: (_) =>
        'Choose an addressee first. Addressee modifiers wake after that noun exists.',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.addressee?.canTakeModifiers ?? false,
    canRenderWhenEmpty: (state) => state.addressee?.canTakeModifiers ?? false,
  ),
  ConfigurationCompassSlot.companion: _RailPolicy(
    slot: ConfigurationCompassSlot.companion,
    title: (_) => 'Companion',
    unlockHint: (_) =>
        'Choose verb be or a verb that can happen with someone, like speak, work, run, or go.',
    surfaceMarker: (_) => 'with',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.action.infinitive == 'be' ||
        _railBoundTailOwner(state).takesCompanion ||
        state.companion != null,
    canRenderWhenEmpty: (state) => state.companion != null,
    participantLabel: (_) => 'companion',
    participantValue: (state) => _nounTraceText(state.companion),
    participantFilledWhen: (state) => state.companion != null,
  ),
  ConfigurationCompassSlot.companionDeterminer: _RailPolicy(
    slot: ConfigurationCompassSlot.companionDeterminer,
    title: (_) => 'Companion determiner',
    unlockHint: (_) =>
        'Choose a companion first. Companion modifiers wake after that noun exists.',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.companion?.canTakeModifiers ?? false,
    canRenderWhenEmpty: (state) => state.companion?.canTakeModifiers ?? false,
  ),
  ConfigurationCompassSlot.companionAdjective: _RailPolicy(
    slot: ConfigurationCompassSlot.companionAdjective,
    title: (_) => 'Companion adjective',
    unlockHint: (_) =>
        'Choose a companion first. Companion modifiers wake after that noun exists.',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.companion?.canTakeModifiers ?? false,
    canRenderWhenEmpty: (state) => state.companion?.canTakeModifiers ?? false,
  ),
  ConfigurationCompassSlot.destination: _RailPolicy(
    slot: ConfigurationCompassSlot.destination,
    title: (_) => 'Destination',
    unlockHint: (_) =>
        'Choose a movement verb like go, come, travel, arrive, leave, or return.',
    surfaceMarker: (_) => 'to',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        _railBoundTailOwner(state).usesDestinationPlace ||
        state.destination != null,
    canRenderWhenEmpty: (state) => state.destination != null,
    participantLabel: (_) => 'destination',
    participantValue: (state) => _nounTraceText(state.destination),
    participantFilledWhen: (state) => state.destination != null,
  ),
  ConfigurationCompassSlot.destinationDeterminer: _RailPolicy(
    slot: ConfigurationCompassSlot.destinationDeterminer,
    title: (_) => 'Destination determiner',
    unlockHint: (_) =>
        'Choose a destination first. Destination modifiers wake after that noun exists.',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.destination?.canTakeModifiers ?? false,
    canRenderWhenEmpty: (state) => state.destination?.canTakeModifiers ?? false,
  ),
  ConfigurationCompassSlot.destinationAdjective: _RailPolicy(
    slot: ConfigurationCompassSlot.destinationAdjective,
    title: (_) => 'Destination adjective',
    unlockHint: (_) =>
        'Choose a destination first. Destination modifiers wake after that noun exists.',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.destination?.canTakeModifiers ?? false,
    canRenderWhenEmpty: (state) => state.destination?.canTakeModifiers ?? false,
  ),
  ConfigurationCompassSlot.topic: _RailPolicy(
    slot: ConfigurationCompassSlot.topic,
    title: (_) => 'Topic',
    unlockHint: (_) =>
        'Choose a verb that can open an about-topic, like think, talk, learn, read, or explain.',
    surfaceMarker: (_) => 'about',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        _railBoundTailOwner(state).takesTopic || state.topic != null,
    canRenderWhenEmpty: (state) => state.topic != null,
    participantLabel: (_) => 'topic',
    participantValue: (state) => _nounTraceText(state.topic),
    participantFilledWhen: (state) => state.topic != null,
  ),
  ConfigurationCompassSlot.topicDeterminer: _RailPolicy(
    slot: ConfigurationCompassSlot.topicDeterminer,
    title: (_) => 'Topic determiner',
    unlockHint: (_) =>
        'Choose a topic first. Topic modifiers wake after that noun exists.',
    isControlled: true,
    canRenderCollapsedWhen: (state) => state.topic?.canTakeModifiers ?? false,
    canRenderWhenEmpty: (state) => state.topic?.canTakeModifiers ?? false,
  ),
  ConfigurationCompassSlot.topicAdjective: _RailPolicy(
    slot: ConfigurationCompassSlot.topicAdjective,
    title: (_) => 'Topic adjective',
    unlockHint: (_) =>
        'Choose a topic first. Topic modifiers wake after that noun exists.',
    isControlled: true,
    canRenderCollapsedWhen: (state) => state.topic?.canTakeModifiers ?? false,
    canRenderWhenEmpty: (state) => state.topic?.canTakeModifiers ?? false,
  ),
  ConfigurationCompassSlot.beneficiary: _RailPolicy(
    slot: ConfigurationCompassSlot.beneficiary,
    title: (_) => 'Beneficiary',
    unlockHint: (_) =>
        'Choose a verb that can open a for-beneficiary, like work, sing, read, write, play, buy, or cook.',
    surfaceMarker: (_) => 'for',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        _railBoundTailOwner(state).takesBeneficiary ||
        state.beneficiary != null,
    canRenderWhenEmpty: (state) => state.beneficiary != null,
    participantLabel: (_) => 'beneficiary',
    participantValue: (state) => _nounTraceText(state.beneficiary),
    participantFilledWhen: (state) => state.beneficiary != null,
  ),
  ConfigurationCompassSlot.beneficiaryDeterminer: _RailPolicy(
    slot: ConfigurationCompassSlot.beneficiaryDeterminer,
    title: (_) => 'Beneficiary determiner',
    unlockHint: (_) =>
        'Choose a beneficiary first. Beneficiary modifiers wake after that noun exists.',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.beneficiary?.canTakeModifiers ?? false,
    canRenderWhenEmpty: (state) => state.beneficiary?.canTakeModifiers ?? false,
  ),
  ConfigurationCompassSlot.beneficiaryAdjective: _RailPolicy(
    slot: ConfigurationCompassSlot.beneficiaryAdjective,
    title: (_) => 'Beneficiary adjective',
    unlockHint: (_) =>
        'Choose a beneficiary first. Beneficiary modifiers wake after that noun exists.',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.beneficiary?.canTakeModifiers ?? false,
    canRenderWhenEmpty: (state) => state.beneficiary?.canTakeModifiers ?? false,
  ),
  ConfigurationCompassSlot.rightAction: _RailPolicy(
    slot: ConfigurationCompassSlot.rightAction,
    title: (_) => 'Right action',
    unlockHint: (_) =>
        'Choose a verb like want, need, like, love, or learn to open a to-action complement.',
    surfaceMarker: (_) => 'to',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        hasRightActionFrame(state.action) || state.rightAction != null,
    canRenderWhenEmpty: (state) => state.rightAction != null,
    participantLabel: (_) => 'right action',
    participantValue: (state) => state.rightAction?.infinitive ?? 'none',
    participantFilledWhen: (state) => state.rightAction != null,
  ),
  ConfigurationCompassSlot.complement: _RailPolicy(
    slot: ConfigurationCompassSlot.complement,
    title: (_) => 'Noun complement',
    unlockHint: (_) =>
        'Choose verb be first. Noun complements belong to the be frame.',
    surfaceMarker: (_) => '-',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.action.infinitive == 'be' || state.complement != null,
    canRenderWhenEmpty: (state) => state.complement != null,
    participantLabel: (_) => 'noun complement',
    participantValue: (state) => _nounTraceText(state.complement),
    participantFilledWhen: (state) => state.complement != null,
  ),
  ConfigurationCompassSlot.complementDeterminer: _RailPolicy(
    slot: ConfigurationCompassSlot.complementDeterminer,
    title: (_) => 'Complement determiner',
    unlockHint: (_) =>
        'Choose verb be, then choose a noun complement. Complement modifiers wake after that noun exists.',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.complement?.canTakeModifiers ?? false,
    canRenderWhenEmpty: (state) => state.complement?.canTakeModifiers ?? false,
  ),
  ConfigurationCompassSlot.complementAdjective: _RailPolicy(
    slot: ConfigurationCompassSlot.complementAdjective,
    title: (_) => 'Complement adjective',
    unlockHint: (_) =>
        'Choose verb be, then choose a noun complement. Complement modifiers wake after that noun exists.',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.complement?.canTakeModifiers ?? false,
    canRenderWhenEmpty: (state) => state.complement?.canTakeModifiers ?? false,
  ),
  ConfigurationCompassSlot.adjectiveComplement: _RailPolicy(
    slot: ConfigurationCompassSlot.adjectiveComplement,
    title: (_) => 'Adjective complement',
    unlockHint: (_) =>
        'Choose verb be first. Adjective complements belong to the be frame.',
    surfaceMarker: (_) => '-',
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.action.infinitive == 'be' || state.adjectiveComplement != null,
    canRenderWhenEmpty: (state) => state.adjectiveComplement != null,
    participantLabel: (_) => 'adjective complement',
    participantValue: (state) => state.adjectiveComplement?.text ?? 'none',
    participantFilledWhen: (state) => state.adjectiveComplement != null,
  ),
  ConfigurationCompassSlot.voice: _RailPolicy(
    slot: ConfigurationCompassSlot.voice,
    title: (_) => 'Voice',
    unlockHint: (_) =>
        'Choose an object-capable verb and an object first. Passive opens after there is something to promote.',
    isControlled: false,
    canRenderCollapsedWhen: (_) => false,
    canRenderWhenEmpty: (_) => false,
  ),
  ConfigurationCompassSlot.passiveFocus: _RailPolicy(
    slot: ConfigurationCompassSlot.passiveFocus,
    title: (_) => 'Passive focus',
    unlockHint: (_) =>
        'Turn passive voice on first. Recipient focus also needs a recipient-capable verb and a recipient.',
    isControlled: false,
    canRenderCollapsedWhen: (_) => false,
    canRenderWhenEmpty: (_) => false,
  ),
  ConfigurationCompassSlot.passiveAgent: _RailPolicy(
    slot: ConfigurationCompassSlot.passiveAgent,
    title: (_) => 'Passive agent',
    unlockHint: (_) =>
        'Turn passive voice on first. The by-agent phrase can be hidden while the agent stays in state.',
    isControlled: false,
    canRenderCollapsedWhen: (_) => false,
    canRenderWhenEmpty: (_) => false,
  ),
  ConfigurationCompassSlot.passiveAgentNoun: _RailPolicy(
    slot: ConfigurationCompassSlot.passiveAgentNoun,
    title: (_) => 'By-agent',
    unlockHint: (_) =>
        'Turn passive voice on first. This rail changes the remembered by-agent, even when the by-phrase is hidden.',
    surfaceMarker: (_) => 'by',
    isControlled: true,
    canRenderCollapsedWhen: (state) => state.voice == Voice.passive,
    canRenderWhenEmpty: (state) =>
        state.voice == Voice.passive && state.agent != null,
    participantLabel: (_) => 'by-agent',
    participantValue: (state) => _nounTraceText(state.agent),
    participantFilledWhen: (state) =>
        state.voice == Voice.passive && state.agent != null,
  ),
  ConfigurationCompassSlot.modal: _RailPolicy(
    slot: ConfigurationCompassSlot.modal,
    title: (_) => 'Modal',
    unlockHint: (_) => 'No modal fits this tense/frame from here.',
    isControlled: false,
    canRenderCollapsedWhen: (_) => false,
    canRenderWhenEmpty: (_) => false,
  ),
  ConfigurationCompassSlot.placePhrase: _RailPolicy(
    slot: ConfigurationCompassSlot.placePhrase,
    title: (_) => 'Place phrase',
    unlockHint: (_) => 'No open move from here.',
    isControlled: false,
    canRenderCollapsedWhen: (_) => false,
    canRenderWhenEmpty: (_) => true,
  ),
  ConfigurationCompassSlot.timePhrase: _RailPolicy(
    slot: ConfigurationCompassSlot.timePhrase,
    title: (_) => 'Time phrase',
    unlockHint: (_) => 'No open move from here.',
    isControlled: false,
    canRenderCollapsedWhen: (_) => false,
    canRenderWhenEmpty: (_) => true,
  ),
  ConfigurationCompassSlot.frequencyPhrase: _RailPolicy(
    slot: ConfigurationCompassSlot.frequencyPhrase,
    title: (_) => 'Frequency phrase',
    unlockHint: (_) => 'No open move from here.',
    surfaceMarker: (_) => 'how often',
    isControlled: false,
    canRenderCollapsedWhen: (_) => false,
    canRenderWhenEmpty: (_) => true,
  ),
  ConfigurationCompassSlot.mannerPhrase: _RailPolicy(
    slot: ConfigurationCompassSlot.mannerPhrase,
    title: (_) => 'Manner phrase',
    unlockHint: (_) => 'No open move from here.',
    surfaceMarker: (_) => 'how',
    isControlled: false,
    canRenderCollapsedWhen: (_) => false,
    canRenderWhenEmpty: (_) => true,
  ),
};

bool _objectModifiersCanWake(SentenceState state) {
  final object = state.object;
  if (object == null || !object.canTakeModifiers) {
    return false;
  }

  final owner = _railBoundTailOwner(state);
  return !hasFixedObjectFrame(owner) ||
      fixedObjectFrameAllowsModifiers(_railBoundTailOwner(state));
}

String? _fixedObjectSlotTitle(ConfigurationState configuration) {
  final label = fixedObjectFrameLabel(
    _railBoundTailOwner(configuration.sentenceState),
  );
  if (label == null) {
    return null;
  }

  return '${label[0].toUpperCase()}${label.substring(1)}';
}

String _coreObjectDoorLabel(ConfigurationState configuration) {
  final fixedLabel = fixedObjectFrameLabel(
    _railBoundTailOwner(configuration.sentenceState),
  );

  if (fixedLabel == null) {
    return 'object';
  }

  return fixedLabel == 'subject' ? 'study subject' : fixedLabel;
}
