class EngineLogConfig {
  final bool recognition;
  final bool grammar;

  final bool tokens;
  final bool verbChain;
  final bool participants;
  final bool phrases;
  final bool sentenceState;

  final bool unknownTokens;

  const EngineLogConfig({
    this.recognition = false,
    this.grammar = false,
    this.tokens = false,
    this.verbChain = false,
    this.participants = false,
    this.phrases = false,
    this.sentenceState = false,
    this.unknownTokens = true,
  });
}
