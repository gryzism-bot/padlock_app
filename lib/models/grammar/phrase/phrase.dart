import 'package:padlock_app/models/grammar/phrase/phrase_position.dart';

abstract class Phrase {
  final PhrasePosition position;

  const Phrase({this.position = PhrasePosition.afterPredicate});

  String render();
}
