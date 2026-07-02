import 'package:padlock_app/models/language.dart';

class Adjective {
  final String text;

  final Map<Language, String> translations;

  const Adjective({required this.text, required this.translations});
}
