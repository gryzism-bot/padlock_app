import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/language.dart';

const cook = Verb(
  infinitive: 'cook',
  presentThirdPerson: 'cooks',
  pastSimple: 'cooked',
  pastParticiple: 'cooked',
  ingForm: 'cooking',
  translations: {Language.pl: 'gotować'},
);

const bake = Verb(
  infinitive: 'bake',
  presentThirdPerson: 'bakes',
  pastSimple: 'baked',
  pastParticiple: 'baked',
  ingForm: 'baking',
  translations: {Language.pl: 'piec'},
);

const fry = Verb(
  infinitive: 'fry',
  presentThirdPerson: 'fries',
  pastSimple: 'fried',
  pastParticiple: 'fried',
  ingForm: 'frying',
  translations: {Language.pl: 'smażyć'},
);

const boil = Verb(
  infinitive: 'boil',
  presentThirdPerson: 'boils',
  pastSimple: 'boiled',
  pastParticiple: 'boiled',
  ingForm: 'boiling',
  translations: {Language.pl: 'gotować (we wrzątku)'},
);

const grill = Verb(
  infinitive: 'grill',
  presentThirdPerson: 'grills',
  pastSimple: 'grilled',
  pastParticiple: 'grilled',
  ingForm: 'grilling',
  translations: {Language.pl: 'grillować'},
);

const eat = Verb(
  infinitive: 'eat',
  presentThirdPerson: 'eats',
  pastSimple: 'ate',
  pastParticiple: 'eaten',
  ingForm: 'eating',
  translations: {Language.pl: 'jeść'},
);

const drink = Verb(
  infinitive: 'drink',
  presentThirdPerson: 'drinks',
  pastSimple: 'drank',
  pastParticiple: 'drunk',
  ingForm: 'drinking',
  translations: {Language.pl: 'pić'},
);

const roast = Verb(
  infinitive: 'roast',
  presentThirdPerson: 'roasts',
  pastSimple: 'roasted',
  pastParticiple: 'roasted',
  ingForm: 'roasting',
  translations: {Language.pl: 'piec'},
);

const steam = Verb(
  infinitive: 'steam',
  presentThirdPerson: 'steams',
  pastSimple: 'steamed',
  pastParticiple: 'steamed',
  ingForm: 'steaming',
  translations: {Language.pl: 'gotować na parze'},
);

const cut = Verb(
  infinitive: 'cut',
  presentThirdPerson: 'cuts',
  pastSimple: 'cut',
  pastParticiple: 'cut',
  ingForm: 'cutting',
  translations: {Language.pl: 'kroić'},
);

const chop = Verb(
  infinitive: 'chop',
  presentThirdPerson: 'chops',
  pastSimple: 'chopped',
  pastParticiple: 'chopped',
  ingForm: 'chopping',
  translations: {Language.pl: 'siekać'},
);

const slice = Verb(
  infinitive: 'slice',
  presentThirdPerson: 'slices',
  pastSimple: 'sliced',
  pastParticiple: 'sliced',
  ingForm: 'slicing',
  translations: {Language.pl: 'kroić w plastry'},
);

const peel = Verb(
  infinitive: 'peel',
  presentThirdPerson: 'peels',
  pastSimple: 'peeled',
  pastParticiple: 'peeled',
  ingForm: 'peeling',
  translations: {Language.pl: 'obierać'},
);

const mix = Verb(
  infinitive: 'mix',
  presentThirdPerson: 'mixes',
  pastSimple: 'mixed',
  pastParticiple: 'mixed',
  ingForm: 'mixing',
  translations: {Language.pl: 'mieszać'},
);

const stir = Verb(
  infinitive: 'stir',
  presentThirdPerson: 'stirs',
  pastSimple: 'stirred',
  pastParticiple: 'stirred',
  ingForm: 'stirring',
  translations: {Language.pl: 'mieszać'},
);

const pour = Verb(
  infinitive: 'pour',
  presentThirdPerson: 'pours',
  pastSimple: 'poured',
  pastParticiple: 'poured',
  ingForm: 'pouring',
  translations: {Language.pl: 'nalewać'},
);

const add = Verb(
  infinitive: 'add',
  presentThirdPerson: 'adds',
  pastSimple: 'added',
  pastParticiple: 'added',
  ingForm: 'adding',
  translations: {Language.pl: 'dodawać'},
);

const serve = Verb(
  infinitive: 'serve',
  presentThirdPerson: 'serves',
  pastSimple: 'served',
  pastParticiple: 'served',
  ingForm: 'serving',
  translations: {Language.pl: 'podawać'},
);

const taste = Verb(
  infinitive: 'taste',
  presentThirdPerson: 'tastes',
  pastSimple: 'tasted',
  pastParticiple: 'tasted',
  ingForm: 'tasting',
  translations: {Language.pl: 'smakować'},
);

const freeze = Verb(
  infinitive: 'freeze',
  presentThirdPerson: 'freezes',
  pastSimple: 'froze',
  pastParticiple: 'frozen',
  ingForm: 'freezing',
  translations: {Language.pl: 'zamrażać'},
);

const melt = Verb(
  infinitive: 'melt',
  presentThirdPerson: 'melts',
  pastSimple: 'melted',
  pastParticiple: 'melted',
  ingForm: 'melting',
  translations: {Language.pl: 'topić'},
);

const wash = Verb(
  infinitive: 'wash',
  presentThirdPerson: 'washes',
  pastSimple: 'washed',
  pastParticiple: 'washed',
  ingForm: 'washing',
  translations: {Language.pl: 'myć'},
);

List<Verb> cookingVerbs = [
  cook,
  bake,
  fry,
  boil,
  grill,
  eat,
  drink,
  roast,
  steam,
  cut,
  chop,
  slice,
  peel,
  mix,
  stir,
  pour,
  add,
  serve,
  taste,
  freeze,
  melt,
  wash,
];
