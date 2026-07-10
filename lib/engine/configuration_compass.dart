import 'package:padlock_app/data/modals.dart' as modal_data;
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/adjectives/emotions.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/phrase/place_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/time_phrase.dart';
import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/grammar/voice.dart';

enum ConfigurationCompassSlot {
  action,
  object,
  recipient,
  complement,
  adjectiveComplement,
  voice,
  passiveFocus,
  modal,
  placePhrase,
  timePhrase,
}

class ConfigurationSuggestion {
  final ConfigurationCompassSlot slot;
  final ConfigurationMove move;
  final String label;
  final int priority;
  final ConfigurationState preview;

  const ConfigurationSuggestion({
    required this.slot,
    required this.move,
    required this.label,
    required this.priority,
    required this.preview,
  });
}

class ConfigurationCompass {
  final ConfigurationEngine lock;
  final List<Verb> actions;
  final List<NounPhrase> objects;
  final List<NounPhrase> recipients;
  final List<NounPhrase> complements;
  final List<Adjective> adjectiveComplements;
  final List<Modal> modals;
  final List<PlacePhrase> places;
  final List<TimePhrase> times;

  ConfigurationCompass({
    this.lock = const ConfigurationEngine(),
    List<Verb>? actions,
    List<NounPhrase>? objects,
    List<NounPhrase>? recipients,
    List<NounPhrase>? complements,
    List<Adjective>? adjectiveComplements,
    List<Modal>? modals,
    List<PlacePhrase>? places,
    List<TimePhrase>? times,
  }) : actions = actions ?? verbs,
       objects = objects ?? _defaultObjects,
       recipients = recipients ?? _defaultRecipients,
       complements = complements ?? _defaultComplements,
       adjectiveComplements = adjectiveComplements ?? emotionsAdjectives,
       modals = modals ?? _coreModals,
       places = places ?? placePhrases,
       times = times ?? timePhrases;

  List<ConfigurationSuggestion> suggestionsFor(
    ConfigurationState state,
    ConfigurationCompassSlot slot, {
    int limit = 3,
  }) {
    final suggestions = <ConfigurationSuggestion>[];

    for (final candidate in _candidatesFor(state, slot)) {
      final preview = lock.applyMove(state, candidate.move);
      if (_wasBlocked(preview)) {
        continue;
      }

      suggestions.add(
        ConfigurationSuggestion(
          slot: slot,
          move: candidate.move,
          label: candidate.label,
          priority: candidate.priority,
          preview: preview,
        ),
      );
    }

    suggestions.sort((left, right) {
      final priority = right.priority.compareTo(left.priority);
      if (priority != 0) {
        return priority;
      }

      return left.label.compareTo(right.label);
    });

    if (limit <= 0 || suggestions.length <= limit) {
      return suggestions;
    }

    return suggestions.take(limit).toList();
  }

  Iterable<_CompassCandidate> _candidatesFor(
    ConfigurationState state,
    ConfigurationCompassSlot slot,
  ) {
    final sentence = state.sentenceState;

    return switch (slot) {
      ConfigurationCompassSlot.action =>
        actions
            .where((action) => action != sentence.action)
            .map(
              (action) => _CompassCandidate(
                SetAction(action),
                action.infinitive,
                _actionPriority(sentence.action, action),
              ),
            ),
      ConfigurationCompassSlot.object => objects.map(
        (object) => _CompassCandidate(
          SetObject(object),
          object.text,
          object == sentence.object ? 0 : 100,
        ),
      ),
      ConfigurationCompassSlot.recipient => recipients.map(
        (recipient) => _CompassCandidate(
          SetRecipient(recipient),
          recipient.text,
          recipient == sentence.recipient ? 0 : 100,
        ),
      ),
      ConfigurationCompassSlot.complement => sentence.action == be
          ? complements.map(
              (complement) => _CompassCandidate(
                SetComplement(complement),
                complement.text,
                complement == sentence.complement ? 0 : 100,
              ),
            )
          : const <_CompassCandidate>[],
      ConfigurationCompassSlot.adjectiveComplement => sentence.action == be
          ? adjectiveComplements.map(
              (adjective) => _CompassCandidate(
                SetAdjectiveComplement(adjective),
                adjective.text,
                adjective == sentence.adjectiveComplement ? 0 : 100,
              ),
            )
          : const <_CompassCandidate>[],
      ConfigurationCompassSlot.voice =>
        Voice.values
            .where((voice) => voice != sentence.voice)
            .map(
              (voice) => _CompassCandidate(
                SetVoice(voice),
                voice.name,
                voice == Voice.passive ? 100 : 90,
              ),
            ),
      ConfigurationCompassSlot.passiveFocus =>
        PassiveFocus.values
            .where((focus) => focus != sentence.passiveFocus)
            .map(
              (focus) => _CompassCandidate(
                SetPassiveFocus(focus),
                focus.name,
                focus == PassiveFocus.object ? 100 : 90,
              ),
            ),
      ConfigurationCompassSlot.modal =>
        modals
            .where((modal) => modal != sentence.modal)
            .map(
              (modal) => _CompassCandidate(
                SetModal(modal),
                modal.isNone ? 'no modal' : modal.text,
                _modalPriority(sentence.tense, sentence.modal, modal),
              ),
            ),
      ConfigurationCompassSlot.placePhrase => places.map(
        (place) => _CompassCandidate(
          SetPlacePhrase(place),
          place.noun,
          place == sentence.placePhrase
              ? 0
              : _placePriority(sentence.action, place),
        ),
      ),
      ConfigurationCompassSlot.timePhrase => times.map(
        (time) => _CompassCandidate(
          SetTimePhrase(time),
          time.text,
          _timePriority(sentence.tense, sentence.aspect, time),
        ),
      ),
    };
  }
}

