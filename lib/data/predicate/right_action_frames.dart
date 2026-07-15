import 'package:padlock_app/data/predicate/predicate_paths.dart';
import 'package:padlock_app/data/verbs/communication.dart' show speak;
import 'package:padlock_app/data/verbs/essential.dart'
    show go, learn, sleep, watch, work;
import 'package:padlock_app/data/verbs/movement.dart' show swim;
import 'package:padlock_app/models/grammar/verb/verb.dart';

final Map<String, List<Verb>> rightActionChoicesByVerb = {
  'want': [go, work, learn, swim, speak, watch, sleep],
  'need': [go, work, learn, speak, sleep],
  'like': [go, work, learn, swim, speak, watch, sleep],
  'love': [go, work, learn, swim, speak, watch],
  'learn': [speak, swim, work],
};

bool hasRightActionFrame(Verb action) {
  return predicateVerbChoicesFor(
        action,
        PredicatePathKind.toRightAction,
      ).isNotEmpty ||
      rightActionChoicesByVerb.containsKey(action.infinitive);
}

List<Verb> rightActionChoicesFor(Verb action) {
  final authoredChoices = predicateVerbChoicesFor(
    action,
    PredicatePathKind.toRightAction,
  );
  if (authoredChoices.isNotEmpty) {
    return authoredChoices;
  }

  return rightActionChoicesByVerb[action.infinitive] ?? const [];
}

bool rightActionFitsAction(Verb rightAction, Verb action) {
  return rightActionChoicesFor(action).contains(rightAction);
}
