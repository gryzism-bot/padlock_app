import 'package:padlock_app/models/language.dart';

import 'phrase_position.dart';

class PlacePhrase {
  final String text;

  final PhrasePosition position;

  final Map<Language, String> translations;

  const PlacePhrase({
    required this.text,
    required this.translations,
    this.position = PhrasePosition.afterPredicate,
  });
}
