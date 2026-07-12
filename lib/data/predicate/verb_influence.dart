import 'dart:math';

import 'package:padlock_app/data/predicate/fixed_object_frames.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';

class PredicateInfluence {
  final String key;
  final String label;
  final String tooltip;
  final int rank;

  const PredicateInfluence({
    required this.key,
    required this.label,
    required this.tooltip,
    required this.rank,
  });
}

const _popularDoorwayBonusByVerb = {
  'be': 24,
  'give': 23,
  'get': 22,
  'go': 24,
  'play': 20,
  'learn': 19,
  'work': 16,
  'need': 15,
  'want': 14,
  'make': 13,
  'take': 12,
  'buy': 11,
  'see': 10,
  'speak': 9,
  'study': 8,
  'tell': 7,
  'teach': 6,
  'drive': 5,
  'have': 4,
  'do': 3,
  'say': 2,
  'think': 1,
};

List<PredicateInfluence> predicateInfluencesFor(Verb action) {
  final fixedLabel = fixedObjectFrameLabel(action);

  return [
    if (action.infinitive == 'be')
      PredicateInfluence(
        key: 'complement',
        label: 'complement',
        tooltip: '${action.infinitive} wakes complements',
        rank: 60,
      ),
    if (action.takesRecipient)
      PredicateInfluence(
        key: 'recipient',
        label: 'recipient',
        tooltip: '${action.infinitive} wakes recipient',
        rank: 50,
      ),
    if (action.takesAddressee)
      PredicateInfluence(
        key: 'addressee',
        label: 'addressee',
        tooltip: '${action.infinitive} wakes addressee',
        rank: 48,
      ),
    if (fixedLabel != null)
      PredicateInfluence(
        key: fixedLabel,
        label: fixedLabel,
        tooltip: '${action.infinitive} wakes $fixedLabel',
        rank: 45,
      ),
    if (action.usesDestinationPlace)
      PredicateInfluence(
        key: 'destination',
        label: 'destination',
        tooltip: '${action.infinitive} wakes destination place',
        rank: 40,
      ),
    if (action.takesObject && fixedLabel == null)
      PredicateInfluence(
        key: 'object',
        label: 'object',
        tooltip: '${action.infinitive} wakes object',
        rank: 30,
      ),
  ];
}

int predicateInfluenceRank(Verb action) {
  return predicateInfluencesFor(
    action,
  ).fold(0, (rank, influence) => max(rank, influence.rank));
}

int predicateDoorwayPriority(Verb action) {
  final influenceRank = predicateInfluenceRank(action);
  final popularityBonus = _popularDoorwayBonusByVerb[action.infinitive] ?? 0;

  if (influenceRank == 0 && popularityBonus == 0) {
    return 80;
  }

  if (influenceRank == 0) {
    return 110 + popularityBonus;
  }

  return 90 + influenceRank + popularityBonus;
}
