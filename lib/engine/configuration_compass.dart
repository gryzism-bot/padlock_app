import 'package:padlock_app/data/modals.dart' as modal_data;
import 'package:padlock_app/data/predicate/fixed_object_frames.dart';
import 'package:padlock_app/data/predicate/right_action_frames.dart';
import 'package:padlock_app/data/predicate/verb_influence.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/adjectives/colors.dart';
import 'package:padlock_app/data/subjects/adjectives/emotions.dart';
import 'package:padlock_app/data/subjects/adjectives/quality.dart';
import 'package:padlock_app/data/subjects/adjectives/size.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/object_pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/animals.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/phrase/place_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/time_phrase.dart';
import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/grammar/subject/determiner.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

enum ConfigurationCompassSlot {
  action,
  object,
  objectDeterminer,
  objectAdjective,
  recipient,
  recipientDeterminer,
  recipientAdjective,
  addressee,
  addresseeDeterminer,
  addresseeAdjective,
  companion,
  companionDeterminer,
  companionAdjective,
  destination,
  destinationDeterminer,
  destinationAdjective,
  rightAction,
  complement,
  complementDeterminer,
  complementAdjective,
  adjectiveComplement,
  voice,
  passiveFocus,
  passiveAgent,
  passiveAgentNoun,
  modal,
  placePhrase,
  timePhrase,
}

class ConfigurationSuggestion {
  final ConfigurationCompassSlot slot;
  final ConfigurationMove move;
  final String label;
  final int priority;
  final bool isSelected;
  final ConfigurationState preview;

  const ConfigurationSuggestion({
    required this.slot,
    required this.move,
    required this.label,
    required this.priority,
    this.isSelected = false,
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
  final List<Adjective> nounAdjectives;
  final List<Determiner> determiners;
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
    List<Adjective>? nounAdjectives,
    List<Determiner>? determiners,
    List<Modal>? modals,
    List<PlacePhrase>? places,
    List<TimePhrase>? times,
  }) : actions = actions ?? _defaultActions,
       objects = objects ?? _defaultObjects,
       recipients = recipients ?? _defaultRecipients,
       complements = complements ?? _defaultComplements,
       adjectiveComplements = adjectiveComplements ?? emotionsAdjectives,
       nounAdjectives = nounAdjectives ?? _defaultNounAdjectives,
       determiners = determiners ?? allDeterminers,
       modals = modals ?? _coreModals,
       places = places ?? placePhrases,
       times = times ?? timePhrases;

  List<ConfigurationSuggestion> suggestionsFor(
    ConfigurationState state,
    ConfigurationCompassSlot slot, {
    int limit = 3,
  }) {
    final candidates = _candidatesFor(state, slot).toList()
      ..sort((left, right) {
        final priority = right.priority.compareTo(left.priority);
        if (priority != 0) {
          return priority;
        }

        return left.label.compareTo(right.label);
      });
    final validSuggestions = <ConfigurationSuggestion>[];

    for (final candidate in candidates) {
      final preview = lock.applyMove(state, candidate.move);
      if (_wasBlocked(preview)) {
        continue;
      }

      validSuggestions.add(
        ConfigurationSuggestion(
          slot: slot,
          move: candidate.move,
          label: candidate.label,
          priority: candidate.priority,
          isSelected: candidate.isSelected,
          preview: preview,
        ),
      );
    }

    if (limit <= 0 || validSuggestions.length <= limit) {
      return validSuggestions;
    }

    final visible = validSuggestions.take(limit).toList();
    for (final selected in validSuggestions.where(
      (suggestion) => suggestion.isSelected,
    )) {
      if (!visible.contains(selected)) {
        visible.add(selected);
      }
    }

    return visible;
  }

