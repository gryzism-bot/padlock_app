import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/cooking.dart';
import 'package:padlock_app/data/verbs/education.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/data/verbs/sport.dart';
import 'package:padlock_app/data/verbs/travel.dart';
import 'package:padlock_app/data/verbs/work.dart';

import '../../models/grammar/verb/verb.dart';
import '../../models/language.dart';

const be = Verb(
  infinitive: 'be',
  presentThirdPerson: 'is',
  pastSimple: 'was',
  pastParticiple: 'been',
  ingForm: 'being',
  translations: {Language.pl: 'być'},
);

const have = Verb(
  infinitive: 'have',
  presentThirdPerson: 'has',
  pastSimple: 'had',
  pastParticiple: 'had',
  ingForm: 'having',
  takesObject: true,
  translations: {Language.pl: 'mieć'},
);

const doVerb = Verb(
  infinitive: 'do',
  presentThirdPerson: 'does',
  pastSimple: 'did',
  pastParticiple: 'done',
  ingForm: 'doing',
  translations: {Language.pl: 'robić'},
);

const findVerb = Verb(
  infinitive: 'find',
  presentThirdPerson: 'finds',
  pastSimple: 'found',
  pastParticiple: 'found',
  ingForm: 'finding',
  takesObject: true,
  translations: {Language.pl: 'znaleźć'},
);

const sing = Verb(
  infinitive: 'sing',
  presentThirdPerson: 'sings',
  pastSimple: 'sang',
  pastParticiple: 'sung',
  ingForm: 'singing',
  translations: {Language.pl: 'śpiewać'},
);

const breakVerb = Verb(
  infinitive: 'break',
  presentThirdPerson: 'breaks',
  pastSimple: 'broke',
  pastParticiple: 'broken',
  ingForm: 'breaking',
  translations: {Language.pl: 'złamać'},
);

const read = Verb(
  infinitive: 'read',
  presentThirdPerson: 'reads',
  pastSimple: 'read',
  pastParticiple: 'read',
  ingForm: 'reading',
  takesObject: true,
  translations: {Language.pl: 'czytać'},
);

const begin = Verb(
  infinitive: 'begin',
  presentThirdPerson: 'begins',
  pastSimple: 'began',
  pastParticiple: 'begun',
  ingForm: 'beginning',
  translations: {Language.pl: 'zaczynać'},
);

const go = Verb(
  infinitive: 'go',
  presentThirdPerson: 'goes',
  pastSimple: 'went',
  pastParticiple: 'gone',
  ingForm: 'going',
  usesDestinationPlace: true,
  translations: {Language.pl: 'iść'},
);

const come = Verb(
  infinitive: 'come',
  presentThirdPerson: 'comes',
  pastSimple: 'came',
  pastParticiple: 'come',
  ingForm: 'coming',
  usesDestinationPlace: true,
  translations: {Language.pl: 'przyjść'},
);

const get = Verb(
  infinitive: 'get',
  presentThirdPerson: 'gets',
  pastSimple: 'got',
  pastParticiple: 'got',
  ingForm: 'getting',
  takesObject: true,
  translations: {Language.pl: 'dostać'},
);

const make = Verb(
  infinitive: 'make',
  presentThirdPerson: 'makes',
  pastSimple: 'made',
  pastParticiple: 'made',
  ingForm: 'making',
  takesObject: true,
  takesRecipient: true,
  takesObjectComplement: true,
  translations: {Language.pl: 'robić'},
);

const take = Verb(
  infinitive: 'take',
  presentThirdPerson: 'takes',
  pastSimple: 'took',
  pastParticiple: 'taken',
  ingForm: 'taking',
  takesObject: true,
  translations: {Language.pl: 'brać'},
);

const give = Verb(
  infinitive: 'give',
  presentThirdPerson: 'gives',
  pastSimple: 'gave',
  pastParticiple: 'given',
  ingForm: 'giving',
  takesObject: true,
  takesRecipient: true,
  translations: {Language.pl: 'dać'},
);

const know = Verb(
  infinitive: 'know',
  presentThirdPerson: 'knows',
  pastSimple: 'knew',
  pastParticiple: 'known',
  ingForm: 'knowing',
  takesObject: true,
  translations: {Language.pl: 'wiedzieć'},
);

const think = Verb(
  infinitive: 'think',
  presentThirdPerson: 'thinks',
  pastSimple: 'thought',
  pastParticiple: 'thought',
  ingForm: 'thinking',
  translations: {Language.pl: 'myśleć'},
);

const say = Verb(
  infinitive: 'say',
  presentThirdPerson: 'says',
  pastSimple: 'said',
  pastParticiple: 'said',
  ingForm: 'saying',
  translations: {Language.pl: 'powiedzieć'},
);

const see = Verb(
  infinitive: 'see',
  presentThirdPerson: 'sees',
  pastSimple: 'saw',
  pastParticiple: 'seen',
  ingForm: 'seeing',
  takesObject: true,
  translations: {Language.pl: 'widzieć'},
);

const want = Verb(
  infinitive: 'want',
  presentThirdPerson: 'wants',
  pastSimple: 'wanted',
  pastParticiple: 'wanted',
  ingForm: 'wanting',
  takesObject: true,
  translations: {Language.pl: 'chcieć'},
);

