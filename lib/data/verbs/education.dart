import 'package:padlock_app/models/language.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';

const study = Verb(
  infinitive: 'study',
  presentThirdPerson: 'studies',
  pastSimple: 'studied',
  pastParticiple: 'studied',
  ingForm: 'studying',
  takesObject: true,
  translations: {Language.pl: 'uczyć się'},
);

const teach = Verb(
  infinitive: 'teach',
  presentThirdPerson: 'teaches',
  pastSimple: 'taught',
  pastParticiple: 'taught',
  ingForm: 'teaching',
  takesObject: true,
  takesRecipient: true,
  translations: {Language.pl: 'uczyć'},
);

const spell = Verb(
  infinitive: 'spell',
  presentThirdPerson: 'spells',
  pastSimple: 'spelled',
  pastParticiple: 'spelled',
  ingForm: 'spelling',
  translations: {Language.pl: 'literować'},
);

const count = Verb(
  infinitive: 'count',
  presentThirdPerson: 'counts',
  pastSimple: 'counted',
  pastParticiple: 'counted',
  ingForm: 'counting',
  translations: {Language.pl: 'liczyć'},
);

const calculate = Verb(
  infinitive: 'calculate',
  presentThirdPerson: 'calculates',
  pastSimple: 'calculated',
  pastParticiple: 'calculated',
  ingForm: 'calculating',
  translations: {Language.pl: 'obliczać'},
);

const solve = Verb(
  infinitive: 'solve',
  presentThirdPerson: 'solves',
  pastSimple: 'solved',
  pastParticiple: 'solved',
  ingForm: 'solving',
  translations: {Language.pl: 'rozwiązywać'},
);

const understand = Verb(
  infinitive: 'understand',
  presentThirdPerson: 'understands',
  pastSimple: 'understood',
  pastParticiple: 'understood',
  ingForm: 'understanding',
  translations: {Language.pl: 'rozumieć'},
);

const forget = Verb(
  infinitive: 'forget',
  presentThirdPerson: 'forgets',
  pastSimple: 'forgot',
  pastParticiple: 'forgotten',
  ingForm: 'forgetting',
  translations: {Language.pl: 'zapominać'},
);

const practice = Verb(
  infinitive: 'practice',
  presentThirdPerson: 'practices',
  pastSimple: 'practiced',
  pastParticiple: 'practiced',
  ingForm: 'practicing',
  translations: {Language.pl: 'ćwiczyć'},
);

const repeat = Verb(
  infinitive: 'repeat',
  presentThirdPerson: 'repeats',
  pastSimple: 'repeated',
  pastParticiple: 'repeated',
  ingForm: 'repeating',
  translations: {Language.pl: 'powtarzać'},
);

const improve = Verb(
  infinitive: 'improve',
  presentThirdPerson: 'improves',
  pastSimple: 'improved',
  pastParticiple: 'improved',
  ingForm: 'improving',
  translations: {Language.pl: 'polepszać'},
);

const graduate = Verb(
  infinitive: 'graduate',
  presentThirdPerson: 'graduates',
  pastSimple: 'graduated',
  pastParticiple: 'graduated',
  ingForm: 'graduating',
  translations: {Language.pl: 'ukończyć szkołę'},
);

const research = Verb(
  infinitive: 'research',
  presentThirdPerson: 'researches',
  pastSimple: 'researched',
  pastParticiple: 'researched',
  ingForm: 'researching',
  translations: {Language.pl: 'prowadzić badania'},
);

List<Verb> educationVerbs = [
  study,
  teach,
  spell,
  count,
  calculate,
  solve,
  understand,
  forget,
  practice,
  repeat,
  improve,
  graduate,
  research,
];
