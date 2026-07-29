import 'package:padlock_app/data/predicate/verb_influence.dart';
import 'package:padlock_app/data/verbs/essential.dart';

void main() {
  final silent = [
    for (final verb in verbs)
      if (predicateInfluencesFor(verb).isEmpty) verb.infinitive,
  ]..sort();

  if (silent.isEmpty) {
    print('All verbs have at least one predicate influence.');
    return;
  }

  print('Verbs with no predicate influence (${silent.length}):');
  for (final verb in silent) {
    print('- $verb');
  }
}
