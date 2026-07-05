import 'package:padlock_app/models/sentence/sentence_state.dart';

class GrammarDiagnostics {
  final SentenceState state;

  final String sentence;

  const GrammarDiagnostics({required this.state, required this.sentence});
}