  Iterable<_CompassCandidate> _candidatesFor(
    ConfigurationState state,
    ConfigurationCompassSlot slot,
  ) {
    final sentence = state.sentenceState;

    return switch (slot) {
      ConfigurationCompassSlot.action =>
        actions
            .where(
              (action) =>
                  action == sentence.action ||
                  (sentence.rightAction != null
                      ? rightActionFitsAction(sentence.rightAction!, action)
                      : _objectFitsAction(sentence.object, action) ||
                            _canClearObjectIntoAction(sentence.object, action)),
            )
            .map(
              (action) => _CompassCandidate(
                SetAction(action),
                action.infinitive,
                _actionPriority(sentence.action, action),
                isSelected: action == sentence.action,
              ),
            ),
      ConfigurationCompassSlot.object => [
        if (sentence.object != null)
          const _CompassCandidate(SetObject(null), 'no object', 120),
        ..._objectChoicesForState(sentence, objects)
            .where(
              (object) =>
                  _sameNounChoice(object, sentence.object) ||
                  _objectFitsAction(object, sentence.action),
            )
            .map((object) {
              final isSelected = _sameNounChoice(object, sentence.object);
              final nextObject = isSelected
                  ? sentence.object
                  : _carryCompatibleNounPhrase(
                      from: sentence.object,
                      to: object,
                    );
              return _CompassCandidate(
                SetObject(nextObject),
                nextObject == null ? object.text : _nounPhraseLabel(nextObject),
                100,
                isSelected: isSelected,
              );
            }),
      ],
      ConfigurationCompassSlot.objectDeterminer => _determinerCandidates(
        _objectCanTakeModifiers(sentence) ? sentence.object : null,
        NounPhraseTarget.object,
      ),
      ConfigurationCompassSlot.objectAdjective => _adjectiveCandidates(
        _objectCanTakeModifiers(sentence) ? sentence.object : null,
        NounPhraseTarget.object,
      ),
      ConfigurationCompassSlot.recipient => [
        if (sentence.recipient != null)
          const _CompassCandidate(SetRecipient(null), 'no recipient', 120),
        ...recipients.map((recipient) {
          final isSelected = _sameNounChoice(recipient, sentence.recipient);
          final nextRecipient = isSelected
              ? sentence.recipient
              : _carryCompatibleNounPhrase(
                  from: sentence.recipient,
                  to: recipient,
                );
          return _CompassCandidate(
            SetRecipient(nextRecipient),
            nextRecipient == null
                ? recipient.text
                : _nounPhraseLabel(nextRecipient),
            100,
            isSelected: isSelected,
          );
        }),
      ],
      ConfigurationCompassSlot.recipientDeterminer => _determinerCandidates(
        sentence.recipient,
        NounPhraseTarget.recipient,
      ),
      ConfigurationCompassSlot.recipientAdjective => _adjectiveCandidates(
        sentence.recipient,
        NounPhraseTarget.recipient,
      ),
      ConfigurationCompassSlot.addressee => [
        if (sentence.addressee != null)
          const _CompassCandidate(SetAddressee(null), 'no addressee', 120),
        ...recipients.map((addressee) {
          final isSelected = _sameNounChoice(addressee, sentence.addressee);
          final nextAddressee = isSelected
              ? sentence.addressee
              : _carryCompatibleNounPhrase(
                  from: sentence.addressee,
                  to: addressee,
                );
          return _CompassCandidate(
            SetAddressee(nextAddressee),
            nextAddressee == null
                ? addressee.text
                : _nounPhraseLabel(nextAddressee),
            100,
            isSelected: isSelected,
          );
        }),
      ],
      ConfigurationCompassSlot.addresseeDeterminer => _determinerCandidates(
        sentence.addressee,
        NounPhraseTarget.addressee,
      ),
      ConfigurationCompassSlot.addresseeAdjective => _adjectiveCandidates(
        sentence.addressee,
        NounPhraseTarget.addressee,
      ),
      ConfigurationCompassSlot.companion => [
        if (sentence.companion != null)
          const _CompassCandidate(SetCompanion(null), 'no companion', 120),
        ...recipients.map((companion) {
          final isSelected = _sameNounChoice(companion, sentence.companion);
          final nextCompanion = isSelected
              ? sentence.companion
              : _carryCompatibleNounPhrase(
                  from: sentence.companion,
                  to: companion,
                );
          return _CompassCandidate(
            SetCompanion(nextCompanion),
            nextCompanion == null
                ? companion.text
                : _nounPhraseLabel(nextCompanion),
            100,
            isSelected: isSelected,
          );
        }),
      ],
      ConfigurationCompassSlot.companionDeterminer => _determinerCandidates(
        sentence.companion,
        NounPhraseTarget.companion,
      ),
      ConfigurationCompassSlot.companionAdjective => _adjectiveCandidates(
        sentence.companion,
        NounPhraseTarget.companion,
      ),
      ConfigurationCompassSlot.destination => [
        if (sentence.destination != null)
          const _CompassCandidate(SetDestination(null), 'no destination', 120),
        ...recipients.map((destination) {
          final isSelected = _sameNounChoice(destination, sentence.destination);
          final nextDestination = isSelected
              ? sentence.destination
              : _carryCompatibleNounPhrase(
                  from: sentence.destination,
                  to: destination,
                );
          return _CompassCandidate(
            SetDestination(nextDestination),
            nextDestination == null
                ? destination.text
                : _nounPhraseLabel(nextDestination),
            100,
            isSelected: isSelected,
          );
        }),
      ],
      ConfigurationCompassSlot.destinationDeterminer => _determinerCandidates(
        sentence.destination,
        NounPhraseTarget.destination,
      ),
      ConfigurationCompassSlot.destinationAdjective => _adjectiveCandidates(
        sentence.destination,
        NounPhraseTarget.destination,
      ),
      ConfigurationCompassSlot.rightAction => [
        if (sentence.rightAction != null)
          const _CompassCandidate(SetRightAction(null), 'no right action', 120),
        ...rightActionChoicesFor(sentence.action).map(
          (rightAction) => _CompassCandidate(
            SetRightAction(rightAction),
            rightAction.infinitive,
            rightAction == sentence.rightAction ? 110 : 100,
            isSelected: rightAction == sentence.rightAction,
          ),
        ),
      ],
      ConfigurationCompassSlot.complement =>
        sentence.action == be
            ? complements.map((complement) {
                final isSelected = _sameNounChoice(
                  complement,
                  sentence.complement,
                );
                final nextComplement = isSelected
                    ? sentence.complement
                    : _carryCompatibleNounPhrase(
                        from: sentence.complement,
                        to: complement,
                      );
                return _CompassCandidate(
                  SetComplement(nextComplement),
                  nextComplement == null
                      ? complement.text
                      : _nounPhraseLabel(nextComplement),
                  100,
                  isSelected: isSelected,
                );
              })
            : const <_CompassCandidate>[],
      ConfigurationCompassSlot.complementDeterminer => _determinerCandidates(
        sentence.complement,
        NounPhraseTarget.complement,
      ),
      ConfigurationCompassSlot.complementAdjective => _adjectiveCandidates(
        sentence.complement,
        NounPhraseTarget.complement,
      ),
      ConfigurationCompassSlot.adjectiveComplement =>
        sentence.action == be
            ? adjectiveComplements.map(
                (adjective) => _CompassCandidate(
                  SetAdjectiveComplement(adjective),
                  adjective.text,
                  100,
                  isSelected: adjective == sentence.adjectiveComplement,
                ),
              )
            : const <_CompassCandidate>[],
      ConfigurationCompassSlot.voice => Voice.values.map(
        (voice) => _CompassCandidate(
          SetVoice(voice),
          voice.name,
          voice == Voice.passive ? 100 : 90,
          isSelected: voice == sentence.voice,
        ),
      ),
      ConfigurationCompassSlot.passiveFocus =>
        sentence.voice == Voice.passive
            ? [
                _CompassCandidate(
                  const SetPassiveFocus(null),
                  'no passive focus',
                  sentence.passiveFocus == null ? 110 : 105,
                  isSelected: sentence.passiveFocus == null,
                ),
                ...PassiveFocus.values.map(
                  (focus) => _CompassCandidate(
                    SetPassiveFocus(focus),
                    focus.name,
                    focus == PassiveFocus.object ? 100 : 90,
                    isSelected: focus == sentence.passiveFocus,
                  ),
                ),
              ]
            : const <_CompassCandidate>[],
      ConfigurationCompassSlot.passiveAgent =>
        sentence.voice == Voice.passive && sentence.agent != null
            ? [
                _CompassCandidate(
                  const SetPassiveAgentVisibility(true),
                  'show by-agent',
                  sentence.showPassiveAgent ? 110 : 100,
                  isSelected: sentence.showPassiveAgent,
                ),
                _CompassCandidate(
                  const SetPassiveAgentVisibility(false),
                  'hide by-agent',
                  sentence.showPassiveAgent ? 100 : 110,
                  isSelected: !sentence.showPassiveAgent,
                ),
              ]
            : const <_CompassCandidate>[],
      ConfigurationCompassSlot.passiveAgentNoun =>
        sentence.voice == Voice.passive
            ? recipients.map((agent) {
                final isSelected = _sameNounChoice(agent, sentence.agent);
                final nextAgent = isSelected
                    ? sentence.agent
                    : _carryCompatibleNounPhrase(
                        from: sentence.agent,
                        to: agent,
                      );
                return _CompassCandidate(
                  SetAgent(nextAgent),
                  nextAgent == null ? agent.text : _nounPhraseLabel(nextAgent),
                  isSelected ? 110 : 100,
                  isSelected: isSelected,
                );
              })
            : const <_CompassCandidate>[],
      ConfigurationCompassSlot.modal =>
        modals
            .where(
              (modal) =>
                  sentence.tense != Tense.future || modal != modal_data.will,
            )
            .map(
              (modal) => _CompassCandidate(
                modal == modal_data.will
                    ? const SetTense(Tense.future)
                    : SetModal(modal),
                modal.isNone ? 'no modal' : modal.text,
                _modalPriority(sentence.tense, sentence.modal, modal),
                isSelected: modal == sentence.modal,
              ),
            ),
      ConfigurationCompassSlot.placePhrase => [
        _CompassCandidate(
          const SetPlacePhrase(null),
          'no place',
          sentence.placePhrase == null ? 130 : 120,
          isSelected: sentence.placePhrase == null,
        ),
        ...places.map(
          (place) => _CompassCandidate(
            SetPlacePhrase(place),
            place.noun,
            _placePriority(sentence.action, place),
            isSelected: place == sentence.placePhrase,
          ),
        ),
      ],
      ConfigurationCompassSlot.timePhrase => [
        _CompassCandidate(
          const SetTimePhrase(null),
          'no time',
          sentence.timePhrase == null ? 130 : 120,
          isSelected: sentence.timePhrase == null,
        ),
        ...times.map(
          (time) => _CompassCandidate(
            SetTimePhrase(time),
            time.text,
            _timePriority(sentence.tense, sentence.aspect, time),
            isSelected: time == sentence.timePhrase,
          ),
        ),
      ],
    };
  }

