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

const objectPronouns = [me, youObject, him, her, us, them];
