import '../models/grammar/verb.dart';

const work = Verb(
  infinitive: 'work',
  presentThirdPerson: 'works',
  pastSimple: 'worked',
  pastParticiple: 'worked',
);

const play = Verb(
  infinitive: 'play',
  presentThirdPerson: 'plays',
  pastSimple: 'played',
  pastParticiple: 'played',
);

const go = Verb(
  infinitive: 'go',
  presentThirdPerson: 'goes',
  pastSimple: 'went',
  pastParticiple: 'gone',
);

const verbs = [work, play, go];
