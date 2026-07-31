import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/predicate/fixed_object_frames.dart';
import 'package:padlock_app/data/predicate/predicate_paths.dart';
import 'package:padlock_app/data/predicate/right_action_frames.dart';
import 'package:padlock_app/data/phrases/phrase_classification.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/engine/configuration_laws.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/participant_surface.dart';
import 'package:padlock_app/models/grammar/phrase/frequency_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/manner_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/phrase/place_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/time_phrase.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/grammar/subject/determiner.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/topic_preposition.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

part 'configuration_law_runner.dart';

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
  instrument,
  destination,
  topic,
  beneficiary,
  source,
  purpose,
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

class SetInstrument extends ConfigurationMove {
  final NounPhrase? instrument;

  const SetInstrument(this.instrument);
}

class SetDestination extends ConfigurationMove {
  final NounPhrase? destination;

  const SetDestination(this.destination);
}

class SetTopic extends ConfigurationMove {
  final NounPhrase? topic;
  final TopicPreposition topicPreposition;

  const SetTopic(this.topic, {this.topicPreposition = TopicPreposition.about});
}

class SetBeneficiary extends ConfigurationMove {
  final NounPhrase? beneficiary;

  const SetBeneficiary(this.beneficiary);
}

class SetSource extends ConfigurationMove {
  final NounPhrase? source;

  const SetSource(this.source);
}

class SetPurpose extends ConfigurationMove {
  final NounPhrase? purpose;

  const SetPurpose(this.purpose);
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
  final PlaceMeaning? placeMeaning;

