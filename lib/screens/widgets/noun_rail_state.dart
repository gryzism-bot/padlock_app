part of '../home_screen.dart';

typedef _NounRailReader = NounPhrase? Function(SentenceState state);
typedef _NounRailChoicesBuilder =
    List<NounPhrase> Function(
      ConfigurationCompass compass,
      SentenceState state,
    );
typedef _NounRailMoveBuilder =
    ConfigurationMove Function(NounPhrase nounPhrase);

class _NounRailSlotPolicy {
  final ConfigurationCompassSlot slot;
  final _NounRailReader read;
  final _NounRailChoicesBuilder choices;
  final _NounRailMoveBuilder move;
  final String traceLabel;

  const _NounRailSlotPolicy({
    required this.slot,
    required this.read,
    required this.choices,
    required this.move,
    required this.traceLabel,
  });
}

final Map<ConfigurationCompassSlot, _NounRailSlotPolicy> _nounRailPolicies = {
  ConfigurationCompassSlot.object: _NounRailSlotPolicy(
    slot: ConfigurationCompassSlot.object,
    read: (state) => state.object,
    choices: (compass, state) => [
      ...fixedObjectChoicesFor(_railBoundTailOwner(state)),
      ...compass.objects,
    ],
    move: (nounPhrase) => SetObject(nounPhrase),
    traceLabel: 'object',
  ),
  ConfigurationCompassSlot.objectComplement: _NounRailSlotPolicy(
    slot: ConfigurationCompassSlot.objectComplement,
    read: (state) => state.objectComplement,
    choices: (compass, _) => compass.complements,
    move: (nounPhrase) => SetObjectComplement(nounPhrase),
    traceLabel: 'object complement',
  ),
  ConfigurationCompassSlot.recipient: _NounRailSlotPolicy(
    slot: ConfigurationCompassSlot.recipient,
    read: (state) => state.recipient,
    choices: (compass, _) => compass.recipients,
    move: (nounPhrase) => SetRecipient(nounPhrase),
    traceLabel: 'recipient',
  ),
  ConfigurationCompassSlot.addressee: _NounRailSlotPolicy(
    slot: ConfigurationCompassSlot.addressee,
    read: (state) => state.addressee,
    choices: (compass, _) => compass.recipients,
    move: (nounPhrase) => SetAddressee(nounPhrase),
    traceLabel: 'addressee',
  ),
  ConfigurationCompassSlot.companion: _NounRailSlotPolicy(
    slot: ConfigurationCompassSlot.companion,
    read: (state) => state.companion,
    choices: (compass, _) => compass.recipients,
    move: (nounPhrase) => SetCompanion(nounPhrase),
    traceLabel: 'companion',
  ),
  ConfigurationCompassSlot.destination: _NounRailSlotPolicy(
    slot: ConfigurationCompassSlot.destination,
    read: (state) => state.destination,
    choices: (compass, _) => compass.recipients,
    move: (nounPhrase) => SetDestination(nounPhrase),
    traceLabel: 'destination',
  ),
  ConfigurationCompassSlot.topic: _NounRailSlotPolicy(
    slot: ConfigurationCompassSlot.topic,
    read: (state) => state.topic,
    choices: (compass, _) => compass.recipients,
    move: (nounPhrase) => SetTopic(nounPhrase),
    traceLabel: 'topic',
  ),
  ConfigurationCompassSlot.beneficiary: _NounRailSlotPolicy(
    slot: ConfigurationCompassSlot.beneficiary,
    read: (state) => state.beneficiary,
    choices: (compass, _) => compass.recipients,
    move: (nounPhrase) => SetBeneficiary(nounPhrase),
    traceLabel: 'beneficiary',
  ),
  ConfigurationCompassSlot.source: _NounRailSlotPolicy(
    slot: ConfigurationCompassSlot.source,
    read: (state) => state.source,
    choices: (compass, _) => compass.recipients,
    move: (nounPhrase) => SetSource(nounPhrase),
    traceLabel: 'source',
  ),
  ConfigurationCompassSlot.passiveAgentNoun: _NounRailSlotPolicy(
    slot: ConfigurationCompassSlot.passiveAgentNoun,
    read: (state) => state.agent,
    choices: (compass, _) => compass.recipients,
    move: (nounPhrase) => SetAgent(nounPhrase),
    traceLabel: 'by-agent',
  ),
  ConfigurationCompassSlot.complement: _NounRailSlotPolicy(
    slot: ConfigurationCompassSlot.complement,
    read: (state) => state.complement,
    choices: (compass, _) => compass.complements,
    move: (nounPhrase) => SetComplement(nounPhrase),
    traceLabel: 'noun complement',
  ),
};

