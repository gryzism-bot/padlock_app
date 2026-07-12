import 'package:padlock_app/models/language.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';

const build = Verb(
  infinitive: 'build',
  presentThirdPerson: 'builds',
  pastSimple: 'built',
  pastParticiple: 'built',
  ingForm: 'building',
  takesObject: true,
  translations: {Language.pl: 'budować'},
);

const create = Verb(
  infinitive: 'create',
  presentThirdPerson: 'creates',
  pastSimple: 'created',
  pastParticiple: 'created',
  ingForm: 'creating',
  takesObject: true,
  translations: {Language.pl: 'tworzyć'},
);

const design = Verb(
  infinitive: 'design',
  presentThirdPerson: 'designs',
  pastSimple: 'designed',
  pastParticiple: 'designed',
  ingForm: 'designing',
  takesObject: true,
  translations: {Language.pl: 'projektować'},
);

const develop = Verb(
  infinitive: 'develop',
  presentThirdPerson: 'develops',
  pastSimple: 'developed',
  pastParticiple: 'developed',
  ingForm: 'developing',
  takesObject: true,
  translations: {Language.pl: 'rozwijać'},
);

const program = Verb(
  infinitive: 'program',
  presentThirdPerson: 'programs',
  pastSimple: 'programmed',
  pastParticiple: 'programmed',
  ingForm: 'programming',
  takesObject: true,
  translations: {Language.pl: 'programować'},
);

const testVerb = Verb(
  infinitive: 'test',
  presentThirdPerson: 'tests',
  pastSimple: 'tested',
  pastParticiple: 'tested',
  ingForm: 'testing',
  takesObject: true,
  translations: {Language.pl: 'testować'},
);

const debug = Verb(
  infinitive: 'debug',
  presentThirdPerson: 'debugs',
  pastSimple: 'debugged',
  pastParticiple: 'debugged',
  ingForm: 'debugging',
  takesObject: true,
  translations: {Language.pl: 'debugować'},
);

const fix = Verb(
  infinitive: 'fix',
  presentThirdPerson: 'fixes',
  pastSimple: 'fixed',
  pastParticiple: 'fixed',
  ingForm: 'fixing',
  takesObject: true,
  translations: {Language.pl: 'naprawiać'},
);

const repair = Verb(
  infinitive: 'repair',
  presentThirdPerson: 'repairs',
  pastSimple: 'repaired',
  pastParticiple: 'repaired',
  ingForm: 'repairing',
  takesObject: true,
  translations: {Language.pl: 'naprawiać'},
);

const clean = Verb(
  infinitive: 'clean',
  presentThirdPerson: 'cleans',
  pastSimple: 'cleaned',
  pastParticiple: 'cleaned',
  ingForm: 'cleaning',
  takesObject: true,
  translations: {Language.pl: 'czyścić'},
);

const organize = Verb(
  infinitive: 'organize',
  presentThirdPerson: 'organizes',
  pastSimple: 'organized',
  pastParticiple: 'organized',
  ingForm: 'organizing',
  takesObject: true,
  translations: {Language.pl: 'organizować'},
);

const manage = Verb(
  infinitive: 'manage',
  presentThirdPerson: 'manages',
  pastSimple: 'managed',
  pastParticiple: 'managed',
  ingForm: 'managing',
  takesObject: true,
  translations: {Language.pl: 'zarządzać'},
);

const lead = Verb(
  infinitive: 'lead',
  presentThirdPerson: 'leads',
  pastSimple: 'led',
  pastParticiple: 'led',
  ingForm: 'leading',
  translations: {Language.pl: 'prowadzić'},
);

const deliver = Verb(
  infinitive: 'deliver',
  presentThirdPerson: 'delivers',
  pastSimple: 'delivered',
  pastParticiple: 'delivered',
  ingForm: 'delivering',
  takesObject: true,
  translations: {Language.pl: 'dostarczać'},
);

const produce = Verb(
  infinitive: 'produce',
  presentThirdPerson: 'produces',
  pastSimple: 'produced',
  pastParticiple: 'produced',
  ingForm: 'producing',
  takesObject: true,
  translations: {Language.pl: 'produkować'},
);

const earn = Verb(
  infinitive: 'earn',
  presentThirdPerson: 'earns',
  pastSimple: 'earned',
  pastParticiple: 'earned',
  ingForm: 'earning',
  takesObject: true,
  translations: {Language.pl: 'zarabiać'},
);

List<Verb> workVerbs = [
  build,
  create,
  design,
  develop,
  program,
  testVerb,
  debug,
  fix,
  repair,
  clean,
  organize,
  manage,
  lead,
  deliver,
  produce,
  earn,
];