  Iterable<_CompassCandidate> _determinerCandidates(
    NounPhrase? phrase,
    NounPhraseTarget target,
  ) {
    if (phrase == null || !phrase.canTakeModifiers) {
      return const <_CompassCandidate>[];
    }

    return [
      _CompassCandidate(
        SetNounPhraseDeterminer(target, null),
        'no determiner',
        115,
        isSelected: phrase.determiner == null,
      ),
      ...determiners.map(
        (determiner) => _CompassCandidate(
          SetNounPhraseDeterminer(target, determiner),
          determiner.text,
          _determinerPriority(phrase, determiner),
          isSelected: determiner == phrase.determiner,
        ),
      ),
    ];
  }

  Iterable<_CompassCandidate> _adjectiveCandidates(
    NounPhrase? phrase,
    NounPhraseTarget target,
  ) {
    if (phrase == null || !phrase.canTakeModifiers) {
      return const <_CompassCandidate>[];
    }

    final current = phrase.adjectiveList;

    return [
      _CompassCandidate(
        SetNounPhraseAdjectives(target, const []),
        'no adjective',
        115,
        isSelected: current.isEmpty,
      ),
      ...current.map(
        (adjective) => _CompassCandidate(
          SetNounPhraseAdjectives(target, current),
          adjective.text,
          100,
          isSelected: true,
        ),
      ),
      ...nounAdjectives
          .where((adjective) => !current.contains(adjective))
          .map(
            (adjective) => _CompassCandidate(
              SetNounPhraseAdjectives(target, [...current, adjective]),
              adjective.text,
              100,
            ),
          ),
    ];
  }
}

