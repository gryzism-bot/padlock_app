import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart'
    as fixed_object;
import 'package:padlock_app/data/subjects/object_pronouns.dart'
    as object_pronouns;
import 'package:padlock_app/data/subjects/third_person/animal_categories.dart'
    as animal_categories;
import 'package:padlock_app/data/subjects/third_person/object_categories.dart'
    as object_categories;
import 'package:padlock_app/data/subjects/third_person/people_categories.dart'
    as people_categories;
import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/cooking.dart' as cooking_data;
import 'package:padlock_app/data/verbs/education.dart' as education_data;
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/data/verbs/sport.dart' as sport_data;
import 'package:padlock_app/data/verbs/travel.dart' as travel_data;
import 'package:padlock_app/data/verbs/work.dart' as work_data;
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';

enum PredicatePathMode { authoredTracks, legacyCompassFallback }

enum PredicatePathReadiness { seeded, pendingHandAuthored }

enum PredicatePathKind {
  directObject,
  toRightAction,
  toRecipient,
  toAddressee,
  withCompanion,
  toDestination,
}

class PredicatePath {
  final PredicatePathKind kind;
  final List<NounPhrase> nouns;
  final List<Verb> verbs;

  const PredicatePath._({
    required this.kind,
    this.nouns = const [],
    this.verbs = const [],
  });

  const PredicatePath.directObject(List<NounPhrase> nouns)
    : this._(kind: PredicatePathKind.directObject, nouns: nouns);

  const PredicatePath.toRightAction(List<Verb> verbs)
    : this._(kind: PredicatePathKind.toRightAction, verbs: verbs);

  const PredicatePath.toRecipient(List<NounPhrase> nouns)
    : this._(kind: PredicatePathKind.toRecipient, nouns: nouns);

  const PredicatePath.toAddressee(List<NounPhrase> nouns)
    : this._(kind: PredicatePathKind.toAddressee, nouns: nouns);

  const PredicatePath.withCompanion(List<NounPhrase> nouns)
    : this._(kind: PredicatePathKind.withCompanion, nouns: nouns);

  const PredicatePath.toDestination(List<NounPhrase> nouns)
    : this._(kind: PredicatePathKind.toDestination, nouns: nouns);
}

class PredicateUnlocks {
  final Verb verb;
  final List<PredicatePath> paths;

  const PredicateUnlocks({required this.verb, required this.paths});
}

class PredicatePathMigrationDecision {
  final Verb verb;
  final PredicatePathReadiness readiness;
  final String note;

  const PredicatePathMigrationDecision({
    required this.verb,
    required this.readiness,
    required this.note,
  });
}

List<NounPhrase> _uniqueByText(List<NounPhrase> nouns) {
  final seen = <String>{};

  return [
    for (final noun in nouns)
      if (seen.add(noun.text.toLowerCase())) noun,
  ];
}

