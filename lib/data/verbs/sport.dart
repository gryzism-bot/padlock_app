import 'package:padlock_app/models/language.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';

const playFootball = Verb(
  infinitive: 'play football',
  presentThirdPerson: 'plays football',
  pastSimple: 'played football',
  pastParticiple: 'played football',
  ingForm: 'playing football',
  translations: {Language.pl: 'grać w piłkę nożną'},
);

const playBasketball = Verb(
  infinitive: 'play basketball',
  presentThirdPerson: 'plays basketball',
  pastSimple: 'played basketball',
  pastParticiple: 'played basketball',
  ingForm: 'playing basketball',
  translations: {Language.pl: 'grać w koszykówkę'},
);

const playVolleyball = Verb(
  infinitive: 'play volleyball',
  presentThirdPerson: 'plays volleyball',
  pastSimple: 'played volleyball',
  pastParticiple: 'played volleyball',
  ingForm: 'playing volleyball',
  translations: {Language.pl: 'grać w siatkówkę'},
);

const playTennis = Verb(
  infinitive: 'play tennis',
  presentThirdPerson: 'plays tennis',
  pastSimple: 'played tennis',
  pastParticiple: 'played tennis',
  ingForm: 'playing tennis',
  translations: {Language.pl: 'grać w tenisa'},
);

const playGolf = Verb(
  infinitive: 'play golf',
  presentThirdPerson: 'plays golf',
  pastSimple: 'played golf',
  pastParticiple: 'played golf',
  ingForm: 'playing golf',
  translations: {Language.pl: 'grać w golfa'},
);

const train = Verb(
  infinitive: 'train',
  presentThirdPerson: 'trains',
  pastSimple: 'trained',
  pastParticiple: 'trained',
  ingForm: 'training',
  translations: {Language.pl: 'trenować'},
);

const exercise = Verb(
  infinitive: 'exercise',
  presentThirdPerson: 'exercises',
  pastSimple: 'exercised',
  pastParticiple: 'exercised',
  ingForm: 'exercising',
  translations: {Language.pl: 'ćwiczyć'},
);

const lift = Verb(
  infinitive: 'lift',
  presentThirdPerson: 'lifts',
  pastSimple: 'lifted',
  pastParticiple: 'lifted',
  ingForm: 'lifting',
  takesObject: true,
  translations: {Language.pl: 'podnosić ciężary'},
);

const throwVerb = Verb(
  infinitive: 'throw',
  presentThirdPerson: 'throws',
  pastSimple: 'threw',
  pastParticiple: 'thrown',
  ingForm: 'throwing',
  takesObject: true,
  translations: {Language.pl: 'rzucać'},
);

const catchVerb = Verb(
  infinitive: 'catch',
  presentThirdPerson: 'catches',
  pastSimple: 'caught',
  pastParticiple: 'caught',
  ingForm: 'catching',
  takesObject: true,
  translations: {Language.pl: 'łapać'},
);

const kick = Verb(
  infinitive: 'kick',
  presentThirdPerson: 'kicks',
  pastSimple: 'kicked',
  pastParticiple: 'kicked',
  ingForm: 'kicking',
  takesObject: true,
  translations: {Language.pl: 'kopać'},
);

const hit = Verb(
  infinitive: 'hit',
  presentThirdPerson: 'hits',
  pastSimple: 'hit',
  pastParticiple: 'hit',
  ingForm: 'hitting',
  takesObject: true,
  translations: {Language.pl: 'uderzać'},
);

const score = Verb(
  infinitive: 'score',
  presentThirdPerson: 'scores',
  pastSimple: 'scored',
  pastParticiple: 'scored',
  ingForm: 'scoring',
  translations: {Language.pl: 'zdobywać punkt'},
);

const win = Verb(
  infinitive: 'win',
  presentThirdPerson: 'wins',
  pastSimple: 'won',
  pastParticiple: 'won',
  ingForm: 'winning',
  translations: {Language.pl: 'wygrywać'},
);

const compete = Verb(
  infinitive: 'compete',
  presentThirdPerson: 'competes',
  pastSimple: 'competed',
  pastParticiple: 'competed',
  ingForm: 'competing',
  translations: {Language.pl: 'rywalizować'},
);

const box = Verb(
  infinitive: 'box',
  presentThirdPerson: 'boxes',
  pastSimple: 'boxed',
  pastParticiple: 'boxed',
  ingForm: 'boxing',
  translations: {Language.pl: 'boksować'},
);

const wrestle = Verb(
  infinitive: 'wrestle',
  presentThirdPerson: 'wrestles',
  pastSimple: 'wrestled',
  pastParticiple: 'wrestled',
  ingForm: 'wrestling',
  translations: {Language.pl: 'zapasy'},
);

const surf = Verb(
  infinitive: 'surf',
  presentThirdPerson: 'surfs',
  pastSimple: 'surfed',
  pastParticiple: 'surfed',
  ingForm: 'surfing',
  translations: {Language.pl: 'surfować'},
);

const cycle = Verb(
  infinitive: 'cycle',
  presentThirdPerson: 'cycles',
  pastSimple: 'cycled',
  pastParticiple: 'cycled',
  ingForm: 'cycling',
  translations: {Language.pl: 'jeździć na rowerze'},
);

List<Verb> sportVerbs = [
  playFootball,
  playBasketball,
  playVolleyball,
  playTennis,
  playGolf,
  train,
  exercise,
  lift,
  throwVerb,
  catchVerb,
  kick,
  hit,
  score,
  win,
  compete,
  box,
  wrestle,
  surf,
  cycle,
];
