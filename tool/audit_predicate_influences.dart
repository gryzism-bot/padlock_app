import 'package:padlock_app/data/predicate/predicate_route_audit.dart';

void main() {
  final rows = predicateRouteAuditRows();
  final buckets = predicateRouteAuditBuckets(rows);

  for (final bucket in [
    'no authored paths',
    'one route',
    'thin',
    'recipient-gated right action',
    'connected',
  ]) {
    final bucketRows = buckets[bucket] ?? const [];
    print('$bucket (${bucketRows.length})');
    for (final row in bucketRows) {
      print(
        '- ${row.infinitive}: '
        '${row.visibleOutputCount} output(s), '
        '${row.routeCount} route(s) '
        '[${row.pathSummaries.join('; ')}]',
      );
    }
    print('');
  }

  final essentialRows = essentialPredicateRouteAuditRows();
  final thinEssentialRows = essentialRows.where((row) => row.isThin).toList();
  print('thin essential verbs (${thinEssentialRows.length})');
  for (final row in thinEssentialRows) {
    print('- ${row.infinitive}: ${row.kindLabels.join(', ')}');
  }
}
