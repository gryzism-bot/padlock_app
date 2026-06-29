import 'package:padlock_app/models/language.dart';

class Modal {
  final String text;

  final Map<Language, String> translations;

  final bool isNone;

  const Modal({
    required this.text,
    required this.translations,
    this.isNone = false,
  });
}
