part of 'configuration_engine.dart';

typedef _ConfigurationLawApplier = void Function(_ValidationContext context);

class _ConfigurationLaw {
  final String name;
  final _ConfigurationLawApplier apply;

  const _ConfigurationLaw(this.name, this.apply);
}

class _ValidationContext {
  final ConfigurationEngine engine;
  final SentenceState state;
  final List<ConfigurationMessage> blockers = [];

  _ValidationContext(this.engine, this.state);

  Verb get owner => state.rightAction ?? state.action;

  void block(String text, ConfigurationLawCategory lawCategory) {
    blockers.add(ConfigurationMessage.blocked(text, lawCategory: lawCategory));
  }
}

class _ConfigurationLawRunner {
  const _ConfigurationLawRunner();

  List<ConfigurationMessage> validate(
    ConfigurationEngine engine,
    SentenceState state,
  ) {
    final context = _ValidationContext(engine, state);

    for (final law in _configurationValidationLaws) {
      law.apply(context);
    }

    return context.blockers;
  }
}

const _configurationLawRunner = _ConfigurationLawRunner();

const _configurationValidationLaws = [
  _ConfigurationLaw('noun phrase shape', _validateNounPhraseSurfaces),
  _ConfigurationLaw('right action frame', _validateRightActionLaw),
  _ConfigurationLaw('predicate frame shape', _validatePredicateShapeLaw),
  _ConfigurationLaw('modal tense frame', _validateModalFrameLaw),
  _ConfigurationLaw('imperative frame', _validateImperativeFrameLaw),
  _ConfigurationLaw('phrase compatibility', _validatePhraseFrameLaw),
];

void _validateNounPhraseSurfaces(_ValidationContext context) {
  final state = context.state;
  final phrases = [
    (label: 'Agent', phrase: state.agent),
    (label: 'Object', phrase: state.object),
    (label: 'Object complement', phrase: state.objectComplement),
    (label: 'Recipient', phrase: state.recipient),
    (label: 'Addressee', phrase: state.addressee),
    (label: 'Companion', phrase: state.companion),
    (label: 'Destination', phrase: state.destination),
    (label: 'Topic', phrase: state.topic),
    (label: 'Beneficiary', phrase: state.beneficiary),
    (label: 'Source', phrase: state.source),
    (label: 'Complement', phrase: state.complement),
  ];

  for (final (:label, :phrase) in phrases) {
    _validateNounPhrase(context, label, phrase);
  }
}

void _validateNounPhrase(
  _ValidationContext context,
  String label,
  NounPhrase? phrase,
) {
  if (phrase == null) {
    return;
  }

  if (!phrase.canTakeModifiers &&
      (phrase.determiner != null || phrase.adjectiveList.isNotEmpty)) {
    context.block(
      '$label pronouns do not take modifiers.',
      ConfigurationLawCategory.nounPhraseShape,
    );
    return;
  }

  final determiner = phrase.determiner;
  if (determiner == null) {
    return;
  }

  if (_singularDeterminers.contains(determiner.text) && phrase.isPlural) {
    context.block(
      '$label determiner "${determiner.text}" requires a singular noun.',
      ConfigurationLawCategory.nounPhraseShape,
    );
  }

  if (_pluralDeterminers.contains(determiner.text) && !phrase.isPlural) {
    context.block(
      '$label determiner "${determiner.text}" requires a plural noun.',
      ConfigurationLawCategory.nounPhraseShape,
    );
  }

  final firstSpokenWord = phrase.adjectiveList.isEmpty
      ? phrase.text
      : phrase.adjectiveList.first.text;

  if (determiner.text == 'a' && _startsWithVowelLetter(firstSpokenWord)) {
    context.block(
      '$label determiner "a" requires a consonant sound.',
      ConfigurationLawCategory.nounPhraseShape,
    );
  }

  if (determiner.text == 'an' && !_startsWithVowelLetter(firstSpokenWord)) {
    context.block(
      '$label determiner "an" requires a vowel sound.',
      ConfigurationLawCategory.nounPhraseShape,
    );
  }
}

void _validateRightActionLaw(_ValidationContext context) {
  final state = context.state;
  final rightAction = state.rightAction;
  if (rightAction == null) {
    return;
  }

  if (state.action == be) {
    return;
  }

  if (!hasRightActionFrame(state.action)) {
    context.block(
      '${state.action.infinitive} does not take a right action complement.',
      ConfigurationLawCategory.predicateFrameType,
    );
    return;
  }

  if (!rightActionFitsAction(rightAction, state.action)) {
    context.block(
      '${state.action.infinitive} does not take "${rightAction.infinitive}" as a right action.',
      ConfigurationLawCategory.predicateFrameType,
    );
  }
}

