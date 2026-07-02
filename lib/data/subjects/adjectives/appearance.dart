import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/language.dart';

const beautiful = Adjective(
  text: 'beautiful',
  translations: {Language.pl: 'piękny'},
);

const ugly = Adjective(text: 'ugly', translations: {Language.pl: 'brzydki'});

const handsome = Adjective(
  text: 'handsome',
  translations: {Language.pl: 'przystojny'},
);

const pretty = Adjective(text: 'pretty', translations: {Language.pl: 'ładny'});

const clean = Adjective(text: 'clean', translations: {Language.pl: 'czysty'});

const dirty = Adjective(text: 'dirty', translations: {Language.pl: 'brudny'});

const wet = Adjective(text: 'wet', translations: {Language.pl: 'mokry'});

const dry = Adjective(text: 'dry', translations: {Language.pl: 'suchy'});

const appearanceAdjectives = [
  beautiful,
  ugly,
  handsome,
  pretty,
  clean,
  dirty,
  wet,
  dry,
];
