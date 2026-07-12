import 'package:padlock_app/models/language.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';

const travel = Verb(
  infinitive: 'travel',
  presentThirdPerson: 'travels',
  pastSimple: 'travelled',
  pastParticiple: 'travelled',
  ingForm: 'travelling',
  usesDestinationPlace: true,
  takesCompanion: true,
  translations: {Language.pl: 'podróżować'},
);

const visit = Verb(
  infinitive: 'visit',
  presentThirdPerson: 'visits',
  pastSimple: 'visited',
  pastParticiple: 'visited',
  ingForm: 'visiting',
  translations: {Language.pl: 'odwiedzać'},
);

const arrive = Verb(
  infinitive: 'arrive',
  presentThirdPerson: 'arrives',
  pastSimple: 'arrived',
  pastParticiple: 'arrived',
  ingForm: 'arriving',
  usesDestinationPlace: true,
  takesCompanion: true,
  translations: {Language.pl: 'przybyć'},
);

const leave = Verb(
  infinitive: 'leave',
  presentThirdPerson: 'leaves',
  pastSimple: 'left',
  pastParticiple: 'left',
  ingForm: 'leaving',
  usesDestinationPlace: true,
  takesCompanion: true,
  translations: {Language.pl: 'opuścić'},
);

const depart = Verb(
  infinitive: 'depart',
  presentThirdPerson: 'departs',
  pastSimple: 'departed',
  pastParticiple: 'departed',
  ingForm: 'departing',
  translations: {Language.pl: 'odjeżdżać'},
);

const returnVerb = Verb(
  infinitive: 'return',
  presentThirdPerson: 'returns',
  pastSimple: 'returned',
  pastParticiple: 'returned',
  ingForm: 'returning',
  usesDestinationPlace: true,
  takesCompanion: true,
  translations: {Language.pl: 'wrócić'},
);

const explore = Verb(
  infinitive: 'explore',
  presentThirdPerson: 'explores',
  pastSimple: 'explored',
  pastParticiple: 'explored',
  ingForm: 'exploring',
  translations: {Language.pl: 'odkrywać'},
);

const book = Verb(
  infinitive: 'book',
  presentThirdPerson: 'books',
  pastSimple: 'booked',
  pastParticiple: 'booked',
  ingForm: 'booking',
  translations: {Language.pl: 'rezerwować'},
);

const pack = Verb(
  infinitive: 'pack',
  presentThirdPerson: 'packs',
  pastSimple: 'packed',
  pastParticiple: 'packed',
  ingForm: 'packing',
  translations: {Language.pl: 'pakować'},
);

const unpack = Verb(
  infinitive: 'unpack',
  presentThirdPerson: 'unpacks',
  pastSimple: 'unpacked',
  pastParticiple: 'unpacked',
  ingForm: 'unpacking',
  translations: {Language.pl: 'rozpakowywać'},
);

const board = Verb(
  infinitive: 'board',
  presentThirdPerson: 'boards',
  pastSimple: 'boarded',
  pastParticiple: 'boarded',
  ingForm: 'boarding',
  translations: {Language.pl: 'wsiadać'},
);

const land = Verb(
  infinitive: 'land',
  presentThirdPerson: 'lands',
  pastSimple: 'landed',
  pastParticiple: 'landed',
  ingForm: 'landing',
  translations: {Language.pl: 'lądować'},
);

const rent = Verb(
  infinitive: 'rent',
  presentThirdPerson: 'rents',
  pastSimple: 'rented',
  pastParticiple: 'rented',
  ingForm: 'renting',
  translations: {Language.pl: 'wynajmować'},
);

const reserve = Verb(
  infinitive: 'reserve',
  presentThirdPerson: 'reserves',
  pastSimple: 'reserved',
  pastParticiple: 'reserved',
  ingForm: 'reserving',
  translations: {Language.pl: 'rezerwować'},
);

const navigate = Verb(
  infinitive: 'navigate',
  presentThirdPerson: 'navigates',
  pastSimple: 'navigated',
  pastParticiple: 'navigated',
  ingForm: 'navigating',
  translations: {Language.pl: 'nawigować'},
);

const camp = Verb(
  infinitive: 'camp',
  presentThirdPerson: 'camps',
  pastSimple: 'camped',
  pastParticiple: 'camped',
  ingForm: 'camping',
  translations: {Language.pl: 'biwakować'},
);

const hike = Verb(
  infinitive: 'hike',
  presentThirdPerson: 'hikes',
  pastSimple: 'hiked',
  pastParticiple: 'hiked',
  ingForm: 'hiking',
  translations: {Language.pl: 'wędrować'},
);

const photograph = Verb(
  infinitive: 'photograph',
  presentThirdPerson: 'photographs',
  pastSimple: 'photographed',
  pastParticiple: 'photographed',
  ingForm: 'photographing',
  translations: {Language.pl: 'fotografować'},
);

const stay = Verb(
  infinitive: 'stay',
  presentThirdPerson: 'stays',
  pastSimple: 'stayed',
  pastParticiple: 'stayed',
  ingForm: 'staying',
  translations: {Language.pl: 'zatrzymywać się'},
);

const cross = Verb(
  infinitive: 'cross',
  presentThirdPerson: 'crosses',
  pastSimple: 'crossed',
  pastParticiple: 'crossed',
  ingForm: 'crossing',
  translations: {Language.pl: 'przekraczać'},
);

List<Verb> travelVerbs = [
  travel,
  visit,
  arrive,
  leave,
  depart,
  returnVerb,
  explore,
  book,
  pack,
  unpack,
  board,
  land,
  rent,
  reserve,
  navigate,
  camp,
  hike,
  photograph,
  stay,
  cross,
];
