import "package:padlock_app/engine/grammar_engine.dart";

class SentenceState {
  final Subject subject;
  final Verb verb;
  final Tense tense;

  const SentenceState({
    required this.subject,
    required this.verb,
    required this.tense,
  });

  @override
  String toString() {
    return 'Subject: $subject, Verb: $verb, Tense: $tense';
  }
}
