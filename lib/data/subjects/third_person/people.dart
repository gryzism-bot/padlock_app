import 'package:padlock_app/models/grammar/subject/noun.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/subject/person.dart';
import 'package:padlock_app/models/language.dart';

const john = Noun(
  singular: 'John',
  plural: 'Johns',
  singularTranslations: {Language.pl: 'Jan'},
  pluralTranslations: {Language.pl: 'Janowie'},
);

const mary = Noun(
  singular: 'Mary',
  plural: 'Marys',
  singularTranslations: {Language.pl: 'Maria'},
  pluralTranslations: {Language.pl: 'Marie'},
);

const tom = Noun(
  singular: 'Tom',
  plural: 'Toms',
  singularTranslations: {Language.pl: 'Tomasz'},
  pluralTranslations: {Language.pl: 'Tomasze'},
);

const anna = Noun(
  singular: 'Anna',
  plural: 'Annas',
  singularTranslations: {Language.pl: 'Anna'},
  pluralTranslations: {Language.pl: 'Anny'},
);

const alice = Noun(
  singular: 'Alice',
  plural: 'Alices',
  singularTranslations: {Language.pl: 'Alicja'},
  pluralTranslations: {Language.pl: 'Alicje'},
);

const david = Noun(
  singular: 'David',
  plural: 'Davids',
  singularTranslations: {Language.pl: 'Dawid'},
  pluralTranslations: {Language.pl: 'Dawidowie'},
);

const choir = Noun(
  singular: 'choir',
  plural: 'choirs',
  singularTranslations: {Language.pl: 'chór'},
  pluralTranslations: {Language.pl: 'chóry'},
);

const person = Noun(
  singular: 'person',
  plural: 'people',
  singularTranslations: {Language.pl: 'osoba'},
  pluralTranslations: {Language.pl: 'ludzie'},
);

const teacher = Noun(
  singular: 'teacher',
  plural: 'teachers',
  singularTranslations: {Language.pl: 'nauczyciel'},
  pluralTranslations: {Language.pl: 'nauczyciele'},
);

const student = Noun(
  singular: 'student',
  plural: 'students',
  singularTranslations: {Language.pl: 'uczeń'},
  pluralTranslations: {Language.pl: 'uczniowie'},
);

const doctor = Noun(
  singular: 'doctor',
  plural: 'doctors',
  singularTranslations: {Language.pl: 'lekarz'},
  pluralTranslations: {Language.pl: 'lekarze'},
);

const nurse = Noun(
  singular: 'nurse',
  plural: 'nurses',
  singularTranslations: {Language.pl: 'pielęgniarka'},
  pluralTranslations: {Language.pl: 'pielęgniarki'},
);

const engineer = Noun(
  singular: 'engineer',
  plural: 'engineers',
  singularTranslations: {Language.pl: 'inżynier'},
  pluralTranslations: {Language.pl: 'inżynierowie'},
);

const worker = Noun(
  singular: 'worker',
  plural: 'workers',
  singularTranslations: {Language.pl: 'pracownik'},
  pluralTranslations: {Language.pl: 'pracownicy'},
);

const programmer = Noun(
  singular: 'programmer',
  plural: 'programmers',
  singularTranslations: {Language.pl: 'programista'},
  pluralTranslations: {Language.pl: 'programiści'},
);

const friend = Noun(
  singular: 'friend',
  plural: 'friends',
  singularTranslations: {Language.pl: 'przyjaciel'},
  pluralTranslations: {Language.pl: 'przyjaciele'},
);

const enemy = Noun(
  singular: 'enemy',
  plural: 'enemies',
  singularTranslations: {Language.pl: 'wrog'},
  pluralTranslations: {Language.pl: 'wrogowie'},
);

const neighbour = Noun(
  singular: 'neighbour',
  plural: 'neighbours',
  singularTranslations: {Language.pl: 'sąsiad'},
  pluralTranslations: {Language.pl: 'sąsiedzi'},
);

const customer = Noun(
  singular: 'customer',
  plural: 'customers',
  singularTranslations: {Language.pl: 'klient'},
  pluralTranslations: {Language.pl: 'klienci'},
);

const manager = Noun(
  singular: 'manager',
  plural: 'managers',
  singularTranslations: {Language.pl: 'kierownik'},
  pluralTranslations: {Language.pl: 'kierownicy'},
);

const child = Noun(
  singular: 'child',
  plural: 'children',
  singularTranslations: {Language.pl: 'dziecko'},
  pluralTranslations: {Language.pl: 'dzieci'},
);

const man = Noun(
  singular: 'man',
  plural: 'men',
  singularTranslations: {Language.pl: 'mężczyzna'},
  pluralTranslations: {Language.pl: 'mężczyźni'},
);

