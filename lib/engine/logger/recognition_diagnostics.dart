import 'package:padlock_app/models/sentence/sentence_state.dart';

class RecognitionDiagnostics {
  final String sentence;

  final List<String> tokens;

  final int verbChainStart;
  final int verbChainEnd;

  final SentenceState state;

  final List<String> unknownTokens;

  const RecognitionDiagnostics({
    required this.sentence,
    required this.tokens,
    required this.verbChainStart,
    required this.verbChainEnd,
    required this.state,
    this.unknownTokens = const [],
  });
}
