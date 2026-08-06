import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart';
import 'package:padlock_app/data/subjects/third_person/object_categories.dart'
    as object_categories;
import 'package:padlock_app/models/grammar/subject/noun.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';

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

final _subjectObjectChoices = [
  english,
  polish,
  spanish,
  grammar,
  math,
  history,
  science,
  ..._nounForms(
    object_categories.abstractObjectNouns.firstWhere(
      (noun) => noun.singular == 'language',
    ),
  ),
  ..._nounForms(
    object_categories.abstractObjectNouns.firstWhere(
      (noun) => noun.singular == 'skill',
    ),
  ),
  ..._nounForms(
    object_categories.abstractObjectNouns.firstWhere(
      (noun) => noun.singular == 'lesson',
    ),
  ),
];

final Map<String, List<NounPhrase>> fixedObjectChoicesByVerb = {
  'play': [
    football,
    basketball,
    volleyball,
    tennis,
    golf,
    music,
    for (final noun in object_categories.musicObjectNouns) ..._nounForms(noun),
    for (final noun in object_categories.gameObjectNouns) ..._nounForms(noun),
  ],
  'learn': _subjectObjectChoices,
  'study': _subjectObjectChoices,
  'teach': _subjectObjectChoices,
  'speak': [english, polish, spanish],
  'read': [
    for (final noun in object_categories.textObjectNouns) ..._nounForms(noun),
    english,
    polish,
    spanish,
  ],
  'write': [
    for (final noun in object_categories.textObjectNouns) ..._nounForms(noun),
    something,
    anything,
    nothing,
    everything,
    itObject,
    thisObject,
    thatObject,
  ],
  'use': [
    something,
    anything,
    nothing,
    everything,
    itObject,
    thisObject,
    thatObject,
    for (final noun in object_categories.toolObjectNouns) ..._nounForms(noun),
  ],
  'watch': [
    something,
    anything,
    nothing,
    everything,
    itObject,
    thisObject,
    thatObject,
    for (final noun in object_categories.mediaObjectNouns) ..._nounForms(noun),
    show,
    ..._nounForms(
      object_categories.gameObjectNouns.firstWhere(
        (noun) => noun.singular == 'game',
      ),
    ),
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
    itObject,
    thisObject,
    thatObject,
    something,
    anything,
    nothing,
    everything,
    for (final noun in object_categories.openableObjectNouns)
      ..._nounForms(noun),
  ],
  'close': [
    itObject,
    thisObject,
    thatObject,
    something,
    anything,
    nothing,
    everything,
    for (final noun in object_categories.openableObjectNouns)
      ..._nounForms(noun),
  ],
};

List<NounPhrase> _nounForms(Noun noun) {
  return [noun.toNounPhrase(Number.singular), noun.toNounPhrase(Number.plural)];
}

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