const woman = Noun(
  singular: 'woman',
  plural: 'women',
  singularTranslations: {Language.pl: 'kobieta'},
  pluralTranslations: {Language.pl: 'kobiety'},
);

const boy = Noun(
  singular: 'boy',
  plural: 'boys',
  singularTranslations: {Language.pl: 'chłopiec'},
  pluralTranslations: {Language.pl: 'chłopcy'},
);

const girl = Noun(
  singular: 'girl',
  plural: 'girls',
  singularTranslations: {Language.pl: 'dziewczynka'},
  pluralTranslations: {Language.pl: 'dziewczynki'},
);

const parent = Noun(
  singular: 'parent',
  plural: 'parents',
  singularTranslations: {Language.pl: 'rodzic'},
  pluralTranslations: {Language.pl: 'rodzice'},
);

const mother = Noun(
  singular: 'mother',
  plural: 'mothers',
  singularTranslations: {Language.pl: 'matka'},
  pluralTranslations: {Language.pl: 'matki'},
);

const father = Noun(
  singular: 'father',
  plural: 'fathers',
  singularTranslations: {Language.pl: 'ojciec'},
  pluralTranslations: {Language.pl: 'ojcowie'},
);

const grandmother = Noun(
  singular: 'grandmother',
  plural: 'grandmothers',
  singularTranslations: {Language.pl: 'babcia'},
  pluralTranslations: {Language.pl: 'babcie'},
);

const grandfather = Noun(
  singular: 'grandfather',
  plural: 'grandfathers',
  singularTranslations: {Language.pl: 'dziadek'},
  pluralTranslations: {Language.pl: 'dziadkowie'},
);

const sister = Noun(
  singular: 'sister',
  plural: 'sisters',
  singularTranslations: {Language.pl: 'siostra'},
  pluralTranslations: {Language.pl: 'siostry'},
);

const brother = Noun(
  singular: 'brother',
  plural: 'brothers',
  singularTranslations: {Language.pl: 'brat'},
  pluralTranslations: {Language.pl: 'bracia'},
);

const boss = Noun(
  singular: 'boss',
  plural: 'bosses',
  singularTranslations: {Language.pl: 'szef'},
  pluralTranslations: {Language.pl: 'szefowie'},
);

const colleague = Noun(
  singular: 'colleague',
  plural: 'colleagues',
  singularTranslations: {Language.pl: 'kolega'},
  pluralTranslations: {Language.pl: 'koledzy'},
);

const classmate = Noun(
  singular: 'classmate',
  plural: 'classmates',
  singularTranslations: {Language.pl: 'kolega z klasy'},
  pluralTranslations: {Language.pl: 'koledzy z klasy'},
);

const musician = Noun(
  singular: 'musician',
  plural: 'musicians',
  singularTranslations: {Language.pl: 'muzyk'},
  pluralTranslations: {Language.pl: 'muzycy'},
);

const artist = Noun(
  singular: 'artist',
  plural: 'artists',
  singularTranslations: {Language.pl: 'artysta'},
  pluralTranslations: {Language.pl: 'artysci'},
);

const writer = Noun(
  singular: 'writer',
  plural: 'writers',
  singularTranslations: {Language.pl: 'pisarz'},
  pluralTranslations: {Language.pl: 'pisarze'},
);

const driver = Noun(
  singular: 'driver',
  plural: 'drivers',
  singularTranslations: {Language.pl: 'kierowca'},
  pluralTranslations: {Language.pl: 'kierowcy'},
);

const cook = Noun(
  singular: 'cook',
  plural: 'cooks',
  singularTranslations: {Language.pl: 'kucharz'},
  pluralTranslations: {Language.pl: 'kucharze'},
);

const baker = Noun(
  singular: 'baker',
  plural: 'bakers',
  singularTranslations: {Language.pl: 'piekarz'},
  pluralTranslations: {Language.pl: 'piekarze'},
);

const farmer = Noun(
  singular: 'farmer',
  plural: 'farmers',
  singularTranslations: {Language.pl: 'rolnik'},
  pluralTranslations: {Language.pl: 'rolnicy'},
);

const policeOfficer = Noun(
  singular: 'police officer',
  plural: 'police officers',
  singularTranslations: {Language.pl: 'policjant'},
  pluralTranslations: {Language.pl: 'policjanci'},
);

const lawyer = Noun(
  singular: 'lawyer',
  plural: 'lawyers',
  singularTranslations: {Language.pl: 'prawnik'},
  pluralTranslations: {Language.pl: 'prawnicy'},
);

