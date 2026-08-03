import '../../models/grammar/verb/verb.dart';
import '../../models/language.dart';

const turn = Verb(
  infinitive: 'turn',
  presentThirdPerson: 'turns',
  pastSimple: 'turned',
  pastParticiple: 'turned',
  ingForm: 'turning',
  takesObject: true,
  translations: {Language.pl: 'obracac'},
);

const pick = Verb(
  infinitive: 'pick',
  presentThirdPerson: 'picks',
  pastSimple: 'picked',
  pastParticiple: 'picked',
  ingForm: 'picking',
  takesObject: true,
  translations: {Language.pl: 'podnosic'},
);

const put = Verb(
  infinitive: 'put',
  presentThirdPerson: 'puts',
  pastSimple: 'put',
  pastParticiple: 'put',
  ingForm: 'putting',
  takesObject: true,
  translations: {Language.pl: 'kladac'},
);

const look = Verb(
  infinitive: 'look',
  presentThirdPerson: 'looks',
  pastSimple: 'looked',
  pastParticiple: 'looked',
  ingForm: 'looking',
  takesObject: true,
  takesTopic: true,
  translations: {Language.pl: 'patrzec'},
);

const wake = Verb(
  infinitive: 'wake',
  presentThirdPerson: 'wakes',
  pastSimple: 'woke',
  pastParticiple: 'woken',
  ingForm: 'waking',
  translations: {Language.pl: 'budzic sie'},
);

const calmVerb = Verb(
  infinitive: 'calm',
  presentThirdPerson: 'calms',
  pastSimple: 'calmed',
  pastParticiple: 'calmed',
  ingForm: 'calming',
  translations: {Language.pl: 'uspokajac sie'},
);

const slowVerb = Verb(
  infinitive: 'slow',
  presentThirdPerson: 'slows',
  pastSimple: 'slowed',
  pastParticiple: 'slowed',
  ingForm: 'slowing',
  translations: {Language.pl: 'zwalniac'},
);

const particleVerbs = [turn, pick, put, look, wake, calmVerb, slowVerb];
