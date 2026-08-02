import 'package:padlock_app/data/predicate/predicate_route_audit.dart';
import 'package:padlock_app/data/verbs/essential.dart';

void main(List<String> args) {
  final rows = _rowsForArgs(args);
  final buckets = predicateRouteAuditBuckets(rows);

  if (args.contains('--non-essential')) {
    print('non-essential predicate route audit (${rows.length} verbs)');
    print('');
  } else if (args.contains('--essential')) {
    print('essential predicate route audit (${rows.length} verbs)');
    print('');
  }

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

  if (!args.contains('--non-essential')) {
    final essentialRows = essentialPredicateRouteAuditRows();
    final thinEssentialRows = essentialRows.where((row) => row.isThin).toList();
    print('thin essential verbs (${thinEssentialRows.length})');
    for (final row in thinEssentialRows) {
      print('- ${row.infinitive}: ${row.kindLabels.join(', ')}');
    }
  }
}

List<PredicateRouteAuditRow> _rowsForArgs(List<String> args) {
  final unknownArgs = args
      .where((arg) => arg != '--essential' && arg != '--non-essential')
      .toList();
  if (unknownArgs.isNotEmpty) {
    throw ArgumentError(
      'Unknown argument(s): ${unknownArgs.join(', ')}. '
      'Use --essential or --non-essential.',
    );
  }

  if (args.contains('--essential') && args.contains('--non-essential')) {
    throw ArgumentError('Use either --essential or --non-essential, not both.');
  }

  if (args.contains('--essential')) {
    return essentialPredicateRouteAuditRows();
  }

  if (args.contains('--non-essential')) {
    final essentialInfinitives = essentialVerbs
        .map((verb) => verb.infinitive)
        .toSet();
    return predicateRouteAuditRows(
      verbsToAudit: verbs.where(
        (verb) => !essentialInfinitives.contains(verb.infinitive),
      ),
    );
  }

  return predicateRouteAuditRows();
}
