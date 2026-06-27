import 'package:padlock_app/models/language.dart';

class Determiner {
  final String text;

  final Map<Language, String> translations;

  const Determiner({
    required this.text,
    required this.translations,
  });
}