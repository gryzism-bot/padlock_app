import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/language.dart';

const speak = Verb(
  infinitive: 'speak',
  presentThirdPerson: 'speaks',
  pastSimple: 'spoke',
  pastParticiple: 'spoken',
  ingForm: 'speaking',
  translations: {Language.pl: 'mówić'},
);

const talk = Verb(
  infinitive: 'talk',
  presentThirdPerson: 'talks',
  pastSimple: 'talked',
  pastParticiple: 'talked',
  ingForm: 'talking',
  translations: {Language.pl: 'rozmawiać'},
);

const tell = Verb(
  infinitive: 'tell',
  presentThirdPerson: 'tells',
  pastSimple: 'told',
  pastParticiple: 'told',
  ingForm: 'telling',
  translations: {Language.pl: 'powiedzieć'},
);

const ask = Verb(
  infinitive: 'ask',
  presentThirdPerson: 'asks',
  pastSimple: 'asked',
  pastParticiple: 'asked',
  ingForm: 'asking',
  translations: {Language.pl: 'pytać'},
);

const answer = Verb(
  infinitive: 'answer',
  presentThirdPerson: 'answers',
  pastSimple: 'answered',
  pastParticiple: 'answered',
  ingForm: 'answering',
  translations: {Language.pl: 'odpowiadać'},
);

const call = Verb(
  infinitive: 'call',
  presentThirdPerson: 'calls',
  pastSimple: 'called',
  pastParticiple: 'called',
  ingForm: 'calling',
  translations: {Language.pl: 'dzwonić'},
);

const listen = Verb(
  infinitive: 'listen',
  presentThirdPerson: 'listens',
  pastSimple: 'listened',
  pastParticiple: 'listened',
  ingForm: 'listening',
  translations: {Language.pl: 'słuchać'},
);

const hear = Verb(
  infinitive: 'hear',
  presentThirdPerson: 'hears',
  pastSimple: 'heard',
  pastParticiple: 'heard',
  ingForm: 'hearing',
  translations: {Language.pl: 'słyszeć'},
);

const read = Verb(
  infinitive: 'read',
  presentThirdPerson: 'reads',
  pastSimple: 'read',
  pastParticiple: 'read',
  ingForm: 'reading',
  translations: {Language.pl: 'czytać'},
);

const write = Verb(
  infinitive: 'write',
  presentThirdPerson: 'writes',
  pastSimple: 'wrote',
  pastParticiple: 'written',
  ingForm: 'writing',
  translations: {Language.pl: 'pisać'},
);

const explain = Verb(
  infinitive: 'explain',
  presentThirdPerson: 'explains',
  pastSimple: 'explained',
  pastParticiple: 'explained',
  ingForm: 'explaining',
  translations: {Language.pl: 'wyjaśniać'},
);

const describe = Verb(
  infinitive: 'describe',
  presentThirdPerson: 'describes',
  pastSimple: 'described',
  pastParticiple: 'described',
  ingForm: 'describing',
  translations: {Language.pl: 'opisywać'},
);

const discuss = Verb(
  infinitive: 'discuss',
  presentThirdPerson: 'discusses',
  pastSimple: 'discussed',
  pastParticiple: 'discussed',
  ingForm: 'discussing',
  translations: {Language.pl: 'dyskutować'},
);

const agree = Verb(
  infinitive: 'agree',
  presentThirdPerson: 'agrees',
  pastSimple: 'agreed',
  pastParticiple: 'agreed',
  ingForm: 'agreeing',
  translations: {Language.pl: 'zgadzać się'},
);

const disagree = Verb(
  infinitive: 'disagree',
  presentThirdPerson: 'disagrees',
  pastSimple: 'disagreed',
  pastParticiple: 'disagreed',
  ingForm: 'disagreeing',
  translations: {Language.pl: 'nie zgadzać się'},
);

const laugh = Verb(
  infinitive: 'laugh',
  presentThirdPerson: 'laughs',
  pastSimple: 'laughed',
  pastParticiple: 'laughed',
  ingForm: 'laughing',
  translations: {Language.pl: 'śmiać się'},
);

const smile = Verb(
  infinitive: 'smile',
  presentThirdPerson: 'smiles',
  pastSimple: 'smiled',
  pastParticiple: 'smiled',
  ingForm: 'smiling',
  translations: {Language.pl: 'uśmiechać się'},
);

const shout = Verb(
  infinitive: 'shout',
  presentThirdPerson: 'shouts',
  pastSimple: 'shouted',
  pastParticiple: 'shouted',
  ingForm: 'shouting',
  translations: {Language.pl: 'krzyczeć'},
);

const whisper = Verb(
  infinitive: 'whisper',
  presentThirdPerson: 'whispers',
  pastSimple: 'whispered',
  pastParticiple: 'whispered',
  ingForm: 'whispering',
  translations: {Language.pl: 'szeptać'},
);

const introduce = Verb(
  infinitive: 'introduce',
  presentThirdPerson: 'introduces',
  pastSimple: 'introduced',
  pastParticiple: 'introduced',
  ingForm: 'introducing',
  translations: {Language.pl: 'przedstawiać'},
);

List<Verb> communicationVerbs = [
  speak,
  talk,
  tell,
  ask,
  answer,
  call,
  listen,
  hear,
  read,
  write,
  explain,
  describe,
  discuss,
  agree,
  disagree,
  laugh,
  smile,
  shout,
  whisper,
  introduce,
];
