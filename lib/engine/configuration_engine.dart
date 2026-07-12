import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/predicate/fixed_object_frames.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/phrase/frequency_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/manner_phrase.dart';
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

enum ConfigurationMode { guided }

enum NounPhraseTarget { agent, object, recipient, complement }

enum ConfigurationMessageKind { blocked, info }

enum ConfigurationMessageSource { lock, compass, ui }

class ConfigurationMessage {
  final ConfigurationMessageKind kind;
  final ConfigurationMessageSource source;
  final String text;

  const ConfigurationMessage(
    this.text, {
    required this.kind,
    this.source = ConfigurationMessageSource.lock,
  });

  const ConfigurationMessage.blocked(
    String text, {
    ConfigurationMessageSource source = ConfigurationMessageSource.lock,
  }) : this(text, kind: ConfigurationMessageKind.blocked, source: source);

  const ConfigurationMessage.info(
    String text, {
    ConfigurationMessageSource source = ConfigurationMessageSource.lock,
  }) : this(text, kind: ConfigurationMessageKind.info, source: source);

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

class SetComplement extends ConfigurationMove {
  final NounPhrase? complement;

  const SetComplement(this.complement);
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

  ConfigurationState applyMove(
    ConfigurationState current,
    ConfigurationMove move,
  ) {
    final candidate = _applyMove(current.sentenceState, move);
    final blockers = _validate(candidate);

    if (mode == ConfigurationMode.guided && blockers.isNotEmpty) {
      return current.copyWith(messages: blockers);
    }

    return ConfigurationState(
      sentenceState: candidate,
      messages: _collectMessages(current.sentenceState, candidate),
    );
  }

  SentenceState _applyMove(SentenceState state, ConfigurationMove move) {
    return switch (move) {
      SetAgent(:final agent) => _copy(state, agent: agent),
      SetAction(:final action) =>
        action == be
            ? _copy(
                state,
                action: action,
                object: null,
                recipient: null,
                voice: Voice.active,
                passiveFocus: null,
                showPassiveAgent: true,
              )
            : _copy(
                state,
                action: action,
                complement: null,
                adjectiveComplement: null,
              ),
      SetObject(:final object) => _copy(state, object: object),
      SetRecipient(:final recipient) => _copy(state, recipient: recipient),
      SetComplement(:final complement) => _copy(
        state,
        complement: complement,
        adjectiveComplement: complement == null
            ? state.adjectiveComplement
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
      SetLexicalBeComplement(:final complement) => _copy(
        state,
        action: be,
        object: null,
        recipient: null,
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
        complement: null,
        adjectiveComplement: adjectiveComplement,
        voice: Voice.active,
        passiveFocus: null,
        showPassiveAgent: true,
      ),
      SetVoice(:final voice) => _copy(
        state,
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
      SetTense(:final tense) => _copy(state, tense: tense),
      SetAspect(:final aspect) => _copy(state, aspect: aspect),
      SetModal(:final modal) => _copy(state, modal: modal),
      SetPolarity(:final polarity) => _copy(state, polarity: polarity),
      SetSentenceForm(:final sentenceForm) => _copy(
        state,
        sentenceForm: sentenceForm,
      ),
      SetTimePhrase(:final timePhrase) => _copy(state, timePhrase: timePhrase),
      SetPlacePhrase(:final placePhrase) => _copy(
        state,
        placePhrase: placePhrase,
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
    _validateNounPhrase('Complement', state.complement, blockers);

    if (state.action.infinitive == 'be') {
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
    final determiner = phrase?.determiner;
    if (phrase == null || determiner == null) {
      return;
    }

    if (_singularDeterminers.contains(determiner.text) && phrase.isPlural) {
      blockers.add(
        ConfigurationMessage.blocked(
          '$label determiner "${determiner.text}" requires a singular noun.',
        ),
      );
    }

    if (_pluralDeterminers.contains(determiner.text) && !phrase.isPlural) {
      blockers.add(
        ConfigurationMessage.blocked(
          '$label determiner "${determiner.text}" requires a plural noun.',
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
        ),
      );
    }

    if (determiner.text == 'an' && !_startsWithVowelLetter(firstSpokenWord)) {
      blockers.add(
        ConfigurationMessage.blocked(
          '$label determiner "an" requires a vowel sound.',
        ),
      );
    }
  }

  void _validateLexicalBe(
    SentenceState state,
    List<ConfigurationMessage> blockers,
  ) {
    if (state.agent == null) {
      blockers.add(
        const ConfigurationMessage.blocked('Lexical be requires an agent.'),
      );
    }

    if (state.voice != Voice.active) {
      blockers.add(
        const ConfigurationMessage.blocked('Lexical be is active-only.'),
      );
    }

    if (state.agent != null &&
        state.complement != null &&
        state.agent!.isPlural != state.complement!.isPlural) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Lexical be noun complement must match agent number.',
        ),
      );
    }

    if (state.object != null) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Lexical be does not take an object.',
        ),
      );
    }

