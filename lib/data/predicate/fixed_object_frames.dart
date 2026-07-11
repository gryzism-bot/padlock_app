import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart';
import 'package:padlock_app/data/verbs/essential.dart' show play;
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';

class FixedObjectVerbAlias {
  final Verb action;
  final NounPhrase object;

  const FixedObjectVerbAlias({required this.action, required this.object});
}

const fixedObjectFrameLabels = {
  'play': 'activity',
  'learn': 'subject',
  'study': 'subject',
  'speak': 'language',
};

const fixedObjectChoicesByVerb = {
  'play': [football, basketball, volleyball, tennis, golf],
  'learn': [english, grammar, math, history, science],
  'study': [english, grammar, math, history, science],
  'speak': [english, polish, spanish],
};

const flattenedFixedObjectVerbInfinitives = {
  'play football',
  'play basketball',
  'play volleyball',
  'play tennis',
  'play golf',
};

const fixedObjectVerbAliases = {
  'play football': FixedObjectVerbAlias(action: play, object: football),
  'play basketball': FixedObjectVerbAlias(action: play, object: basketball),
  'play volleyball': FixedObjectVerbAlias(action: play, object: volleyball),
  'play tennis': FixedObjectVerbAlias(action: play, object: tennis),
  'play golf': FixedObjectVerbAlias(action: play, object: golf),
};

bool hasFixedObjectFrame(Verb action) {
  return fixedObjectChoicesByVerb.containsKey(action.infinitive);
}

String? fixedObjectFrameLabel(Verb action) {
  return fixedObjectFrameLabels[action.infinitive];
}

List<NounPhrase> fixedObjectChoicesFor(Verb action) {
  return fixedObjectChoicesByVerb[action.infinitive] ?? const [];
}

bool fixedObjectFitsAction(NounPhrase object, Verb action) {
  return fixedObjectChoicesFor(
    action,
  ).any((choice) => choice.text.toLowerCase() == object.text.toLowerCase());
}

bool isFlattenedFixedObjectVerb(Verb action) {
  return flattenedFixedObjectVerbInfinitives.contains(action.infinitive);
}

FixedObjectVerbAlias? fixedObjectVerbAliasFor(Verb action) {
  return fixedObjectVerbAliases[action.infinitive];
}
