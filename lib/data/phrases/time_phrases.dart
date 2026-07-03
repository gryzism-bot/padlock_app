import 'package:padlock_app/models/language.dart';
import 'package:padlock_app/models/grammar/phrase/time_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/phrase_position.dart';

const todayTimePhrase = TimePhrase(
  text: 'today',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'dzisiaj'},
);

const yesterdayTimePhrase = TimePhrase(
  text: 'yesterday',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'wczoraj'},
);

const tomorrowTimePhrase = TimePhrase(
  text: 'tomorrow',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'jutro'},
);

const nowTimePhrase = TimePhrase(
  text: 'now',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'teraz'},
);

const laterTimePhrase = TimePhrase(
  text: 'later',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'później'},
);

const soonTimePhrase = TimePhrase(
  text: 'soon',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'wkrótce'},
);

const tonightTimePhrase = TimePhrase(
  text: 'tonight',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'dziś wieczorem'},
);

const thisMorningTimePhrase = TimePhrase(
  text: 'this morning',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'dziś rano'},
);

const thisAfternoonTimePhrase = TimePhrase(
  text: 'this afternoon',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'dziś po południu'},
);

const thisEveningTimePhrase = TimePhrase(
  text: 'this evening',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'dziś wieczorem'},
);

const onMondayTimePhrase = TimePhrase(
  text: 'on Monday',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'w poniedziałek'},
);

const onTuesdayTimePhrase = TimePhrase(
  text: 'on Tuesday',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'we wtorek'},
);

const onWednesdayTimePhrase = TimePhrase(
  text: 'on Wednesday',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'w środę'},
);

const onThursdayTimePhrase = TimePhrase(
  text: 'on Thursday',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'w czwartek'},
);

const onFridayTimePhrase = TimePhrase(
  text: 'on Friday',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'w piątek'},
);

const onSaturdayTimePhrase = TimePhrase(
  text: 'on Saturday',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'w sobotę'},
);

const onSundayTimePhrase = TimePhrase(
  text: 'on Sunday',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'w niedzielę'},
);

const inTheMorningTimePhrase = TimePhrase(
  text: 'in the morning',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'rano'},
);

const inTheAfternoonTimePhrase = TimePhrase(
  text: 'in the afternoon',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'po południu'},
);

const inTheEveningTimePhrase = TimePhrase(
  text: 'in the evening',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'wieczorem'},
);

const atNightTimePhrase = TimePhrase(
  text: 'at night',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'w nocy'},
);

List<TimePhrase> timePhrases = [
  todayTimePhrase,
  yesterdayTimePhrase,
  tomorrowTimePhrase,
  nowTimePhrase,
  laterTimePhrase,
  soonTimePhrase,
  tonightTimePhrase,
  thisMorningTimePhrase,
  thisAfternoonTimePhrase,
  thisEveningTimePhrase,
  onMondayTimePhrase,
  onTuesdayTimePhrase,
  onWednesdayTimePhrase,
  onThursdayTimePhrase,
  onFridayTimePhrase,
  onSaturdayTimePhrase,
  onSundayTimePhrase,
  inTheMorningTimePhrase,
  inTheAfternoonTimePhrase,
  inTheEveningTimePhrase,
  atNightTimePhrase,
];
