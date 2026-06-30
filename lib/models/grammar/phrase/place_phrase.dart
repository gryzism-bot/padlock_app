import 'package:padlock_app/models/language.dart';

import 'phrase_position.dart';

class PlacePhrase {
  final String text;

  final PhrasePosition position;

  /// "at home", "in the park", "under the table"
  final String locationPreposition;

  /// "go home", "travel to work", "walk to the park"
  final String destinationPreposition;

  /// "from home", "from work", "from the park"
  final String sourcePreposition;

  final Map<Language, String> translations;

  const PlacePhrase({
    required this.text,
    required this.translations,
    this.locationPreposition = 'at',
    this.destinationPreposition = 'to',
    this.sourcePreposition = 'from',
    this.position = PhrasePosition.afterPredicate,
  });
}
