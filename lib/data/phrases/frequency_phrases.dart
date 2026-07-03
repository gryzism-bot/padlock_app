import 'package:padlock_app/models/language.dart';
import 'package:padlock_app/models/grammar/phrase/frequency_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/phrase_position.dart';

const alwaysFrequencyPhrase = FrequencyPhrase(
  text: 'always',
  translations: {Language.pl: 'zawsze'},
  position: PhrasePosition.beforeSubject,
);

const usuallyFrequencyPhrase = FrequencyPhrase(
  text: 'usually',
  translations: {Language.pl: 'zwykle'},
  position: PhrasePosition.beforeSubject,
);

const oftenFrequencyPhrase = FrequencyPhrase(
  text: 'often',
  translations: {Language.pl: 'często'},
  position: PhrasePosition.beforeSubject,
);

const sometimesFrequencyPhrase = FrequencyPhrase(
  text: 'sometimes',
  translations: {Language.pl: 'czasami'},
  position: PhrasePosition.beforeSubject,
);

const occasionallyFrequencyPhrase = FrequencyPhrase(
  text: 'occasionally',
  translations: {Language.pl: 'od czasu do czasu'},
  position: PhrasePosition.beforeSubject,
);

const rarelyFrequencyPhrase = FrequencyPhrase(
  text: 'rarely',
  translations: {Language.pl: 'rzadko'},
  position: PhrasePosition.beforeSubject,
);

const seldomFrequencyPhrase = FrequencyPhrase(
  text: 'seldom',
  translations: {Language.pl: 'rzadko'},
  position: PhrasePosition.beforeSubject,
);

const hardlyEverFrequencyPhrase = FrequencyPhrase(
  text: 'hardly ever',
  translations: {Language.pl: 'prawie nigdy'},
  position: PhrasePosition.beforeSubject,
);

const neverFrequencyPhrase = FrequencyPhrase(
  text: 'never',
  translations: {Language.pl: 'nigdy'},
  position: PhrasePosition.beforeSubject,
);

const everyDayFrequencyPhrase = FrequencyPhrase(
  text: 'every day',
  translations: {Language.pl: 'codziennie'},
  position: PhrasePosition.afterPredicate,
);

const everyWeekFrequencyPhrase = FrequencyPhrase(
  text: 'every week',
  translations: {Language.pl: 'co tydzień'},
  position: PhrasePosition.afterPredicate,
);

const everyMonthFrequencyPhrase = FrequencyPhrase(
  text: 'every month',
  translations: {Language.pl: 'co miesiąc'},
  position: PhrasePosition.afterPredicate,
);

const everyYearFrequencyPhrase = FrequencyPhrase(
  text: 'every year',
  translations: {Language.pl: 'co roku'},
  position: PhrasePosition.afterPredicate,
);

const onceADayFrequencyPhrase = FrequencyPhrase(
  text: 'once a day',
  translations: {Language.pl: 'raz dziennie'},
  position: PhrasePosition.afterPredicate,
);

const twiceADayFrequencyPhrase = FrequencyPhrase(
  text: 'twice a day',
  translations: {Language.pl: 'dwa razy dziennie'},
  position: PhrasePosition.afterPredicate,
);

const threeTimesAWeekFrequencyPhrase = FrequencyPhrase(
  text: 'three times a week',
  translations: {Language.pl: 'trzy razy w tygodniu'},
  position: PhrasePosition.afterPredicate,
);

const fromTimeToTimeFrequencyPhrase = FrequencyPhrase(
  text: 'from time to time',
  translations: {Language.pl: 'od czasu do czasu'},
  position: PhrasePosition.afterPredicate,
);

List<FrequencyPhrase> frequencyPhrases = [
  alwaysFrequencyPhrase,
  usuallyFrequencyPhrase,
  oftenFrequencyPhrase,
  sometimesFrequencyPhrase,
  occasionallyFrequencyPhrase,
  rarelyFrequencyPhrase,
  seldomFrequencyPhrase,
  hardlyEverFrequencyPhrase,
  neverFrequencyPhrase,
  everyDayFrequencyPhrase,
  everyWeekFrequencyPhrase,
  everyMonthFrequencyPhrase,
  everyYearFrequencyPhrase,
  onceADayFrequencyPhrase,
  twiceADayFrequencyPhrase,
  threeTimesAWeekFrequencyPhrase,
  fromTimeToTimeFrequencyPhrase,
];
