import 'package:padlock_app/data/subjects/third_person/animals.dart' as animals;
import 'package:padlock_app/data/subjects/third_person/objects.dart' as objects;
import 'package:padlock_app/models/grammar/subject/noun.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';

const foodObjectNouns = [
  objects.food,
  objects.apple,
  objects.bread,
  objects.sandwich,
  objects.cheese,
  objects.meat,
  objects.soup,
  objects.pizza,
  objects.salad,
  objects.potato,
  objects.carrot,
  objects.onion,
  objects.fruit,
  objects.vegetable,
  objects.pasta,
  objects.sugar,
  objects.salt,
  objects.oil,
  objects.banana,
  objects.orange,
  objects.rice,
  objects.egg,
  objects.cake,
  objects.coffee,
  objects.tea,
  objects.juice,
  objects.water,
  objects.milk,
];

const textObjectNouns = [
  objects.book,
  objects.newspaper,
  objects.letter,
  objects.story,
  objects.magazine,
  objects.document,
  objects.email,
  objects.message,
  objects.article,
  objects.note,
  objects.report,
  objects.poem,
  objects.diary,
  objects.list,
  objects.card,
  objects.script,
];

const toolObjectNouns = [
  objects.phone,
  objects.computer,
  objects.laptop,
  objects.pen,
  objects.pencil,
  objects.keyboard,
  objects.key,
  objects.camera,
  objects.map,
  objects.knife,
  objects.spoon,
  objects.fork,
  objects.brush,
  objects.hammer,
  objects.scissors,
  objects.tablet,
  objects.tool,
  objects.charger,
  objects.cable,
  objects.notebook,
  objects.ruler,
];

const deviceObjectNouns = [
  objects.phone,
  objects.speaker,
  objects.headphone,
  objects.computer,
  objects.laptop,
  objects.keyboard,
  objects.mouseDevice,
  objects.monitor,
  objects.television,
  objects.camera,
  objects.screen,
  objects.tablet,
  objects.charger,
  objects.cable,
];

const openableObjectNouns = [
  objects.book,
  objects.door,
  objects.window,
  objects.bottle,
  objects.box,
  objects.schoolbag,
  objects.bag,
  objects.wallet,
  objects.drawer,
  objects.cabinet,
  objects.folder,
];

const vehicleObjectNouns = [
  objects.car,
  objects.bus,
  objects.train,
  objects.bicycle,
];

const drivableObjectNouns = [objects.car, objects.bus, objects.train];

const rideableObjectNouns = [
  objects.bicycle,
  objects.bus,
  objects.train,
  animals.horse,
];

const mediaObjectNouns = [
  objects.television,
  objects.book,
  objects.newspaper,
  objects.magazine,
  objects.story,
  objects.movie,
  objects.film,
  objects.video,
  objects.episode,
  objects.series,
  objects.scene,
  objects.script,
  objects.song,
  objects.photo,
  objects.painting,
];

const clothingObjectNouns = [
  objects.shirt,
  objects.coat,
  objects.shoe,
  objects.hat,
];

const furnitureObjectNouns = [
  objects.table,
  objects.chair,
  objects.bed,
  objects.desk,
  objects.sofa,
  objects.lamp,
];

const moneyObjectNouns = [
  objects.gift,
  objects.coin,
  objects.wallet,
  objects.ticket,
];

const musicObjectNouns = [
  objects.guitar,
  objects.piano,
  objects.violin,
  objects.drum,
  objects.song,
];

const gameObjectNouns = [objects.ball, objects.game, objects.toy];

const placeObjectNouns = [
  objects.city,
  objects.road,
  objects.street,
  objects.station,
  objects.airport,
  objects.hotel,
  objects.beach,
  objects.forest,
  objects.river,
  objects.lake,
];

const abstractObjectNouns = [
  objects.idea,
  objects.project,
  objects.plan,
  objects.problem,
  objects.question,
  objects.answer,
  objects.lesson,
  objects.language,
  objects.skill,
];

List<NounPhrase> _singular(List<Noun> nouns) {
  return [for (final noun in nouns) noun.toNounPhrase(Number.singular)];
}

List<NounPhrase> _plural(List<Noun> nouns) {
  return [for (final noun in nouns) noun.toNounPhrase(Number.plural)];
}

final singularFoodObjects = _singular(foodObjectNouns);
final pluralFoodObjects = _plural(foodObjectNouns);

final singularTextObjects = _singular(textObjectNouns);
final pluralTextObjects = _plural(textObjectNouns);

final singularToolObjects = _singular(toolObjectNouns);
final pluralToolObjects = _plural(toolObjectNouns);

final singularDeviceObjects = _singular(deviceObjectNouns);
final pluralDeviceObjects = _plural(deviceObjectNouns);

final singularOpenableObjects = _singular(openableObjectNouns);
final pluralOpenableObjects = _plural(openableObjectNouns);

final singularVehicleObjects = _singular(vehicleObjectNouns);
final pluralVehicleObjects = _plural(vehicleObjectNouns);

final singularDrivableObjects = _singular(drivableObjectNouns);
final pluralDrivableObjects = _plural(drivableObjectNouns);

final singularRideableObjects = _singular(rideableObjectNouns);
final pluralRideableObjects = _plural(rideableObjectNouns);

final singularMediaObjects = _singular(mediaObjectNouns);
final pluralMediaObjects = _plural(mediaObjectNouns);

final singularClothingObjects = _singular(clothingObjectNouns);
final pluralClothingObjects = _plural(clothingObjectNouns);

final singularFurnitureObjects = _singular(furnitureObjectNouns);
final pluralFurnitureObjects = _plural(furnitureObjectNouns);

final singularMoneyObjects = _singular(moneyObjectNouns);
final pluralMoneyObjects = _plural(moneyObjectNouns);

final singularMusicObjects = _singular(musicObjectNouns);
final pluralMusicObjects = _plural(musicObjectNouns);

final singularGameObjects = _singular(gameObjectNouns);
final pluralGameObjects = _plural(gameObjectNouns);

final singularPlaceObjects = _singular(placeObjectNouns);
final pluralPlaceObjects = _plural(placeObjectNouns);

final singularAbstractObjects = _singular(abstractObjectNouns);
final pluralAbstractObjects = _plural(abstractObjectNouns);
