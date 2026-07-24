part of '../home_screen.dart';

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
  return switch (slot) {
    ConfigurationCompassSlot.object => state.object,
    ConfigurationCompassSlot.objectComplement => state.objectComplement,
    ConfigurationCompassSlot.recipient => state.recipient,
    ConfigurationCompassSlot.addressee => state.addressee,
    ConfigurationCompassSlot.companion => state.companion,
    ConfigurationCompassSlot.destination => state.destination,
    ConfigurationCompassSlot.topic => state.topic,
    ConfigurationCompassSlot.beneficiary => state.beneficiary,
    ConfigurationCompassSlot.source => state.source,
    ConfigurationCompassSlot.passiveAgentNoun => state.agent,
    ConfigurationCompassSlot.complement => state.complement,
    _ => null,
  };
}

List<NounPhrase> _nounChoicesForSlot(
  ConfigurationCompass compass,
  SentenceState state,
  ConfigurationCompassSlot slot,
) {
  return switch (slot) {
    ConfigurationCompassSlot.object => [
      ...fixedObjectChoicesFor(state.action),
      ...compass.objects,
    ],
    ConfigurationCompassSlot.objectComplement => compass.complements,
    ConfigurationCompassSlot.recipient => compass.recipients,
    ConfigurationCompassSlot.addressee => compass.recipients,
    ConfigurationCompassSlot.companion => compass.recipients,
    ConfigurationCompassSlot.destination => compass.recipients,
    ConfigurationCompassSlot.topic => compass.recipients,
    ConfigurationCompassSlot.beneficiary => compass.recipients,
    ConfigurationCompassSlot.source => compass.recipients,
    ConfigurationCompassSlot.passiveAgentNoun => compass.recipients,
    ConfigurationCompassSlot.complement => compass.complements,
    _ => const [],
  };
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
  return switch (slot) {
    ConfigurationCompassSlot.object => SetObject(nounPhrase),
    ConfigurationCompassSlot.objectComplement => SetObjectComplement(
      nounPhrase,
    ),
    ConfigurationCompassSlot.recipient => SetRecipient(nounPhrase),
    ConfigurationCompassSlot.addressee => SetAddressee(nounPhrase),
    ConfigurationCompassSlot.companion => SetCompanion(nounPhrase),
    ConfigurationCompassSlot.destination => SetDestination(nounPhrase),
    ConfigurationCompassSlot.topic => SetTopic(nounPhrase),
    ConfigurationCompassSlot.beneficiary => SetBeneficiary(nounPhrase),
    ConfigurationCompassSlot.source => SetSource(nounPhrase),
    ConfigurationCompassSlot.passiveAgentNoun => SetAgent(nounPhrase),
    ConfigurationCompassSlot.complement => SetComplement(nounPhrase),
    _ => throw ArgumentError('No noun number switch for ${slot.name}.'),
  };
}

String _slotTraceLabel(ConfigurationCompassSlot slot) {
  return switch (slot) {
    ConfigurationCompassSlot.object => 'object',
    ConfigurationCompassSlot.objectComplement => 'object complement',
    ConfigurationCompassSlot.recipient => 'recipient',
    ConfigurationCompassSlot.addressee => 'addressee',
    ConfigurationCompassSlot.companion => 'companion',
    ConfigurationCompassSlot.destination => 'destination',
    ConfigurationCompassSlot.topic => 'topic',
    ConfigurationCompassSlot.beneficiary => 'beneficiary',
    ConfigurationCompassSlot.source => 'source',
    ConfigurationCompassSlot.passiveAgentNoun => 'by-agent',
    ConfigurationCompassSlot.complement => 'noun complement',
    _ => slot.name,
  };
}

bool _slotHasNounNumberSwitch(ConfigurationCompassSlot slot) {
  return switch (slot) {
    ConfigurationCompassSlot.object ||
    ConfigurationCompassSlot.objectComplement ||
    ConfigurationCompassSlot.recipient ||
    ConfigurationCompassSlot.addressee ||
    ConfigurationCompassSlot.companion ||
    ConfigurationCompassSlot.destination ||
    ConfigurationCompassSlot.topic ||
    ConfigurationCompassSlot.beneficiary ||
    ConfigurationCompassSlot.source ||
    ConfigurationCompassSlot.passiveAgentNoun ||
    ConfigurationCompassSlot.complement => true,
    _ => false,
  };
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
  return switch (move) {
    SetObject(:final object) => _updatedNounNumbers(
      current,
      ConfigurationCompassSlot.object,
      object,
    ),
    SetObjectComplement(:final objectComplement) => _updatedNounNumbers(
      current,
      ConfigurationCompassSlot.objectComplement,
      objectComplement,
    ),
    SetRecipient(:final recipient) => _updatedNounNumbers(
      current,
      ConfigurationCompassSlot.recipient,
      recipient,
    ),
    SetAddressee(:final addressee) => _updatedNounNumbers(
      current,
      ConfigurationCompassSlot.addressee,
      addressee,
    ),
    SetCompanion(:final companion) => _updatedNounNumbers(
      current,
      ConfigurationCompassSlot.companion,
      companion,
    ),
    SetDestination(:final destination) => _updatedNounNumbers(
      current,
      ConfigurationCompassSlot.destination,
      destination,
    ),
    SetTopic(:final topic) => _updatedNounNumbers(
      current,
      ConfigurationCompassSlot.topic,
      topic,
    ),
    SetBeneficiary(:final beneficiary) => _updatedNounNumbers(
      current,
      ConfigurationCompassSlot.beneficiary,
      beneficiary,
    ),
    SetSource(:final source) => _updatedNounNumbers(
      current,
      ConfigurationCompassSlot.source,
      source,
    ),
    SetAgent(:final agent) => _updatedNounNumbers(
      current,
      ConfigurationCompassSlot.passiveAgentNoun,
      agent,
    ),
    SetComplement(:final complement) => _updatedNounNumbers(
      current,
      ConfigurationCompassSlot.complement,
      complement,
    ),
    _ => current,
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
