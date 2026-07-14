import 'package:padlock_app/data/subjects/third_person/animals.dart' as animals;
import 'package:padlock_app/models/grammar/subject/noun.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';

const petAnimalNouns = [
  animals.cat,
  animals.dog,
  animals.puppy,
  animals.kitten,
  animals.rabbit,
  animals.fish,
  animals.parrot,
];

const farmAnimalNouns = [
  animals.horse,
  animals.cow,
  animals.pig,
  animals.sheep,
  animals.goat,
  animals.chicken,
  animals.duck,
  animals.donkey,
];

const wildAnimalNouns = [
  animals.bear,
  animals.wolf,
  animals.fox,
  animals.lion,
  animals.tiger,
  animals.elephant,
  animals.monkey,
  animals.snake,
  animals.turtle,
  animals.camel,
  animals.deer,
  animals.giraffe,
  animals.zebra,
];

const smallAnimalNouns = [
  animals.mouse,
  animals.bee,
  animals.butterfly,
  animals.frog,
  animals.spider,
  animals.ant,
];

const birdAnimalNouns = [
  animals.bird,
  animals.chicken,
  animals.duck,
  animals.owl,
  animals.eagle,
  animals.parrot,
];

const waterAnimalNouns = [
  animals.fish,
  animals.dolphin,
  animals.whale,
  animals.shark,
];

List<NounPhrase> _singular(List<Noun> nouns) {
  return [for (final noun in nouns) noun.toNounPhrase(Number.singular)];
}

List<NounPhrase> _plural(List<Noun> nouns) {
  return [for (final noun in nouns) noun.toNounPhrase(Number.plural)];
}

final singularPetAnimals = _singular(petAnimalNouns);
final pluralPetAnimals = _plural(petAnimalNouns);

final singularFarmAnimals = _singular(farmAnimalNouns);
final pluralFarmAnimals = _plural(farmAnimalNouns);

final singularWildAnimals = _singular(wildAnimalNouns);
final pluralWildAnimals = _plural(wildAnimalNouns);

final singularSmallAnimals = _singular(smallAnimalNouns);
final pluralSmallAnimals = _plural(smallAnimalNouns);

final singularBirdAnimals = _singular(birdAnimalNouns);
final pluralBirdAnimals = _plural(birdAnimalNouns);

final singularWaterAnimals = _singular(waterAnimalNouns);
final pluralWaterAnimals = _plural(waterAnimalNouns);

final singularEverydayAnimals = [
  ...singularPetAnimals,
  ...singularFarmAnimals,
  ...singularWildAnimals,
  ...singularSmallAnimals,
  ...singularBirdAnimals,
  ...singularWaterAnimals,
];

final pluralEverydayAnimals = [
  ...pluralPetAnimals,
  ...pluralFarmAnimals,
  ...pluralWildAnimals,
  ...pluralSmallAnimals,
  ...pluralBirdAnimals,
  ...pluralWaterAnimals,
];
