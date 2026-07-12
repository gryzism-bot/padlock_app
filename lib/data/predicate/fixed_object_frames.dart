import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart'
    as object_data;
import 'package:padlock_app/data/verbs/essential.dart' show play;
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

final Map<String, List<NounPhrase>> fixedObjectChoicesByVerb = {
  'play': [football, basketball, volleyball, tennis, golf],
  'learn': [english, grammar, math, history, science],
  'study': [english, grammar, math, history, science],
  'speak': [english, polish, spanish],
  'read': [
    object_data.book.toNounPhrase(Number.singular),
    object_data.newspaper.toNounPhrase(Number.singular),
    object_data.letter.toNounPhrase(Number.singular),
    object_data.story.toNounPhrase(Number.singular),
    object_data.magazine.toNounPhrase(Number.singular),
  ],
  'write': [
    object_data.book.toNounPhrase(Number.singular),
    object_data.letter.toNounPhrase(Number.singular),
    object_data.story.toNounPhrase(Number.singular),
  ],
  'use': [
    object_data.phone.toNounPhrase(Number.singular),
    object_data.computer.toNounPhrase(Number.singular),
    object_data.laptop.toNounPhrase(Number.singular),
    object_data.keyboard.toNounPhrase(Number.singular),
    object_data.pen.toNounPhrase(Number.singular),
    object_data.pencil.toNounPhrase(Number.singular),
    object_data.key.toNounPhrase(Number.singular),
  ],
  'watch': [
    object_data.television.toNounPhrase(Number.singular),
    object_data.story.toNounPhrase(Number.singular),
  ],
  'drive': [
    object_data.car.toNounPhrase(Number.singular),
    object_data.bus.toNounPhrase(Number.singular),
    object_data.train.toNounPhrase(Number.singular),
  ],
  'ride': [
    object_data.bicycle.toNounPhrase(Number.singular),
    object_data.bus.toNounPhrase(Number.singular),
    object_data.train.toNounPhrase(Number.singular),
  ],
  'open': [
    object_data.book.toNounPhrase(Number.singular),
    object_data.door.toNounPhrase(Number.singular),
    object_data.window.toNounPhrase(Number.singular),
    object_data.bottle.toNounPhrase(Number.singular),
  ],
  'close': [
    object_data.book.toNounPhrase(Number.singular),
    object_data.door.toNounPhrase(Number.singular),
    object_data.window.toNounPhrase(Number.singular),
    object_data.bottle.toNounPhrase(Number.singular),
  ],
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
