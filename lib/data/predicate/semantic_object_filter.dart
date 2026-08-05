import 'package:padlock_app/data/predicate/fixed_object_frames.dart';
import 'package:padlock_app/data/predicate/predicate_paths.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/verb/right_particle.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';

List<NounPhrase> semanticDirectObjectChoicesFor(
  Verb action, {
  RightParticle? rightParticle,
}) {
  final authoredChoices = predicateObjectChoicesFor(
    action,
    rightParticle: rightParticle,
  );

  if (authoredChoices.isNotEmpty) {
    return authoredChoices;
  }

  return fixedObjectChoicesFor(action);
}

bool semanticDirectObjectFitsAction(
  NounPhrase object,
  Verb action, {
  RightParticle? rightParticle,
  bool allowUnowned = true,
}) {
  final choices = semanticDirectObjectChoicesFor(
    action,
    rightParticle: rightParticle,
  );

  if (choices.isEmpty) {
    return allowUnowned;
  }

  return choices.any(
    (choice) =>
        choice.text.toLowerCase() == object.text.toLowerCase() &&
        choice.number == object.number,
  );
}
