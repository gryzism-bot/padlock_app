import 'package:padlock_app/models/language.dart';
import 'package:padlock_app/models/grammar/phrase/frequency_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/phrase_position.dart';

const always = FrequencyPhrase(
  text: 'always',
  translations: {Language.pl: 'zawsze'},
  position: PhrasePosition.beforeSubject,
);

const usually = FrequencyPhrase(
  text: 'usually',
  translations: {Language.pl: 'zwykle'},
  position: PhrasePosition.beforeSubject,
);

const often = FrequencyPhrase(
  text: 'often',
  translations: {Language.pl: 'często'},
  position: PhrasePosition.beforeSubject,
);

const sometimes = FrequencyPhrase(
  text: 'sometimes',
  translations: {Language.pl: 'czasami'},
  position: PhrasePosition.beforeSubject,
);

const occasionally = FrequencyPhrase(
  text: 'occasionally',
  translations: {Language.pl: 'od czasu do czasu'},
  position: PhrasePosition.beforeSubject,
);

const rarely = FrequencyPhrase(
  text: 'rarely',
  translations: {Language.pl: 'rzadko'},
  position: PhrasePosition.beforeSubject,
);

const seldom = FrequencyPhrase(
  text: 'seldom',
  translations: {Language.pl: 'rzadko'},
  position: PhrasePosition.beforeSubject,
);

const hardlyEver = FrequencyPhrase(
  text: 'hardly ever',
  translations: {Language.pl: 'prawie nigdy'},
  position: PhrasePosition.beforeSubject,
);

const never = FrequencyPhrase(
  text: 'never',
  translations: {Language.pl: 'nigdy'},
  position: PhrasePosition.beforeSubject,
);

const everyDay = FrequencyPhrase(
  text: 'every day',
  translations: {Language.pl: 'codziennie'},
  position: PhrasePosition.afterPredicate,
);

const everyWeek = FrequencyPhrase(
  text: 'every week',
  translations: {Language.pl: 'co tydzień'},
  position: PhrasePosition.afterPredicate,
);

const everyMonth = FrequencyPhrase(
  text: 'every month',
  translations: {Language.pl: 'co miesiąc'},
  position: PhrasePosition.afterPredicate,
);

const everyYear = FrequencyPhrase(
  text: 'every year',
  translations: {Language.pl: 'co roku'},
  position: PhrasePosition.afterPredicate,
);

const onceADay = FrequencyPhrase(
  text: 'once a day',
  translations: {Language.pl: 'raz dziennie'},
  position: PhrasePosition.afterPredicate,
);

const twiceADay = FrequencyPhrase(
  text: 'twice a day',
  translations: {Language.pl: 'dwa razy dziennie'},
  position: PhrasePosition.afterPredicate,
);

const threeTimesAWeek = FrequencyPhrase(
  text: 'three times a week',
  translations: {Language.pl: 'trzy razy w tygodniu'},
  position: PhrasePosition.afterPredicate,
);

const fromTimeToTime = FrequencyPhrase(
  text: 'from time to time',
  translations: {Language.pl: 'od czasu do czasu'},
  position: PhrasePosition.afterPredicate,
);

List<FrequencyPhrase> frequencyPhrases = [
  always,
  usually,
  often,
  sometimes,
  occasionally,
  rarely,
  seldom,
  hardlyEver,
  never,
  everyDay,
  everyWeek,
  everyMonth,
  everyYear,
  onceADay,
  twiceADay,
  threeTimesAWeek,
  fromTimeToTime,
];
