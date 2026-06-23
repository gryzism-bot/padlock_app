import '../models/sentence_state.dart';

enum Subject { he, she, it, they }

enum Verb { work, play, eat }

enum Tense { past, present }

class GrammarEngine {
  String generate(SentenceState state) {
    if (state.tense == Tense.past) {
      return 'He worked.';
    }

    if (state.tense == Tense.present) {
      return 'He works.';
    }

    return 'Unknown sentence';
  }
}
