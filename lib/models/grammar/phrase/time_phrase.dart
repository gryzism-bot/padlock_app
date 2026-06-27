import 'package:padlock_app/models/language.dart';

import 'phrase_position.dart';

class TimePhrase {
  final String text;

  final PhrasePosition position;

  final Map<Language, String> translations;

  const TimePhrase({
    required this.text,
    required this.translations,
    this.position = PhrasePosition.afterPredicate,
  });
}
