import 'package:padlock_app/models/language.dart';
import 'package:padlock_app/models/grammar/phrase/manner_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/phrase_position.dart';

const quickly = MannerPhrase(
  text: 'quickly',
  translations: {Language.pl: 'szybko'},
  position: PhrasePosition.afterPredicate,
);

const slowly = MannerPhrase(
  text: 'slowly',
  translations: {Language.pl: 'powoli'},
  position: PhrasePosition.afterPredicate,
);

const carefully = MannerPhrase(
  text: 'carefully',
  translations: {Language.pl: 'ostrożnie'},
  position: PhrasePosition.afterPredicate,
);

const easily = MannerPhrase(
  text: 'easily',
  translations: {Language.pl: 'łatwo'},
  position: PhrasePosition.afterPredicate,
);

const quietly = MannerPhrase(
  text: 'quietly',
  translations: {Language.pl: 'cicho'},
  position: PhrasePosition.afterPredicate,
);

const loudly = MannerPhrase(
  text: 'loudly',
  translations: {Language.pl: 'głośno'},
  position: PhrasePosition.afterPredicate,
);

const happily = MannerPhrase(
  text: 'happily',
  translations: {Language.pl: 'wesoło'},
  position: PhrasePosition.afterPredicate,
);

const sadly = MannerPhrase(
  text: 'sadly',
  translations: {Language.pl: 'smutno'},
  position: PhrasePosition.afterPredicate,
);

const angrily = MannerPhrase(
  text: 'angrily',
  translations: {Language.pl: 'gniewnie'},
  position: PhrasePosition.afterPredicate,
);

const politely = MannerPhrase(
  text: 'politely',
  translations: {Language.pl: 'uprzejmie'},
  position: PhrasePosition.afterPredicate,
);

const patiently = MannerPhrase(
  text: 'patiently',
  translations: {Language.pl: 'cierpliwie'},
  position: PhrasePosition.afterPredicate,
);

const well = MannerPhrase(
  text: 'well',
  translations: {Language.pl: 'dobrze'},
  position: PhrasePosition.afterPredicate,
);

const badly = MannerPhrase(
  text: 'badly',
  translations: {Language.pl: 'źle'},
  position: PhrasePosition.afterPredicate,
);

const together = MannerPhrase(
  text: 'together',
  translations: {Language.pl: 'razem'},
  position: PhrasePosition.afterPredicate,
);

const alone = MannerPhrase(
  text: 'alone',
  translations: {Language.pl: 'sam'},
  position: PhrasePosition.afterPredicate,
);

const byHand = MannerPhrase(
  text: 'by hand',
  translations: {Language.pl: 'ręcznie'},
  position: PhrasePosition.afterPredicate,
);

const inSilence = MannerPhrase(
  text: 'in silence',
  translations: {Language.pl: 'w ciszy'},
  position: PhrasePosition.afterPredicate,
);

const withCare = MannerPhrase(
  text: 'with care',
  translations: {Language.pl: 'z należytą starannością'},
  position: PhrasePosition.afterPredicate,
);

const withConfidence = MannerPhrase(
  text: 'with confidence',
  translations: {Language.pl: 'z pewnością siebie'},
  position: PhrasePosition.afterPredicate,
);

const byAccident = MannerPhrase(
  text: 'by accident',
  translations: {Language.pl: 'przypadkowo'},
  position: PhrasePosition.afterPredicate,
);

const onPurpose = MannerPhrase(
  text: 'on purpose',
  translations: {Language.pl: 'celowo'},
  position: PhrasePosition.afterPredicate,
);

List<MannerPhrase> allMannerPhrases = [
  quickly,
  slowly,
  carefully,
  easily,
  quietly,
  loudly,
  happily,
  sadly,
  angrily,
  politely,
  patiently,
  well,
  badly,
  together,
  alone,
  byHand,
  inSilence,
  withCare,
  withConfidence,
  byAccident,
  onPurpose,
];