  const SetPlacePhrase(this.placePhrase, {this.placeMeaning});
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
        instrument: null,
        destination: null,
        topic: null,
        beneficiary: null,
        source: null,
        purpose: null,
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
      recipient: state.recipient,
    );
    final tailOwner = rightAction ?? action;
    final object = _objectAfterActionChange(state.object, tailOwner);
    final recipient =
        action.takesRecipient && (object != null || hasRightActionFrame(action))
        ? state.recipient
        : null;
    final addressee = _surfaceAfterActionChange(
      state.addressee,
      tailOwner,
      addresseeSurface,
    );
    final companion = _surfaceAfterActionChange(
      state.companion,
      tailOwner,
      companionSurface,
    );
    final instrument = _surfaceAfterActionChange(
      state.instrument,
      tailOwner,
      instrumentSurface,
    );
    final destination = _surfaceAfterActionChange(
      state.destination,
      tailOwner,
      destinationSurface,
    );
    final nextDestination =
        destination != null &&
            object == null &&
            predicatePathRequiresObject(
              tailOwner,
              PredicatePathKind.toDestination,
            )
        ? null
        : destination;
    final topic = _surfaceAfterActionChange(
      state.topic,
      tailOwner,
      topicSurface,
      topicPreposition: state.topicPreposition,
    );
    final beneficiary = _surfaceAfterActionChange(
      state.beneficiary,
      tailOwner,
      beneficiarySurface,
    );
    final source = _surfaceAfterActionChange(
      state.source,
      tailOwner,
      sourceSurface,
    );
    final purpose = _surfaceAfterActionChange(
      state.purpose,
      tailOwner,
      purposeSurface,
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
      instrument: instrument,
      destination: nextDestination,
      topic: topic,
      topicPreposition: topic == null
          ? TopicPreposition.about
          : state.topicPreposition,
      beneficiary: beneficiary,
      source: source,
      purpose: purpose,
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
        destination:
            object == null &&
                predicatePathRequiresObject(
                  state.rightAction ?? state.action,
                  PredicatePathKind.toDestination,
                )
            ? null
            : state.destination,
      ),
      SetRecipient(:final recipient) => _copy(state, recipient: recipient),
      SetAddressee(:final addressee) => _copy(state, addressee: addressee),
      SetCompanion(:final companion) => _copy(state, companion: companion),
      SetInstrument(:final instrument) => _copy(state, instrument: instrument),
      SetDestination(:final destination) => _copy(
        state,
        destination: destination,
      ),
      SetTopic(:final topic, :final topicPreposition) => _copy(
        state,
        topic: topic,
        topicPreposition: topic == null
            ? TopicPreposition.about
            : topicPreposition,
      ),
      SetBeneficiary(:final beneficiary) => _copy(
        state,
        beneficiary: beneficiary,
      ),
      SetSource(:final source) => _copy(state, source: source),
      SetPurpose(:final purpose) => _copy(state, purpose: purpose),
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
        instrument: null,
        destination: null,
        topic: null,
        beneficiary: null,
        source: null,
        purpose: null,
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
        instrument: null,
        destination: null,
        topic: null,
        beneficiary: null,
        source: null,
        purpose: null,
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
      SetPlacePhrase(:final placePhrase, :final placeMeaning) => _copy(
        state,
        placePhrase: placePhrase,
        placeMeaning: placePhrase == null
            ? null
            : placeMeaning ?? state.placeMeaning,
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
    return _configurationLawRunner.validate(this, state);
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
    if (previous.instrument != null && current.instrument == null) {
      fields.add('instrument');
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
    if (previous.source != null && current.source == null) {
      fields.add('source');
    }
    if (previous.purpose != null && current.purpose == null) {
      fields.add('purpose');
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

  NounPhrase? _surfaceAfterActionChange(
    NounPhrase? noun,
    Verb action,
    PrepositionalParticipantSurface surface, {
    TopicPreposition topicPreposition = TopicPreposition.about,
  }) {
    if (noun == null) {
      return null;
    }

    if (!surface.isSupportedBy(action)) {
      return null;
    }

    if (!_predicatePathAcceptsNoun(
      action,
      _predicatePathKindForSurface(surface, topicPreposition: topicPreposition),
      noun,
    )) {
      return null;
    }

    return noun;
  }

  PredicatePathKind _predicatePathKindForSurface(
    PrepositionalParticipantSurface surface, {
    TopicPreposition topicPreposition = TopicPreposition.about,
  }) {
    return switch (surface.kind) {
      PrepositionalParticipantKind.addressee => PredicatePathKind.toAddressee,
      PrepositionalParticipantKind.companion => PredicatePathKind.withCompanion,
      PrepositionalParticipantKind.instrument =>
        PredicatePathKind.withInstrument,
      PrepositionalParticipantKind.destination =>
        PredicatePathKind.toDestination,
      PrepositionalParticipantKind.topic => switch (topicPreposition) {
        TopicPreposition.about => PredicatePathKind.aboutTopic,
        TopicPreposition.of => PredicatePathKind.ofTopic,
        TopicPreposition.on => PredicatePathKind.onTopic,
        TopicPreposition.withPrep => PredicatePathKind.withTopic,
      },
      PrepositionalParticipantKind.beneficiary =>
        PredicatePathKind.forBeneficiary,
      PrepositionalParticipantKind.source => PredicatePathKind.fromSource,
      PrepositionalParticipantKind.purpose => PredicatePathKind.forPurpose,
    };
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

    final choices = predicateAuthoredPlaceChoicesFor(action);
    if (choices.isEmpty) {
      return false;
    }

    return choices.any((choice) => _samePlaceRoute(choice, phrase));
  }

  bool _samePlaceRoute(PlacePhrase left, PlacePhrase right) {
    return _placeRouteKey(left) == _placeRouteKey(right);
  }

  String _placeRouteKey(PlacePhrase phrase) {
    return [
      phrase.render(PlaceMeaning.location),
      phrase.render(PlaceMeaning.destination),
      phrase.render(PlaceMeaning.source),
    ].join('|').toLowerCase();
  }

  bool _predicatePathAcceptsTime(Verb action, TimePhrase phrase) {
    if (isClauseLevelModifier(phrase)) {
      return true;
    }

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
    if (isClauseLevelModifier(phrase)) {
      return true;
    }

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
      return false;
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

  Verb? _rightActionAfterActionChange(
    Verb? rightAction,
    Verb action, {
    NounPhrase? recipient,
  }) {
    if (rightAction == null) {
      return null;
    }

    if (!rightActionFitsAction(rightAction, action)) {
      return null;
    }

    if (predicatePathRequiresRecipient(
          action,
          PredicatePathKind.toRightAction,
        ) &&
        recipient == null) {
      return null;
    }

    return rightAction;
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
    Object? instrument = _unchanged,
    Object? destination = _unchanged,
    Object? topic = _unchanged,
    TopicPreposition? topicPreposition,
    Object? beneficiary = _unchanged,
    Object? source = _unchanged,
    Object? purpose = _unchanged,
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
      instrument: identical(instrument, _unchanged)
          ? state.instrument
          : instrument as NounPhrase?,
      destination: identical(destination, _unchanged)
          ? state.destination
          : destination as NounPhrase?,
      topic: identical(topic, _unchanged) ? state.topic : topic as NounPhrase?,
      topicPreposition: topicPreposition ?? state.topicPreposition,
      beneficiary: identical(beneficiary, _unchanged)
          ? state.beneficiary
          : beneficiary as NounPhrase?,
      source: identical(source, _unchanged)
          ? state.source
          : source as NounPhrase?,
      purpose: identical(purpose, _unchanged)
          ? state.purpose
          : purpose as NounPhrase?,
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
      NounPhraseTarget.instrument =>
        state.instrument == null
            ? state
            : _copy(state, instrument: transform(state.instrument!)),
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
      NounPhraseTarget.source =>
        state.source == null
            ? state
            : _copy(state, source: transform(state.source!)),
      NounPhraseTarget.purpose =>
        state.purpose == null
            ? state
            : _copy(state, purpose: transform(state.purpose!)),
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
