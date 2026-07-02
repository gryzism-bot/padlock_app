import 'package:padlock_app/models/grammar/phrase/phrase.dart';
import 'package:padlock_app/models/language.dart';

class FrequencyPhrase extends Phrase {
  final String text;

  final Map<Language, String> translations;

  const FrequencyPhrase({
    required this.text,
    required this.translations,
    super.position,
  });

  @override
  String render() => text;
}
