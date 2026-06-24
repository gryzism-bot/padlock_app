import "package:padlock_app/engine/grammar_engine.dart";

class SentenceState {
  final String subject;
  final String verb;
  final Tense tense;

  const SentenceState({
    required this.subject,
    required this.verb,
    required this.tense,
  });
}
