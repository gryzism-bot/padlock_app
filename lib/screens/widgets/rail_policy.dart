part of '../home_screen.dart';

String _collapsedRailHint(String title) {
  return 'Click to open $title choices.';
}

typedef _RailTitleBuilder = String Function(ConfigurationState configuration);
typedef _RailHintBuilder = String Function(ConfigurationState configuration);
typedef _RailStatePredicate = bool Function(SentenceState state);
typedef _RailValueBuilder = String Function(SentenceState state);
typedef _RailSuggestionsBuilder =
    List<ConfigurationSuggestion> Function(ConfigurationCompassSlot slot);

class _RailPolicy {
  final ConfigurationCompassSlot slot;
  final _RailTitleBuilder title;
  final _RailHintBuilder unlockHint;
  final bool isControlled;
  final _RailStatePredicate canRenderCollapsedWhen;
  final _RailStatePredicate canRenderWhenEmpty;
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
        isExpanded: isExpanded,
        canToggle: canToggle,
      ),
    );
  }

  return sections;
}

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
  final fixedLabel = fixedObjectFrameLabel(state.action);

  if (fixedLabel == null) {
    return 'Choose a verb that can take an object, like build, give, need, see, or use.';
  }

  return 'Choose a fixed $fixedLabel for ${state.action.infinitive}.';
}

String _objectModifierUnlockHint(ConfigurationState configuration) {
  final state = configuration.sentenceState;

  if (hasFixedObjectFrame(state.action) &&
      !fixedObjectFrameAllowsModifiers(state.action)) {
    return '${state.action.infinitive} fixed ${fixedObjectFrameLabel(state.action)} choices stay bare.';
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
  ConfigurationCompassSlot.recipient,
  ConfigurationCompassSlot.addressee,
  ConfigurationCompassSlot.companion,
  ConfigurationCompassSlot.destination,
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
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.action.takesObject || hasFixedObjectFrame(state.action),
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
  ConfigurationCompassSlot.recipient: _RailPolicy(
    slot: ConfigurationCompassSlot.recipient,
    title: (_) => 'Recipient',
    unlockHint: (_) =>
        'Choose a ditransitive verb like give, tell, teach, write, or buy, then keep an object active.',
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
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.action.takesAddressee || state.addressee != null,
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
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.action.infinitive == 'be' ||
        state.action.takesCompanion ||
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
    isControlled: true,
    canRenderCollapsedWhen: (state) =>
        state.action.usesDestinationPlace || state.destination != null,
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
  ConfigurationCompassSlot.rightAction: _RailPolicy(
    slot: ConfigurationCompassSlot.rightAction,
    title: (_) => 'Right action',
    unlockHint: (_) =>
        'Choose a verb like want, need, like, love, or learn to open a to-action complement.',
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
};

bool _objectModifiersCanWake(SentenceState state) {
  final object = state.object;
  if (object == null || !object.canTakeModifiers) {
    return false;
  }

  return !hasFixedObjectFrame(state.action) ||
      fixedObjectFrameAllowsModifiers(state.action);
}

String? _fixedObjectSlotTitle(ConfigurationState configuration) {
  final label = fixedObjectFrameLabel(configuration.sentenceState.action);
  if (label == null) {
    return null;
  }

  return '${label[0].toUpperCase()}${label.substring(1)}';
}

String _coreObjectDoorLabel(ConfigurationState configuration) {
  final fixedLabel = fixedObjectFrameLabel(configuration.sentenceState.action);

  if (fixedLabel == null) {
    return 'object';
  }

  return fixedLabel == 'subject' ? 'study subject' : fixedLabel;
}
