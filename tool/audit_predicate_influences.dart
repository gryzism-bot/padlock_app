import 'package:padlock_app/data/predicate/verb_influence.dart';
import 'package:padlock_app/data/verbs/essential.dart';

void main() {
  final rows =
      [
        for (final verb in verbs)
          (
            verb: verb.infinitive,
            influences: predicateInfluencesFor(verb),
            outputs: predicateDoorwayOutputCount(verb),
          ),
      ]..sort((left, right) {
        final outputComparison = left.outputs.compareTo(right.outputs);
        if (outputComparison != 0) {
          return outputComparison;
        }

        return left.verb.compareTo(right.verb);
      });

  final silent = [
    for (final row in rows)
      if (row.influences.isEmpty) row.verb,
  ];

  if (silent.isEmpty) {
    print('All verbs have at least one predicate influence.');
  } else {
    print('Verbs with no predicate influence (${silent.length}):');
    for (final verb in silent) {
      print('- $verb');
    }
  }

  final shallow = rows.where((row) => row.outputs <= 2).toList();
  print('');
  print('Thin verbs with one or two visible outputs (${shallow.length}):');
  for (final row in shallow) {
    final labels = row.influences
        .map((influence) => influence.label)
        .join(', ');
    print('- ${row.verb}: ${row.outputs} output(s) [$labels]');
  }
}
