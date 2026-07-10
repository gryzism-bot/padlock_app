import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/phrase/frequency_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/manner_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/place_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/time_phrase.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

enum ConfigurationMode { guided }

enum ConfigurationMessageKind { blocked, info }

class ConfigurationMessage {
  final ConfigurationMessageKind kind;
  final String text;

  const ConfigurationMessage(this.text, {required this.kind});

  const ConfigurationMessage.blocked(String text)
    : this(text, kind: ConfigurationMessageKind.blocked);

  const ConfigurationMessage.info(String text)
    : this(text, kind: ConfigurationMessageKind.info);
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
        agent: he,
        action: work,
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
      SetAction(:final action) => action == be
          ? _copy(
              state,
              action: action,
              object: null,
              recipient: null,
              voice: Voice.active,
              passiveFocus: null,
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
      ),
      SetVoice(:final voice) => _copy(
        state,
        voice: voice,
        passiveFocus: voice == Voice.active ? null : state.passiveFocus,
      ),
      SetPassiveFocus(:final passiveFocus) => _copy(
        state,
        passiveFocus: passiveFocus,
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

    if (state.action.infinitive == 'be') {
      _validateLexicalBe(state, blockers);
    } else {
      _validatePredicateFrame(state, blockers);
    }

    _validateModalFrame(state, blockers);
    _validateImperativeFrame(state, blockers);

    return blockers;
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
    Object? recipient = _unchanged,
    Object? complement = _unchanged,
    Object? adjectiveComplement = _unchanged,
    Voice? voice,
    Object? passiveFocus = _unchanged,
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
      recipient: identical(recipient, _unchanged)
          ? state.recipient
          : recipient as NounPhrase?,
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
}

const _unchanged = Object();