final _people = _uniqueByText([
  ...people_categories.singularEverydayPeople,
  ...people_categories.pluralEverydayPeople,
  ...object_pronouns.objectPronouns,
]);
final _peopleAndAnimals = _uniqueByText([
  ...people_categories.singularEverydayPeople,
  ...people_categories.pluralEverydayPeople,
  ...object_pronouns.objectPronouns,
  ...animal_categories.singularEverydayAnimals,
  ...animal_categories.pluralEverydayAnimals,
]);
final _textObjects = _uniqueByText([
  ...object_categories.singularTextObjects,
  ...object_categories.pluralTextObjects,
]);
final _foodObjects = _uniqueByText([
  ...object_categories.singularFoodObjects,
  ...object_categories.pluralFoodObjects,
]);
final _drinkObjects = [
  object_categories.singularFoodObjects.firstWhere(
    (object) => object.text == 'coffee',
  ),
  object_categories.singularFoodObjects.firstWhere(
    (object) => object.text == 'tea',
  ),
  object_categories.singularFoodObjects.firstWhere(
    (object) => object.text == 'juice',
  ),
  object_categories.pluralFoodObjects.firstWhere(
    (object) => object.text == 'coffees',
  ),
  object_categories.pluralFoodObjects.firstWhere(
    (object) => object.text == 'teas',
  ),
  object_categories.pluralFoodObjects.firstWhere(
    (object) => object.text == 'juices',
  ),
];
final _toolObjects = _uniqueByText([
  ...object_categories.singularToolObjects,
  ...object_categories.pluralToolObjects,
]);
final _deviceObjects = _uniqueByText([
  ...object_categories.singularDeviceObjects,
  ...object_categories.pluralDeviceObjects,
]);
final _openableObjects = _uniqueByText([
  ...object_categories.singularOpenableObjects,
  ...object_categories.pluralOpenableObjects,
]);
final _mediaObjects = _uniqueByText([
  ...object_categories.singularMediaObjects,
  ...object_categories.pluralMediaObjects,
]);
final _moneyObjects = _uniqueByText([
  ...object_categories.singularMoneyObjects,
  ...object_categories.pluralMoneyObjects,
]);
final _musicObjects = _uniqueByText([
  ...object_categories.singularMusicObjects,
  ...object_categories.pluralMusicObjects,
]);
final _gameObjects = _uniqueByText([
  ...object_categories.singularGameObjects,
  ...object_categories.pluralGameObjects,
]);
final _drivableObjects = _uniqueByText([
  ...object_categories.singularDrivableObjects,
  ...object_categories.pluralDrivableObjects,
]);
final _rideableObjects = _uniqueByText([
  ...object_categories.singularRideableObjects,
  ...object_categories.pluralRideableObjects,
]);
final _throwCatchObjects = _uniqueByText([
  ...object_categories.singularGameObjects,
  ...object_categories.singularFoodObjects,
]);
final _breakableObjects = _uniqueByText([
  ...object_categories.singularOpenableObjects,
  ...object_categories.singularDeviceObjects,
  ...object_categories.singularFurnitureObjects,
]);
final _findableObjects = _uniqueByText([
  ...object_categories.singularTextObjects,
  ...object_categories.singularToolObjects,
  ...object_categories.singularMoneyObjects,
]);
final _everydayObjects = _uniqueByText([
  ...object_categories.singularTextObjects,
  ...object_categories.pluralTextObjects,
  ...object_categories.singularToolObjects,
  ...object_categories.pluralToolObjects,
  ...object_categories.singularDeviceObjects,
  ...object_categories.pluralDeviceObjects,
  ...object_categories.singularFoodObjects,
  ...object_categories.pluralFoodObjects,
  ...object_categories.singularFurnitureObjects,
  ...object_categories.pluralFurnitureObjects,
  ...object_categories.singularMoneyObjects,
  ...object_categories.pluralMoneyObjects,
]);
final _transferObjects = _uniqueByText([
  ..._textObjects,
  ..._moneyObjects,
  ..._foodObjects,
  ..._toolObjects,
]);
final _learnSubjects = [
  fixed_object.english,
  fixed_object.grammar,
  fixed_object.math,
  fixed_object.history,
  fixed_object.science,
];
final _spokenLanguages = [
  fixed_object.english,
  fixed_object.polish,
  fixed_object.spanish,
];
final _playActivities = [
  fixed_object.football,
  fixed_object.basketball,
  fixed_object.volleyball,
  fixed_object.tennis,
  fixed_object.golf,
];
final _rightActionWants = [go, work, learn, swim, speak, watch, sleep];
final _rightActionNeeds = [go, work, learn, speak, sleep];
final _rightActionLikes = [go, work, learn, swim, speak, watch, sleep];
final _rightActionLoves = [go, work, learn, swim, speak, watch];
final _rightActionLearns = [speak, swim, work];

PredicateUnlocks _direct(Verb verb, List<NounPhrase> nouns) {
  return PredicateUnlocks(
    verb: verb,
    paths: [PredicatePath.directObject(nouns)],
  );
}