const waiter = Noun(
  singular: 'waiter',
  plural: 'waiters',
  singularTranslations: {Language.pl: 'kelner'},
  pluralTranslations: {Language.pl: 'kelnerzy'},
);

const mechanic = Noun(
  singular: 'mechanic',
  plural: 'mechanics',
  singularTranslations: {Language.pl: 'mechanik'},
  pluralTranslations: {Language.pl: 'mechanicy'},
);

const dentist = Noun(
  singular: 'dentist',
  plural: 'dentists',
  singularTranslations: {Language.pl: 'dentysta'},
  pluralTranslations: {Language.pl: 'dentysci'},
);

const guard = Noun(
  singular: 'guard',
  plural: 'guards',
  singularTranslations: {Language.pl: 'ochroniarz'},
  pluralTranslations: {Language.pl: 'ochroniarze'},
);

const guest = Noun(
  singular: 'guest',
  plural: 'guests',
  singularTranslations: {Language.pl: 'gosc'},
  pluralTranslations: {Language.pl: 'goscie'},
);

const client = Noun(
  singular: 'client',
  plural: 'clients',
  singularTranslations: {Language.pl: 'klient'},
  pluralTranslations: {Language.pl: 'klienci'},
);

const teammate = Noun(
  singular: 'teammate',
  plural: 'teammates',
  singularTranslations: {Language.pl: 'kolega z druzyny'},
  pluralTranslations: {Language.pl: 'koledzy z druzyny'},
);

const coach = Noun(
  singular: 'coach',
  plural: 'coaches',
  singularTranslations: {Language.pl: 'trener'},
  pluralTranslations: {Language.pl: 'trenerzy'},
);

const player = Noun(
  singular: 'player',
  plural: 'players',
  singularTranslations: {Language.pl: 'gracz'},
  pluralTranslations: {Language.pl: 'gracze'},
);

const singer = Noun(
  singular: 'singer',
  plural: 'singers',
  singularTranslations: {Language.pl: 'piosenkarz'},
  pluralTranslations: {Language.pl: 'piosenkarze'},
);

const actor = Noun(
  singular: 'actor',
  plural: 'actors',
  singularTranslations: {Language.pl: 'aktor'},
  pluralTranslations: {Language.pl: 'aktorzy'},
);

const director = Noun(
  singular: 'director',
  plural: 'directors',
  singularTranslations: {Language.pl: 'rezyser'},
  pluralTranslations: {Language.pl: 'rezyserzy'},
);

const tourist = Noun(
  singular: 'tourist',
  plural: 'tourists',
  singularTranslations: {Language.pl: 'turysta'},
  pluralTranslations: {Language.pl: 'turysci'},
);

const passenger = Noun(
  singular: 'passenger',
  plural: 'passengers',
  singularTranslations: {Language.pl: 'pasazer'},
  pluralTranslations: {Language.pl: 'pasazerowie'},
);

const guide = Noun(
  singular: 'guide',
  plural: 'guides',
  singularTranslations: {Language.pl: 'przewodnik'},
  pluralTranslations: {Language.pl: 'przewodnicy'},
);

const someone = NounPhrase(
  text: 'someone',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'ktos'},
);

const anyone = NounPhrase(
  text: 'anyone',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'ktokolwiek'},
);

const nobody = NounPhrase(
  text: 'nobody',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'nikt'},
);

const everyone = NounPhrase(
  text: 'everyone',
  person: Person.third,
  number: Number.singular,
  translations: {Language.pl: 'wszyscy'},
);

const peopleNouns = [
  john,
  mary,
  tom,
  anna,
  alice,
  david,
  choir,
  person,
  teacher,
  student,
  doctor,
  nurse,
  engineer,
  worker,
  programmer,
  friend,
  enemy,
  neighbour,
  customer,
  manager,
  child,
  man,
  woman,
  boy,
  girl,
  parent,
  mother,
  father,
  grandmother,
  grandfather,
  sister,
  brother,
  boss,
  colleague,
  classmate,
  musician,
  artist,
  writer,
  driver,
  cook,
  baker,
  farmer,
  policeOfficer,
  lawyer,
  waiter,
  mechanic,
  dentist,
  guard,
  guest,
  client,
  teammate,
  coach,
  player,
  singer,
  actor,
  director,
  tourist,
  passenger,
  guide,
];

const indefinitePeople = [someone, anyone, nobody, everyone];

final singularPeople = [
  for (final noun in peopleNouns) noun.toNounPhrase(Number.singular),
  ...indefinitePeople,
];

final pluralPeople = [
  for (final noun in peopleNouns) noun.toNounPhrase(Number.plural),
];

final peopleNounPhrases = [...singularPeople, ...pluralPeople];
