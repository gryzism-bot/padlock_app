import 'package:padlock_app/data/predicate/predicate_paths.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/topic_preposition.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';

ConfigurationMove firstMoveForPredicatePath(PredicatePath path, {Verb? owner}) {
  return switch (path.kind) {
    PredicatePathKind.directObject => SetObject(_first(path.nouns, path)),
    PredicatePathKind.toRightAction => SetRightAction(_first(path.verbs, path)),
    PredicatePathKind.toRecipient => SetRecipient(_first(path.nouns, path)),
    PredicatePathKind.toAddressee => SetAddressee(_first(path.nouns, path)),
    PredicatePathKind.withCompanion => SetCompanion(_first(path.nouns, path)),
    PredicatePathKind.withInstrument => SetInstrument(_first(path.nouns, path)),
    PredicatePathKind.toDestination => SetDestination(_first(path.nouns, path)),
    PredicatePathKind.aboutTopic => SetTopic(
      _first(path.nouns, path),
      topicPreposition: TopicPreposition.about,
    ),
    PredicatePathKind.ofTopic => SetTopic(
      _first(path.nouns, path),
      topicPreposition: TopicPreposition.of,
    ),
    PredicatePathKind.onTopic => SetTopic(
      _first(path.nouns, path),
      topicPreposition: TopicPreposition.on,
    ),
    PredicatePathKind.withTopic => SetTopic(
      _first(path.nouns, path),
      topicPreposition: TopicPreposition.withPrep,
    ),
    PredicatePathKind.forBeneficiary => SetBeneficiary(
      _first(path.nouns, path),
    ),
    PredicatePathKind.fromSource => SetSource(_first(path.nouns, path)),
    PredicatePathKind.forPurpose => SetPurpose(_first(path.nouns, path)),
    PredicatePathKind.atLocation => SetPlacePhrase(
      _first(path.places, path),
      placeMeaning: PlaceMeaning.location,
    ),
    PredicatePathKind.inLocation => SetPlacePhrase(
      _first(path.places, path),
      placeMeaning: PlaceMeaning.location,
    ),
    PredicatePathKind.onLocation => SetPlacePhrase(
      _first(path.places, path),
      placeMeaning: PlaceMeaning.location,
    ),
    PredicatePathKind.fromLocation => SetPlacePhrase(
      _first(path.places, path),
      placeMeaning: PlaceMeaning.source,
    ),
    PredicatePathKind.placePhrase => SetPlacePhrase(
      _first(path.places, path),
      placeMeaning: owner?.usesDestinationPlace == true
          ? PlaceMeaning.destination
          : PlaceMeaning.location,
    ),
    PredicatePathKind.timePhrase => SetTimePhrase(_first(path.times, path)),
    PredicatePathKind.frequencyPhrase => SetFrequencyPhrase(
      _first(path.frequencies, path),
    ),
    PredicatePathKind.mannerPhrase => SetMannerPhrase(
      _first(path.manners, path),
    ),
  };
}

ConfigurationState compileFirstPredicatePathChoice(
  PredicateUnlocks unlocks,
  PredicatePath path, {
  ConfigurationEngine lock = const ConfigurationEngine(),
  ConfigurationState? from,
}) {
  var state = from ?? ConfigurationState.initial();
  state = lock.applyMove(state, SetAction(unlocks.verb));

  if (path.kind == PredicatePathKind.toRecipient || path.requiresObject) {
    final directObjectPath = _firstPathOfKind(
      unlocks.paths,
      PredicatePathKind.directObject,
    );
    if (directObjectPath != null) {
      state = lock.applyMove(
        state,
        firstMoveForPredicatePath(directObjectPath, owner: unlocks.verb),
      );
    }
  }

  if (path.requiresRecipient) {
    final recipientPath = _firstPathOfKind(
      unlocks.paths,
      PredicatePathKind.toRecipient,
    );
    if (recipientPath != null) {
      state = lock.applyMove(
        state,
        firstMoveForPredicatePath(recipientPath, owner: unlocks.verb),
      );
    }
  }

  return lock.applyMove(
    state,
    firstMoveForPredicatePath(path, owner: unlocks.verb),
  );
}

PredicatePath? _firstPathOfKind(
  List<PredicatePath> paths,
  PredicatePathKind kind,
) {
  for (final path in paths) {
    if (path.kind == kind) {
      return path;
    }
  }

  return null;
}

T _first<T>(List<T> choices, PredicatePath path) {
  if (choices.isEmpty) {
    throw StateError('Predicate path ${path.kind} has no choices to compile.');
  }

  return choices.first;
}
