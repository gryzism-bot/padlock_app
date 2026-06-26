import '../models/grammar/verb.dart';

const work = Verb(
  infinitive: 'work',
  presentThirdPerson: 'works',
  pastSimple: 'worked',
  pastParticiple: 'worked',
  ingForm: 'working',
);

const play = Verb(
  infinitive: 'play',
  presentThirdPerson: 'plays',
  pastSimple: 'played',
  pastParticiple: 'played',
  ingForm: 'playing',
);

const go = Verb(
  infinitive: 'go',
  presentThirdPerson: 'goes',
  pastSimple: 'went',
  pastParticiple: 'gone',
  ingForm: 'going',
);

const verbs = [work, play, go];
