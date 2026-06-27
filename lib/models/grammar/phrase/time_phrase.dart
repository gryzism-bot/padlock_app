import 'phrase_position.dart';

class TimePhrase {
  final String text;

  final PhrasePosition position;

  const TimePhrase({
    required this.text,
    this.position = PhrasePosition.afterPredicate,
  });
}