    if (state.objectComplement != null ||
        state.objectAdjectiveComplement != null) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Lexical be does not take an object complement.',
        ),
      );
    }

    if (state.recipient != null) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Lexical be does not take a recipient.',
        ),
      );
    }

    if (state.passiveFocus != null) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Lexical be does not take passive focus.',
        ),
      );
    }

    if (!state.showPassiveAgent) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Lexical be does not take passive agent visibility.',
        ),
      );
    }
  }

  void _validatePredicateFrame(
    SentenceState state,
    List<ConfigurationMessage> blockers,
  ) {
    if (state.complement != null || state.adjectiveComplement != null) {
      blockers.add(
        ConfigurationMessage.blocked(
          '${state.action.infinitive} does not take a complement.',
        ),
      );
    }

    if (state.objectComplement != null ||
        state.objectAdjectiveComplement != null) {
      if (!state.action.takesObjectComplement) {
        blockers.add(
          ConfigurationMessage.blocked(
            '${state.action.infinitive} does not take an object complement.',
          ),
        );
      }

      if (state.object == null) {
        blockers.add(
          const ConfigurationMessage.blocked(
            'Object complements require an object.',
          ),
        );
      }
    }

    if (hasFixedObjectFrame(state.action) && state.object != null) {
      final label = fixedObjectFrameLabel(state.action) ?? 'fixed object';
      if (!fixedObjectFitsAction(state.object!, state.action)) {
        blockers.add(
          ConfigurationMessage.blocked(
            '${state.action.infinitive} only takes fixed $label objects.',
          ),
        );
      }

      if (state.object!.determiner != null ||
          state.object!.adjectiveList.isNotEmpty) {
        blockers.add(
          ConfigurationMessage.blocked(
            '${state.action.infinitive} fixed $label objects stay bare.',
          ),
        );
      }
    }

    switch (state.voice) {
      case Voice.active:
        if (state.agent == null) {
          blockers.add(
            const ConfigurationMessage.blocked(
              'Active voice requires an agent.',
            ),
          );
        }

        if (state.passiveFocus != null) {
          blockers.add(
            const ConfigurationMessage.blocked(
              'Passive focus belongs to passive voice.',
            ),
          );
        }

        if (!state.showPassiveAgent) {
          blockers.add(
            const ConfigurationMessage.blocked(
              'Passive agent visibility belongs to passive voice.',
            ),
          );
        }

        if (state.recipient != null && !state.action.takesRecipient) {
          blockers.add(
            ConfigurationMessage.blocked(
              '${state.action.infinitive} does not take a recipient.',
            ),
          );
        }

        if (state.object != null && !state.action.takesObject) {
          blockers.add(
            ConfigurationMessage.blocked(
              '${state.action.infinitive} does not take an object.',
            ),
          );
        }

        if (state.recipient != null && state.object == null) {
          blockers.add(
            const ConfigurationMessage.blocked(
              'Recipient frames require an object.',
            ),
          );
        }

        break;

      case Voice.passive:
        if (!state.action.takesObject) {
          blockers.add(
            ConfigurationMessage.blocked(
              '${state.action.infinitive} cannot be passive in this frame.',
            ),
          );
        }

        final focus = state.passiveFocus ?? PassiveFocus.object;
        switch (focus) {
          case PassiveFocus.object:
            if (state.object == null) {
              blockers.add(
                const ConfigurationMessage.blocked(
                  'Passive object focus requires an object.',
                ),
              );
            }
            break;
          case PassiveFocus.recipient:
            if (!state.action.takesRecipient) {
              blockers.add(
                ConfigurationMessage.blocked(
                  '${state.action.infinitive} has no recipient focus.',
                ),
              );
            }
            if (state.recipient == null) {
              blockers.add(
                const ConfigurationMessage.blocked(
                  'Passive recipient focus requires a recipient.',
                ),
              );
            }
            if (state.object == null) {
              blockers.add(
                const ConfigurationMessage.blocked(
                  'Passive recipient focus still requires an object.',
                ),
              );
            }
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

    if (state.sentenceForm == SentenceForm.imperative) {
      blockers.add(
        const ConfigurationMessage.blocked('Imperatives cannot take a modal.'),
      );
    }

    if (state.modal == will && state.tense != Tense.future) {
      blockers.add(
        const ConfigurationMessage.blocked(
          'Will belongs to the future tense frame.',
        ),
      );
    }

    if (state.modal != will && state.tense == Tense.future) {
      blockers.add(
        ConfigurationMessage.blocked(
          '${state.modal.text} belongs to the present modal frame.',
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

    if (state.tense != Tense.present || state.aspect != Aspect.simple) {
      blockers.add(
        const ConfigurationMessage.blocked('Imperatives use present simple.'),
      );
    }

    if (state.voice != Voice.active) {
      blockers.add(
        const ConfigurationMessage.blocked('Imperatives use active voice.'),
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
    }

    return messages;
  }

  SentenceState _copy(
    SentenceState state, {
    Object? agent = _unchanged,
    Verb? action,
    Object? object = _unchanged,
    Object? objectComplement = _unchanged,
    Object? objectAdjectiveComplement = _unchanged,
    Object? recipient = _unchanged,
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
      NounPhraseTarget.recipient =>
        state.recipient == null
            ? state
            : _copy(state, recipient: transform(state.recipient!)),
      NounPhraseTarget.complement =>
        state.complement == null
            ? state
            : _copy(state, complement: transform(state.complement!)),
    };
  }
}

const _unchanged = Object();

const _singularDeterminers = {'a', 'an', 'this', 'that', 'each', 'every'};

const _pluralDeterminers = {'these', 'those', 'many'};

bool _startsWithVowelLetter(String text) {
  if (text.isEmpty) {
    return false;
  }

  return 'aeiou'.contains(text[0].toLowerCase());
}
