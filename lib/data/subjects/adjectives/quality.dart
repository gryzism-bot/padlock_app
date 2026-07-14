import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/language.dart';

const good = Adjective(text: 'good', translations: {Language.pl: 'dobry'});

const bad = Adjective(text: 'bad', translations: {Language.pl: 'zły'});

const newAdjective = Adjective(
  text: 'new',
  translations: {Language.pl: 'nowy'},
);

const old = Adjective(text: 'old', translations: {Language.pl: 'stary'});

const young = Adjective(text: 'young', translations: {Language.pl: 'młody'});

const fast = Adjective(text: 'fast', translations: {Language.pl: 'szybki'});

const slow = Adjective(text: 'slow', translations: {Language.pl: 'wolny'});

const strong = Adjective(text: 'strong', translations: {Language.pl: 'silny'});

const weak = Adjective(text: 'weak', translations: {Language.pl: 'słaby'});

const full = Adjective(text: 'full', translations: {Language.pl: 'pełny'});

const free = Adjective(text: 'free', translations: {Language.pl: 'darmowy'});

const qualityAdjectives = [
  good,
  bad,
  newAdjective,
  old,
  young,
  fast,
  slow,
  strong,
  weak,
  full,
  free,
];
