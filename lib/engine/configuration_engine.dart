import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/predicate/fixed_object_frames.dart';
import 'package:padlock_app/data/predicate/predicate_paths.dart';
import 'package:padlock_app/data/predicate/right_action_frames.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/engine/configuration_laws.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/phrase/frequency_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/manner_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/phrase/place_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/time_phrase.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/grammar/subject/determiner.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

enum ConfigurationMode { guided, assisted, manual, explorer }

enum IncompatibleTailPolicy { shave, previewShave, blockWithExplanation, allow }

class ConfigurationModePolicy {
  final PredicatePathMode predicatePathMode;
  final IncompatibleTailPolicy incompatibleTailPolicy;
  final bool showEducationalTooltips;
  final bool showDeveloperDiagnostics;

  const ConfigurationModePolicy({
    required this.predicatePathMode,
    required this.incompatibleTailPolicy,
    required this.showEducationalTooltips,
    required this.showDeveloperDiagnostics,
  });

  factory ConfigurationModePolicy.forMode(ConfigurationMode mode) {
    return switch (mode) {
      ConfigurationMode.guided => const ConfigurationModePolicy(
        predicatePathMode: PredicatePathMode.authoredTracks,
        incompatibleTailPolicy: IncompatibleTailPolicy.shave,
        showEducationalTooltips: true,
        showDeveloperDiagnostics: false,
      ),
      ConfigurationMode.assisted => const ConfigurationModePolicy(
        predicatePathMode: PredicatePathMode.authoredTracks,
        incompatibleTailPolicy: IncompatibleTailPolicy.previewShave,
        showEducationalTooltips: true,
        showDeveloperDiagnostics: true,
      ),
      ConfigurationMode.manual => const ConfigurationModePolicy(
        predicatePathMode: PredicatePathMode.authoredTracks,
        incompatibleTailPolicy: IncompatibleTailPolicy.blockWithExplanation,
        showEducationalTooltips: false,
        showDeveloperDiagnostics: true,
      ),
      ConfigurationMode.explorer => const ConfigurationModePolicy(
        predicatePathMode: PredicatePathMode.legacyCompassFallback,
        incompatibleTailPolicy: IncompatibleTailPolicy.allow,
        showEducationalTooltips: false,
        showDeveloperDiagnostics: true,
      ),
    };
  }
}

enum NounPhraseTarget {
  agent,
  object,
  objectComplement,
  recipient,
  addressee,
  companion,
  destination,
  topic,
  beneficiary,
  complement,
}

enum ConfigurationMessageKind { blocked, info }

enum ConfigurationMessageSource { lock, compass, ui }

enum ConfigurationLawCategory {
  stateUpdate,
  nounPhraseShape,
  lexicalBeFrame,
  predicateFrameType,
  passiveConfigurationShape,
  modalTenseFrame,
  imperativeFrame,
  phraseCompatibility,
  activeVoiceShape,
  configurationLaw,
}

class ConfigurationMessage {
  final ConfigurationMessageKind kind;
  final ConfigurationMessageSource source;
  final ConfigurationLawCategory lawCategory;
  final String text;

  const ConfigurationMessage(
    this.text, {
    required this.kind,
    this.source = ConfigurationMessageSource.lock,
    this.lawCategory = ConfigurationLawCategory.configurationLaw,
  });

  const ConfigurationMessage.blocked(
    String text, {
    ConfigurationMessageSource source = ConfigurationMessageSource.lock,
    ConfigurationLawCategory lawCategory =
        ConfigurationLawCategory.configurationLaw,
  }) : this(
         text,
         kind: ConfigurationMessageKind.blocked,
         source: source,
         lawCategory: lawCategory,
       );

  const ConfigurationMessage.info(
    String text, {
    ConfigurationMessageSource source = ConfigurationMessageSource.lock,
    ConfigurationLawCategory lawCategory = ConfigurationLawCategory.stateUpdate,
  }) : this(
         text,
         kind: ConfigurationMessageKind.info,
         source: source,
         lawCategory: lawCategory,
       );

  String get title {
    return switch (kind) {
      ConfigurationMessageKind.blocked => 'Blocked by ${source.label}',
      ConfigurationMessageKind.info => '${source.label} update',
    };
  }

  String get tooltip {
    return [
      title,
      text,
      if (kind == ConfigurationMessageKind.blocked) ...[
        '',
        'The attempted state was rejected and the previous sentence stayed active.',
        'If this came from a normal visible chip, refine Compass or the UI rail that exposed it.',
        'If this came from a direct probe, the Lock is doing its job.',
      ] else ...[
        '',
        'The move was accepted and the sentence state changed.',
      ],
    ].join('\n');
  }
}

extension ConfigurationMessageSourceLabel on ConfigurationMessageSource {
  String get label {
    return switch (this) {
      ConfigurationMessageSource.lock => 'Lock',
      ConfigurationMessageSource.compass => 'Compass',
      ConfigurationMessageSource.ui => 'UI',
    };
  }
}

extension ConfigurationLawCategoryLabel on ConfigurationLawCategory {
  String get label {
    return switch (this) {
      ConfigurationLawCategory.stateUpdate => 'state update',
      ConfigurationLawCategory.nounPhraseShape => 'noun phrase shape violation',
      ConfigurationLawCategory.lexicalBeFrame => 'lexical be frame violation',
      ConfigurationLawCategory.predicateFrameType =>
        'verb predicate frame type violation',
      ConfigurationLawCategory.passiveConfigurationShape =>
        'passive configuration shape violation',
      ConfigurationLawCategory.modalTenseFrame => 'modal tense frame violation',
      ConfigurationLawCategory.imperativeFrame => 'imperative frame violation',
      ConfigurationLawCategory.phraseCompatibility =>
        'phrase compatibility violation',
      ConfigurationLawCategory.activeVoiceShape =>
        'active voice shape violation',
      ConfigurationLawCategory.configurationLaw =>
        'configuration law violation',
    };
  }
}

class ConfigurationState {
  final SentenceState sentenceState;
  final List<ConfigurationMessage> messages;

  const ConfigurationState({
    required this.sentenceState,
    this.messages = const [],
  });

  factory ConfigurationState.initial() {
    return ConfigurationState(
      sentenceState: SentenceState(
        agent: you,
        action: learn,
        tense: Tense.present,
        aspect: Aspect.simple,
      ),
    );
  }

  ConfigurationState copyWith({
    SentenceState? sentenceState,
    List<ConfigurationMessage>? messages,
  }) {
    return ConfigurationState(
      sentenceState: sentenceState ?? this.sentenceState,
      messages: messages ?? this.messages,
    );
  }
}

sealed class ConfigurationMove {
  const ConfigurationMove();
}