void _validatePredicateShapeLaw(_ValidationContext context) {
  if (isLexicalBeFrame(context.state)) {
    _validateLexicalBe(context);
  } else {
    _validatePredicateFrame(context);
  }
}

void _validateLexicalBe(_ValidationContext context) {
  final state = context.state;

  if (lexicalBeNeedsAgent(state)) {
    context.block(
      'Lexical be requires an agent.',
      ConfigurationLawCategory.lexicalBeFrame,
    );
  }

  if (lexicalBeNeedsActiveVoice(state)) {
    context.block(
      'Lexical be is active-only.',
      ConfigurationLawCategory.lexicalBeFrame,
    );
  }

  if (!lexicalBeNounComplementMatchesAgentNumber(state)) {
    context.block(
      'Lexical be noun complement must match agent number.',
      ConfigurationLawCategory.lexicalBeFrame,
    );
  }

  if (lexicalBeRejectsObjectSurface(state)) {
    context.block(
      'Lexical be does not take an object.',
      ConfigurationLawCategory.lexicalBeFrame,
    );
  }

  if (lexicalBeRejectsObjectComplementSurface(state)) {
    context.block(
      'Lexical be does not take an object complement.',
      ConfigurationLawCategory.lexicalBeFrame,
    );
  }

  if (lexicalBeRejectsRecipientSurface(state)) {
    context.block(
      'Lexical be does not take a recipient.',
      ConfigurationLawCategory.lexicalBeFrame,
    );
  }

  for (final surface in prepositionalParticipantSurfaces) {
    if (lexicalBeRejectsPrepositionalSurface(state, surface)) {
      context.block(
        'Lexical be does not take ${surface.blockedNounLabel}.',
        ConfigurationLawCategory.lexicalBeFrame,
      );
    }
  }

  if (lexicalBeRejectsRightActionSurface(state)) {
    context.block(
      'Lexical be does not take a right action complement.',
      ConfigurationLawCategory.lexicalBeFrame,
    );
  }

  if (lexicalBeRejectsPassiveFocus(state)) {
    context.block(
      'Lexical be does not take passive focus.',
      ConfigurationLawCategory.lexicalBeFrame,
    );
  }

  if (lexicalBeRejectsPassiveAgentVisibility(state)) {
    context.block(
      'Lexical be does not take passive agent visibility.',
      ConfigurationLawCategory.lexicalBeFrame,
    );
  }
}

void _validatePredicateFrame(_ValidationContext context) {
  final state = context.state;

  if (state.complement != null || state.adjectiveComplement != null) {
    context.block(
      '${state.action.infinitive} does not take a complement.',
      ConfigurationLawCategory.predicateFrameType,
    );
  }

  if (state.objectComplement != null ||
      state.objectAdjectiveComplement != null) {
    if (!objectComplementsNeedObjectCapablePredicate(state)) {
      context.block(
        '${state.action.infinitive} does not take an object complement.',
        ConfigurationLawCategory.predicateFrameType,
      );
    }

    if (!objectComplementsNeedObject(state)) {
      context.block(
        'Object complements require an object.',
        ConfigurationLawCategory.predicateFrameType,
      );
    }
  }

  for (final surface in predicateFrameValidatedPrepositionalSurfaces) {
    if (!prepositionalSurfaceNeedsCapablePredicate(state, surface)) {
      context.block(
        '${context.owner.infinitive} does not take ${surface.blockedNounLabel}.',
        ConfigurationLawCategory.predicateFrameType,
      );
    }
  }

  final objectOwner = context.owner;
  if (hasFixedObjectFrame(objectOwner) && state.object != null) {
    final label = fixedObjectFrameLabel(objectOwner) ?? 'fixed object';
    if (!fixedObjectFitsAction(state.object!, objectOwner)) {
      context.block(
        '${objectOwner.infinitive} only takes fixed $label objects.',
        ConfigurationLawCategory.predicateFrameType,
      );
    }

    if (!fixedObjectFrameAllowsModifiers(objectOwner) &&
        (state.object!.determiner != null ||
            state.object!.adjectiveList.isNotEmpty)) {
      context.block(
        '${objectOwner.infinitive} fixed $label objects stay bare.',
        ConfigurationLawCategory.predicateFrameType,
      );
    }
  }

  switch (state.voice) {
    case Voice.active:
      _validateActiveVoiceFrame(context);
    case Voice.passive:
      _validatePassiveVoiceFrame(context);
  }
}

