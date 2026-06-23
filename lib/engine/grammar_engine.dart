import '../models/sentence_state.dart';

class GrammarEngine {
  String generate(SentenceState state) {
  if (
    state.subject == 'he' &&
    state.verb == 'work' &&
    state.tense == 'past'
  ) {
    return 'He worked.';
  }

  return 'Unknown sentence';
  }
}