class SetAgent extends ConfigurationMove {
  final NounPhrase? agent;

  const SetAgent(this.agent);
}

class SetAction extends ConfigurationMove {
  final Verb action;

  const SetAction(this.action);
}

class SetObject extends ConfigurationMove {
  final NounPhrase? object;

  const SetObject(this.object);
}

class SetRecipient extends ConfigurationMove {
  final NounPhrase? recipient;

  const SetRecipient(this.recipient);
}

class SetAddressee extends ConfigurationMove {
  final NounPhrase? addressee;

  const SetAddressee(this.addressee);
}

class SetCompanion extends ConfigurationMove {
  final NounPhrase? companion;

  const SetCompanion(this.companion);
}

class SetDestination extends ConfigurationMove {
  final NounPhrase? destination;

  const SetDestination(this.destination);
}

class SetTopic extends ConfigurationMove {
  final NounPhrase? topic;

  const SetTopic(this.topic);
}

class SetBeneficiary extends ConfigurationMove {
  final NounPhrase? beneficiary;

  const SetBeneficiary(this.beneficiary);
}

class SetRightAction extends ConfigurationMove {
  final Verb? rightAction;

  const SetRightAction(this.rightAction);
}

class SetComplement extends ConfigurationMove {
  final NounPhrase? complement;

  const SetComplement(this.complement);
}

class SetObjectComplement extends ConfigurationMove {
  final NounPhrase? objectComplement;

  const SetObjectComplement(this.objectComplement);
}

class SetNounPhraseDeterminer extends ConfigurationMove {
  final NounPhraseTarget target;
  final Determiner? determiner;

  const SetNounPhraseDeterminer(this.target, this.determiner);
}

class SetNounPhraseAdjectives extends ConfigurationMove {
  final NounPhraseTarget target;
  final List<Adjective> adjectives;

  const SetNounPhraseAdjectives(this.target, this.adjectives);
}

class SetAdjectiveComplement extends ConfigurationMove {
  final Adjective? adjectiveComplement;

  const SetAdjectiveComplement(this.adjectiveComplement);
}

class SetObjectAdjectiveComplement extends ConfigurationMove {
  final Adjective? objectAdjectiveComplement;

  const SetObjectAdjectiveComplement(this.objectAdjectiveComplement);
}

class SetLexicalBeComplement extends ConfigurationMove {
  final NounPhrase complement;

  const SetLexicalBeComplement(this.complement);
}

class SetLexicalBeAdjectiveComplement extends ConfigurationMove {
  final Adjective adjectiveComplement;

  const SetLexicalBeAdjectiveComplement(this.adjectiveComplement);
}

class SetVoice extends ConfigurationMove {
  final Voice voice;

  const SetVoice(this.voice);
}

class SetPassiveFocus extends ConfigurationMove {
  final PassiveFocus? passiveFocus;

  const SetPassiveFocus(this.passiveFocus);
}

class SetPassiveAgentVisibility extends ConfigurationMove {
  final bool showPassiveAgent;

  const SetPassiveAgentVisibility(this.showPassiveAgent);
}

class SetTense extends ConfigurationMove {
  final Tense tense;

  const SetTense(this.tense);
}

class SetAspect extends ConfigurationMove {
  final Aspect aspect;

  const SetAspect(this.aspect);
}

class SetModal extends ConfigurationMove {
  final Modal modal;

  const SetModal(this.modal);
}

class SetPolarity extends ConfigurationMove {
  final Polarity polarity;

  const SetPolarity(this.polarity);
}

class SetSentenceForm extends ConfigurationMove {
  final SentenceForm sentenceForm;

  const SetSentenceForm(this.sentenceForm);
}

class SetTimePhrase extends ConfigurationMove {
  final TimePhrase? timePhrase;

  const SetTimePhrase(this.timePhrase);
}

class SetPlacePhrase extends ConfigurationMove {
  final PlacePhrase? placePhrase;

  const SetPlacePhrase(this.placePhrase);
}

class SetFrequencyPhrase extends ConfigurationMove {
  final FrequencyPhrase? frequencyPhrase;

  const SetFrequencyPhrase(this.frequencyPhrase);
}

class SetMannerPhrase extends ConfigurationMove {
  final MannerPhrase? mannerPhrase;

  const SetMannerPhrase(this.mannerPhrase);
}

class ConfigurationEngine {
  final ConfigurationMode mode;

  const ConfigurationEngine({this.mode = ConfigurationMode.guided});

  ConfigurationModePolicy get modePolicy =>
      ConfigurationModePolicy.forMode(mode);

  ConfigurationState applyMove(
    ConfigurationState current,
    ConfigurationMove move,
  ) {
    final candidate = _candidateForMode(current.sentenceState, move);
    final blockers = _validate(candidate);

    if (modePolicy.incompatibleTailPolicy != IncompatibleTailPolicy.allow &&
        blockers.isNotEmpty) {
      return current.copyWith(messages: blockers);
    }

    return ConfigurationState(
      sentenceState: candidate,
      messages: [
        if (modePolicy.incompatibleTailPolicy == IncompatibleTailPolicy.allow)
          ...blockers,
        ..._collectMessages(current.sentenceState, candidate),
      ],
    );
  }

  SentenceState _candidateForMode(SentenceState state, ConfigurationMove move) {
    if (move is! SetAction) {
      return _applyMove(state, move);
    }

    return switch (modePolicy.incompatibleTailPolicy) {
      IncompatibleTailPolicy.shave || IncompatibleTailPolicy.previewShave =>
        _actionChangeWithShavedTail(state, move.action),
      IncompatibleTailPolicy.blockWithExplanation ||
      IncompatibleTailPolicy.allow => _rawActionChange(state, move.action),
    };
  }

  SentenceState _rawActionChange(SentenceState state, Verb action) {
    return _copy(state, action: action);
  }

