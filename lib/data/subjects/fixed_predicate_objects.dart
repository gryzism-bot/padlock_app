import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/subject/person.dart';
import 'package:padlock_app/models/language.dart';

const football = NounPhrase(
  text: 'football',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'piłka nożna'},
);

const basketball = NounPhrase(
  text: 'basketball',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'koszykówka'},
);

const volleyball = NounPhrase(
  text: 'volleyball',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'siatkówka'},
);

const tennis = NounPhrase(
  text: 'tennis',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'tenis'},
);

const golf = NounPhrase(
  text: 'golf',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'golf'},
);

const english = NounPhrase(
  text: 'English',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'angielski'},
);

const polish = NounPhrase(
  text: 'Polish',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'polski'},
);

const spanish = NounPhrase(
  text: 'Spanish',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'hiszpański'},
);

const math = NounPhrase(
  text: 'math',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'matematyka'},
);

const history = NounPhrase(
  text: 'history',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'historia'},
);

const science = NounPhrase(
  text: 'science',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'nauka'},
);

const grammar = NounPhrase(
  text: 'grammar',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'gramatyka'},
);
