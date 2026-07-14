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
  objects.potato,
  objects.carrot,
  objects.onion,
  objects.rice,
  objects.egg,
  objects.cake,
  objects.coffee,
  objects.tea,
  objects.juice,
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
];

const toolObjectNouns = [
  objects.pen,
  objects.pencil,
  objects.keyboard,
  objects.key,
  objects.camera,
  objects.map,
  objects.knife,
  objects.spoon,
  objects.fork,
];

const deviceObjectNouns = [
  objects.phone,
  objects.computer,
  objects.laptop,
  objects.keyboard,
  objects.mouseDevice,
  objects.monitor,
  objects.television,
  objects.camera,
  objects.screen,
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
];

const vehicleObjectNouns = [
  objects.car,
  objects.bus,
  objects.train,
  objects.bicycle,
];

const mediaObjectNouns = [
  objects.television,
  objects.book,
  objects.newspaper,
  objects.magazine,
  objects.story,
  objects.movie,
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
  objects.drum,
  objects.song,
];

const gameObjectNouns = [objects.ball, objects.game, objects.toy];

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