  SentenceState _actionChangeWithShavedTail(SentenceState state, Verb action) {
    if (action == be) {
      return _copy(
        state,
        action: action,
        object: null,
        objectComplement: null,
        objectAdjectiveComplement: null,
        recipient: null,
        addressee: null,
        companion: state.companion,
        destination: null,
        topic: null,
        beneficiary: null,
        rightAction: null,
        complement: null,
        adjectiveComplement: null,
        voice: Voice.active,
        passiveFocus: null,
        showPassiveAgent: true,
      );
    }

    final rightAction = _rightActionAfterActionChange(
      state.rightAction,
      action,
    );
    final tailOwner = rightAction ?? action;
    final object = _objectAfterActionChange(state.object, tailOwner);
    final recipient = action.takesRecipient && object != null
        ? state.recipient
        : null;
    final addressee = tailOwner.takesAddressee ? state.addressee : null;
    final companion = _companionAfterActionChange(state.companion, tailOwner);
    final destination = tailOwner.usesDestinationPlace
        ? state.destination
        : null;
    final topic = _topicAfterActionChange(state.topic, tailOwner);
    final beneficiary = _beneficiaryAfterActionChange(
      state.beneficiary,
      tailOwner,
    );
    final placePhrase = _placePhraseAfterActionChange(
      state.placePhrase,
      tailOwner,
    );
    final timePhrase = _timePhraseAfterActionChange(
      state.timePhrase,
      tailOwner,
    );
    final frequencyPhrase = _frequencyPhraseAfterActionChange(
      state.frequencyPhrase,
      tailOwner,
    );
    final mannerPhrase = _mannerPhraseAfterActionChange(
      state.mannerPhrase,
      tailOwner,
    );
    final canKeepPassive =
        state.voice == Voice.passive && action.takesObject && object != null;
    final voice = canKeepPassive ? state.voice : Voice.active;
    final passiveFocus = voice == Voice.passive
        ? _passiveFocusAfterActionChange(state.passiveFocus, action, recipient)
        : null;

    return _copy(
      state,
      action: action,
      object: object,
      objectComplement: _objectComplementAfterActionChange(
        state.objectComplement,
        object,
        action,
      ),
      objectAdjectiveComplement: _objectAdjectiveComplementAfterActionChange(
        state.objectAdjectiveComplement,
        object,
        action,
      ),
      recipient: recipient,
      addressee: addressee,
      companion: companion,
      destination: destination,
      topic: topic,
      beneficiary: beneficiary,
      rightAction: rightAction,
      complement: null,
      adjectiveComplement: null,
      placePhrase: placePhrase,
      placeMeaning: placePhrase == null ? null : state.placeMeaning,
      timePhrase: timePhrase,
      frequencyPhrase: frequencyPhrase,
      mannerPhrase: mannerPhrase,
      voice: voice,
      passiveFocus: passiveFocus,
      showPassiveAgent: voice == Voice.passive ? state.showPassiveAgent : true,
    );
  }

  SentenceState _applyMove(SentenceState state, ConfigurationMove move) {
    return switch (move) {
      SetAgent(:final agent) => _copy(state, agent: agent),
      SetAction(:final action) => _actionChangeWithShavedTail(state, action),
      SetObject(:final object) => _copy(
        state,
        object: object,
        objectComplement: object == null ? null : state.objectComplement,
        objectAdjectiveComplement: object == null
            ? null
            : state.objectAdjectiveComplement,
      ),
      SetRecipient(:final recipient) => _copy(state, recipient: recipient),
      SetAddressee(:final addressee) => _copy(state, addressee: addressee),
      SetCompanion(:final companion) => _copy(state, companion: companion),
      SetDestination(:final destination) => _copy(
        state,
        destination: destination,
      ),
      SetTopic(:final topic) => _copy(state, topic: topic),
      SetBeneficiary(:final beneficiary) => _copy(
        state,
        beneficiary: beneficiary,
      ),
      SetRightAction(:final rightAction) => _copy(
        state,
        rightAction: rightAction,
      ),
      SetComplement(:final complement) => _copy(
        state,
        complement: complement,
        adjectiveComplement: complement == null
            ? state.adjectiveComplement
            : null,
      ),
      SetObjectComplement(:final objectComplement) => _copy(
        state,
        objectComplement: objectComplement,
        objectAdjectiveComplement: objectComplement == null
            ? state.objectAdjectiveComplement
            : null,
      ),
      SetNounPhraseDeterminer(:final target, :final determiner) =>
        _copyNounPhrase(
          state,
          target,
          (phrase) => phrase.copyWith(determiner: determiner),
        ),
      SetNounPhraseAdjectives(:final target, :final adjectives) =>
        _copyNounPhrase(
          state,
          target,
          (phrase) => phrase.copyWith(
            adjective: adjectives.isEmpty ? null : adjectives.first,
            adjectives: adjectives,
          ),
        ),
      SetAdjectiveComplement(:final adjectiveComplement) => _copy(
        state,
        complement: adjectiveComplement == null ? state.complement : null,
        adjectiveComplement: adjectiveComplement,
      ),
      SetObjectAdjectiveComplement(:final objectAdjectiveComplement) => _copy(
        state,
        objectComplement: objectAdjectiveComplement == null
            ? state.objectComplement
            : null,
        objectAdjectiveComplement: objectAdjectiveComplement,
      ),
      SetLexicalBeComplement(:final complement) => _copy(
        state,
        action: be,
        object: null,
        recipient: null,
        addressee: null,
        destination: null,
        topic: null,
        beneficiary: null,
        rightAction: null,
        complement: complement,
        adjectiveComplement: null,
        voice: Voice.active,
        passiveFocus: null,
        showPassiveAgent: true,
      ),
      SetLexicalBeAdjectiveComplement(:final adjectiveComplement) => _copy(
        state,
        action: be,
        object: null,
        recipient: null,
        addressee: null,
        destination: null,
        topic: null,
        beneficiary: null,
        rightAction: null,
        complement: null,
        adjectiveComplement: adjectiveComplement,
        voice: Voice.active,
        passiveFocus: null,
        showPassiveAgent: true,
      ),
      SetVoice(:final voice) => _copy(
        state,
        agent: voice == Voice.active
            ? _activeAgentAfterVoiceChange(state.agent)
            : state.agent,
        voice: voice,
        passiveFocus: voice == Voice.active ? null : state.passiveFocus,
        showPassiveAgent: voice == Voice.active ? true : state.showPassiveAgent,
      ),
      SetPassiveFocus(:final passiveFocus) => _copy(
        state,
        passiveFocus: passiveFocus,
      ),
      SetPassiveAgentVisibility(:final showPassiveAgent) => _copy(
        state,
        showPassiveAgent: showPassiveAgent,
      ),
      SetTense(:final tense) => _copy(
        state,
        tense: tense,
        modal: tense == Tense.future || state.modal == will
            ? noModal
            : state.modal,
      ),
      SetAspect(:final aspect) => _copy(state, aspect: aspect),
      SetModal(:final modal) =>
        modal == will
            ? _copy(state, tense: Tense.future, modal: noModal)
            : _copy(
                state,
                tense: state.tense == Tense.future && !modal.isNone
                    ? Tense.present
                    : state.tense,
                modal: modal,
              ),
      SetPolarity(:final polarity) => _copy(state, polarity: polarity),
      SetSentenceForm(:final sentenceForm) => _copy(
        state,
        sentenceForm: sentenceForm,
      ),
      SetTimePhrase(:final timePhrase) => _copy(state, timePhrase: timePhrase),
      SetPlacePhrase(:final placePhrase) => _copy(
        state,
        placePhrase: placePhrase,
        placeMeaning: placePhrase == null ? null : state.placeMeaning,
      ),
      SetFrequencyPhrase(:final frequencyPhrase) => _copy(
        state,
        frequencyPhrase: frequencyPhrase,
      ),
      SetMannerPhrase(:final mannerPhrase) => _copy(
        state,
        mannerPhrase: mannerPhrase,
      ),
    };
  }

