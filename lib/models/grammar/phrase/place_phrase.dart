import 'package:padlock_app/models/grammar/phrase/phrase.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/preposition.dart';
import 'package:padlock_app/models/language.dart';

class PlacePhrase extends Phrase {
  final String noun;

  final bool takesArticle;

  final Map<PlaceMeaning, Preposition?> prepositions;

  final Map<Language, String> translations;

  const PlacePhrase({
    required this.noun,
    required this.prepositions,
    required this.translations,
    this.takesArticle = true,
    super.position,
  });

  @override
  String render([PlaceMeaning meaning = PlaceMeaning.location]) {
    final preposition = prepositions[meaning];

    final buffer = StringBuffer();

    if (preposition != null) {
      buffer.write(preposition.text);
      buffer.write(' ');
    }

    if (takesArticle) {
      buffer.write('the ');
    }

    buffer.write(noun);

    return buffer.toString();
  }
}
