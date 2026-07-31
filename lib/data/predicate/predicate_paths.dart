import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart'
    as fixed_object;
import 'package:padlock_app/data/subjects/object_pronouns.dart'
    as object_pronouns;
import 'package:padlock_app/data/subjects/third_person/animal_categories.dart'
    as animal_categories;
import 'package:padlock_app/data/subjects/third_person/object_categories.dart'
    as object_categories;
import 'package:padlock_app/data/subjects/third_person/objects.dart'
    as object_data;
import 'package:padlock_app/data/subjects/third_person/people_categories.dart'
    as people_categories;
import 'package:padlock_app/data/phrases/frequency_phrases.dart'
    as frequency_data;
import 'package:padlock_app/data/phrases/manner_phrases.dart' as manner_data;
import 'package:padlock_app/data/phrases/place_phrases.dart' as place_data;
import 'package:padlock_app/data/phrases/time_phrases.dart' as time_data;
import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/cooking.dart' as cooking_data;
import 'package:padlock_app/data/verbs/education.dart' as education_data;
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/data/verbs/sport.dart' as sport_data;
import 'package:padlock_app/data/verbs/travel.dart' as travel_data;
import 'package:padlock_app/data/verbs/work.dart' as work_data;
import 'package:padlock_app/models/grammar/phrase/frequency_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/manner_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/phrase/place_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/time_phrase.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';

enum PredicatePathMode { authoredTracks, legacyCompassFallback }

enum PredicatePathReadiness { seeded, pendingHandAuthored }

enum PredicatePathKind {
  directObject,
  toRightAction,
  toRecipient,
  toAddressee,
  withCompanion,
  withInstrument,
  toDestination,
  aboutTopic,
  ofTopic,
  onTopic,
  forBeneficiary,
  fromSource,
  forPurpose,
  atLocation,
  inLocation,
  onLocation,
  fromLocation,
  placePhrase,
  timePhrase,
  frequencyPhrase,
  mannerPhrase,
}

const predicateLocationPathKinds = [
  PredicatePathKind.atLocation,
  PredicatePathKind.inLocation,
  PredicatePathKind.onLocation,
];

const predicateSourceLocationPathKinds = [PredicatePathKind.fromLocation];

const predicateTopicPathKinds = [
  PredicatePathKind.aboutTopic,
  PredicatePathKind.ofTopic,
  PredicatePathKind.onTopic,
];

const predicateAuthoredPlacePathKinds = [
  ...predicateLocationPathKinds,
  ...predicateSourceLocationPathKinds,
  PredicatePathKind.placePhrase,
];

String? predicatePlaceConnectorFor(PredicatePathKind kind) {
  return switch (kind) {
    PredicatePathKind.atLocation => 'at',
    PredicatePathKind.inLocation => 'in',
    PredicatePathKind.onLocation => 'on',
    PredicatePathKind.fromLocation => 'from',
    _ => null,
  };
}

String? predicateTopicConnectorFor(PredicatePathKind kind) {
  return switch (kind) {
    PredicatePathKind.aboutTopic => 'about',
    PredicatePathKind.ofTopic => 'of',
    PredicatePathKind.onTopic => 'on',
    _ => null,
  };
}

class PredicatePath {
  final PredicatePathKind kind;
  final bool requiresObject;
  final List<NounPhrase> nouns;
  final List<Verb> verbs;
  final List<PlacePhrase> places;
  final List<TimePhrase> times;
  final List<FrequencyPhrase> frequencies;
  final List<MannerPhrase> manners;

