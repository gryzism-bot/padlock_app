import 'phrase_position.dart';

class PlacePhrase {
  final String text;

  final PhrasePosition position;

  const PlacePhrase({
    required this.text,
    this.position = PhrasePosition.afterPredicate,
  });
}