PredicateUnlocks _directWithCompanion(Verb verb, List<NounPhrase> nouns) {
  return PredicateUnlocks(
    verb: verb,
    paths: [
      PredicatePath.directObject(nouns),
      PredicatePath.withCompanion(_people),
    ],
  );
}

PredicateUnlocks _destinationWithCompanion(Verb verb) {
  return PredicateUnlocks(
    verb: verb,
    paths: [
      PredicatePath.toDestination(_people),
      if (verb.takesCompanion) PredicatePath.withCompanion(_people),
    ],
  );
}

PredicateUnlocks _addressee(Verb verb, List<NounPhrase> nouns) {
  return PredicateUnlocks(
    verb: verb,
    paths: [PredicatePath.toAddressee(nouns)],
  );
}

PredicateUnlocks _companion(Verb verb) {
  return PredicateUnlocks(
    verb: verb,
    paths: [PredicatePath.withCompanion(_people)],
  );
}

final guidedPredicateUnlocks = [
  _direct(have, _everydayObjects),
  _direct(findVerb, _findableObjects),
  _direct(breakVerb, _breakableObjects),
  _destinationWithCompanion(go),
  _destinationWithCompanion(come),
  _direct(get, _everydayObjects),
  PredicateUnlocks(
    verb: make,
    paths: [
      PredicatePath.directObject(_everydayObjects),
      PredicatePath.toRecipient(_people),
    ],
  ),
  _direct(take, _everydayObjects),
  PredicateUnlocks(
    verb: give,
    paths: [
      PredicatePath.directObject(_transferObjects),
      PredicatePath.toRecipient(_people),
    ],
  ),
  _direct(know, _uniqueByText([..._peopleAndAnimals, ..._learnSubjects])),
  _direct(see, _uniqueByText([..._peopleAndAnimals, ..._everydayObjects])),
  PredicateUnlocks(
    verb: want,
    paths: [
      PredicatePath.directObject(
        _uniqueByText([..._everydayObjects, ..._people]),
      ),
      PredicatePath.toRightAction(_rightActionWants),
    ],
  ),
  PredicateUnlocks(
    verb: need,
    paths: [
      PredicatePath.directObject(
        _uniqueByText([..._everydayObjects, ..._people]),
      ),
      PredicatePath.toRightAction(_rightActionNeeds),
    ],
  ),
  PredicateUnlocks(
    verb: like,
    paths: [
      PredicatePath.directObject(
        _uniqueByText([..._everydayObjects, ..._peopleAndAnimals]),
      ),
      PredicatePath.toRightAction(_rightActionLikes),
    ],
  ),
  PredicateUnlocks(
    verb: love,
    paths: [
      PredicatePath.directObject(
        _uniqueByText([
          ..._peopleAndAnimals,
          ..._musicObjects,
          ..._gameObjects,
        ]),
      ),
      PredicatePath.toRightAction(_rightActionLoves),
    ],
  ),
  _companion(work),
  PredicateUnlocks(
    verb: play,
    paths: [
      PredicatePath.directObject(_playActivities),
      PredicatePath.withCompanion(_people),
    ],
  ),
  PredicateUnlocks(
    verb: learn,
    paths: [
      PredicatePath.directObject(_learnSubjects),
      PredicatePath.toRightAction(_rightActionLearns),
      PredicatePath.withCompanion(_people),
    ],
  ),
  _direct(remember, _uniqueByText([..._peopleAndAnimals, ..._learnSubjects])),
  _direct(hate, _uniqueByText([..._peopleAndAnimals, ..._everydayObjects])),
  _direct(meet, _peopleAndAnimals),
  _direct(use, _toolObjects),
  _direct(open, _openableObjects),
  _direct(close, _openableObjects),
  _direct(help, _peopleAndAnimals),
  PredicateUnlocks(
    verb: buy,
    paths: [
      PredicatePath.directObject(
        _uniqueByText([..._moneyObjects, ..._everydayObjects]),
      ),
      PredicatePath.toRecipient(_people),
    ],
  ),
  _direct(sell, _uniqueByText([..._moneyObjects, ..._everydayObjects])),
  _direct(read, _textObjects),
  _direct(watch, _mediaObjects),
  _direct(lose, _uniqueByText([..._moneyObjects, ..._toolObjects])),
  PredicateUnlocks(
    verb: speak,
    paths: [
      PredicatePath.directObject(_spokenLanguages),
      PredicatePath.toAddressee(_peopleAndAnimals),
      PredicatePath.withCompanion(_people),
    ],
  ),
  PredicateUnlocks(
    verb: talk,
    paths: [
      PredicatePath.toAddressee(_peopleAndAnimals),
      PredicatePath.withCompanion(_people),
    ],
  ),
  PredicateUnlocks(
    verb: tell,
    paths: [
      PredicatePath.directObject(_textObjects),
      PredicatePath.toRecipient(_people),
    ],
  ),
  _direct(call, _peopleAndAnimals),
  _addressee(listen, _peopleAndAnimals),
  PredicateUnlocks(
    verb: write,
    paths: [
      PredicatePath.directObject(_textObjects),
      PredicatePath.toRecipient(_people),
      PredicatePath.toAddressee(_people),
      PredicatePath.withCompanion(_people),
    ],
  ),
  PredicateUnlocks(
    verb: explain,
    paths: [
      PredicatePath.directObject(_learnSubjects),
      PredicatePath.toAddressee(_people),
    ],
  ),
  _companion(agree),
  _companion(disagree),
  _addressee(shout, _peopleAndAnimals),
  _addressee(whisper, _peopleAndAnimals),
  PredicateUnlocks(
    verb: introduce,
    paths: [
      PredicatePath.directObject(_peopleAndAnimals),
      PredicatePath.toAddressee(_peopleAndAnimals),
    ],
  ),
  _directWithCompanion(education_data.study, _learnSubjects),
  PredicateUnlocks(
    verb: education_data.teach,
    paths: [
      PredicatePath.directObject(_learnSubjects),
      PredicatePath.toRecipient(_people),
      PredicatePath.withCompanion(_people),
    ],
  ),
  _direct(education_data.spell, _textObjects),
  _direct(
    education_data.count,
    _uniqueByText([..._learnSubjects, ..._gameObjects]),
  ),
  _direct(education_data.calculate, _learnSubjects),
  _direct(education_data.solve, _learnSubjects),
  _direct(
    education_data.understand,
    _uniqueByText([..._learnSubjects, ..._people]),
  ),
  _direct(
    education_data.forget,
    _uniqueByText([..._learnSubjects, ..._people]),
  ),
  _direct(
    education_data.practice,
    _uniqueByText([..._learnSubjects, ..._playActivities]),
  ),
  _direct(education_data.repeat, _learnSubjects),
  _direct(
    education_data.improve,
    _uniqueByText([..._learnSubjects, ..._textObjects]),
  ),
  _direct(education_data.research, _learnSubjects),
  _destinationWithCompanion(walk),
  _destinationWithCompanion(run),
  _destinationWithCompanion(swim),
  _destinationWithCompanion(fly),
  PredicateUnlocks(
    verb: drive,
    paths: [
      PredicatePath.directObject(_drivableObjects),
      PredicatePath.toDestination(_people),
    ],
  ),
  PredicateUnlocks(
    verb: ride,
    paths: [
      PredicatePath.directObject(_rideableObjects),
      PredicatePath.toDestination(_people),
    ],
  ),
  _destinationWithCompanion(sail),
  _destinationWithCompanion(skate),
  _destinationWithCompanion(ski),
  _destinationWithCompanion(travel_data.travel),
  _destinationWithCompanion(travel_data.arrive),
  _destinationWithCompanion(travel_data.leave),
  _destinationWithCompanion(travel_data.returnVerb),
  _direct(cooking_data.cook, _foodObjects),
  _direct(cooking_data.bake, _foodObjects),
  _direct(cooking_data.fry, _foodObjects),
  _direct(cooking_data.boil, _foodObjects),
  _direct(cooking_data.grill, _foodObjects),
  _direct(cooking_data.eat, _foodObjects),
  _direct(cooking_data.drink, _drinkObjects),
  _direct(cooking_data.roast, _foodObjects),
  _direct(cooking_data.steam, _foodObjects),
  _direct(cooking_data.cut, _foodObjects),
  _direct(cooking_data.chop, _foodObjects),
  _direct(cooking_data.slice, _foodObjects),
  _direct(cooking_data.peel, _foodObjects),
  _direct(cooking_data.mix, _foodObjects),
  _direct(cooking_data.stir, _foodObjects),
  _direct(cooking_data.pour, _foodObjects),
  _direct(cooking_data.add, _foodObjects),
  _direct(cooking_data.serve, _foodObjects),
  _direct(cooking_data.taste, _foodObjects),
  _direct(cooking_data.freeze, _foodObjects),
  _direct(cooking_data.melt, _foodObjects),
  _direct(
    cooking_data.wash,
    _uniqueByText([..._foodObjects, ..._openableObjects]),
  ),
  _direct(
    work_data.build,
    _uniqueByText([
      ...object_categories.singularFurnitureObjects,
      ...object_categories.singularOpenableObjects,
    ]),
  ),
  _direct(work_data.create, _uniqueByText([..._textObjects, ..._mediaObjects])),
  _direct(
    work_data.design,
    _uniqueByText([..._textObjects, ..._deviceObjects]),
  ),
  _direct(
    work_data.develop,
    _uniqueByText([..._deviceObjects, ..._textObjects]),
  ),
  _direct(work_data.program, _deviceObjects),
  _direct(
    work_data.testVerb,
    _uniqueByText([..._deviceObjects, ..._textObjects]),
  ),
  _direct(work_data.debug, _deviceObjects),
  _direct(
    work_data.fix,
    _uniqueByText([..._deviceObjects, ..._openableObjects]),
  ),
  _direct(
    work_data.repair,
    _uniqueByText([..._deviceObjects, ..._openableObjects]),
  ),
  _direct(
    work_data.clean,
    _uniqueByText([
      ..._deviceObjects,
      ...object_categories.singularFurnitureObjects,
      ..._openableObjects,
    ]),
  ),
  _direct(
    work_data.organize,
    _uniqueByText([..._textObjects, ..._toolObjects]),
  ),
  _direct(work_data.manage, _uniqueByText([..._people, ..._textObjects])),
  _direct(
    work_data.deliver,
    _uniqueByText([..._textObjects, ..._moneyObjects]),
  ),
  _direct(
    work_data.produce,
    _uniqueByText([..._textObjects, ..._mediaObjects]),
  ),
  _direct(work_data.earn, _moneyObjects),
  _direct(sport_data.lift, _uniqueByText([..._gameObjects, ..._toolObjects])),
  _direct(sport_data.throwVerb, _throwCatchObjects),
  _direct(sport_data.catchVerb, _throwCatchObjects),
  _direct(sport_data.kick, _gameObjects),
  _direct(sport_data.hit, _gameObjects),
];