  const PredicatePath._({
    required this.kind,
    this.requiresObject = false,
    this.nouns = const [],
    this.verbs = const [],
    this.places = const [],
    this.times = const [],
    this.frequencies = const [],
    this.manners = const [],
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

  const PredicatePath.withInstrument(List<NounPhrase> nouns)
    : this._(kind: PredicatePathKind.withInstrument, nouns: nouns);

  const PredicatePath.toDestination(
    List<NounPhrase> nouns, {
    bool requiresObject = false,
  }) : this._(
         kind: PredicatePathKind.toDestination,
         nouns: nouns,
         requiresObject: requiresObject,
       );

  const PredicatePath.aboutTopic(List<NounPhrase> nouns)
    : this._(kind: PredicatePathKind.aboutTopic, nouns: nouns);

  const PredicatePath.ofTopic(List<NounPhrase> nouns)
    : this._(kind: PredicatePathKind.ofTopic, nouns: nouns);

  const PredicatePath.onTopic(List<NounPhrase> nouns)
    : this._(kind: PredicatePathKind.onTopic, nouns: nouns);

  const PredicatePath.forBeneficiary(List<NounPhrase> nouns)
    : this._(kind: PredicatePathKind.forBeneficiary, nouns: nouns);

  const PredicatePath.fromSource(List<NounPhrase> nouns)
    : this._(kind: PredicatePathKind.fromSource, nouns: nouns);

  const PredicatePath.forPurpose(List<NounPhrase> nouns)
    : this._(kind: PredicatePathKind.forPurpose, nouns: nouns);

  const PredicatePath.atLocation(List<PlacePhrase> places)
    : this._(kind: PredicatePathKind.atLocation, places: places);

  const PredicatePath.inLocation(List<PlacePhrase> places)
    : this._(kind: PredicatePathKind.inLocation, places: places);

  const PredicatePath.onLocation(List<PlacePhrase> places)
    : this._(kind: PredicatePathKind.onLocation, places: places);

  const PredicatePath.fromLocation(List<PlacePhrase> places)
    : this._(kind: PredicatePathKind.fromLocation, places: places);

  const PredicatePath.placePhrase(List<PlacePhrase> places)
    : this._(kind: PredicatePathKind.placePhrase, places: places);

  const PredicatePath.timePhrase(List<TimePhrase> times)
    : this._(kind: PredicatePathKind.timePhrase, times: times);

  const PredicatePath.frequencyPhrase(List<FrequencyPhrase> frequencies)
    : this._(kind: PredicatePathKind.frequencyPhrase, frequencies: frequencies);

  const PredicatePath.mannerPhrase(List<MannerPhrase> manners)
    : this._(kind: PredicatePathKind.mannerPhrase, manners: manners);
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

List<PlacePhrase> _uniquePlacesByText(List<PlacePhrase> places) {
  final seen = <String>{};

  return [
    for (final place in places)
      if (seen.add(_placeRouteKey(place))) place,
  ];
}

String _placeRouteKey(PlacePhrase place) {
  return [
    place.render(PlaceMeaning.location),
    place.render(PlaceMeaning.destination),
    place.render(PlaceMeaning.source),
  ].join('|').toLowerCase();
}

List<TimePhrase> _uniqueTimesByText(List<TimePhrase> times) {
  final seen = <String>{};

  return [
    for (final time in times)
      if (seen.add(time.text.toLowerCase())) time,
  ];
}

List<FrequencyPhrase> _uniqueFrequenciesByText(
  List<FrequencyPhrase> frequencies,
) {
  final seen = <String>{};

  return [
    for (final frequency in frequencies)
      if (seen.add(frequency.text.toLowerCase())) frequency,
  ];
}

List<MannerPhrase> _uniqueMannersByText(List<MannerPhrase> manners) {
  final seen = <String>{};

  return [
    for (final manner in manners)
      if (seen.add(manner.text.toLowerCase())) manner,
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
final _writingInstruments = _objectsWithText(_toolObjects, [
  'pen',
  'pens',
  'pencil',
  'pencils',
  'keyboard',
  'keyboards',
  'computer',
  'computers',
  'laptop',
  'laptops',
]);
final _openingInstruments = _objectsWithText(_toolObjects, ['key', 'keys']);
final _cuttingInstruments = _objectsWithText(_toolObjects, ['knife', 'knives']);
final _eatingInstruments = _objectsWithText(_toolObjects, [
  'fork',
  'forks',
  'spoon',
  'spoons',
]);
final _mixingInstruments = _objectsWithText(_toolObjects, ['spoon', 'spoons']);
final _photoInstruments = _objectsWithText(_toolObjects, [
  'camera',
  'cameras',
  'phone',
  'phones',
]);
final _navigationInstruments = _objectsWithText(_toolObjects, [
  'map',
  'maps',
  'phone',
  'phones',
]);

List<NounPhrase> _objectsWithText(
  List<NounPhrase> objects,
  List<String> texts,
) {
  final wanted = texts.map((text) => text.toLowerCase()).toSet();
  return [
    for (final object in objects)
      if (wanted.contains(object.text.toLowerCase())) object,
  ];
}

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
  fixed_object.show,
  object_data.game.toNounPhrase(Number.singular),
  object_data.game.toNounPhrase(Number.plural),
]);
final _photoObjects = _uniqueByText([
  for (final object in _mediaObjects)
    if (object.text == 'photo' || object.text == 'photos') object,
]);
final _moneyObjects = _uniqueByText([
  fixed_object.money,
  ...object_categories.singularMoneyObjects,
  ...object_categories.pluralMoneyObjects,
]);
final _clothingObjects = _uniqueByText([
  ...object_categories.singularClothingObjects,
  ...object_categories.pluralClothingObjects,
]);
final _musicObjects = _uniqueByText([
  fixed_object.music,
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
final _travelObjects = _uniqueByText([
  ..._moneyObjects,
  ..._openableObjects,
  ...object_categories.singularVehicleObjects,
  ...object_categories.pluralVehicleObjects,
  object_data.house.toNounPhrase(Number.singular),
  object_data.house.toNounPhrase(Number.plural),
  object_data.apartment.toNounPhrase(Number.singular),
  object_data.apartment.toNounPhrase(Number.plural),
]);
final _saleObjects = _uniqueByText([
  ..._moneyObjects,
  ..._everydayObjects,
  ...object_categories.singularVehicleObjects,
  ...object_categories.pluralVehicleObjects,
  object_data.house.toNounPhrase(Number.singular),
  object_data.house.toNounPhrase(Number.plural),
  object_data.apartment.toNounPhrase(Number.singular),
  object_data.apartment.toNounPhrase(Number.plural),
]);
final _throwCatchObjects = _uniqueByText([
  ...object_categories.singularGameObjects,
  ...object_categories.singularFoodObjects,
]);
final _breakableObjects = _uniqueByText([
  ...object_categories.singularOpenableObjects,
  ...object_categories.singularDeviceObjects,
  ...object_categories.singularFurnitureObjects,
  object_data.cup.toNounPhrase(Number.singular),
  object_data.cup.toNounPhrase(Number.plural),
]);
final _findableObjects = _uniqueByText([
  ...object_categories.singularTextObjects,
  ...object_categories.singularToolObjects,
  ...object_categories.singularMoneyObjects,
  fixed_object.money,
  ..._peopleAndAnimals,
]);
final _lifeObjects = _uniqueByText([
  fixed_object.breakfast,
  fixed_object.money,
  fixed_object.time,
  fixed_object.problem,
  fixed_object.question,
  fixed_object.job,
  fixed_object.helpNoun,
  fixed_object.plan,
  fixed_object.mistake,
  fixed_object.answer,
  fixed_object.word,
  fixed_object.yes,
  fixed_object.no,
  fixed_object.hello,
  fixed_object.noise,
  fixed_object.waiting,
]);
final _everydayObjects = _uniqueByText([
  ..._lifeObjects,
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
  fixed_object.polish,
  fixed_object.spanish,
  fixed_object.grammar,
  fixed_object.math,
  fixed_object.history,
  fixed_object.science,
];
final _workTopics = _uniqueByText([
  ..._learnSubjects,
  ...object_categories.singularVehicleObjects,
  ...object_categories.pluralVehicleObjects,
  fixed_object.physique,
  fixed_object.skill,
  fixed_object.skills,
  fixed_object.swimming,
  fixed_object.skating,
]);
final _basicTopics = _uniqueByText([
  ..._learnSubjects,
  ..._textObjects,
  ..._peopleAndAnimals,
  ...object_categories.singularMediaObjects,
  ...object_categories.pluralMediaObjects,
  ...object_categories.singularDeviceObjects,
  ...object_categories.pluralDeviceObjects,
]);
final _basicBeneficiaries = _uniqueByText([..._people]);
final _basicPurposes = _uniqueByText([
  fixed_object.workNoun,
  fixed_object.homework,
  fixed_object.job,
  fixed_object.exerciseNoun,
  fixed_object.schoolNoun,
  fixed_object.healthNoun,
  fixed_object.funNoun,
  fixed_object.grammar,
  fixed_object.skill,
  fixed_object.skills,
]);
final _learningPurposes = _uniqueByText([
  fixed_object.schoolNoun,
  fixed_object.workNoun,
  fixed_object.grammar,
  fixed_object.skill,
  fixed_object.skills,
]);
final _movementPurposes = _uniqueByText([
  fixed_object.exerciseNoun,
  fixed_object.healthNoun,
  fixed_object.funNoun,
]);
final _trainingPurposes = _uniqueByText([
  fixed_object.exerciseNoun,
  fixed_object.healthNoun,
  fixed_object.football,
  fixed_object.basketball,
  fixed_object.tennis,
  fixed_object.swimming,
  fixed_object.skating,
]);
final _cookingPurposes = _uniqueByText([fixed_object.dinnerNoun]);
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
final _doObjects = _uniqueByText([
  fixed_object.workNoun,
  fixed_object.homework,
  fixed_object.job,
  fixed_object.exerciseNoun,
  ..._learnSubjects,
  ..._textObjects,
  ..._gameObjects,
]);
final _beginObjects = _uniqueByText([
  fixed_object.lesson,
  fixed_object.workNoun,
  ..._learnSubjects,
]);
final _sayObjects = _uniqueByText([
  fixed_object.word,
  fixed_object.yes,
  fixed_object.no,
  fixed_object.hello,
  ..._textObjects,
]);
final _rightActionWants = [
  go,
  work,
  learn,
  swim,
  speak,
  watch,
  sleep,
  read,
  write,
  play,
  sing,
  help,
];
final _rightActionNeeds = [go, work, learn, speak, sleep, read, write, help];
final _rightActionLikes = [
  go,
  work,
  learn,
  swim,
  speak,
  watch,
  sleep,
  read,
  write,
  play,
  sing,
];
final _rightActionLoves = [
  go,
  work,
  learn,
  swim,
  speak,
  watch,
  sleep,
  read,
  write,
  play,
  sing,
];
final _rightActionBegins = [go, work, learn, speak, swim, read, write, play];
final _rightActionLearns = [speak, swim, work, read, write, sing, play];
final _rightActionRemembers = [go, call, work, learn, read, write, speak];
final _rightActionForgets = [go, call, work, learn, read, write, speak];
final _rightActionHates = [
  go,
  work,
  learn,
  swim,
  speak,
  watch,
  sleep,
  lose,
  read,
  write,
  play,
  sing,
  help,
];
final _rightActionHelps = [work, learn, speak, read, write];
final _rightActionTeaches = [speak, swim, read, write, work, learn];
final _rightActionMovementPurposes = [
  sport_data.exercise,
  sport_data.train,
  education_data.forget,
];
final _homeSchoolWorkPlaces = [
  place_data.homePlacePhrase,
  place_data.schoolPlacePhrase,
  place_data.workPlacePhrase,
  place_data.officePlacePhrase,
];
final _surfacePlaces = [
  place_data.tablePlacePhrase,
  place_data.bedPlacePhrase,
  place_data.bridgePlacePhrase,
];
final _everydayPlaces = _uniquePlacesByText([
  place_data.homePlacePhrase,
  place_data.schoolPlacePhrase,
  place_data.workPlacePhrase,
  place_data.officePlacePhrase,
  place_data.shopPlacePhrase,
  place_data.parkPlacePhrase,
  place_data.restaurantPlacePhrase,
  place_data.hospitalPlacePhrase,
  place_data.roomPlacePhrase,
]);
final _basicTimes = [
  time_data.todayTimePhrase,
  time_data.nowTimePhrase,
  time_data.tomorrowTimePhrase,
  time_data.laterTimePhrase,
  time_data.atNightTimePhrase,
];
final _todayTimes = [
  time_data.todayTimePhrase,
  time_data.nowTimePhrase,
  time_data.thisMorningTimePhrase,
  time_data.thisAfternoonTimePhrase,
  time_data.thisEveningTimePhrase,
];
final _basicFrequencies = [
  frequency_data.alwaysFrequencyPhrase,
  frequency_data.oftenFrequencyPhrase,
  frequency_data.sometimesFrequencyPhrase,
  frequency_data.everyDayFrequencyPhrase,
];
final _movementManners = [
  manner_data.quicklyMannerPhrase,
  manner_data.slowlyMannerPhrase,
  manner_data.carefullyMannerPhrase,
];
final _carefulManners = [
  manner_data.carefullyMannerPhrase,
  manner_data.withCareMannerPhrase,
  manner_data.quicklyMannerPhrase,
  manner_data.slowlyMannerPhrase,
];
final _speechManners = [
  manner_data.loudlyMannerPhrase,
  manner_data.quietlyMannerPhrase,
  manner_data.politelyMannerPhrase,
];
final _performanceManners = [
  manner_data.wellMannerPhrase,
  manner_data.badlyMannerPhrase,
  manner_data.loudlyMannerPhrase,
  manner_data.quietlyMannerPhrase,
];
final _mistakeManners = [
  manner_data.byAccidentMannerPhrase,
  manner_data.onPurposeMannerPhrase,
];

PredicateUnlocks _direct(Verb verb, List<NounPhrase> nouns) {
  return PredicateUnlocks(
    verb: verb,
    paths: [PredicatePath.directObject(nouns)],
  );
}

PredicateUnlocks _directWithPaths(
  Verb verb,
  List<NounPhrase> nouns, {
  List<PredicatePath> paths = const [],
}) {
  return PredicateUnlocks(
    verb: verb,
    paths: [PredicatePath.directObject(nouns), ...paths],
  );
}

PredicateUnlocks _destinationWithCompanion(
  Verb verb, {
  List<PredicatePath> paths = const [],
}) {
  return PredicateUnlocks(
    verb: verb,
    paths: [
      PredicatePath.toDestination(_people),
      if (verb.takesCompanion) PredicatePath.withCompanion(_people),
      _fromLocations(_homeSchoolWorkPlaces),
      ...paths,
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

PredicatePath _beneficiaries() {
  return PredicatePath.forBeneficiary(_basicBeneficiaries);
}

PredicatePath _sources() {
  return PredicatePath.fromSource(_peopleAndAnimals);
}

PredicatePath _purposes(List<NounPhrase> nouns) {
  return PredicatePath.forPurpose(_uniqueByText(nouns));
}

PredicatePath _places(List<PlacePhrase> places) {
  return PredicatePath.placePhrase(_uniquePlacesByText(places));
}

PredicatePath _atLocations(List<PlacePhrase> places) {
  return PredicatePath.atLocation(_locationsWithPreposition(places, 'at'));
}

PredicatePath _inLocations(List<PlacePhrase> places) {
  return PredicatePath.inLocation(_locationsWithPreposition(places, 'in'));
}

PredicatePath _onLocations(List<PlacePhrase> places) {
  return PredicatePath.onLocation(_locationsWithPreposition(places, 'on'));
}

PredicatePath _fromLocations(List<PlacePhrase> places) {
  return PredicatePath.fromLocation(
    _placesWithMeaningPreposition(places, PlaceMeaning.source, 'from'),
  );
}

List<PlacePhrase> _locationsWithPreposition(
  List<PlacePhrase> places,
  String preposition,
) {
  return _placesWithMeaningPreposition(
    places,
    PlaceMeaning.location,
    preposition,
  );
}

List<PlacePhrase> _placesWithMeaningPreposition(
  List<PlacePhrase> places,
  PlaceMeaning meaning,
  String preposition,
) {
  return _uniquePlacesByText(
    places
        .where((place) => place.prepositions[meaning]?.text == preposition)
        .toList(),
  );
}

PredicatePath _times(List<TimePhrase> times) {
  return PredicatePath.timePhrase(_uniqueTimesByText(times));
}

PredicatePath _frequencies(List<FrequencyPhrase> frequencies) {
  return PredicatePath.frequencyPhrase(_uniqueFrequenciesByText(frequencies));
}

PredicatePath _manners(List<MannerPhrase> manners) {
  return PredicatePath.mannerPhrase(_uniqueMannersByText(manners));
}

List<PredicatePath> _cookingContexts() {
  return [
    _inLocations([
      place_data.kitchenPlacePhrase,
      place_data.restaurantPlacePhrase,
      place_data.homePlacePhrase,
    ]),
    _manners(_carefulManners),
    _times(_todayTimes),
  ];
}

List<PredicatePath> _workContexts() {
  return [
    _atLocations(_homeSchoolWorkPlaces),
    _inLocations([..._homeSchoolWorkPlaces, place_data.itDomainPlacePhrase]),
    _manners(_carefulManners),
    _times(_todayTimes),
  ];
}

List<PredicatePath> _sportContexts() {
  return [
    _atLocations(_everydayPlaces),
    _manners(_performanceManners),
    _times(_todayTimes),
  ];
}

List<PredicatePath> _speechContexts() {
  return [_manners(_speechManners), _times(_todayTimes)];
}

List<PredicatePath> _studySurfaceContexts() {
  return [
    _atLocations(_homeSchoolWorkPlaces),
    _inLocations([..._homeSchoolWorkPlaces, place_data.itDomainPlacePhrase]),
    _manners(_carefulManners),
    _times(_todayTimes),
  ];
}

List<PredicatePath> _studyContexts() {
  return [
    PredicatePath.aboutTopic(_basicTopics),
    PredicatePath.withCompanion(_people),
    ..._studySurfaceContexts(),
  ];
}

List<PredicatePath> _travelContexts() {
  return [
    _atLocations(_everydayPlaces),
    _inLocations(_everydayPlaces),
    _fromLocations(_homeSchoolWorkPlaces),
    _manners(_movementManners),
    _times(_todayTimes),
  ];
}

List<PredicatePath> _movementContexts() {
  return [
    _atLocations(_everydayPlaces),
    _inLocations(_everydayPlaces),
    _manners(_movementManners),
    _times(_todayTimes),
  ];
}

final guidedPredicateUnlocks = [
  PredicateUnlocks(
    verb: be,
    paths: [
      _atLocations(_homeSchoolWorkPlaces),
      _inLocations(_homeSchoolWorkPlaces),
      _onLocations(_surfacePlaces),
      _fromLocations([
        place_data.polandPlacePhrase,
        place_data.europePlacePhrase,
        place_data.homePlacePhrase,
        place_data.schoolPlacePhrase,
      ]),
      _times(_todayTimes),
      _manners([
        manner_data.quietlyMannerPhrase,
        manner_data.happilyMannerPhrase,
      ]),
    ],
  ),
  _directWithPaths(
    have,
    _everydayObjects,
    paths: [
      PredicatePath.withCompanion(_people),
      _atLocations(_homeSchoolWorkPlaces),
      _inLocations(_homeSchoolWorkPlaces),
      _times(_todayTimes),
      _frequencies(_basicFrequencies),
    ],
  ),
  _directWithPaths(
    doVerb,
    _doObjects,
    paths: [
      PredicatePath.withCompanion(_people),
      _manners([
        manner_data.quicklyMannerPhrase,
        manner_data.carefullyMannerPhrase,
        manner_data.againMannerPhrase,
      ]),
      _times(_todayTimes),
    ],
  ),
  _directWithPaths(
    findVerb,
    _findableObjects,
    paths: [
      _atLocations(_everydayPlaces),
      _inLocations(_everydayPlaces),
      _onLocations(_surfacePlaces),
      PredicatePath.withCompanion(_people),
      _manners([
        manner_data.quicklyMannerPhrase,
        manner_data.byAccidentMannerPhrase,
      ]),
    ],
  ),
  PredicateUnlocks(
    verb: sing,
    paths: [
      PredicatePath.directObject(_musicObjects),
      PredicatePath.toAddressee(_people),
      PredicatePath.withCompanion(_people),
      _beneficiaries(),
      _atLocations(_homeSchoolWorkPlaces),
      _inLocations(_homeSchoolWorkPlaces),
      _manners(_performanceManners),
    ],
  ),
  _directWithPaths(
    breakVerb,
    _breakableObjects,
    paths: [
      PredicatePath.withInstrument(_toolObjects),
      _manners([..._mistakeManners, manner_data.quicklyMannerPhrase]),
      _times(_todayTimes),
    ],
  ),
  _directWithPaths(
    read,
    _uniqueByText([..._textObjects, ..._spokenLanguages]),
    paths: [
      PredicatePath.aboutTopic(_basicTopics),
      PredicatePath.toAddressee(_people),
      PredicatePath.withCompanion(_people),
      _beneficiaries(),
      _purposes([fixed_object.schoolNoun, fixed_object.workNoun]),
      _atLocations(_homeSchoolWorkPlaces),
      _inLocations(_homeSchoolWorkPlaces),
      _onLocations([place_data.bedPlacePhrase, place_data.tablePlacePhrase]),
      _times([time_data.atNightTimePhrase, ..._todayTimes]),
      _manners([manner_data.carefullyMannerPhrase]),
    ],
  ),
  PredicateUnlocks(
    verb: begin,
    paths: [
      PredicatePath.directObject(_learnSubjects),
      PredicatePath.directObject(_beginObjects),
      PredicatePath.toRightAction(_rightActionBegins),
      PredicatePath.withCompanion(_people),
      _atLocations(_homeSchoolWorkPlaces),
      _inLocations(_homeSchoolWorkPlaces),
      _times([time_data.todayTimePhrase, time_data.nowTimePhrase]),
    ],
  ),
  PredicateUnlocks(
    verb: go,
    paths: [
      PredicatePath.toDestination(_people),
      PredicatePath.withCompanion(_people),
      _places(_everydayPlaces),
      _fromLocations(_everydayPlaces),
      _purposes(_movementPurposes),
      _times(_basicTimes),
      _manners([
        ..._movementManners,
        manner_data.awayMannerPhrase,
        manner_data.backMannerPhrase,
        manner_data.thereMannerPhrase,
      ]),
      _frequencies(_basicFrequencies),
    ],
  ),
  PredicateUnlocks(
    verb: come,
    paths: [
      PredicatePath.toDestination(_people),
      PredicatePath.withCompanion(_people),
      _places(_homeSchoolWorkPlaces),
      _fromLocations(_homeSchoolWorkPlaces),
      _times(_basicTimes),
      _manners([
        ..._movementManners,
        manner_data.hereMannerPhrase,
        manner_data.backMannerPhrase,
      ]),
    ],
  ),
  _directWithPaths(
    get,
    _everydayObjects,
    paths: [
      _sources(),
      _beneficiaries(),
      _atLocations(_homeSchoolWorkPlaces),
      _inLocations(_homeSchoolWorkPlaces),
      _fromLocations(_homeSchoolWorkPlaces),
      _times(_todayTimes),
    ],
  ),
  PredicateUnlocks(
    verb: make,
    paths: [
      PredicatePath.directObject(_everydayObjects),
      PredicatePath.toRecipient(_people),
      PredicatePath.withCompanion(_people),
      _manners(_carefulManners),
    ],
  ),
  _directWithPaths(
    take,
    _uniqueByText([..._everydayObjects, ..._photoObjects]),
    paths: [
      _sources(),
      PredicatePath.toDestination(_people, requiresObject: true),
      PredicatePath.withCompanion(_people),
      _atLocations(_everydayPlaces),
      _inLocations(_everydayPlaces),
      _fromLocations(_everydayPlaces),
      _manners(_movementManners),
      _times(_todayTimes),
    ],
  ),
  _directWithPaths(
    bring,
    _uniqueByText([..._everydayObjects, ..._photoObjects]),
    paths: [
      _sources(),
      PredicatePath.toDestination(_people, requiresObject: true),
      PredicatePath.withCompanion(_people),
      _atLocations(_everydayPlaces),
      _inLocations(_everydayPlaces),
      _fromLocations(_everydayPlaces),
      _manners(_movementManners),
      _times(_todayTimes),
    ],
  ),
  PredicateUnlocks(
    verb: give,
    paths: [
      PredicatePath.directObject(_transferObjects),
      PredicatePath.toRecipient(_people),
      PredicatePath.withCompanion(_people),
      _beneficiaries(),
      _times(_todayTimes),
    ],
  ),
  _directWithPaths(
    know,
    _uniqueByText([
      fixed_object.answer,
      ..._peopleAndAnimals,
      ..._learnSubjects,
    ]),
    paths: [
      PredicatePath.aboutTopic(_basicTopics),
      _manners([manner_data.wellMannerPhrase, manner_data.alreadyMannerPhrase]),
      _times([time_data.nowTimePhrase]),
    ],
  ),
  PredicateUnlocks(
    verb: think,
    paths: [
      PredicatePath.aboutTopic(_basicTopics),
      PredicatePath.ofTopic(_peopleAndAnimals),
      PredicatePath.withCompanion(_people),
      _manners([
        manner_data.carefullyMannerPhrase,
        manner_data.quicklyMannerPhrase,
      ]),
      _times(_todayTimes),
    ],
  ),
  PredicateUnlocks(
    verb: say,
    paths: [
      PredicatePath.directObject(_sayObjects),
      PredicatePath.toAddressee(_people),
      PredicatePath.aboutTopic(_basicTopics),
      _manners(_speechManners),
    ],
  ),
  _directWithPaths(
    see,
    _uniqueByText([..._peopleAndAnimals, ..._everydayObjects]),
    paths: [
      PredicatePath.withCompanion(_people),
      _atLocations(_everydayPlaces),
      _inLocations(_everydayPlaces),
      _manners([manner_data.clearlyMannerPhrase]),
      _times(_todayTimes),
    ],
  ),
  PredicateUnlocks(
    verb: want,
    paths: [
      PredicatePath.directObject(
        _uniqueByText([..._everydayObjects, ..._people]),
      ),
      PredicatePath.toRightAction(_rightActionWants),
      PredicatePath.withCompanion(_people),
      _times([time_data.nowTimePhrase]),
    ],
  ),
  PredicateUnlocks(
    verb: need,
    paths: [
      PredicatePath.directObject(
        _uniqueByText([..._everydayObjects, ..._people]),
      ),
      PredicatePath.toRightAction(_rightActionNeeds),
      _times([time_data.nowTimePhrase]),
    ],
  ),
  PredicateUnlocks(
    verb: like,
    paths: [
      PredicatePath.directObject(
        _uniqueByText([
          ..._everydayObjects,
          ..._peopleAndAnimals,
          ..._musicObjects,
          ..._gameObjects,
        ]),
      ),
      PredicatePath.toRightAction(_rightActionLikes),
      PredicatePath.withCompanion(_people),
      _frequencies(_basicFrequencies),
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
          ..._foodObjects,
        ]),
      ),
      PredicatePath.toRightAction(_rightActionLoves),
      PredicatePath.withCompanion(_people),
      _frequencies(_basicFrequencies),
    ],
  ),
  _directWithPaths(
    meet,
    _peopleAndAnimals,
    paths: [
      PredicatePath.withCompanion(_people),
      _atLocations(_homeSchoolWorkPlaces),
      _inLocations(_homeSchoolWorkPlaces),
      _times([
        time_data.todayTimePhrase,
        time_data.tomorrowTimePhrase,
        time_data.laterTimePhrase,
      ]),
    ],
  ),
  PredicateUnlocks(
    verb: work,
    paths: [
      PredicatePath.withCompanion(_people),
      PredicatePath.withInstrument(_toolObjects),
      PredicatePath.onTopic(_workTopics),
      _beneficiaries(),
      _atLocations(_homeSchoolWorkPlaces),
      _inLocations([..._homeSchoolWorkPlaces, place_data.itDomainPlacePhrase]),
      _manners([
        manner_data.quicklyMannerPhrase,
        manner_data.carefullyMannerPhrase,
        manner_data.manuallyMannerPhrase,
      ]),
      _times(_todayTimes),
      _frequencies(_basicFrequencies),
    ],
  ),
  PredicateUnlocks(
    verb: buy,
    paths: [
      PredicatePath.directObject(
        _uniqueByText([..._moneyObjects, ..._everydayObjects]),
      ),
      PredicatePath.toRecipient(_people),
      PredicatePath.withCompanion(_people),
      _beneficiaries(),
      _sources(),
      _inLocations([place_data.shopPlacePhrase]),
      _times(_todayTimes),
    ],
  ),
  PredicateUnlocks(
    verb: sell,
    paths: [
      PredicatePath.directObject(_saleObjects),
      PredicatePath.toAddressee(_people),
      PredicatePath.withCompanion(_people),
      _inLocations([place_data.shopPlacePhrase]),
      _times(_todayTimes),
    ],
  ),
  _directWithPaths(
    use,
    _toolObjects,
    paths: [
      PredicatePath.withCompanion(_people),
      _purposes(_basicPurposes),
      _manners(_carefulManners),
      _times(_todayTimes),
    ],
  ),
  _directWithPaths(
    watch,
    _mediaObjects,
    paths: [
      PredicatePath.withCompanion(_people),
      PredicatePath.toRightAction([
        education_data.research,
        education_data.analyze,
        learn,
      ]),
      _atLocations(_homeSchoolWorkPlaces),
      _inLocations(_homeSchoolWorkPlaces),
      _onLocations([place_data.bedPlacePhrase]),
      _manners([
        manner_data.closelyMannerPhrase,
        manner_data.quietlyMannerPhrase,
      ]),
    ],
  ),
  _directWithPaths(
    lose,
    _uniqueByText([..._moneyObjects, ..._toolObjects, ..._gameObjects]),
    paths: [
      _atLocations(_everydayPlaces),
      _inLocations(_everydayPlaces),
      _onLocations(_surfacePlaces),
      _manners(_mistakeManners),
      _times(_todayTimes),
    ],
  ),
  PredicateUnlocks(
    verb: play,
    paths: [
      PredicatePath.directObject(
        _uniqueByText([..._playActivities, ..._musicObjects, ..._gameObjects]),
      ),
      PredicatePath.withCompanion(_people),
      _beneficiaries(),
      _atLocations(_homeSchoolWorkPlaces),
      _inLocations(_homeSchoolWorkPlaces),
      _onLocations(_surfacePlaces),
      _manners([..._performanceManners, manner_data.outsideMannerPhrase]),
    ],
  ),
  PredicateUnlocks(
    verb: learn,
    paths: [
      PredicatePath.directObject(_learnSubjects),
      PredicatePath.aboutTopic(_basicTopics),
      PredicatePath.toRightAction(_rightActionLearns),
      PredicatePath.withCompanion(_people),
      _sources(),
      _purposes(_learningPurposes),
      _atLocations(_homeSchoolWorkPlaces),
      _inLocations(_homeSchoolWorkPlaces),
      _manners([manner_data.quicklyMannerPhrase]),
    ],
  ),
  PredicateUnlocks(
    verb: hate,
    paths: [
      PredicatePath.directObject(
        _uniqueByText([..._peopleAndAnimals, ..._everydayObjects]),
      ),
      PredicatePath.toRightAction(_rightActionHates),
      _manners([manner_data.quietlyMannerPhrase]),
    ],
  ),
  PredicateUnlocks(
    verb: remember,
    paths: [
      PredicatePath.directObject(
        _uniqueByText([
          ..._peopleAndAnimals,
          ..._learnSubjects,
          ..._textObjects,
        ]),
      ),
      PredicatePath.toRightAction(_rightActionRemembers),
      _manners([
        manner_data.clearlyMannerPhrase,
        manner_data.alreadyMannerPhrase,
      ]),
      _times(_todayTimes),
    ],
  ),
  PredicateUnlocks(
    verb: sleep,
    paths: [
      PredicatePath.withCompanion(_people),
      _atLocations([place_data.homePlacePhrase]),
      _inLocations([place_data.inBedPlacePhrase]),
      _onLocations([place_data.bedPlacePhrase]),
      _times([time_data.atNightTimePhrase, ..._todayTimes]),
      _manners([
        manner_data.wellMannerPhrase,
        manner_data.badlyMannerPhrase,
        manner_data.quietlyMannerPhrase,
      ]),
    ],
  ),
  _directWithPaths(
    open,
    _openableObjects,
    paths: [
      PredicatePath.withInstrument(_openingInstruments),
      _beneficiaries(),
      _manners(_carefulManners),
      _times(_todayTimes),
    ],
  ),
  _directWithPaths(
    close,
    _openableObjects,
    paths: [
      PredicatePath.withInstrument(_openingInstruments),
      _beneficiaries(),
      _manners(_carefulManners),
      _times(_todayTimes),
    ],
  ),
  PredicateUnlocks(
    verb: help,
    paths: [
      PredicatePath.directObject(_peopleAndAnimals),
      PredicatePath.toRightAction(_rightActionHelps),
      _atLocations(_homeSchoolWorkPlaces),
      _inLocations(_homeSchoolWorkPlaces),
      _times(_todayTimes),
    ],
  ),
  PredicateUnlocks(
    verb: speak,
    paths: [
      PredicatePath.directObject(_spokenLanguages),
      PredicatePath.aboutTopic(_basicTopics),
      PredicatePath.toAddressee(_peopleAndAnimals),
      PredicatePath.withCompanion(_people),
      ..._speechContexts(),
    ],
  ),
  PredicateUnlocks(
    verb: talk,
    paths: [
      PredicatePath.aboutTopic(_basicTopics),
      PredicatePath.toAddressee(_peopleAndAnimals),
      PredicatePath.withCompanion(_people),
      ..._speechContexts(),
    ],
  ),
  PredicateUnlocks(
    verb: tell,
    paths: [
      PredicatePath.directObject(_textObjects),
      PredicatePath.toRecipient(_people),
      ..._speechContexts(),
    ],
  ),
  PredicateUnlocks(
    verb: ask,
    paths: [
      PredicatePath.toAddressee(_peopleAndAnimals),
      PredicatePath.aboutTopic(_basicTopics),
      _manners(_speechManners),
    ],
  ),
  PredicateUnlocks(
    verb: answer,
    paths: [
      PredicatePath.directObject(_textObjects),
      PredicatePath.toAddressee(_people),
      _manners(_speechManners),
    ],
  ),
  _directWithPaths(call, _peopleAndAnimals, paths: _speechContexts()),
  PredicateUnlocks(
    verb: listen,
    paths: [PredicatePath.toAddressee(_peopleAndAnimals), ..._speechContexts()],
  ),
  PredicateUnlocks(
    verb: hear,
    paths: [
      _sources(),
      PredicatePath.aboutTopic(_basicTopics),
      ..._speechContexts(),
    ],
  ),
  PredicateUnlocks(
    verb: write,
    paths: [
      PredicatePath.directObject(_textObjects),
      PredicatePath.toRecipient(_people),
      PredicatePath.toAddressee(_people),
      PredicatePath.withCompanion(_people),
      PredicatePath.withInstrument(_writingInstruments),
      _beneficiaries(),
      _onLocations([place_data.tablePlacePhrase]),
    ],
  ),
  PredicateUnlocks(
    verb: explain,
    paths: [
      PredicatePath.directObject(_learnSubjects),
      PredicatePath.aboutTopic(_basicTopics),
      PredicatePath.toAddressee(_people),
      ..._speechContexts(),
    ],
  ),
  _directWithPaths(
    describe,
    _basicTopics,
    paths: [
      _manners([manner_data.clearlyMannerPhrase]),
    ],
  ),
  _directWithPaths(
    discuss,
    _basicTopics,
    paths: [PredicatePath.withCompanion(_people), _manners(_speechManners)],
  ),
  PredicateUnlocks(
    verb: agree,
    paths: [
      PredicatePath.withCompanion(_people),
      PredicatePath.aboutTopic(_basicTopics),
      ..._speechContexts(),
    ],
  ),
  PredicateUnlocks(
    verb: disagree,
    paths: [
      PredicatePath.withCompanion(_people),
      PredicatePath.aboutTopic(_basicTopics),
      ..._speechContexts(),
    ],
  ),
  PredicateUnlocks(
    verb: laugh,
    paths: [
      PredicatePath.withCompanion(_people),
      _manners([
        manner_data.loudlyMannerPhrase,
        manner_data.quietlyMannerPhrase,
        manner_data.happilyMannerPhrase,
      ]),
    ],
  ),
  PredicateUnlocks(
    verb: smile,
    paths: [
      PredicatePath.withCompanion(_people),
      _manners([
        manner_data.happilyMannerPhrase,
        manner_data.politelyMannerPhrase,
      ]),
    ],
  ),
  PredicateUnlocks(
    verb: shout,
    paths: [PredicatePath.toAddressee(_peopleAndAnimals), ..._speechContexts()],
  ),
  PredicateUnlocks(
    verb: whisper,
    paths: [PredicatePath.toAddressee(_peopleAndAnimals), ..._speechContexts()],
  ),
  PredicateUnlocks(
    verb: introduce,
    paths: [
      PredicatePath.directObject(_peopleAndAnimals),
      PredicatePath.toAddressee(_peopleAndAnimals),
    ],
  ),
  _directWithPaths(
    education_data.study,
    _learnSubjects,
    paths: [_purposes(_learningPurposes), ..._studyContexts()],
  ),
  PredicateUnlocks(
    verb: education_data.teach,
    paths: [
      PredicatePath.directObject(_learnSubjects),
      PredicatePath.toRecipient(_people),
      PredicatePath.toRightAction(_rightActionTeaches),
      PredicatePath.withCompanion(_people),
    ],
  ),
  _directWithPaths(
    education_data.spell,
    _textObjects,
    paths: _studySurfaceContexts(),
  ),
  _directWithPaths(
    education_data.count,
    _uniqueByText([..._learnSubjects, ..._gameObjects]),
    paths: _studySurfaceContexts(),
  ),
  _directWithPaths(
    education_data.calculate,
    _learnSubjects,
    paths: _studySurfaceContexts(),
  ),
  _directWithPaths(
    education_data.solve,
    _learnSubjects,
    paths: _studySurfaceContexts(),
  ),
  _directWithPaths(
    education_data.understand,
    _uniqueByText([..._learnSubjects, ..._people]),
    paths: [PredicatePath.aboutTopic(_basicTopics)],
  ),
  _directWithPaths(
    education_data.forget,
    _uniqueByText([..._learnSubjects, ..._people]),
    paths: [
      PredicatePath.toRightAction(_rightActionForgets),
      ..._studySurfaceContexts(),
    ],
  ),
  _directWithPaths(
    education_data.practice,
    _uniqueByText([..._learnSubjects, ..._playActivities]),
    paths: [_purposes(_trainingPurposes)],
  ),
  _directWithPaths(
    education_data.repeat,
    _learnSubjects,
    paths: _studySurfaceContexts(),
  ),
  _directWithPaths(
    education_data.improve,
    _uniqueByText([..._learnSubjects, ..._textObjects]),
    paths: _studySurfaceContexts(),
  ),
  PredicateUnlocks(
    verb: education_data.graduate,
    paths: [
      _fromLocations([
        place_data.schoolPlacePhrase,
        place_data.universityPlacePhrase,
      ]),
      _times([time_data.todayTimePhrase, time_data.laterTimePhrase]),
    ],
  ),
  _directWithPaths(
    education_data.research,
    _learnSubjects,
    paths: [PredicatePath.aboutTopic(_basicTopics)],
  ),
  _destinationWithCompanion(
    walk,
    paths: [
      PredicatePath.toRightAction(_rightActionMovementPurposes),
      _purposes(_movementPurposes),
      ..._movementContexts(),
    ],
  ),
  _destinationWithCompanion(
    run,
    paths: [
      PredicatePath.toRightAction(_rightActionMovementPurposes),
      _purposes(_movementPurposes),
      ..._movementContexts(),
    ],
  ),
  PredicateUnlocks(verb: jump, paths: _movementContexts()),
  _destinationWithCompanion(
    swim,
    paths: [
      PredicatePath.toRightAction(_rightActionMovementPurposes),
      _purposes(_movementPurposes),
      ..._movementContexts(),
    ],
  ),
  _destinationWithCompanion(fly, paths: _travelContexts()),
  PredicateUnlocks(
    verb: climb,
    paths: [_onLocations(_surfacePlaces), ..._movementContexts()],
  ),
  PredicateUnlocks(verb: crawl, paths: _movementContexts()),
  PredicateUnlocks(
    verb: dance,
    paths: [
      PredicatePath.withCompanion(_people),
      _manners(_performanceManners),
    ],
  ),
  PredicateUnlocks(verb: dive, paths: _movementContexts()),
  PredicateUnlocks(
    verb: fall,
    paths: [
      _atLocations(_everydayPlaces),
      _inLocations(_everydayPlaces),
      _manners([manner_data.byAccidentMannerPhrase]),
      _times(_todayTimes),
    ],
  ),
  PredicateUnlocks(
    verb: drive,
    paths: [
      PredicatePath.directObject(_drivableObjects),
      PredicatePath.toDestination(_people),
      ..._travelContexts(),
    ],
  ),
  PredicateUnlocks(
    verb: ride,
    paths: [
      PredicatePath.directObject(_rideableObjects),
      PredicatePath.toDestination(_people),
      ..._travelContexts(),
    ],
  ),
  _destinationWithCompanion(sail, paths: _travelContexts()),
  _destinationWithCompanion(skate, paths: _travelContexts()),
  _destinationWithCompanion(ski, paths: _travelContexts()),
  PredicateUnlocks(
    verb: sit,
    paths: [
      PredicatePath.withCompanion(_people),
      _onLocations([place_data.bedPlacePhrase, place_data.tablePlacePhrase]),
    ],
  ),
  PredicateUnlocks(
    verb: stand,
    paths: [
      PredicatePath.withCompanion(_people),
      _onLocations([place_data.bridgePlacePhrase, place_data.tablePlacePhrase]),
    ],
  ),
  PredicateUnlocks(
    verb: lie,
    paths: [
      PredicatePath.withCompanion(_people),
      _onLocations([place_data.bedPlacePhrase]),
    ],
  ),
  _destinationWithCompanion(travel_data.travel, paths: _travelContexts()),
  _destinationWithCompanion(travel_data.arrive, paths: _travelContexts()),
  _destinationWithCompanion(travel_data.leave, paths: _travelContexts()),
  _directWithPaths(
    travel_data.visit,
    _peopleAndAnimals,
    paths: _travelContexts(),
  ),
  PredicateUnlocks(
    verb: travel_data.depart,
    paths: [_fromLocations(_everydayPlaces), _times(_basicTimes)],
  ),
  _destinationWithCompanion(travel_data.returnVerb, paths: _travelContexts()),
  _directWithPaths(
    travel_data.explore,
    _uniqueByText([..._everydayObjects, ..._peopleAndAnimals]),
    paths: _travelContexts(),
  ),
  _directWithPaths(
    travel_data.book,
    _travelObjects,
    paths: [_beneficiaries(), ..._travelContexts()],
  ),
  _directWithPaths(
    travel_data.pack,
    _uniqueByText([..._openableObjects, ..._clothingObjects, ..._toolObjects]),
    paths: _travelContexts(),
  ),
  _directWithPaths(
    travel_data.unpack,
    _uniqueByText([..._openableObjects, ..._clothingObjects, ..._toolObjects]),
    paths: _travelContexts(),
  ),
  _directWithPaths(
    travel_data.board,
    _uniqueByText([..._drivableObjects]),
    paths: _travelContexts(),
  ),
  PredicateUnlocks(verb: travel_data.land, paths: _travelContexts()),
  _directWithPaths(travel_data.rent, _travelObjects, paths: _travelContexts()),
  _directWithPaths(
    travel_data.reserve,
    _travelObjects,
    paths: _travelContexts(),
  ),
  PredicateUnlocks(
    verb: travel_data.navigate,
    paths: [
      PredicatePath.withInstrument(_navigationInstruments),
      _fromLocations(_everydayPlaces),
    ],
  ),
  PredicateUnlocks(
    verb: travel_data.photograph,
    paths: [
      PredicatePath.directObject(
        _uniqueByText([..._peopleAndAnimals, ..._mediaObjects]),
      ),
      PredicatePath.withInstrument(_photoInstruments),
      _atLocations(_everydayPlaces),
      _inLocations(_everydayPlaces),
    ],
  ),
  PredicateUnlocks(verb: travel_data.camp, paths: _travelContexts()),
  PredicateUnlocks(
    verb: travel_data.hike,
    paths: [
      _atLocations(_everydayPlaces),
      _fromLocations(_everydayPlaces),
      _manners(_movementManners),
    ],
  ),
  PredicateUnlocks(verb: travel_data.stay, paths: _travelContexts()),
  _directWithPaths(travel_data.cross, [
    object_data.bridge.toNounPhrase(Number.singular),
    object_data.bridge.toNounPhrase(Number.plural),
  ], paths: _travelContexts()),
  _directWithPaths(
    cooking_data.cook,
    _foodObjects,
    paths: [
      PredicatePath.withInstrument(_mixingInstruments),
      _beneficiaries(),
      _purposes(_cookingPurposes),
      ..._cookingContexts(),
    ],
  ),
  _directWithPaths(cooking_data.bake, _foodObjects, paths: _cookingContexts()),
  _directWithPaths(cooking_data.fry, _foodObjects, paths: _cookingContexts()),
  _directWithPaths(cooking_data.boil, _foodObjects, paths: _cookingContexts()),
  _directWithPaths(cooking_data.grill, _foodObjects, paths: _cookingContexts()),
  _directWithPaths(
    cooking_data.eat,
    _foodObjects,
    paths: [
      PredicatePath.withInstrument(_eatingInstruments),
      ..._cookingContexts(),
    ],
  ),
  _directWithPaths(
    cooking_data.drink,
    _drinkObjects,
    paths: _cookingContexts(),
  ),
  _directWithPaths(cooking_data.roast, _foodObjects, paths: _cookingContexts()),
  _directWithPaths(cooking_data.steam, _foodObjects, paths: _cookingContexts()),
  _directWithPaths(
    cooking_data.cut,
    _foodObjects,
    paths: [
      PredicatePath.withInstrument(_cuttingInstruments),
      ..._cookingContexts(),
    ],
  ),
  _directWithPaths(
    cooking_data.chop,
    _foodObjects,
    paths: [
      PredicatePath.withInstrument(_cuttingInstruments),
      ..._cookingContexts(),
    ],
  ),
  _directWithPaths(
    cooking_data.slice,
    _foodObjects,
    paths: [
      PredicatePath.withInstrument(_cuttingInstruments),
      ..._cookingContexts(),
    ],
  ),
  _directWithPaths(
    cooking_data.peel,
    _foodObjects,
    paths: [
      PredicatePath.withInstrument(_cuttingInstruments),
      ..._cookingContexts(),
    ],
  ),
  _directWithPaths(
    cooking_data.mix,
    _foodObjects,
    paths: [
      PredicatePath.withInstrument(_mixingInstruments),
      ..._cookingContexts(),
    ],
  ),
  _directWithPaths(
    cooking_data.stir,
    _foodObjects,
    paths: [
      PredicatePath.withInstrument(_mixingInstruments),
      ..._cookingContexts(),
    ],
  ),
  _directWithPaths(cooking_data.pour, _foodObjects, paths: _cookingContexts()),
  _directWithPaths(cooking_data.add, _foodObjects, paths: _cookingContexts()),
  _directWithPaths(cooking_data.serve, _foodObjects, paths: _cookingContexts()),
  _directWithPaths(cooking_data.taste, _foodObjects, paths: _cookingContexts()),
  _directWithPaths(
    cooking_data.freeze,
    _foodObjects,
    paths: _cookingContexts(),
  ),
  _directWithPaths(cooking_data.melt, _foodObjects, paths: _cookingContexts()),
  _directWithPaths(
    cooking_data.wash,
    _uniqueByText([..._foodObjects, ..._openableObjects]),
    paths: _cookingContexts(),
  ),
  PredicateUnlocks(
    verb: sport_data.train,
    paths: [_purposes(_trainingPurposes), ..._sportContexts()],
  ),
  PredicateUnlocks(
    verb: sport_data.exercise,
    paths: [_purposes(_movementPurposes), ..._sportContexts()],
  ),
  PredicateUnlocks(verb: sport_data.score, paths: _sportContexts()),
  _directWithPaths(sport_data.win, _gameObjects, paths: _sportContexts()),
  PredicateUnlocks(
    verb: sport_data.compete,
    paths: [PredicatePath.withCompanion(_people), _purposes(_trainingPurposes)],
  ),
  PredicateUnlocks(
    verb: sport_data.box,
    paths: [PredicatePath.withCompanion(_people), ..._sportContexts()],
  ),
  PredicateUnlocks(
    verb: sport_data.wrestle,
    paths: [PredicatePath.withCompanion(_people), ..._sportContexts()],
  ),
  PredicateUnlocks(
    verb: sport_data.surf,
    paths: [
      _atLocations(_everydayPlaces),
      _manners(_movementManners),
      _times(_todayTimes),
    ],
  ),
  PredicateUnlocks(
    verb: sport_data.cycle,
    paths: [
      _atLocations(_everydayPlaces),
      _manners(_movementManners),
      _times(_todayTimes),
    ],
  ),
  _directWithPaths(
    work_data.build,
    _uniqueByText([
      ...object_categories.singularFurnitureObjects,
      ...object_categories.singularOpenableObjects,
    ]),
    paths: _workContexts(),
  ),
  _directWithPaths(
    work_data.create,
    _uniqueByText([..._textObjects, ..._mediaObjects]),
    paths: _workContexts(),
  ),
  _directWithPaths(
    work_data.design,
    _uniqueByText([..._textObjects, ..._deviceObjects]),
    paths: _workContexts(),
  ),
  _directWithPaths(
    work_data.develop,
    _uniqueByText([..._deviceObjects, ..._textObjects]),
    paths: _workContexts(),
  ),
  _directWithPaths(work_data.program, _deviceObjects, paths: _workContexts()),
  _directWithPaths(
    work_data.testVerb,
    _uniqueByText([..._deviceObjects, ..._textObjects]),
    paths: _workContexts(),
  ),
  _directWithPaths(work_data.debug, _deviceObjects, paths: _workContexts()),
  _directWithPaths(
    work_data.fix,
    _uniqueByText([..._deviceObjects, ..._openableObjects]),
    paths: _workContexts(),
  ),
  _directWithPaths(
    work_data.repair,
    _uniqueByText([..._deviceObjects, ..._openableObjects]),
    paths: _workContexts(),
  ),
  _directWithPaths(
    work_data.clean,
    _uniqueByText([
      ..._deviceObjects,
      ...object_categories.singularFurnitureObjects,
      ..._openableObjects,
    ]),
    paths: _workContexts(),
  ),
  _directWithPaths(
    work_data.organize,
    _uniqueByText([..._textObjects, ..._toolObjects]),
    paths: _workContexts(),
  ),
  _directWithPaths(
    work_data.manage,
    _uniqueByText([..._people, ..._textObjects]),
    paths: _workContexts(),
  ),
  _directWithPaths(work_data.lead, _people, paths: _workContexts()),
  _directWithPaths(
    work_data.deliver,
    _uniqueByText([..._textObjects, ..._moneyObjects]),
    paths: _workContexts(),
  ),
  _directWithPaths(
    work_data.produce,
    _uniqueByText([..._textObjects, ..._mediaObjects]),
    paths: _workContexts(),
  ),
  _directWithPaths(work_data.earn, _moneyObjects, paths: _workContexts()),
  _directWithPaths(
    sport_data.lift,
    _uniqueByText([..._gameObjects, ..._toolObjects]),
    paths: _sportContexts(),
  ),
  _directWithPaths(
    sport_data.throwVerb,
    _throwCatchObjects,
    paths: _sportContexts(),
  ),
  _directWithPaths(
    sport_data.catchVerb,
    _throwCatchObjects,
    paths: _sportContexts(),
  ),
  _directWithPaths(sport_data.kick, _gameObjects, paths: _sportContexts()),
  _directWithPaths(sport_data.hit, _gameObjects, paths: _sportContexts()),
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
    verb: bring,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author bringable object and destination tracks',
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

bool predicatePathRequiresObject(Verb verb, PredicatePathKind kind) {
  return predicatePathsFor(
    verb,
  ).any((path) => path.kind == kind && path.requiresObject);
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

List<PlacePhrase> predicatePlaceChoicesFor(Verb verb, PredicatePathKind kind) {
  return _uniquePlacesByText([
    for (final path in predicatePathsFor(
      verb,
    ).where((path) => path.kind == kind))
      ...path.places,
  ]);
}

List<PlacePhrase> predicateAuthoredPlaceChoicesFor(Verb verb) {
  return _uniquePlacesByText([
    for (final kind in predicateAuthoredPlacePathKinds)
      ...predicatePlaceChoicesFor(verb, kind),
  ]);
}

List<String> predicateLocationConnectorsFor(Verb verb) {
  return [
    for (final kind in predicateLocationPathKinds)
      if (predicatePlaceChoicesFor(verb, kind).isNotEmpty)
        predicatePlaceConnectorFor(kind)!,
  ];
}

List<String> predicateSourceLocationConnectorsFor(Verb verb) {
  return [
    for (final kind in predicateSourceLocationPathKinds)
      if (predicatePlaceChoicesFor(verb, kind).isNotEmpty)
        predicatePlaceConnectorFor(kind)!,
  ];
}

List<String> predicateTopicConnectorsFor(Verb verb) {
  return [
    for (final kind in predicateTopicPathKinds)
      if (predicateNounChoicesFor(verb, kind).isNotEmpty)
        predicateTopicConnectorFor(kind)!,
  ];
}

List<TimePhrase> predicateTimeChoicesFor(Verb verb, PredicatePathKind kind) {
  return _uniqueTimesByText([
    for (final path in predicatePathsFor(
      verb,
    ).where((path) => path.kind == kind))
      ...path.times,
  ]);
}

List<FrequencyPhrase> predicateFrequencyChoicesFor(
  Verb verb,
  PredicatePathKind kind,
) {
  return _uniqueFrequenciesByText([
    for (final path in predicatePathsFor(
      verb,
    ).where((path) => path.kind == kind))
      ...path.frequencies,
  ]);
}

List<MannerPhrase> predicateMannerChoicesFor(
  Verb verb,
  PredicatePathKind kind,
) {
  return _uniqueMannersByText([
    for (final path in predicatePathsFor(
      verb,
    ).where((path) => path.kind == kind))
      ...path.manners,
  ]);
}

PredicatePathMigrationDecision? predicatePathMigrationFor(Verb verb) {
  for (final decision in essentialPredicatePathMigration) {
    if (decision.verb.infinitive == verb.infinitive) {
      return decision;
    }
  }
  return null;
}
