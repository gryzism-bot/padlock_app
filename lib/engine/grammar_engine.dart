import '../models/sentence_state.dart';

enum Subject { he, she, it, they }

enum Verb { work, play, eat }

enum Tense { past, present }

class GrammarEngine {
  String generate(SentenceState state) {
    print(state);

    if (state.subject == Subject.he &&
        state.tense == Tense.past &&
        state.verb == Verb.work) {
      return 'He worked.';
    }

    if (state.subject == Subject.he &&
        state.tense == Tense.present &&
        state.verb == Verb.work) {
      return 'He works.';
    }

    if (state.subject == Subject.they &&
        state.tense == Tense.past &&
        state.verb == Verb.work) {
      return 'They worked.';
    }

    if (state.subject == Subject.they &&
        state.tense == Tense.present &&
        state.verb == Verb.work) {
      return 'They work.';
    }

    return 'Unknown sentence';
  }
}
