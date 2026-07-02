import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/language.dart';

const happy = Adjective(
  text: 'happy',
  translations: {Language.pl: 'szczęśliwy'},
);

const sad = Adjective(text: 'sad', translations: {Language.pl: 'smutny'});

const angry = Adjective(text: 'angry', translations: {Language.pl: 'zły'});

const calm = Adjective(text: 'calm', translations: {Language.pl: 'spokojny'});

const tired = Adjective(text: 'tired', translations: {Language.pl: 'zmęczony'});

const hungry = Adjective(text: 'hungry', translations: {Language.pl: 'głodny'});

const thirsty = Adjective(
  text: 'thirsty',
  translations: {Language.pl: 'spragniony'},
);

const emotionsAdjectives = [happy, sad, angry, calm, tired, hungry, thirsty];
