import 'package:padlock_app/models/language.dart';
import 'package:padlock_app/models/grammar/subject/determiner.dart';

const aDeterminer = Determiner(
  text: 'a',
  translations: {Language.pl: '(rodzajnik nieokreślony)'},
);

const anDeterminer = Determiner(
  text: 'an',
  translations: {Language.pl: '(rodzajnik nieokreślony)'},
);

const theDeterminer = Determiner(
  text: 'the',
  translations: {Language.pl: '(rodzajnik określony)'},
);

const thisDeterminer = Determiner(
  text: 'this',
  translations: {Language.pl: 'ten'},
);

const thatDeterminer = Determiner(
  text: 'that',
  translations: {Language.pl: 'tamten'},
);

const theseDeterminer = Determiner(
  text: 'these',
  translations: {Language.pl: 'te'},
);

const thoseDeterminer = Determiner(
  text: 'those',
  translations: {Language.pl: 'tamte'},
);

const someDeterminer = Determiner(
  text: 'some',
  translations: {Language.pl: 'kilka'},
);

const allDeterminer = Determiner(
  text: 'all',
  translations: {Language.pl: 'wszystkie'},
);

const anyDeterminer = Determiner(
  text: 'any',
  translations: {Language.pl: 'jakiekolwiek'},
);

const eachDeterminer = Determiner(
  text: 'each',
  translations: {Language.pl: 'każdy'},
);

const everyDeterminer = Determiner(
  text: 'every',
  translations: {Language.pl: 'każdy'},
);

const noDeterminer = Determiner(
  text: 'no',
  translations: {Language.pl: 'żaden'},
);

const myDeterminer = Determiner(text: 'my', translations: {Language.pl: 'mój'});

const yourDeterminer = Determiner(
  text: 'your',
  translations: {Language.pl: 'twój'},
);

const hisDeterminer = Determiner(
  text: 'his',
  translations: {Language.pl: 'jego'},
);

const herDeterminer = Determiner(
  text: 'her',
  translations: {Language.pl: 'jej'},
);

const ourDeterminer = Determiner(
  text: 'our',
  translations: {Language.pl: 'nasz'},
);

const theirDeterminer = Determiner(
  text: 'their',
  translations: {Language.pl: 'ich'},
);

const manyDeterminer = Determiner(
  text: 'many',
  translations: {Language.pl: 'wiele'},
);

List<Determiner> allDeterminers = [
  aDeterminer,
  anDeterminer,
  theDeterminer,
  thisDeterminer,
  thatDeterminer,
  theseDeterminer,
  thoseDeterminer,
  someDeterminer,
  allDeterminer,
  anyDeterminer,
  eachDeterminer,
  everyDeterminer,
  noDeterminer,
  myDeterminer,
  yourDeterminer,
  hisDeterminer,
  herDeterminer,
  ourDeterminer,
  theirDeterminer,
  manyDeterminer,
];
