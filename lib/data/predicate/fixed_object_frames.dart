import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart';
import 'package:padlock_app/data/subjects/third_person/object_categories.dart'
    as object_categories;
import 'package:padlock_app/data/verbs/essential.dart' show play;
import 'package:padlock_app/models/grammar/subject/noun.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
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
  'teach': 'subject',
  'speak': 'language',
  'read': 'text',
  'write': 'text',
  'use': 'tool',
  'watch': 'media',
  'drive': 'vehicle',
  'ride': 'vehicle',
  'open': 'openable',
  'close': 'openable',
};

const _modifierFriendlyFixedObjectFrames = {
  'text',
  'tool',
  'media',
  'vehicle',
  'openable',
};

final Map<String, List<NounPhrase>> fixedObjectChoicesByVerb = {
  'play': [football, basketball, volleyball, tennis, golf],
  'learn': [english, grammar, math, history, science],
  'study': [english, grammar, math, history, science],
  'teach': [english, grammar, math, history, science],
  'speak': [english, polish, spanish],
  'read': [
    for (final noun in object_categories.textObjectNouns) ..._nounForms(noun),
  ],
  'write': [
    for (final noun in object_categories.textObjectNouns) ..._nounForms(noun),
  ],
  'use': [
    for (final noun in object_categories.toolObjectNouns) ..._nounForms(noun),
  ],
  'watch': [
    for (final noun in object_categories.mediaObjectNouns) ..._nounForms(noun),
  ],
  'drive': [
    for (final noun in object_categories.drivableObjectNouns)
      ..._nounForms(noun),
  ],
  'ride': [
    for (final noun in object_categories.rideableObjectNouns)
      ..._nounForms(noun),
  ],
  'open': [
    for (final noun in object_categories.openableObjectNouns)
      ..._nounForms(noun),
  ],
  'close': [
    for (final noun in object_categories.openableObjectNouns)
      ..._nounForms(noun),
  ],
};

List<NounPhrase> _nounForms(Noun noun) {
  return [noun.toNounPhrase(Number.singular), noun.toNounPhrase(Number.plural)];
}

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

bool fixedObjectFrameAllowsModifiers(Verb action) {
  final label = fixedObjectFrameLabel(action);
  return label != null && _modifierFriendlyFixedObjectFrames.contains(label);
}

List<NounPhrase> fixedObjectChoicesFor(Verb action) {
  return fixedObjectChoicesByVerb[action.infinitive] ?? const [];
}

bool fixedObjectFitsAction(NounPhrase object, Verb action) {
  return fixedObjectChoicesFor(
    action,
  ).any((choice) => choice.text.toLowerCase() == object.text.toLowerCase());
}

bool canClearObjectForFixedSubjectFrame(NounPhrase object, Verb action) {
  return fixedObjectFrameLabel(action) == 'subject' &&
      !fixedObjectFitsAction(object, action);
}

bool isFlattenedFixedObjectVerb(Verb action) {
  return flattenedFixedObjectVerbInfinitives.contains(action.infinitive);
}

FixedObjectVerbAlias? fixedObjectVerbAliasFor(Verb action) {
  return fixedObjectVerbAliases[action.infinitive];
}
