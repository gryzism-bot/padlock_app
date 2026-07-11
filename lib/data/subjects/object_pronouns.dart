import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/subject/person.dart';
import 'package:padlock_app/models/language.dart';

const me = NounPhrase(
  text: 'me',
  person: Person.first,
  number: Number.singular,
  translations: {Language.pl: 'mnie'},
);

const youObject = NounPhrase(
  text: 'you',
  person: Person.second,
  number: Number.singular,
  translations: {Language.pl: 'ciebie'},
);

const him = NounPhrase(
  text: 'him',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'jemu'},
);

const her = NounPhrase(
  text: 'her',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'jej'},
);

const us = NounPhrase(
  text: 'us',
  person: Person.first,
  number: Number.plural,
  translations: {Language.pl: 'nam'},
);

const them = NounPhrase(
  text: 'them',
  person: Person.third,
  number: Number.plural,
  translations: {Language.pl: 'im'},
);

const myself = NounPhrase(
  text: 'myself',
  person: Person.first,
  number: Number.singular,
  translations: {Language.pl: 'siebie'},
);

const yourself = NounPhrase(
  text: 'yourself',
  person: Person.second,
  number: Number.singular,
  translations: {Language.pl: 'siebie'},
);

const himself = NounPhrase(
  text: 'himself',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'siebie'},
);

const herself = NounPhrase(
  text: 'herself',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'siebie'},
);

const itself = NounPhrase(
  text: 'itself',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'siebie'},
);

const ourselves = NounPhrase(
  text: 'ourselves',
  person: Person.first,
  number: Number.plural,
  translations: {Language.pl: 'siebie'},
);

const yourselves = NounPhrase(
  text: 'yourselves',
  person: Person.second,
  number: Number.plural,
  translations: {Language.pl: 'siebie'},
);

const themselves = NounPhrase(
  text: 'themselves',
  person: Person.third,
  number: Number.plural,
  translations: {Language.pl: 'siebie'},
);

const objectPronouns = [me, youObject, him, her, us, them];

const reflexivePronouns = [
  myself,
  yourself,
  himself,
  herself,
  itself,
  ourselves,
  yourselves,
  themselves,
];