  List<ConfigurationMessage> _validate(SentenceState state) {
    final blockers = <ConfigurationMessage>[];

    _validateNounPhrase('Agent', state.agent, blockers);
    _validateNounPhrase('Object', state.object, blockers);
    _validateNounPhrase('Object complement', state.objectComplement, blockers);
    _validateNounPhrase('Recipient', state.recipient, blockers);
    _validateNounPhrase('Addressee', state.addressee, blockers);
    _validateNounPhrase('Companion', state.companion, blockers);
    _validateNounPhrase('Destination', state.destination, blockers);
    _validateNounPhrase('Topic', state.topic, blockers);
    _validateNounPhrase('Beneficiary', state.beneficiary, blockers);
    _validateNounPhrase('Complement', state.complement, blockers);
    _validateRightAction(state, blockers);

    if (isLexicalBeFrame(state)) {
      _validateLexicalBe(state, blockers);
    } else {
      _validatePredicateFrame(state, blockers);
    }

    _validateModalFrame(state, blockers);
    _validateImperativeFrame(state, blockers);
    _validatePhraseFrame(state, blockers);

    return blockers;
  }

  void _validateNounPhrase(
    String label,
    NounPhrase? phrase,
    List<ConfigurationMessage> blockers,
  ) {
    if (phrase == null) {
      return;
    }

    if (!phrase.canTakeModifiers &&
        (phrase.determiner != null || phrase.adjectiveList.isNotEmpty)) {
      blockers.add(
        ConfigurationMessage.blocked(
          '$label pronouns do not take modifiers.',
          lawCategory: ConfigurationLawCategory.nounPhraseShape,
        ),
      );
      return;
    }

    final determiner = phrase.determiner;
    if (determiner == null) {
      return;
    }

    if (_singularDeterminers.contains(determiner.text) && phrase.isPlural) {
      blockers.add(
        ConfigurationMessage.blocked(
          '$label determiner "${determiner.text}" requires a singular noun.',
          lawCategory: ConfigurationLawCategory.nounPhraseShape,
        ),
      );
    }

    if (_pluralDeterminers.contains(determiner.text) && !phrase.isPlural) {
      blockers.add(
        ConfigurationMessage.blocked(
          '$label determiner "${determiner.text}" requires a plural noun.',
          lawCategory: ConfigurationLawCategory.nounPhraseShape,
        ),
      );
    }

    final firstSpokenWord = phrase.adjectiveList.isEmpty
        ? phrase.text
        : phrase.adjectiveList.first.text;

    if (determiner.text == 'a' && _startsWithVowelLetter(firstSpokenWord)) {
      blockers.add(
        ConfigurationMessage.blocked(
          '$label determiner "a" requires a consonant sound.',
          lawCategory: ConfigurationLawCategory.nounPhraseShape,
        ),
      );
    }

    if (determiner.text == 'an' && !_startsWithVowelLetter(firstSpokenWord)) {
      blockers.add(
        ConfigurationMessage.blocked(
          '$label determiner "an" requires a vowel sound.',
          lawCategory: ConfigurationLawCategory.nounPhraseShape,
        ),
      );
    }
  }

