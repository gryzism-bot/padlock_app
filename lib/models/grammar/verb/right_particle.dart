import 'package:padlock_app/models/language.dart';

class RightParticle {
  final String text;
  final Map<Language, String> translations;

  const RightParticle({required this.text, required this.translations});

  String render() => text;
}
