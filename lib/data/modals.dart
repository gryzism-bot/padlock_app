import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/language.dart';

const noModal = Modal(text: '', isNone: true, translations: {});

const can = Modal(text: 'can', translations: {Language.pl: 'móc'});

const could = Modal(text: 'could', translations: {Language.pl: 'mógł'});

const may = Modal(text: 'may', translations: {Language.pl: 'móc'});

const might = Modal(text: 'might', translations: {Language.pl: 'mógłby'});

const must = Modal(text: 'must', translations: {Language.pl: 'musieć'});

const shall = Modal(
  text: 'shall',
  translations: {Language.pl: 'mieć (formalny przyszły)'},
);

const should = Modal(text: 'should', translations: {Language.pl: 'powinien'});

const will = Modal(text: 'will', translations: {Language.pl: 'będzie'});

const would = Modal(
  text: 'would',
  translations: {Language.pl: 'chciałby / zrobiłby'},
);

const oughtTo = Modal(
  text: 'ought to',
  translations: {Language.pl: 'powinien'},
);

const need = Modal(text: 'need', translations: {Language.pl: 'potrzebować'});

const dare = Modal(text: 'dare', translations: {Language.pl: 'odważyć się'});