class _CompassCandidate {
  final ConfigurationMove move;
  final String label;
  final int priority;

  const _CompassCandidate(this.move, this.label, this.priority);
}

int _actionPriority(Verb current, Verb candidate) {
  if (current == be && candidate == work) {
    return 120;
  }

  if (current == be) {
    return 100;
  }

  if (candidate == be) {
    return 105;
  }

  if (candidate.takesRecipient) {
    return 95;
  }

  if (candidate.takesObject) {
    return 90;
  }

  if (current.takesObject && !candidate.takesObject) {
    return 60;
  }

  return 80;
}

int _modalPriority(Tense tense, Modal current, Modal modal) {
  if (modal.isNone) {
    return current.isNone ? 60 : 120;
  }

  if (tense == Tense.future) {
    return modal == modal_data.will ? 100 : 50;
  }

  return modal == modal_data.will ? 50 : 100;
}

int _placePriority(Verb action, PlacePhrase place) {
  final noun = place.noun;

  if (action.usesDestinationPlace) {
    return switch (noun) {
      'home' => 130,
      'school' || 'work' || 'university' || 'office' => 120,
      'park' || 'shop' || 'restaurant' || 'hospital' => 110,
      _ => 90,
    };
  }

  return switch (noun) {
    'school' => 110,
    'home' => 105,
    'work' || 'office' => 100,
    'park' => 95,
    _ => 80,
  };
}

int _timePriority(Tense tense, Aspect aspect, TimePhrase time) {
  final text = time.text;

  if (tense == Tense.past) {
    return text == 'yesterday' ? 110 : 70;
  }

  if (tense == Tense.future) {
    return switch (text) {
      'tomorrow' => 110,
      'soon' => 100,
      'later' => 90,
      _ => 60,
    };
  }

  if (aspect == Aspect.continuous && text == 'now') {
    return 110;
  }

  return switch (text) {
    'today' => 105,
    'now' => 100,
    'this morning' || 'this afternoon' || 'this evening' => 90,
    _ => 70,
  };
}

bool _wasBlocked(ConfigurationState state) {
  return state.messages.any(
    (message) => message.kind == ConfigurationMessageKind.blocked,
  );
}

final _defaultObjects = [
  book.toNounPhrase(Number.singular),
  bridge.toNounPhrase(Number.singular),
  house.toNounPhrase(Number.singular),
  car.toNounPhrase(Number.singular),
  computer.toNounPhrase(Number.singular),
  phone.toNounPhrase(Number.singular),
];

final _defaultRecipients = [
  mary.toNounPhrase(Number.singular),
  john.toNounPhrase(Number.singular),
  teacher.toNounPhrase(Number.singular),
  student.toNounPhrase(Number.singular),
  friend.toNounPhrase(Number.singular),
];

final _defaultComplements = [
  doctor.toNounPhrase(Number.singular, determiner: aDeterminer),
  doctor.toNounPhrase(Number.plural),
  teacher.toNounPhrase(Number.singular, determiner: aDeterminer),
  teacher.toNounPhrase(Number.plural),
  student.toNounPhrase(Number.singular, determiner: aDeterminer),
  student.toNounPhrase(Number.plural),
  engineer.toNounPhrase(Number.singular, determiner: anDeterminer),
  engineer.toNounPhrase(Number.plural),
];

final _coreModals = [
  modal_data.noModal,
  modal_data.can,
  modal_data.could,
  modal_data.may,
  modal_data.might,
  modal_data.must,
  modal_data.shall,
  modal_data.should,
  modal_data.will,
  modal_data.would,
];
