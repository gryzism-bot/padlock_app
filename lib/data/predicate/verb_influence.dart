import 'dart:math';

import 'package:padlock_app/data/predicate/fixed_object_frames.dart';
import 'package:padlock_app/data/predicate/predicate_paths.dart';
import 'package:padlock_app/data/predicate/right_action_frames.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';

enum PredicateInfluenceSource { grammarFrame, predicateProperty }

class PredicateInfluence {
  final String key;
  final String label;
  final String tooltip;
  final int rank;
  final PredicateInfluenceSource source;

  const PredicateInfluence({
    required this.key,
    required this.label,
    required this.tooltip,
    required this.rank,
    required this.source,
  });
}

const _popularDoorwayBonusByVerb = {
  'be': 24,
  'give': 23,
  'get': 22,
  'go': 24,
  'play': 20,
  'learn': 19,
  'read': 18,
  'run': 18,
  'use': 17,
  'drive': 17,
  'watch': 16,
  'work': 16,
  'need': 15,
  'open': 15,
  'want': 14,
  'close': 14,
  'make': 13,
  'take': 12,
  'buy': 11,
  'see': 10,
  'speak': 9,
  'study': 8,
  'tell': 7,
  'teach': 6,
  'travel': 5,
  'have': 4,
  'do': 3,
  'say': 2,
  'think': 1,
};

const _visibleOutputCountByVerb = {'be': 2};

List<PredicateInfluence> predicateInfluencesFor(Verb action) {
  final fixedLabel = fixedObjectFrameLabel(action);
  final influences = <PredicateInfluence>[];
  final seenKeys = <String>{};

  void add(PredicateInfluence influence) {
    if (seenKeys.add(influence.key)) {
      influences.add(influence);
    }
  }

  for (final path in predicatePathsFor(action)) {
    add(_influenceForPath(action, path.kind, fixedLabel));
  }

  if (action.infinitive == 'be') {
    add(_predicateProperty(action, 'complement', 'complement', 60));
  }

  if (action.takesRecipient) {
    add(_grammarFrame(action, 'recipient', 'recipient', 50));
  }

  if (action.takesAddressee) {
    add(_predicateProperty(action, 'addressee', 'addressee', 48));
  }

  if (action.takesCompanion) {
    add(_predicateProperty(action, 'companion', 'companion', 46));
  }

  if (fixedLabel != null) {
    add(_predicateProperty(action, fixedLabel, fixedLabel, 45));
  }

  if (action.usesDestinationPlace) {
    add(_predicateProperty(action, 'destination', 'destination', 40));
  }

  if (hasRightActionFrame(action)) {
    add(_predicateProperty(action, 'right-action', 'right action', 39));
  }

  if (action.takesObjectComplement) {
    add(_grammarFrame(action, 'object-complement', 'object complement', 38));
  }

  if (action.takesObject && fixedLabel == null) {
    add(_grammarFrame(action, 'object', 'object', 30));
  }

  influences.sort((left, right) => right.rank.compareTo(left.rank));
  return influences;
}

PredicateInfluence _influenceForPath(
  Verb action,
  PredicatePathKind kind,
  String? fixedLabel,
) {
  return switch (kind) {
    PredicatePathKind.directObject =>
      fixedLabel == null
          ? _grammarFrame(action, 'object', 'object', 30)
          : _predicateProperty(action, fixedLabel, fixedLabel, 45),
    PredicatePathKind.toRightAction => _predicateProperty(
      action,
      'right-action',
      'right action',
      39,
    ),
    PredicatePathKind.toRecipient => _grammarFrame(
      action,
      'recipient',
      'recipient',
      50,
    ),
    PredicatePathKind.toAddressee => _predicateProperty(
      action,
      'addressee',
      'addressee',
      48,
    ),
    PredicatePathKind.withCompanion => _predicateProperty(
      action,
      'companion',
      'companion',
      46,
    ),
    PredicatePathKind.toDestination => _predicateProperty(
      action,
      'destination',
      'destination',
      40,
    ),
  };
}

PredicateInfluence _grammarFrame(
  Verb action,
  String key,
  String label,
  int rank,
) {
  return _influence(
    action,
    key,
    label,
    rank,
    PredicateInfluenceSource.grammarFrame,
  );
}

PredicateInfluence _predicateProperty(
  Verb action,
  String key,
  String label,
  int rank,
) {
  return _influence(
    action,
    key,
    label,
    rank,
    PredicateInfluenceSource.predicateProperty,
  );
}

PredicateInfluence _influence(
  Verb action,
  String key,
  String label,
  int rank,
  PredicateInfluenceSource source,
) {
  return PredicateInfluence(
    key: key,
    label: label,
    tooltip: '${action.infinitive} wakes $label',
    rank: rank,
    source: source,
  );
}

int predicateInfluenceRank(Verb action) {
  return predicateInfluencesFor(
    action,
  ).fold(0, (rank, influence) => max(rank, influence.rank));
}

int predicateDoorwayOutputCount(Verb action) {
  final influences = predicateInfluencesFor(action);
  if (influences.isEmpty) {
    return 0;
  }

  return _visibleOutputCountByVerb[action.infinitive] ?? influences.length;
}

int predicateDoorwayPriority(Verb action) {
  final influenceRank = predicateInfluenceRank(action);
  final popularityBonus = _popularDoorwayBonusByVerb[action.infinitive] ?? 0;
  final outputCount = predicateDoorwayOutputCount(action);

  if (outputCount == 0 && popularityBonus == 0) {
    return 80;
  }

  if (outputCount == 0) {
    return 110 + popularityBonus;
  }

  return 200 + (outputCount * 100) + influenceRank + popularityBonus;
}
