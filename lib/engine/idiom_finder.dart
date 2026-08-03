import 'package:padlock_app/data/idioms/idiom_patterns.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

class IdiomFinder {
  final List<IdiomPattern> patterns;

  const IdiomFinder({this.patterns = idiomPatterns});

  int get total => patterns.length;

  List<IdiomMatch> find(SentenceState state) {
    return [
      for (final pattern in patterns)
        if (pattern.matches(state)) IdiomMatch(pattern),
    ];
  }
}

class IdiomMatch {
  final IdiomPattern pattern;

  const IdiomMatch(this.pattern);
}