  void _validateLexicalBe(
    SentenceState state,
    List<ConfigurationMessage> blockers,
  ) {
    if (lexicalBeNeedsAgent(state)) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Lexical be requires an agent.',
          lawCategory: ConfigurationLawCategory.lexicalBeFrame,
        ),
      );
    }

    if (lexicalBeNeedsActiveVoice(state)) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Lexical be is active-only.',
          lawCategory: ConfigurationLawCategory.lexicalBeFrame,
        ),
      );
    }

    if (!lexicalBeNounComplementMatchesAgentNumber(state)) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Lexical be noun complement must match agent number.',
          lawCategory: ConfigurationLawCategory.lexicalBeFrame,
        ),
      );
    }

    if (lexicalBeRejectsObjectSurface(state)) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Lexical be does not take an object.',
          lawCategory: ConfigurationLawCategory.lexicalBeFrame,
        ),
      );
    }

    if (lexicalBeRejectsObjectComplementSurface(state)) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Lexical be does not take an object complement.',
          lawCategory: ConfigurationLawCategory.lexicalBeFrame,
        ),
      );
    }

    if (lexicalBeRejectsRecipientSurface(state)) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Lexical be does not take a recipient.',
          lawCategory: ConfigurationLawCategory.lexicalBeFrame,
        ),
      );
    }

    if (lexicalBeRejectsAddresseeSurface(state)) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Lexical be does not take an addressee.',
          lawCategory: ConfigurationLawCategory.lexicalBeFrame,
        ),
      );
    }

    if (lexicalBeRejectsTopicSurface(state)) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Lexical be does not take an about-topic.',
          lawCategory: ConfigurationLawCategory.lexicalBeFrame,
        ),
      );
    }

    if (lexicalBeRejectsBeneficiarySurface(state)) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Lexical be does not take a beneficiary.',
          lawCategory: ConfigurationLawCategory.lexicalBeFrame,
        ),
      );
    }

    if (lexicalBeRejectsDestinationSurface(state)) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Lexical be does not take a destination.',
          lawCategory: ConfigurationLawCategory.lexicalBeFrame,
        ),
      );
    }

    if (lexicalBeRejectsRightActionSurface(state)) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Lexical be does not take a right action complement.',
          lawCategory: ConfigurationLawCategory.lexicalBeFrame,
        ),
      );
    }

    if (lexicalBeRejectsPassiveFocus(state)) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Lexical be does not take passive focus.',
          lawCategory: ConfigurationLawCategory.lexicalBeFrame,
        ),
      );
    }

    if (lexicalBeRejectsPassiveAgentVisibility(state)) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Lexical be does not take passive agent visibility.',
          lawCategory: ConfigurationLawCategory.lexicalBeFrame,
        ),
      );
    }
  }

  void _validateRightAction(
    SentenceState state,
    List<ConfigurationMessage> blockers,
  ) {
    final rightAction = state.rightAction;
    if (rightAction == null) {
      return;
    }

    if (state.action == be) {
      return;
    }

    if (!hasRightActionFrame(state.action)) {
      blockers.add(
        ConfigurationMessage.blocked(
          '${state.action.infinitive} does not take a right action complement.',
          lawCategory: ConfigurationLawCategory.predicateFrameType,
        ),
      );
      return;
    }

    if (!rightActionFitsAction(rightAction, state.action)) {
      blockers.add(
        ConfigurationMessage.blocked(
          '${state.action.infinitive} does not take "${rightAction.infinitive}" as a right action.',
          lawCategory: ConfigurationLawCategory.predicateFrameType,
        ),
      );
    }

    return;
  }

  void _validatePredicateFrame(
    SentenceState state,
    List<ConfigurationMessage> blockers,
  ) {
    if (state.complement != null || state.adjectiveComplement != null) {
      blockers.add(
        ConfigurationMessage.blocked(
          '${state.action.infinitive} does not take a complement.',
          lawCategory: ConfigurationLawCategory.predicateFrameType,
        ),
      );
    }

    if (state.objectComplement != null ||
        state.objectAdjectiveComplement != null) {
      if (!objectComplementsNeedObjectCapablePredicate(state)) {
        blockers.add(
          ConfigurationMessage.blocked(
            '${state.action.infinitive} does not take an object complement.',
            lawCategory: ConfigurationLawCategory.predicateFrameType,
          ),
        );
      }

      if (!objectComplementsNeedObject(state)) {
        blockers.add(
          const ConfigurationMessage.blocked(
            'Object complements require an object.',
            lawCategory: ConfigurationLawCategory.predicateFrameType,
          ),
        );
      }
    }

    if (state.companion != null &&
        !(state.rightAction == null
            ? state.action.takesCompanion
            : state.rightAction!.takesCompanion)) {
      blockers.add(
        ConfigurationMessage.blocked(
          '${(state.rightAction ?? state.action).infinitive} does not take a companion.',
          lawCategory: ConfigurationLawCategory.predicateFrameType,
        ),
      );
    }

    if (state.destination != null &&
        !(state.rightAction == null
            ? state.action.usesDestinationPlace
            : state.rightAction!.usesDestinationPlace)) {
      blockers.add(
        ConfigurationMessage.blocked(
          '${(state.rightAction ?? state.action).infinitive} does not take a destination.',
          lawCategory: ConfigurationLawCategory.predicateFrameType,
        ),
      );
    }

    if (state.topic != null &&
        !(state.rightAction == null
            ? state.action.takesTopic
            : state.rightAction!.takesTopic)) {
      blockers.add(
        ConfigurationMessage.blocked(
          '${(state.rightAction ?? state.action).infinitive} does not take an about-topic.',
          lawCategory: ConfigurationLawCategory.predicateFrameType,
        ),
      );
    }

    if (state.beneficiary != null &&
        !(state.rightAction == null
            ? state.action.takesBeneficiary
            : state.rightAction!.takesBeneficiary)) {
      blockers.add(
        ConfigurationMessage.blocked(
          '${(state.rightAction ?? state.action).infinitive} does not take a beneficiary.',
          lawCategory: ConfigurationLawCategory.predicateFrameType,
        ),
      );
    }

    final objectOwner = state.rightAction ?? state.action;
    if (hasFixedObjectFrame(objectOwner) && state.object != null) {
      final label = fixedObjectFrameLabel(objectOwner) ?? 'fixed object';
      if (!fixedObjectFitsAction(state.object!, objectOwner)) {
        blockers.add(
          ConfigurationMessage.blocked(
            '${objectOwner.infinitive} only takes fixed $label objects.',
            lawCategory: ConfigurationLawCategory.predicateFrameType,
          ),
        );
      }

      if (!fixedObjectFrameAllowsModifiers(objectOwner) &&
          (state.object!.determiner != null ||
              state.object!.adjectiveList.isNotEmpty)) {
        blockers.add(
          ConfigurationMessage.blocked(
            '${objectOwner.infinitive} fixed $label objects stay bare.',
            lawCategory: ConfigurationLawCategory.predicateFrameType,
          ),
        );
      }
    }

    switch (state.voice) {
      case Voice.active:
        if (activeVoiceNeedsAgent(state)) {
          blockers.add(
            const ConfigurationMessage.blocked(
              'Active voice requires an agent.',
              lawCategory: ConfigurationLawCategory.activeVoiceShape,
            ),
          );
        }

        if (!passiveFocusBelongsToPassiveVoice(state)) {
          blockers.add(
            const ConfigurationMessage.blocked(
              'Passive focus belongs to passive voice.',
              lawCategory: ConfigurationLawCategory.passiveConfigurationShape,
            ),
          );
        }

        if (!passiveAgentVisibilityBelongsToPassiveVoice(state)) {
          blockers.add(
            const ConfigurationMessage.blocked(
              'Passive agent visibility belongs to passive voice.',
              lawCategory: ConfigurationLawCategory.passiveConfigurationShape,
            ),
          );
        }

        if (!activeRecipientNeedsRecipientCapablePredicate(state)) {
          blockers.add(
            ConfigurationMessage.blocked(
              '${state.action.infinitive} does not take a recipient.',
              lawCategory: ConfigurationLawCategory.predicateFrameType,
            ),
          );
        }

        if (!activeAddresseeNeedsAddresseeCapablePredicate(state)) {
          blockers.add(
            ConfigurationMessage.blocked(
              '${(state.rightAction ?? state.action).infinitive} does not take an addressee.',
              lawCategory: ConfigurationLawCategory.predicateFrameType,
            ),
          );
        }

        if (!activeTopicNeedsTopicCapablePredicate(state)) {
          blockers.add(
            ConfigurationMessage.blocked(
              '${(state.rightAction ?? state.action).infinitive} does not take an about-topic.',
              lawCategory: ConfigurationLawCategory.predicateFrameType,
            ),
          );
        }

        if (!activeBeneficiaryNeedsBeneficiaryCapablePredicate(state)) {
          blockers.add(
            ConfigurationMessage.blocked(
              '${(state.rightAction ?? state.action).infinitive} does not take a beneficiary.',
              lawCategory: ConfigurationLawCategory.predicateFrameType,
            ),
          );
        }

        if (!activeObjectNeedsObjectCapablePredicate(state)) {
          blockers.add(
            ConfigurationMessage.blocked(
              '${(state.rightAction ?? state.action).infinitive} does not take an object.',
              lawCategory: ConfigurationLawCategory.predicateFrameType,
            ),
          );
        }

        if (!recipientFrameNeedsObject(state)) {
          blockers.add(
            const ConfigurationMessage.blocked(
              'Recipient frames require an object.',
              lawCategory: ConfigurationLawCategory.predicateFrameType,
            ),
          );
        }

        break;

      case Voice.passive:
        if (state.addressee != null && !state.action.takesAddressee) {
          blockers.add(
            ConfigurationMessage.blocked(
              '${state.action.infinitive} does not take an addressee.',
              lawCategory: ConfigurationLawCategory.predicateFrameType,
            ),
          );
        }

        if (state.topic != null && !state.action.takesTopic) {
          blockers.add(
            ConfigurationMessage.blocked(
              '${state.action.infinitive} does not take an about-topic.',
              lawCategory: ConfigurationLawCategory.predicateFrameType,
            ),
          );
        }

        if (state.beneficiary != null && !state.action.takesBeneficiary) {
          blockers.add(
            ConfigurationMessage.blocked(
              '${state.action.infinitive} does not take a beneficiary.',
              lawCategory: ConfigurationLawCategory.predicateFrameType,
            ),
          );
        }

        if (!passiveVoiceNeedsObjectCapablePredicate(state)) {
          blockers.add(
            ConfigurationMessage.blocked(
              '${state.action.infinitive} cannot be passive in this frame.',
              lawCategory: ConfigurationLawCategory.predicateFrameType,
            ),
          );
        }

        if (!passiveObjectFocusNeedsObject(state)) {
          blockers.add(
            const ConfigurationMessage.blocked(
              'Passive object focus requires an object.',
              lawCategory: ConfigurationLawCategory.passiveConfigurationShape,
            ),
          );
        }

        if (!passiveRecipientFocusNeedsRecipientCapablePredicate(state)) {
          blockers.add(
            ConfigurationMessage.blocked(
              '${state.action.infinitive} has no recipient focus.',
              lawCategory: ConfigurationLawCategory.passiveConfigurationShape,
            ),
          );
        }

        if (!passiveRecipientFocusNeedsRecipient(state)) {
          blockers.add(
            const ConfigurationMessage.blocked(
              'Passive recipient focus requires a recipient.',
              lawCategory: ConfigurationLawCategory.passiveConfigurationShape,
            ),
          );
        }

        if (!passiveRecipientFocusNeedsObject(state)) {
          blockers.add(
            const ConfigurationMessage.blocked(
              'Passive recipient focus still requires an object.',
              lawCategory: ConfigurationLawCategory.passiveConfigurationShape,
            ),
          );
        }
    }
  }

  void _validateModalFrame(
    SentenceState state,
    List<ConfigurationMessage> blockers,
  ) {
    if (state.modal.isNone) {
      return;
    }

    if (!modalAllowedInSentenceForm(state)) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Imperatives cannot take a modal.',
          lawCategory: ConfigurationLawCategory.imperativeFrame,
        ),
      );
    }

    if (state.modal == will && !modalMatchesTenseFrame(state)) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Will belongs to the future tense frame.',
          lawCategory: ConfigurationLawCategory.modalTenseFrame,
        ),
      );
    }

    if (state.modal != will && !modalMatchesTenseFrame(state)) {
      blockers.add(
        ConfigurationMessage.blocked(
          '${state.modal.text} belongs to the present modal frame.',
          lawCategory: ConfigurationLawCategory.modalTenseFrame,
        ),
      );
    }
  }

  void _validateImperativeFrame(
    SentenceState state,
    List<ConfigurationMessage> blockers,
  ) {
    if (state.sentenceForm != SentenceForm.imperative) {
      return;
    }

    if (!imperativeUsesPresentSimple(state)) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Imperatives use present simple.',
          lawCategory: ConfigurationLawCategory.imperativeFrame,
        ),
      );
    }

    if (!imperativeUsesActiveVoice(state)) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Imperatives use active voice.',
          lawCategory: ConfigurationLawCategory.imperativeFrame,
        ),
      );
    }
  }

  void _validatePhraseFrame(
    SentenceState state,
    List<ConfigurationMessage> blockers,
  ) {
    final place = state.placePhrase;
    if (place == null) {
      return;
    }

    if (place.noun.toLowerCase() == state.action.infinitive.toLowerCase()) {
      blockers.add(
        ConfigurationMessage.blocked(
          'Place phrase cannot repeat the verb word "${place.noun}".',
          lawCategory: ConfigurationLawCategory.phraseCompatibility,
        ),
      );
    }
  }

  List<ConfigurationMessage> _collectMessages(
    SentenceState previous,
    SentenceState current,
  ) {
    final messages = <ConfigurationMessage>[];

    if (previous.voice != current.voice) {
      messages.add(
        ConfigurationMessage.info('Voice changed to ${current.voice.name}.'),
      );
    }

    if (previous.action != current.action) {
      messages.add(
        ConfigurationMessage.info(
          'Verb changed to ${current.action.infinitive}.',
        ),
      );

      final shavedFields = _shavedTailFields(previous, current);
      if (shavedFields.isNotEmpty) {
        messages.add(
          ConfigurationMessage.info(
            'Verb switch removed incompatible ${_joinLabels(shavedFields)}.',
            lawCategory: ConfigurationLawCategory.stateUpdate,
          ),
        );
      }
    }

    return messages;
  }

  List<String> _shavedTailFields(
    SentenceState previous,
    SentenceState current,
  ) {
    final fields = <String>[];

    if (previous.object != null && current.object == null) {
      fields.add('object');
    }
    if (previous.objectComplement != null && current.objectComplement == null) {
      fields.add('object complement');
    }
    if (previous.objectAdjectiveComplement != null &&
        current.objectAdjectiveComplement == null) {
      fields.add('object adjective complement');
    }
    if (previous.recipient != null && current.recipient == null) {
      fields.add('recipient');
    }
    if (previous.addressee != null && current.addressee == null) {
      fields.add('addressee');
    }
    if (previous.companion != null && current.companion == null) {
      fields.add('companion');
    }
    if (previous.destination != null && current.destination == null) {
      fields.add('destination');
    }
    if (previous.topic != null && current.topic == null) {
      fields.add('about-topic');
    }
    if (previous.beneficiary != null && current.beneficiary == null) {
      fields.add('beneficiary');
    }
    if (previous.rightAction != null && current.rightAction == null) {
      fields.add('right action');
    }
    if (previous.complement != null && current.complement == null) {
      fields.add('complement');
    }
    if (previous.adjectiveComplement != null &&
        current.adjectiveComplement == null) {
      fields.add('adjective complement');
    }
    if (previous.placePhrase != null && current.placePhrase == null) {
      fields.add('place phrase');
    }
    if (previous.timePhrase != null && current.timePhrase == null) {
      fields.add('time phrase');
    }
    if (previous.frequencyPhrase != null && current.frequencyPhrase == null) {
      fields.add('frequency phrase');
    }
    if (previous.mannerPhrase != null && current.mannerPhrase == null) {
      fields.add('manner phrase');
    }
    if (previous.voice == Voice.passive && current.voice == Voice.active) {
      fields.add('passive voice');
    } else if (previous.passiveFocus != null && current.passiveFocus == null) {
      fields.add('passive focus');
    }

    return fields;
  }

  String _joinLabels(List<String> labels) {
    if (labels.length == 1) {
      return labels.single;
    }

    return '${labels.take(labels.length - 1).join(', ')} and ${labels.last}';
  }

  NounPhrase? _objectAfterActionChange(NounPhrase? object, Verb action) {
    if (object == null) {
      return null;
    }

    if (!action.takesObject) {
      return null;
    }

    if (!_predicatePathAcceptsNoun(
      action,
      PredicatePathKind.directObject,
      object,
    )) {
      return null;
    }

    if (canClearObjectForFixedSubjectFrame(object, action)) {
      return null;
    }

    if (hasFixedObjectFrame(action)) {
      if (!fixedObjectFitsAction(object, action)) {
        return null;
      }

      if (!fixedObjectFrameAllowsModifiers(action) &&
          (object.determiner != null || object.adjectiveList.isNotEmpty)) {
        return null;
      }
    }

    return object;
  }

  NounPhrase? _companionAfterActionChange(NounPhrase? companion, Verb action) {
    if (companion == null) {
      return null;
    }

    if (!action.takesCompanion) {
      return null;
    }

    if (!_predicatePathAcceptsNoun(
      action,
      PredicatePathKind.withCompanion,
      companion,
    )) {
      return null;
    }

    return companion;
  }

  NounPhrase? _topicAfterActionChange(NounPhrase? topic, Verb action) {
    if (topic == null) {
      return null;
    }

    if (!action.takesTopic) {
      return null;
    }

    if (!_predicatePathAcceptsNoun(
      action,
      PredicatePathKind.aboutTopic,
      topic,
    )) {
      return null;
    }

    return topic;
  }

  NounPhrase? _beneficiaryAfterActionChange(
    NounPhrase? beneficiary,
    Verb action,
  ) {
    if (beneficiary == null) {
      return null;
    }

    if (!action.takesBeneficiary) {
      return null;
    }

    if (!_predicatePathAcceptsNoun(
      action,
      PredicatePathKind.forBeneficiary,
      beneficiary,
    )) {
      return null;
    }

    return beneficiary;
  }

  bool _predicatePathAcceptsNoun(
    Verb action,
    PredicatePathKind kind,
    NounPhrase noun,
  ) {
    if (modePolicy.predicatePathMode != PredicatePathMode.authoredTracks) {
      return true;
    }

    final choices = predicateNounChoicesFor(action, kind);
    if (choices.isEmpty) {
      return true;
    }

    return choices.any(
      (choice) =>
          choice.text.toLowerCase() == noun.text.toLowerCase() &&
          choice.number == noun.number,
    );
  }

  PlacePhrase? _placePhraseAfterActionChange(
    PlacePhrase? placePhrase,
    Verb action,
  ) {
    if (placePhrase == null) {
      return null;
    }

    if (!_predicatePathAcceptsPlace(action, placePhrase)) {
      return null;
    }

    return placePhrase;
  }

  TimePhrase? _timePhraseAfterActionChange(
    TimePhrase? timePhrase,
    Verb action,
  ) {
    if (timePhrase == null) {
      return null;
    }

    if (!_predicatePathAcceptsTime(action, timePhrase)) {
      return null;
    }

    return timePhrase;
  }

  FrequencyPhrase? _frequencyPhraseAfterActionChange(
    FrequencyPhrase? frequencyPhrase,
    Verb action,
  ) {
    if (frequencyPhrase == null) {
      return null;
    }

    if (!_predicatePathAcceptsFrequency(action, frequencyPhrase)) {
      return null;
    }

    return frequencyPhrase;
  }

  MannerPhrase? _mannerPhraseAfterActionChange(
    MannerPhrase? mannerPhrase,
    Verb action,
  ) {
    if (mannerPhrase == null) {
      return null;
    }

    if (!_predicatePathAcceptsManner(action, mannerPhrase)) {
      return null;
    }

    return mannerPhrase;
  }

  bool _predicatePathAcceptsPlace(Verb action, PlacePhrase phrase) {
    if (modePolicy.predicatePathMode != PredicatePathMode.authoredTracks) {
      return true;
    }

    final choices = predicatePlaceChoicesFor(
      action,
      PredicatePathKind.placePhrase,
    );
    if (choices.isEmpty) {
      return true;
    }

    return choices.any(
      (choice) => choice.noun.toLowerCase() == phrase.noun.toLowerCase(),
    );
  }

  bool _predicatePathAcceptsTime(Verb action, TimePhrase phrase) {
    if (modePolicy.predicatePathMode != PredicatePathMode.authoredTracks) {
      return true;
    }

    final choices = predicateTimeChoicesFor(
      action,
      PredicatePathKind.timePhrase,
    );
    if (choices.isEmpty) {
      return true;
    }

    return choices.any(
      (choice) => choice.text.toLowerCase() == phrase.text.toLowerCase(),
    );
  }

  bool _predicatePathAcceptsFrequency(Verb action, FrequencyPhrase phrase) {
    if (modePolicy.predicatePathMode != PredicatePathMode.authoredTracks) {
      return true;
    }

    final choices = predicateFrequencyChoicesFor(
      action,
      PredicatePathKind.frequencyPhrase,
    );
    if (choices.isEmpty) {
      return true;
    }

    return choices.any(
      (choice) => choice.text.toLowerCase() == phrase.text.toLowerCase(),
    );
  }

  bool _predicatePathAcceptsManner(Verb action, MannerPhrase phrase) {
    if (modePolicy.predicatePathMode != PredicatePathMode.authoredTracks) {
      return true;
    }

    final choices = predicateMannerChoicesFor(
      action,
      PredicatePathKind.mannerPhrase,
    );
    if (choices.isEmpty) {
      return true;
    }

    return choices.any(
      (choice) => choice.text.toLowerCase() == phrase.text.toLowerCase(),
    );
  }

  NounPhrase? _objectComplementAfterActionChange(
    NounPhrase? objectComplement,
    NounPhrase? object,
    Verb action,
  ) {
    if (objectComplement == null) {
      return null;
    }

    return action.takesObjectComplement &&
            _objectAfterActionChange(object, action) != null
        ? objectComplement
        : null;
  }

  Adjective? _objectAdjectiveComplementAfterActionChange(
    Adjective? objectAdjectiveComplement,
    NounPhrase? object,
    Verb action,
  ) {
    if (objectAdjectiveComplement == null) {
      return null;
    }

    return action.takesObjectComplement &&
            _objectAfterActionChange(object, action) != null
        ? objectAdjectiveComplement
        : null;
  }

  Verb? _rightActionAfterActionChange(Verb? rightAction, Verb action) {
    if (rightAction == null) {
      return null;
    }

    return rightActionFitsAction(rightAction, action) ? rightAction : null;
  }

  PassiveFocus? _passiveFocusAfterActionChange(
    PassiveFocus? passiveFocus,
    Verb action,
    NounPhrase? recipient,
  ) {
    if ((passiveFocus ?? PassiveFocus.object) == PassiveFocus.recipient &&
        (!action.takesRecipient || recipient == null)) {
      return null;
    }

    return passiveFocus;
  }

  SentenceState _copy(
    SentenceState state, {
    Object? agent = _unchanged,
    Verb? action,
    Object? object = _unchanged,
    Object? objectComplement = _unchanged,
    Object? objectAdjectiveComplement = _unchanged,
    Object? recipient = _unchanged,
    Object? addressee = _unchanged,
    Object? companion = _unchanged,
    Object? destination = _unchanged,
    Object? topic = _unchanged,
    Object? beneficiary = _unchanged,
    Object? rightAction = _unchanged,
    Object? complement = _unchanged,
    Object? adjectiveComplement = _unchanged,
    Voice? voice,
    Object? passiveFocus = _unchanged,
    bool? showPassiveAgent,
    Tense? tense,
    Aspect? aspect,
    Modal? modal,
    Polarity? polarity,
    SentenceForm? sentenceForm,
    Object? timePhrase = _unchanged,
    Object? placePhrase = _unchanged,
    Object? placeMeaning = _unchanged,
    Object? frequencyPhrase = _unchanged,
    Object? mannerPhrase = _unchanged,
  }) {
    return SentenceState(
      agent: identical(agent, _unchanged) ? state.agent : agent as NounPhrase?,
      action: action ?? state.action,
      object: identical(object, _unchanged)
          ? state.object
          : object as NounPhrase?,
      objectComplement: identical(objectComplement, _unchanged)
          ? state.objectComplement
          : objectComplement as NounPhrase?,
      objectAdjectiveComplement:
          identical(objectAdjectiveComplement, _unchanged)
          ? state.objectAdjectiveComplement
          : objectAdjectiveComplement as Adjective?,
      recipient: identical(recipient, _unchanged)
          ? state.recipient
          : recipient as NounPhrase?,
      addressee: identical(addressee, _unchanged)
          ? state.addressee
          : addressee as NounPhrase?,
      companion: identical(companion, _unchanged)
          ? state.companion
          : companion as NounPhrase?,
      destination: identical(destination, _unchanged)
          ? state.destination
          : destination as NounPhrase?,
      topic: identical(topic, _unchanged) ? state.topic : topic as NounPhrase?,
      beneficiary: identical(beneficiary, _unchanged)
          ? state.beneficiary
          : beneficiary as NounPhrase?,
      rightAction: identical(rightAction, _unchanged)
          ? state.rightAction
          : rightAction as Verb?,
      recipientPlacement: state.recipientPlacement,
      recipientPreposition: state.recipientPreposition,
      complement: identical(complement, _unchanged)
          ? state.complement
          : complement as NounPhrase?,
      adjectiveComplement: identical(adjectiveComplement, _unchanged)
          ? state.adjectiveComplement
          : adjectiveComplement as Adjective?,
      voice: voice ?? state.voice,
      passiveFocus: identical(passiveFocus, _unchanged)
          ? state.passiveFocus
          : passiveFocus as PassiveFocus?,
      showPassiveAgent: showPassiveAgent ?? state.showPassiveAgent,
      tense: tense ?? state.tense,
      aspect: aspect ?? state.aspect,
      modal: modal ?? state.modal,
      polarity: polarity ?? state.polarity,
      sentenceForm: sentenceForm ?? state.sentenceForm,
      timePhrase: identical(timePhrase, _unchanged)
          ? state.timePhrase
          : timePhrase as TimePhrase?,
      placePhrase: identical(placePhrase, _unchanged)
          ? state.placePhrase
          : placePhrase as PlacePhrase?,
      placeMeaning: identical(placeMeaning, _unchanged)
          ? state.placeMeaning
          : placeMeaning as PlaceMeaning?,
      frequencyPhrase: identical(frequencyPhrase, _unchanged)
          ? state.frequencyPhrase
          : frequencyPhrase as FrequencyPhrase?,
      mannerPhrase: identical(mannerPhrase, _unchanged)
          ? state.mannerPhrase
          : mannerPhrase as MannerPhrase?,
    );
  }

  SentenceState _copyNounPhrase(
    SentenceState state,
    NounPhraseTarget target,
    NounPhrase Function(NounPhrase phrase) transform,
  ) {
    return switch (target) {
      NounPhraseTarget.agent =>
        state.agent == null
            ? state
            : _copy(state, agent: transform(state.agent!)),
      NounPhraseTarget.object =>
        state.object == null
            ? state
            : _copy(state, object: transform(state.object!)),
      NounPhraseTarget.objectComplement =>
        state.objectComplement == null
            ? state
            : _copy(
                state,
                objectComplement: transform(state.objectComplement!),
              ),
      NounPhraseTarget.recipient =>
        state.recipient == null
            ? state
            : _copy(state, recipient: transform(state.recipient!)),
      NounPhraseTarget.addressee =>
        state.addressee == null
            ? state
            : _copy(state, addressee: transform(state.addressee!)),
      NounPhraseTarget.companion =>
        state.companion == null
            ? state
            : _copy(state, companion: transform(state.companion!)),
      NounPhraseTarget.destination =>
        state.destination == null
            ? state
            : _copy(state, destination: transform(state.destination!)),
      NounPhraseTarget.topic =>
        state.topic == null
            ? state
            : _copy(state, topic: transform(state.topic!)),
      NounPhraseTarget.beneficiary =>
        state.beneficiary == null
            ? state
            : _copy(state, beneficiary: transform(state.beneficiary!)),
      NounPhraseTarget.complement =>
        state.complement == null
            ? state
            : _copy(state, complement: transform(state.complement!)),
    };
  }
}

const _unchanged = Object();

NounPhrase? _activeAgentAfterVoiceChange(NounPhrase? agent) {
  return switch (agent?.text.toLowerCase()) {
    'me' => i,
    'him' => he,
    'her' => she,
    'us' => we,
    'them' => they,
    _ => agent,
  };
}

const _singularDeterminers = {'a', 'an', 'this', 'that', 'each', 'every'};

const _pluralDeterminers = {'these', 'those', 'all', 'many'};

bool _startsWithVowelLetter(String text) {
  if (text.isEmpty) {
    return false;
  }

  return 'aeiou'.contains(text[0].toLowerCase());
}
