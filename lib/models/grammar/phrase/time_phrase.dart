import 'package:padlock_app/models/grammar/phrase/phrase.dart';
import 'package:padlock_app/models/language.dart';

class TimePhrase extends Phrase {
  final String text;

  final Map<Language, String> translations;

  const TimePhrase({
    required this.text,
    required this.translations,
    super.position,
  });

  @override
  String render() => text;
}