_NounRailSlotPolicy? _nounRailPolicy(ConfigurationCompassSlot slot) {
  return _nounRailPolicies[slot];
}

bool _sameNounPhrase(NounPhrase? left, NounPhrase right) {
  return left != null &&
      left.text == right.text &&
      left.person == right.person &&
      left.number == right.number;
}

NounPhrase? _nounVariant(
  List<NounPhrase> candidates,
  NounPhrase current,
  Number number,
) {
  for (final candidate in candidates) {
    if (candidate.number == number && _sameNounFamily(candidate, current)) {
      return candidate;
    }
  }

  return null;
}

NounPhrase? _nounPhraseForSlot(
  SentenceState state,
  ConfigurationCompassSlot slot,
) {
  return _nounRailPolicy(slot)?.read(state);
}

List<NounPhrase> _nounChoicesForSlot(
  ConfigurationCompass compass,
  SentenceState state,
  ConfigurationCompassSlot slot,
) {
  return _nounRailPolicy(slot)?.choices(compass, state) ?? const [];
}

List<NounPhrase> _nounChoicesForConfigurationSlot(
  ConfigurationCompass compass,
  ConfigurationState configuration,
  ConfigurationCompassSlot slot,
) {
  final choices = [
    for (final suggestion in compass.suggestionsFor(
      configuration,
      slot,
      limit: 0,
    ))
      ?_nounPhraseForSlot(suggestion.preview.sentenceState, slot),
    ..._nounChoicesForSlot(compass, configuration.sentenceState, slot),
  ];

  return _uniqueNounChoicesForRail(choices);
}

List<NounPhrase> _uniqueNounChoicesForRail(List<NounPhrase> choices) {
  final seen = <String>{};

  return [
    for (final choice in choices)
      if (seen.add(
        [
          choice.person.name,
          choice.number.name,
          choice.determiner?.text ?? '',
          for (final adjective in choice.adjectiveList) adjective.text,
          choice.text.toLowerCase(),
        ].join(':'),
      ))
        choice,
  ];
}

ConfigurationMove _setNounPhraseMove(
  ConfigurationCompassSlot slot,
  NounPhrase nounPhrase,
) {
  final policy = _nounRailPolicy(slot);
  if (policy == null) {
    throw ArgumentError('No noun number switch for ${slot.name}.');
  }

  return policy.move(nounPhrase);
}

String _slotTraceLabel(ConfigurationCompassSlot slot) {
  return _nounRailPolicy(slot)?.traceLabel ?? slot.name;
}

bool _slotHasNounNumberSwitch(ConfigurationCompassSlot slot) {
  return _nounRailPolicy(slot) != null;
}

Map<ConfigurationCompassSlot, Number> _updatedNounNumbers(
  Map<ConfigurationCompassSlot, Number> current,
  ConfigurationCompassSlot slot,
  NounPhrase? nounPhrase,
) {
  if (!_slotHasNounNumberSwitch(slot)) {
    return current;
  }

  return {...current, slot: nounPhrase?.number ?? Number.singular};
}

Map<ConfigurationCompassSlot, Number> _updatedNounNumbersFromMove(
  Map<ConfigurationCompassSlot, Number> current,
  ConfigurationMove move,
) {
  final railState = _nounRailStateFromMove(move);
  if (railState == null) {
    return current;
  }

  return _updatedNounNumbers(current, railState.slot, railState.nounPhrase);
}

