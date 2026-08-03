import 'package:padlock_app/data/predicate/predicate_paths.dart';
import 'package:padlock_app/data/predicate/verb_influence.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';

class PredicateRouteAuditRow {
  final Verb verb;
  final List<PredicatePath> paths;
  final PredicatePathMigrationDecision? migration;

  const PredicateRouteAuditRow({
    required this.verb,
    required this.paths,
    required this.migration,
  });

  String get infinitive => verb.infinitive;

  int get routeCount => paths.length;

  int get visibleOutputCount => predicateDoorwayOutputCount(verb);

  bool get hasAuthoredPaths => paths.isNotEmpty;

  bool get isNoAuthoredPath => paths.isEmpty;

  bool get isOneRoute => paths.length == 1;

  bool get isThin => visibleOutputCount <= 2;

  bool get hasRecipientGatedRightAction {
    return paths.any(
      (path) =>
          path.kind == PredicatePathKind.toRightAction &&
          path.requiresRecipient,
    );
  }

  Set<PredicatePathKind> get kinds => {for (final path in paths) path.kind};

  List<String> get kindLabels =>
      [for (final kind in kinds) predicatePathKindAuditLabel(kind)]..sort();

  List<String> get pathSummaries =>
      [for (final path in paths) predicatePathAuditSummary(path)]..sort();

  String get bucket {
    if (isNoAuthoredPath) {
      return 'no authored paths';
    }
    if (isOneRoute) {
      return 'one route';
    }
    if (hasRecipientGatedRightAction) {
      return 'recipient-gated right action';
    }
    if (isThin) {
      return 'thin';
    }
    return 'connected';
  }
}

List<PredicateRouteAuditRow> predicateRouteAuditRows({
  Iterable<Verb>? verbsToAudit,
}) {
  final seen = <String>{};
  final rows = [
    for (final verb in verbsToAudit ?? verbs)
      if (seen.add(verb.infinitive))
        PredicateRouteAuditRow(
          verb: verb,
          paths: predicatePathsFor(verb),
          migration: predicatePathMigrationFor(verb),
        ),
  ];

  rows.sort(_comparePredicateRouteAuditRows);
  return rows;
}

List<PredicateRouteAuditRow> essentialPredicateRouteAuditRows() {
  return predicateRouteAuditRows(verbsToAudit: essentialVerbs);
}

Map<String, List<PredicateRouteAuditRow>> predicateRouteAuditBuckets(
  Iterable<PredicateRouteAuditRow> rows,
) {
  final buckets = <String, List<PredicateRouteAuditRow>>{};
  for (final row in rows) {
    buckets.putIfAbsent(row.bucket, () => []).add(row);
  }
  return buckets;
}

String predicatePathKindAuditLabel(PredicatePathKind kind) {
  return switch (kind) {
    PredicatePathKind.directObject => 'object',
    PredicatePathKind.toRightAction => 'to + verb',
    PredicatePathKind.toRecipient => 'recipient',
    PredicatePathKind.toAddressee => 'to someone',
    PredicatePathKind.withCompanion => 'with someone',
    PredicatePathKind.withInstrument => 'with tool',
    PredicatePathKind.toDestination => 'to destination',
    PredicatePathKind.aboutTopic => 'about',
    PredicatePathKind.ofTopic => 'of',
    PredicatePathKind.onTopic => 'on topic',
    PredicatePathKind.overTopic => 'over topic',
    PredicatePathKind.withTopic => 'with topic',
    PredicatePathKind.forBeneficiary => 'for someone',
    PredicatePathKind.fromSource => 'from someone',
    PredicatePathKind.forPurpose => 'for purpose',
    PredicatePathKind.atLocation => 'at place',
    PredicatePathKind.inLocation => 'in place',
    PredicatePathKind.onLocation => 'on place',
    PredicatePathKind.fromLocation => 'from place',
    PredicatePathKind.placePhrase => 'place phrase',
    PredicatePathKind.timePhrase => 'time phrase',
    PredicatePathKind.frequencyPhrase => 'frequency phrase',
    PredicatePathKind.mannerPhrase => 'manner phrase',
    PredicatePathKind.rightParticle => 'right particle',
  };
}

String predicatePathAuditSummary(PredicatePath path) {
  final count = _pathChoiceCount(path);
  final gates = [
    if (path.requiresObject) 'needs object',
    if (path.requiresRecipient) 'needs recipient',
  ];
  final suffix = gates.isEmpty ? '' : ' (${gates.join(', ')})';

  return '${predicatePathKindAuditLabel(path.kind)}: $count$suffix';
}

int _pathChoiceCount(PredicatePath path) {
  return switch (path.kind) {
    PredicatePathKind.toRightAction => path.verbs.length,
    PredicatePathKind.atLocation ||
    PredicatePathKind.inLocation ||
    PredicatePathKind.onLocation ||
    PredicatePathKind.fromLocation ||
    PredicatePathKind.placePhrase => path.places.length,
    PredicatePathKind.timePhrase => path.times.length,
    PredicatePathKind.frequencyPhrase => path.frequencies.length,
    PredicatePathKind.mannerPhrase ||
    PredicatePathKind.rightParticle => path.manners.length,
    _ => path.nouns.length,
  };
}

int _comparePredicateRouteAuditRows(
  PredicateRouteAuditRow left,
  PredicateRouteAuditRow right,
) {
  final bucketComparison = _bucketRank(left).compareTo(_bucketRank(right));
  if (bucketComparison != 0) {
    return bucketComparison;
  }

  final outputComparison = left.visibleOutputCount.compareTo(
    right.visibleOutputCount,
  );
  if (outputComparison != 0) {
    return outputComparison;
  }

  final routeComparison = left.routeCount.compareTo(right.routeCount);
  if (routeComparison != 0) {
    return routeComparison;
  }

  return left.infinitive.compareTo(right.infinitive);
}

int _bucketRank(PredicateRouteAuditRow row) {
  return switch (row.bucket) {
    'no authored paths' => 0,
    'one route' => 1,
    'thin' => 2,
    'recipient-gated right action' => 3,
    'connected' => 4,
    _ => 5,
  };
}