const need = Verb(
  infinitive: 'need',
  presentThirdPerson: 'needs',
  pastSimple: 'needed',
  pastParticiple: 'needed',
  ingForm: 'needing',
  takesObject: true,
  translations: {Language.pl: 'potrzebować'},
);

const meet = Verb(
  infinitive: 'meet',
  presentThirdPerson: 'meets',
  pastSimple: 'met',
  pastParticiple: 'met',
  ingForm: 'meeting',
  takesObject: true,
  translations: {Language.pl: 'spotykać'},
);

const like = Verb(
  infinitive: 'like',
  presentThirdPerson: 'likes',
  pastSimple: 'liked',
  pastParticiple: 'liked',
  ingForm: 'liking',
  takesObject: true,
  translations: {Language.pl: 'lubić'},
);

const love = Verb(
  infinitive: 'love',
  presentThirdPerson: 'loves',
  pastSimple: 'loved',
  pastParticiple: 'loved',
  ingForm: 'loving',
  takesObject: true,
  translations: {Language.pl: 'kochać'},
);

const work = Verb(
  infinitive: 'work',
  presentThirdPerson: 'works',
  pastSimple: 'worked',
  pastParticiple: 'worked',
  ingForm: 'working',
  translations: {Language.pl: 'pracować'},
);

const buy = Verb(
  infinitive: 'buy',
  presentThirdPerson: 'buys',
  pastSimple: 'bought',
  pastParticiple: 'bought',
  ingForm: 'buying',
  takesObject: true,
  takesRecipient: true,
  translations: {Language.pl: 'kupować'},
);

const sell = Verb(
  infinitive: 'sell',
  presentThirdPerson: 'sells',
  pastSimple: 'sold',
  pastParticiple: 'sold',
  ingForm: 'selling',
  takesObject: true,
  translations: {Language.pl: 'sprzedawać'},
);

const use = Verb(
  infinitive: 'use',
  presentThirdPerson: 'uses',
  pastSimple: 'used',
  pastParticiple: 'used',
  ingForm: 'using',
  takesObject: true,
  translations: {Language.pl: 'używać'},
);

const watch = Verb(
  infinitive: 'watch',
  presentThirdPerson: 'watches',
  pastSimple: 'watched',
  pastParticiple: 'watched',
  ingForm: 'watching',
  takesObject: true,
  translations: {Language.pl: 'oglądać'},
);

const lose = Verb(
  infinitive: 'lose',
  presentThirdPerson: 'loses',
  pastSimple: 'lost',
  pastParticiple: 'lost',
  ingForm: 'losing',
  takesObject: true,
  translations: {Language.pl: 'zgubić'},
);

const play = Verb(
  infinitive: 'play',
  presentThirdPerson: 'plays',
  pastSimple: 'played',
  pastParticiple: 'played',
  ingForm: 'playing',
  takesObject: true,
  translations: {Language.pl: 'grać'},
);

const learn = Verb(
  infinitive: 'learn',
  presentThirdPerson: 'learns',
  pastSimple: 'learned',
  pastParticiple: 'learned',
  ingForm: 'learning',
  takesObject: true,
  translations: {Language.pl: 'uczyć się'},
);

const hate = Verb(
  infinitive: 'hate',
  presentThirdPerson: 'hates',
  pastSimple: 'hated',
  pastParticiple: 'hated',
  ingForm: 'hating',
  takesObject: true,
  translations: {Language.pl: 'nienawidzić'},
);

const remember = Verb(
  infinitive: 'remember',
  presentThirdPerson: 'remembers',
  pastSimple: 'remembered',
  pastParticiple: 'remembered',
  ingForm: 'remembering',
  takesObject: true,
  translations: {Language.pl: 'pamiętać'},
);

const sleep = Verb(
  infinitive: 'sleep',
  presentThirdPerson: 'sleeps',
  pastSimple: 'slept',
  pastParticiple: 'slept',
  ingForm: 'sleeping',
  translations: {Language.pl: 'spać'},
);

const open = Verb(
  infinitive: 'open',
  presentThirdPerson: 'opens',
  pastSimple: 'opened',
  pastParticiple: 'opened',
  ingForm: 'opening',
  takesObject: true,
  translations: {Language.pl: 'otwierać'},
);

const close = Verb(
  infinitive: 'close',
  presentThirdPerson: 'closes',
  pastSimple: 'closed',
  pastParticiple: 'closed',
  ingForm: 'closing',
  takesObject: true,
  translations: {Language.pl: 'zamykać'},
);

const help = Verb(
  infinitive: 'help',
  presentThirdPerson: 'helps',
  pastSimple: 'helped',
  pastParticiple: 'helped',
  ingForm: 'helping',
  takesObject: true,
  translations: {Language.pl: 'pomagać'},
);

final List<Verb> essentialVerbs = [
  be,
  have,
  doVerb,
  findVerb,
  sing,
  breakVerb,
  begin,
  go,
  come,
  get,
  make,
  take,
  give,
  know,
  think,
  say,
  see,
  want,
  need,
  like,
  love,
  work,
  play,
  learn,
  sleep,
  remember,
  hate,
  meet,
  use,
  open,
  close,
  help,
  buy,
  sell,
  read,
  watch,
  lose,
];

final List<Verb> verbs = [
  ...communicationVerbs,
  ...cookingVerbs,
  ...educationVerbs,
  ...essentialVerbs,
  ...movementVerbs,
  ...sportVerbs,
  ...travelVerbs,
  ...workVerbs,
];