bool _objectCanTakeModifiers(SentenceState sentence) {
  final object = sentence.object;
  if (object == null || !object.canTakeModifiers) {
    return false;
  }

  return !hasFixedObjectFrame(sentence.action) ||
      fixedObjectFrameAllowsModifiers(sentence.action);
}

class _CompassCandidate {
  final ConfigurationMove move;
  final String label;
  final int priority;
  final bool isSelected;

  const _CompassCandidate(
    this.move,
    this.label,
    this.priority, {
    this.isSelected = false,
  });
}

int _actionPriority(Verb current, Verb candidate) {
  if (current == be && candidate == work) {
    return 120;
  }

  if (current == be) {
    return 100;
  }

  final priority = predicateDoorwayPriority(candidate);

  if (current.takesObject &&
      !candidate.takesObject &&
      predicateInfluenceRank(candidate) == 0 &&
      priority == 80) {
    return 60;
  }

  return priority;
}

int _modalPriority(Tense tense, Modal current, Modal modal) {
  if (modal.isNone) {
    return current.isNone ? 60 : 120;
  }

  if (tense == Tense.future) {
    return 90;
  }

  return modal == modal_data.will ? 90 : 100;
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

int _determinerPriority(NounPhrase phrase, Determiner determiner) {
  final text = determiner.text;

  if (phrase.isPlural) {
    return switch (text) {
      'the' || 'some' || 'all' || 'many' => 110,
      'these' || 'those' => 105,
      _ => 80,
    };
  }

  return switch (text) {
    'a' || 'an' || 'the' => 110,
    'this' || 'that' => 105,
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

bool _sameNounChoice(NounPhrase candidate, NounPhrase? current) {
  return current != null &&
      candidate.text == current.text &&
      candidate.person == current.person &&
      candidate.number == current.number;
}

bool _objectFitsAction(NounPhrase? object, Verb action) {
  if (object == null) {
    return true;
  }

  if (hasFixedObjectFrame(action)) {
    return fixedObjectFitsAction(object, action);
  }

  final noun = object.text.toLowerCase();

  return switch (action.infinitive) {
    'drive' => _vehicleObjects.contains(noun),
    'ride' => _rideableObjects.contains(noun),
    _ => true,
  };
}

bool _canClearObjectIntoAction(NounPhrase? object, Verb action) {
  return object != null && canClearObjectForFixedSubjectFrame(object, action);
}

List<Verb> get _defaultActions =>
    verbs.where((action) => !isFlattenedFixedObjectVerb(action)).toList();

List<NounPhrase> _objectChoicesFor(Verb action, List<NounPhrase> fallback) {
  final fixedChoices = fixedObjectChoicesFor(action);
  return fixedChoices.isEmpty ? fallback : fixedChoices;
}

List<NounPhrase> _objectChoicesForState(
  SentenceState sentence,
  List<NounPhrase> fallback,
) {
  final choices = [..._objectChoicesFor(sentence.action, fallback)];
  final current = sentence.object;

  if (current != null &&
      !choices.any((choice) => _sameNounChoice(choice, current))) {
    choices.add(current);
  }

  return choices;
}

String _nounPhraseLabel(NounPhrase phrase) {
  return [
    if (phrase.determiner != null) phrase.determiner!.text,
    ...phrase.adjectiveList.map((adjective) => adjective.text),
    phrase.text,
  ].join(' ');
}

NounPhrase _carryCompatibleNounPhrase({
  required NounPhrase? from,
  required NounPhrase to,
}) {
  if (from == null) {
    return to;
  }

  final adjectives = from.adjectiveList;

  return to.copyWith(
    determiner: _compatibleDeterminer(from.determiner, to, adjectives),
    adjective: adjectives.isEmpty ? null : adjectives.first,
    adjectives: adjectives,
  );
}

Determiner? _compatibleDeterminer(
  Determiner? determiner,
  NounPhrase phrase,
  List<Adjective> adjectives,
) {
  if (determiner == null) {
    return null;
  }

  final text = determiner.text;
  if (phrase.isPlural &&
      const {'a', 'an', 'this', 'that', 'each', 'every'}.contains(text)) {
    return null;
  }

  if (!phrase.isPlural && const {'these', 'those', 'many'}.contains(text)) {
    return null;
  }

  final firstSpokenWord = adjectives.isEmpty
      ? phrase.text
      : adjectives.first.text;
  if (text == 'a' && _startsWithVowelLetter(firstSpokenWord)) {
    return anDeterminer;
  }

  if (text == 'an' && !_startsWithVowelLetter(firstSpokenWord)) {
    return aDeterminer;
  }

  return determiner;
}

bool _startsWithVowelLetter(String text) {
  if (text.isEmpty) {
    return false;
  }

  return 'aeiou'.contains(text[0].toLowerCase());
}

const _vehicleObjects = {'car', 'cars', 'bus', 'buses', 'train', 'trains'};

const _rideableObjects = {
  'bicycle',
  'bicycles',
  'horse',
  'horses',
  ..._vehicleObjects,
};

final _defaultObjects = [
  book.toNounPhrase(Number.singular),
  book.toNounPhrase(Number.plural),
  bridge.toNounPhrase(Number.singular),
  bridge.toNounPhrase(Number.plural),
  house.toNounPhrase(Number.singular),
  house.toNounPhrase(Number.plural),
  car.toNounPhrase(Number.singular),
  car.toNounPhrase(Number.plural),
  computer.toNounPhrase(Number.singular),
  computer.toNounPhrase(Number.plural),
  phone.toNounPhrase(Number.singular),
  phone.toNounPhrase(Number.plural),
  letter.toNounPhrase(Number.singular),
  letter.toNounPhrase(Number.plural),
  gift.toNounPhrase(Number.singular),
  gift.toNounPhrase(Number.plural),
  key.toNounPhrase(Number.singular),
  key.toNounPhrase(Number.plural),
  door.toNounPhrase(Number.singular),
  door.toNounPhrase(Number.plural),
  table.toNounPhrase(Number.singular),
  table.toNounPhrase(Number.plural),
  chair.toNounPhrase(Number.singular),
  chair.toNounPhrase(Number.plural),
  window.toNounPhrase(Number.singular),
  window.toNounPhrase(Number.plural),
  bottle.toNounPhrase(Number.singular),
  bottle.toNounPhrase(Number.plural),
  ball.toNounPhrase(Number.singular),
  ball.toNounPhrase(Number.plural),
  plant.toNounPhrase(Number.singular),
  plant.toNounPhrase(Number.plural),
  food.toNounPhrase(Number.singular),
  food.toNounPhrase(Number.plural),
  apple.toNounPhrase(Number.singular),
  apple.toNounPhrase(Number.plural),
  bread.toNounPhrase(Number.singular),
  bread.toNounPhrase(Number.plural),
  sandwich.toNounPhrase(Number.singular),
  sandwich.toNounPhrase(Number.plural),
  cheese.toNounPhrase(Number.singular),
  cheese.toNounPhrase(Number.plural),
  meat.toNounPhrase(Number.singular),
  meat.toNounPhrase(Number.plural),
  soup.toNounPhrase(Number.singular),
  soup.toNounPhrase(Number.plural),
  potato.toNounPhrase(Number.singular),
  potato.toNounPhrase(Number.plural),
  carrot.toNounPhrase(Number.singular),
  carrot.toNounPhrase(Number.plural),
  onion.toNounPhrase(Number.singular),
  onion.toNounPhrase(Number.plural),
  cat.toNounPhrase(Number.singular),
  cat.toNounPhrase(Number.plural),
  dog.toNounPhrase(Number.singular),
  dog.toNounPhrase(Number.plural),
];

final _defaultRecipients = [
  him,
  her,
  them,
  me,
  us,
  youObject,
  mary.toNounPhrase(Number.singular),
  john.toNounPhrase(Number.singular),
  someone,
  anyone,
  nobody,
  everyone,
  teacher.toNounPhrase(Number.singular),
  student.toNounPhrase(Number.singular),
  person.toNounPhrase(Number.singular),
  person.toNounPhrase(Number.plural),
  friend.toNounPhrase(Number.singular),
  friend.toNounPhrase(Number.singular, determiner: aDeterminer),
  friend.toNounPhrase(Number.singular, determiner: myDeterminer),
  friend.toNounPhrase(Number.singular, determiner: ourDeterminer),
  friend.toNounPhrase(Number.plural),
  enemy.toNounPhrase(Number.singular, determiner: thatDeterminer),
  enemy.toNounPhrase(Number.plural),
  cat.toNounPhrase(Number.singular, determiner: aDeterminer),
  cat.toNounPhrase(Number.plural),
  dog.toNounPhrase(Number.singular, determiner: aDeterminer),
  dog.toNounPhrase(Number.plural),
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
  person.toNounPhrase(Number.singular, determiner: aDeterminer),
  person.toNounPhrase(Number.plural),
  friend.toNounPhrase(Number.singular, determiner: aDeterminer),
  friend.toNounPhrase(Number.singular, determiner: myDeterminer),
  friend.toNounPhrase(Number.singular, determiner: ourDeterminer),
  friend.toNounPhrase(Number.plural),
  enemy.toNounPhrase(Number.singular, determiner: thatDeterminer),
  enemy.toNounPhrase(Number.plural),
  someone,
  anyone,
  nobody,
  everyone,
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

final _defaultNounAdjectives = [
  ...sizeAdjectives,
  ...colorAdjectives,
  ...qualityAdjectives,
  ...emotionsAdjectives,
];
