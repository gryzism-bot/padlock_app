import 'package:padlock_app/models/language.dart';
import 'package:padlock_app/models/grammar/phrase/time_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/phrase_position.dart';

const today = TimePhrase(
  text: 'today',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'dzisiaj'},
);

const yesterday = TimePhrase(
  text: 'yesterday',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'wczoraj'},
);

const tomorrow = TimePhrase(
  text: 'tomorrow',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'jutro'},
);

const now = TimePhrase(
  text: 'now',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'teraz'},
);

const later = TimePhrase(
  text: 'later',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'później'},
);

const soon = TimePhrase(
  text: 'soon',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'wkrótce'},
);

const tonight = TimePhrase(
  text: 'tonight',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'dziś wieczorem'},
);

const thisMorning = TimePhrase(
  text: 'this morning',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'dziś rano'},
);

const thisAfternoon = TimePhrase(
  text: 'this afternoon',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'dziś po południu'},
);

const thisEvening = TimePhrase(
  text: 'this evening',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'dziś wieczorem'},
);

const everyDay = TimePhrase(
  text: 'every day',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'codziennie'},
);

const everyWeek = TimePhrase(
  text: 'every week',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'co tydzień'},
);

const everyMonth = TimePhrase(
  text: 'every month',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'co miesiąc'},
);

const everyYear = TimePhrase(
  text: 'every year',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'co rok'},
);

const onMonday = TimePhrase(
  text: 'on Monday',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'w poniedziałek'},
);

const onTuesday = TimePhrase(
  text: 'on Tuesday',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'we wtorek'},
);

const onWednesday = TimePhrase(
  text: 'on Wednesday',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'w środę'},
);

const onThursday = TimePhrase(
  text: 'on Thursday',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'w czwartek'},
);

const onFriday = TimePhrase(
  text: 'on Friday',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'w piątek'},
);

const onSaturday = TimePhrase(
  text: 'on Saturday',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'w sobotę'},
);

const onSunday = TimePhrase(
  text: 'on Sunday',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'w niedzielę'},
);

const inTheMorning = TimePhrase(
  text: 'in the morning',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'rano'},
);

const inTheAfternoon = TimePhrase(
  text: 'in the afternoon',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'po południu'},
);

const inTheEvening = TimePhrase(
  text: 'in the evening',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'wieczorem'},
);

const atNight = TimePhrase(
  text: 'at night',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'w nocy'},
);
