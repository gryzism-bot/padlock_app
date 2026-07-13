import 'dart:math';

import 'package:padlock_app/data/predicate/fixed_object_frames.dart';
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

  return [
    if (action.infinitive == 'be')
      PredicateInfluence(
        key: 'complement',
        label: 'complement',
        tooltip: '${action.infinitive} wakes complements',
        rank: 60,
        source: PredicateInfluenceSource.predicateProperty,
      ),
    if (action.takesRecipient)
      PredicateInfluence(
        key: 'recipient',
        label: 'recipient',
        tooltip: '${action.infinitive} wakes recipient',
        rank: 50,
        source: PredicateInfluenceSource.grammarFrame,
      ),
    if (action.takesAddressee)
      PredicateInfluence(
        key: 'addressee',
        label: 'addressee',
        tooltip: '${action.infinitive} wakes addressee',
        rank: 48,
        source: PredicateInfluenceSource.predicateProperty,
      ),
    if (action.takesCompanion)
      PredicateInfluence(
        key: 'companion',
        label: 'companion',
        tooltip: '${action.infinitive} wakes companion',
        rank: 46,
        source: PredicateInfluenceSource.predicateProperty,
      ),
    if (fixedLabel != null)
      PredicateInfluence(
        key: fixedLabel,
        label: fixedLabel,
        tooltip: '${action.infinitive} wakes $fixedLabel',
        rank: 45,
        source: PredicateInfluenceSource.predicateProperty,
      ),
    if (action.usesDestinationPlace)
      PredicateInfluence(
        key: 'destination',
        label: 'destination',
        tooltip: '${action.infinitive} wakes destination',
        rank: 40,
        source: PredicateInfluenceSource.predicateProperty,
      ),
    if (hasRightActionFrame(action))
      PredicateInfluence(
        key: 'right-action',
        label: 'right action',
        tooltip: '${action.infinitive} wakes to-action',
        rank: 39,
        source: PredicateInfluenceSource.predicateProperty,
      ),
    if (action.takesObjectComplement)
      PredicateInfluence(
        key: 'object-complement',
        label: 'object complement',
        tooltip: '${action.infinitive} wakes object complement',
        rank: 38,
        source: PredicateInfluenceSource.grammarFrame,
      ),
    if (action.takesObject && fixedLabel == null)
      PredicateInfluence(
        key: 'object',
        label: 'object',
        tooltip: '${action.infinitive} wakes object',
        rank: 30,
        source: PredicateInfluenceSource.grammarFrame,
      ),
  ];
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
