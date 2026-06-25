import '../models/sentence_state.dart';
import '../models/tense.dart';

class GrammarEngine {
  String generate(SentenceState state) {
    final subject = state.subject.text;
    final verb = _buildVerb(state);
    final phrase = _buildPhrase(state);

    return '$subject $verb$phrase.';
  }

  String _buildVerb(SentenceState state) {
    switch (state.tense) {
      case Tense.past:
        return state.verb.pastSimple;

      case Tense.present:
        if (state.subject.takesThirdPersonVerb) {
          // Temporary implementation
          return '${state.verb.infinitive}s';
        }

        return state.verb.infinitive;

      case Tense.future:
        return 'will ${state.verb.infinitive}';
    }
  }

  String _buildPhrase(SentenceState state) {
    if (state.phrase == null) {
      return '';
    }

    return ' ${state.phrase!.text}';
  }
}
