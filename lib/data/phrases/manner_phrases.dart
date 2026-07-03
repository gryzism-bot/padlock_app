import 'package:padlock_app/models/language.dart';
import 'package:padlock_app/models/grammar/phrase/manner_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/phrase_position.dart';

const quicklyMannerPhrase = MannerPhrase(
  text: 'quickly',
  translations: {Language.pl: 'szybko'},
  position: PhrasePosition.afterPredicate,
);

const slowlyMannerPhrase = MannerPhrase(
  text: 'slowly',
  translations: {Language.pl: 'powoli'},
  position: PhrasePosition.afterPredicate,
);

const carefullyMannerPhrase = MannerPhrase(
  text: 'carefully',
  translations: {Language.pl: 'ostrożnie'},
  position: PhrasePosition.afterPredicate,
);

const easilyMannerPhrase = MannerPhrase(
  text: 'easily',
  translations: {Language.pl: 'łatwo'},
  position: PhrasePosition.afterPredicate,
);

const quietlyMannerPhrase = MannerPhrase(
  text: 'quietly',
  translations: {Language.pl: 'cicho'},
  position: PhrasePosition.afterPredicate,
);

const loudlyMannerPhrase = MannerPhrase(
  text: 'loudly',
  translations: {Language.pl: 'głośno'},
  position: PhrasePosition.afterPredicate,
);

const happilyMannerPhrase = MannerPhrase(
  text: 'happily',
  translations: {Language.pl: 'wesoło'},
  position: PhrasePosition.afterPredicate,
);

const sadlyMannerPhrase = MannerPhrase(
  text: 'sadly',
  translations: {Language.pl: 'smutno'},
  position: PhrasePosition.afterPredicate,
);

const angrilyMannerPhrase = MannerPhrase(
  text: 'angrily',
  translations: {Language.pl: 'gniewnie'},
  position: PhrasePosition.afterPredicate,
);

const politelyMannerPhrase = MannerPhrase(
  text: 'politely',
  translations: {Language.pl: 'uprzejmie'},
  position: PhrasePosition.afterPredicate,
);

const patientlyMannerPhrase = MannerPhrase(
  text: 'patiently',
  translations: {Language.pl: 'cierpliwie'},
  position: PhrasePosition.afterPredicate,
);

const wellMannerPhrase = MannerPhrase(
  text: 'well',
  translations: {Language.pl: 'dobrze'},
  position: PhrasePosition.afterPredicate,
);

const badlyMannerPhrase = MannerPhrase(
  text: 'badly',
  translations: {Language.pl: 'źle'},
  position: PhrasePosition.afterPredicate,
);

const togetherMannerPhrase = MannerPhrase(
  text: 'together',
  translations: {Language.pl: 'razem'},
  position: PhrasePosition.afterPredicate,
);

const aloneMannerPhrase = MannerPhrase(
  text: 'alone',
  translations: {Language.pl: 'sam'},
  position: PhrasePosition.afterPredicate,
);

const byHandMannerPhrase = MannerPhrase(
  text: 'by hand',
  translations: {Language.pl: 'ręcznie'},
  position: PhrasePosition.afterPredicate,
);

const inSilenceMannerPhrase = MannerPhrase(
  text: 'in silence',
  translations: {Language.pl: 'w ciszy'},
  position: PhrasePosition.afterPredicate,
);

const withCareMannerPhrase = MannerPhrase(
  text: 'with care',
  translations: {Language.pl: 'z należytą starannością'},
  position: PhrasePosition.afterPredicate,
);

const withConfidenceMannerPhrase = MannerPhrase(
  text: 'with confidence',
  translations: {Language.pl: 'z pewnością siebie'},
  position: PhrasePosition.afterPredicate,
);

const byAccidentMannerPhrase = MannerPhrase(
  text: 'by accident',
  translations: {Language.pl: 'przypadkowo'},
  position: PhrasePosition.afterPredicate,
);

const onPurposeMannerPhrase = MannerPhrase(
  text: 'on purpose',
  translations: {Language.pl: 'celowo'},
  position: PhrasePosition.afterPredicate,
);

List<MannerPhrase> allMannerPhrases = [
  quicklyMannerPhrase,
  slowlyMannerPhrase,
  carefullyMannerPhrase,
  easilyMannerPhrase,
  quietlyMannerPhrase,
  loudlyMannerPhrase,
  happilyMannerPhrase,
  sadlyMannerPhrase,
  angrilyMannerPhrase,
  politelyMannerPhrase,
  patientlyMannerPhrase,
  wellMannerPhrase,
  badlyMannerPhrase,
  togetherMannerPhrase,
  aloneMannerPhrase,
  byHandMannerPhrase,
  inSilenceMannerPhrase,
  withCareMannerPhrase,
  withConfidenceMannerPhrase,
  byAccidentMannerPhrase,
  onPurposeMannerPhrase,
];
