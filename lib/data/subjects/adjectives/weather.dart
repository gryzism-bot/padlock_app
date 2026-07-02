import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/language.dart';

const hot = Adjective(text: 'hot', translations: {Language.pl: 'gorący'});

const cold = Adjective(text: 'cold', translations: {Language.pl: 'zimny'});

const warm = Adjective(text: 'warm', translations: {Language.pl: 'ciepły'});

const cool = Adjective(text: 'cool', translations: {Language.pl: 'chłodny'});

const sunny = Adjective(
  text: 'sunny',
  translations: {Language.pl: 'słoneczny'},
);

const rainy = Adjective(
  text: 'rainy',
  translations: {Language.pl: 'deszczowy'},
);

const cloudy = Adjective(
  text: 'cloudy',
  translations: {Language.pl: 'pochmurny'},
);

const windy = Adjective(text: 'windy', translations: {Language.pl: 'wietrzny'});

const weatherAdjectives = [hot, cold, warm, cool, sunny, rainy, cloudy, windy];
