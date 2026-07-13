import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart'
    as object_data;
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
    ..._nounForms(object_data.book),
    ..._nounForms(object_data.newspaper),
    ..._nounForms(object_data.letter),
    ..._nounForms(object_data.story),
    ..._nounForms(object_data.magazine),
  ],
  'write': [
    ..._nounForms(object_data.book),
    ..._nounForms(object_data.letter),
    ..._nounForms(object_data.story),
  ],
  'use': [
    ..._nounForms(object_data.phone),
    ..._nounForms(object_data.computer),
    ..._nounForms(object_data.laptop),
    ..._nounForms(object_data.keyboard),
    ..._nounForms(object_data.pen),
    ..._nounForms(object_data.pencil),
    ..._nounForms(object_data.key),
  ],
  'watch': [
    ..._nounForms(object_data.television),
    ..._nounForms(object_data.story),
  ],
  'drive': [
    ..._nounForms(object_data.car),
    ..._nounForms(object_data.bus),
    ..._nounForms(object_data.train),
  ],
  'ride': [
    ..._nounForms(object_data.bicycle),
    ..._nounForms(object_data.bus),
    ..._nounForms(object_data.train),
  ],
  'open': [
    ..._nounForms(object_data.book),
    ..._nounForms(object_data.door),
    ..._nounForms(object_data.window),
    ..._nounForms(object_data.bottle),
  ],
  'close': [
    ..._nounForms(object_data.book),
    ..._nounForms(object_data.door),
    ..._nounForms(object_data.window),
    ..._nounForms(object_data.bottle),
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