void _validateActiveVoiceFrame(_ValidationContext context) {
  final state = context.state;

  if (activeVoiceNeedsAgent(state)) {
    context.block(
      'Active voice requires an agent.',
      ConfigurationLawCategory.activeVoiceShape,
    );
  }

  if (!passiveFocusBelongsToPassiveVoice(state)) {
    context.block(
      'Passive focus belongs to passive voice.',
      ConfigurationLawCategory.passiveConfigurationShape,
    );
  }

  if (!passiveAgentVisibilityBelongsToPassiveVoice(state)) {
    context.block(
      'Passive agent visibility belongs to passive voice.',
      ConfigurationLawCategory.passiveConfigurationShape,
    );
  }

  if (!activeRecipientNeedsRecipientCapablePredicate(state)) {
    context.block(
      '${state.action.infinitive} does not take a recipient.',
      ConfigurationLawCategory.predicateFrameType,
    );
  }

  for (final surface in activeVoicePrepositionalSurfaces) {
    if (!activePrepositionalSurfaceNeedsCapablePredicate(state, surface)) {
      context.block(
        '${context.owner.infinitive} does not take ${surface.blockedNounLabel}.',
        ConfigurationLawCategory.predicateFrameType,
      );
    }
  }

  if (!activeObjectNeedsObjectCapablePredicate(state)) {
    context.block(
      '${context.owner.infinitive} does not take an object.',
      ConfigurationLawCategory.predicateFrameType,
    );
  }

  if (!recipientFrameNeedsObject(state)) {
    context.block(
      'Recipient frames require an object.',
      ConfigurationLawCategory.predicateFrameType,
    );
  }
}

void _validatePassiveVoiceFrame(_ValidationContext context) {
  final state = context.state;

  for (final surface in activeVoicePrepositionalSurfaces) {
    if (!prepositionalSurfaceNeedsCapablePredicate(
      state,
      surface,
      includeRightAction: false,
    )) {
      context.block(
        '${state.action.infinitive} does not take ${surface.blockedNounLabel}.',
        ConfigurationLawCategory.predicateFrameType,
      );
    }
  }

  if (!passiveVoiceNeedsObjectCapablePredicate(state)) {
    context.block(
      '${state.action.infinitive} cannot be passive in this frame.',
      ConfigurationLawCategory.predicateFrameType,
    );
  }

  if (!passiveObjectFocusNeedsObject(state)) {
    context.block(
      'Passive object focus requires an object.',
      ConfigurationLawCategory.passiveConfigurationShape,
    );
  }

  if (!passiveRecipientFocusNeedsRecipientCapablePredicate(state)) {
    context.block(
      '${state.action.infinitive} has no recipient focus.',
      ConfigurationLawCategory.passiveConfigurationShape,
    );
  }

  if (!passiveRecipientFocusNeedsRecipient(state)) {
    context.block(
      'Passive recipient focus requires a recipient.',
      ConfigurationLawCategory.passiveConfigurationShape,
    );
  }

  if (!passiveRecipientFocusNeedsObject(state)) {
    context.block(
      'Passive recipient focus still requires an object.',
      ConfigurationLawCategory.passiveConfigurationShape,
    );
  }
}

void _validateModalFrameLaw(_ValidationContext context) {
  final state = context.state;
  if (state.modal.isNone) {
    return;
  }

  if (!modalAllowedInSentenceForm(state)) {
    context.block(
      'Imperatives cannot take a modal.',
      ConfigurationLawCategory.imperativeFrame,
    );
  }

  if (state.modal == will && !modalMatchesTenseFrame(state)) {
    context.block(
      'Will belongs to the future tense frame.',
      ConfigurationLawCategory.modalTenseFrame,
    );
  }

  if (state.modal != will && !modalMatchesTenseFrame(state)) {
    context.block(
      '${state.modal.text} belongs to the present modal frame.',
      ConfigurationLawCategory.modalTenseFrame,
    );
  }
}

void _validateImperativeFrameLaw(_ValidationContext context) {
  final state = context.state;
  if (state.sentenceForm != SentenceForm.imperative) {
    return;
  }

  if (!imperativeUsesPresentSimple(state)) {
    context.block(
      'Imperatives use present simple.',
      ConfigurationLawCategory.imperativeFrame,
    );
  }

  if (!imperativeUsesActiveVoice(state)) {
    context.block(
      'Imperatives use active voice.',
      ConfigurationLawCategory.imperativeFrame,
    );
  }
}

void _validatePhraseFrameLaw(_ValidationContext context) {
  final state = context.state;
  final place = state.placePhrase;
  if (place == null) {
    return;
  }

  if (place.noun.toLowerCase() == state.action.infinitive.toLowerCase()) {
    context.block(
      'Place phrase cannot repeat the verb word "${place.noun}".',
      ConfigurationLawCategory.phraseCompatibility,
    );
  }
}
