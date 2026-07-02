import 'package:padlock_app/models/grammar/phrase/phrase.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/language.dart';

class PlacePhrase extends Phrase {
  final String text;

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
    super.position,
  });

  @override
  String render([PlaceMeaning meaning = PlaceMeaning.location]) {
    switch (meaning) {
      case PlaceMeaning.location:
        return locationPreposition.isEmpty
            ? text
            : '$locationPreposition $text';

      case PlaceMeaning.destination:
        return destinationPreposition.isEmpty
            ? text
            : '$destinationPreposition $text';

      case PlaceMeaning.source:
        return sourcePreposition.isEmpty ? text : '$sourcePreposition $text';
    }
  }
}
