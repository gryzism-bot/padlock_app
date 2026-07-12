import '../../models/grammar/verb/verb.dart';
import '../../models/language.dart';

const walk = Verb(
  infinitive: 'walk',
  presentThirdPerson: 'walks',
  pastSimple: 'walked',
  pastParticiple: 'walked',
  ingForm: 'walking',
  takesCompanion: true,
  translations: {Language.pl: 'chodzić'},
);

const run = Verb(
  infinitive: 'run',
  presentThirdPerson: 'runs',
  pastSimple: 'ran',
  pastParticiple: 'run',
  ingForm: 'running',
  takesCompanion: true,
  translations: {Language.pl: 'biegać'},
);

const jump = Verb(
  infinitive: 'jump',
  presentThirdPerson: 'jumps',
  pastSimple: 'jumped',
  pastParticiple: 'jumped',
  ingForm: 'jumping',
  translations: {Language.pl: 'skakać'},
);

const swim = Verb(
  infinitive: 'swim',
  presentThirdPerson: 'swims',
  pastSimple: 'swam',
  pastParticiple: 'swum',
  ingForm: 'swimming',
  translations: {Language.pl: 'pływać'},
);

const fly = Verb(
  infinitive: 'fly',
  presentThirdPerson: 'flies',
  pastSimple: 'flew',
  pastParticiple: 'flown',
  ingForm: 'flying',
  translations: {Language.pl: 'latać'},
);

const drive = Verb(
  infinitive: 'drive',
  presentThirdPerson: 'drives',
  pastSimple: 'drove',
  pastParticiple: 'driven',
  ingForm: 'driving',
  takesObject: true,
  translations: {Language.pl: 'prowadzić'},
);

const ride = Verb(
  infinitive: 'ride',
  presentThirdPerson: 'rides',
  pastSimple: 'rode',
  pastParticiple: 'ridden',
  ingForm: 'riding',
  takesObject: true,
  translations: {Language.pl: 'jeździć'},
);

const climb = Verb(
  infinitive: 'climb',
  presentThirdPerson: 'climbs',
  pastSimple: 'climbed',
  pastParticiple: 'climbed',
  ingForm: 'climbing',
  translations: {Language.pl: 'wspinać się'},
);

const crawl = Verb(
  infinitive: 'crawl',
  presentThirdPerson: 'crawls',
  pastSimple: 'crawled',
  pastParticiple: 'crawled',
  ingForm: 'crawling',
  translations: {Language.pl: 'czołgać się'},
);

const dance = Verb(
  infinitive: 'dance',
  presentThirdPerson: 'dances',
  pastSimple: 'danced',
  pastParticiple: 'danced',
  ingForm: 'dancing',
  translations: {Language.pl: 'tańczyć'},
);

const sail = Verb(
  infinitive: 'sail',
  presentThirdPerson: 'sails',
  pastSimple: 'sailed',
  pastParticiple: 'sailed',
  ingForm: 'sailing',
  translations: {Language.pl: 'żeglować'},
);

const skate = Verb(
  infinitive: 'skate',
  presentThirdPerson: 'skates',
  pastSimple: 'skated',
  pastParticiple: 'skated',
  ingForm: 'skating',
  translations: {Language.pl: 'jeździć na łyżwach'},
);

const ski = Verb(
  infinitive: 'ski',
  presentThirdPerson: 'skis',
  pastSimple: 'skied',
  pastParticiple: 'skied',
  ingForm: 'skiing',
  translations: {Language.pl: 'jeździć na nartach'},
);

const dive = Verb(
  infinitive: 'dive',
  presentThirdPerson: 'dives',
  pastSimple: 'dived',
  pastParticiple: 'dived',
  ingForm: 'diving',
  translations: {Language.pl: 'nurkować'},
);

const fall = Verb(
  infinitive: 'fall',
  presentThirdPerson: 'falls',
  pastSimple: 'fell',
  pastParticiple: 'fallen',
  ingForm: 'falling',
  translations: {Language.pl: 'upadać'},
);

const stand = Verb(
  infinitive: 'stand',
  presentThirdPerson: 'stands',
  pastSimple: 'stood',
  pastParticiple: 'stood',
  ingForm: 'standing',
  translations: {Language.pl: 'stać'},
);

const sit = Verb(
  infinitive: 'sit',
  presentThirdPerson: 'sits',
  pastSimple: 'sat',
  pastParticiple: 'sat',
  ingForm: 'sitting',
  translations: {Language.pl: 'siedzieć'},
);

const lie = Verb(
  infinitive: 'lie',
  presentThirdPerson: 'lies',
  pastSimple: 'lay',
  pastParticiple: 'lain',
  ingForm: 'lying',
  translations: {Language.pl: 'leżeć'},
);

List<Verb> movementVerbs = [
  walk,
  run,
  jump,
  swim,
  fly,
  drive,
  ride,
  climb,
  crawl,
  dance,
  sail,
  skate,
  ski,
  dive,
  fall,
  stand,
  sit,
  lie,
];