PredicatePathMigrationDecision _migration({
  required Verb verb,
  PredicatePathReadiness? readiness,
  required String note,
}) {
  final authoredReadiness = predicateUnlocksFor(verb) == null
      ? readiness ?? PredicatePathReadiness.pendingHandAuthored
      : PredicatePathReadiness.seeded;

  return PredicatePathMigrationDecision(
    verb: verb,
    readiness: authoredReadiness,
    note: note,
  );
}

final essentialPredicatePathMigration = [
  _migration(
    verb: be,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author noun, adjective, place, and companion complement tracks',
  ),
  _migration(
    verb: have,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author possession object tracks',
  ),
  _migration(
    verb: doVerb,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'decide whether do is product-visible or structural only',
  ),
  _migration(
    verb: findVerb,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author findable object tracks',
  ),
  _migration(
    verb: sing,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author song/performance and companion tracks',
  ),
  _migration(
    verb: breakVerb,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author breakable object tracks',
  ),
  _migration(
    verb: begin,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'likely right-action track candidate',
  ),
  _migration(
    verb: go,
    readiness: PredicatePathReadiness.seeded,
    note: 'seeded destination and companion tracks',
  ),
  _migration(
    verb: come,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author destination and companion tracks',
  ),
  _migration(
    verb: get,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author obtainable object tracks',
  ),
  _migration(
    verb: make,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object, recipient, and object-complement tracks',
  ),
  _migration(
    verb: take,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author takeable object tracks',
  ),
  _migration(
    verb: give,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object and recipient tracks',
  ),
  _migration(
    verb: know,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author knowable object/topic tracks',
  ),
  _migration(
    verb: think,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'decide topic/right-action tracks',
  ),
  _migration(
    verb: say,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'decide speech object/addressee tracks',
  ),
  _migration(
    verb: see,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author visible object tracks',
  ),
  _migration(
    verb: want,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object and right-action tracks',
  ),
  _migration(
    verb: need,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object and right-action tracks',
  ),
  _migration(
    verb: like,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object and right-action tracks',
  ),
  _migration(
    verb: love,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object and right-action tracks',
  ),
  _migration(
    verb: work,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author companion, place, time, and manner tracks',
  ),
  _migration(
    verb: play,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author activity, music, game, and companion tracks',
  ),
  _migration(
    verb: learn,
    readiness: PredicatePathReadiness.seeded,
    note: 'seeded subject, right-action, and companion tracks',
  ),
  _migration(
    verb: sleep,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author place, time, and manner tracks',
  ),
  _migration(
    verb: remember,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object and right-action tracks',
  ),
  _migration(
    verb: hate,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object and right-action tracks',
  ),
  _migration(
    verb: meet,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author people/object tracks',
  ),
  _migration(
    verb: use,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author tool object tracks',
  ),
  _migration(
    verb: open,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author openable object tracks',
  ),
  _migration(
    verb: close,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author openable object tracks',
  ),
  _migration(
    verb: help,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author person/object and right-action tracks',
  ),
  _migration(
    verb: buy,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object and recipient tracks',
  ),
  _migration(
    verb: sell,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object and recipient/addressee tracks if supported',
  ),
  _migration(
    verb: read,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author text object tracks',
  ),
  _migration(
    verb: watch,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author media object tracks',
  ),
  _migration(
    verb: lose,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author losable object tracks',
  ),
];

PredicateUnlocks? predicateUnlocksFor(Verb verb) {
  for (final unlocks in guidedPredicateUnlocks) {
    if (unlocks.verb.infinitive == verb.infinitive) {
      return unlocks;
    }
  }
  return null;
}

List<PredicatePath> predicatePathsFor(Verb verb) {
  return predicateUnlocksFor(verb)?.paths ?? const [];
}

List<NounPhrase> predicateNounChoicesFor(Verb verb, PredicatePathKind kind) {
  return _uniqueByText([
    for (final path in predicatePathsFor(
      verb,
    ).where((path) => path.kind == kind))
      ...path.nouns,
  ]);
}

List<Verb> predicateVerbChoicesFor(Verb verb, PredicatePathKind kind) {
  final seen = <String>{};

  return [
    for (final path in predicatePathsFor(
      verb,
    ).where((path) => path.kind == kind))
      for (final choice in path.verbs)
        if (seen.add(choice.infinitive)) choice,
  ];
}

PredicatePathMigrationDecision? predicatePathMigrationFor(Verb verb) {
  for (final decision in essentialPredicatePathMigration) {
    if (decision.verb.infinitive == verb.infinitive) {
      return decision;
    }
  }
  return null;
}