({ConfigurationCompassSlot slot, NounPhrase? nounPhrase})?
_nounRailStateFromMove(ConfigurationMove move) {
  return switch (move) {
    SetObject(:final object) => (
      slot: ConfigurationCompassSlot.object,
      nounPhrase: object,
    ),
    SetObjectComplement(:final objectComplement) => (
      slot: ConfigurationCompassSlot.objectComplement,
      nounPhrase: objectComplement,
    ),
    SetRecipient(:final recipient) => (
      slot: ConfigurationCompassSlot.recipient,
      nounPhrase: recipient,
    ),
    SetAddressee(:final addressee) => (
      slot: ConfigurationCompassSlot.addressee,
      nounPhrase: addressee,
    ),
    SetCompanion(:final companion) => (
      slot: ConfigurationCompassSlot.companion,
      nounPhrase: companion,
    ),
    SetDestination(:final destination) => (
      slot: ConfigurationCompassSlot.destination,
      nounPhrase: destination,
    ),
    SetTopic(:final topic) => (
      slot: ConfigurationCompassSlot.topic,
      nounPhrase: topic,
    ),
    SetBeneficiary(:final beneficiary) => (
      slot: ConfigurationCompassSlot.beneficiary,
      nounPhrase: beneficiary,
    ),
    SetSource(:final source) => (
      slot: ConfigurationCompassSlot.source,
      nounPhrase: source,
    ),
    SetAgent(:final agent) => (
      slot: ConfigurationCompassSlot.passiveAgentNoun,
      nounPhrase: agent,
    ),
    SetComplement(:final complement) => (
      slot: ConfigurationCompassSlot.complement,
      nounPhrase: complement,
    ),
    _ => null,
  };
}

Map<ConfigurationCompassSlot, Number> _syncNounNumbersWithState(
  Map<ConfigurationCompassSlot, Number> current,
  SentenceState state,
) {
  var next = current;

  for (final slot in ConfigurationCompassSlot.values.where(
    _slotHasNounNumberSwitch,
  )) {
    next = _updatedNounNumbers(next, slot, _nounPhraseForSlot(state, slot));
  }

  return next;
}

bool _sameNounFamily(NounPhrase left, NounPhrase right) {
  return objectNumberFamilyKey(left.text) == objectNumberFamilyKey(right.text);
}

String objectNumberFamilyKey(String text) {
  final lower = text.toLowerCase();

  if (lower.endsWith('ies')) {
    return '${lower.substring(0, lower.length - 3)}y';
  }

  if (lower.endsWith('ves')) {
    return '${lower.substring(0, lower.length - 3)}fe';
  }

  if (lower.endsWith('sses')) {
    return lower.substring(0, lower.length - 2);
  }

  if (lower.endsWith('ses')) {
    return lower.substring(0, lower.length - 1);
  }

  if (lower.endsWith('ches') ||
      lower.endsWith('shes') ||
      lower.endsWith('xes') ||
      lower.endsWith('zes') ||
      lower.endsWith('oes')) {
    return lower.substring(0, lower.length - 2);
  }

  if (lower.endsWith('ss')) {
    return lower;
  }

  if (lower.endsWith('s')) {
    return lower.substring(0, lower.length - 1);
  }

  return lower;
}

NounPhrase _carrySafeNounModifiers(NounPhrase previous, NounPhrase next) {
  final adjectives = previous.adjectiveList;

  return next.copyWith(
    determiner: _safeDeterminerForNumber(previous, next.number),
    adjective: adjectives.isEmpty ? null : adjectives.first,
    adjectives: adjectives,
  );
}

Object? _safeDeterminerForNumber(NounPhrase previous, Number number) {
  final determiner = previous.determiner;
  if (determiner == null) {
    return null;
  }

  final text = determiner.text;
  if (number == Number.plural &&
      const {'a', 'an', 'this', 'that', 'each', 'every'}.contains(text)) {
    return null;
  }

  if (number == Number.singular &&
      const {'these', 'those', 'many'}.contains(text)) {
    return null;
  }

  return determiner;
}
