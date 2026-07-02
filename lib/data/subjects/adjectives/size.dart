import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/language.dart';

const big = Adjective(text: 'big', translations: {Language.pl: 'duży'});

const small = Adjective(text: 'small', translations: {Language.pl: 'mały'});

const large = Adjective(text: 'large', translations: {Language.pl: 'duży'});

const little = Adjective(text: 'little', translations: {Language.pl: 'mały'});

const tall = Adjective(text: 'tall', translations: {Language.pl: 'wysoki'});

const short = Adjective(text: 'short', translations: {Language.pl: 'niski'});

const long = Adjective(text: 'long', translations: {Language.pl: 'długi'});

const sizeAdjectives = [big, small, large, little, tall, short, long];
