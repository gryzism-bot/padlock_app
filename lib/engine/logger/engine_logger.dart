import 'dart:developer' as developer;

import 'engine_log_config.dart';
import 'grammar_diagnostics.dart';
import 'recognition_diagnostics.dart';

class EngineLogger {
  final EngineLogConfig config;

  const EngineLogger({this.config = const EngineLogConfig()});

  void logRecognition(RecognitionDiagnostics diagnostics) {
    if (!config.recognition) {
      return;
    }

    if (config.tokens) {
      developer.log('Sentence: ${diagnostics.sentence}', name: 'Recognition');

      developer.log('Tokens: ${diagnostics.tokens}', name: 'Recognition');
    }

    if (config.verbChain) {
      developer.log(
        'Verb chain: ${diagnostics.verbChainStart} -> ${diagnostics.verbChainEnd}',
        name: 'Recognition',
      );
    }

    if (config.sentenceState) {
      developer.log(diagnostics.state.toString(), name: 'Recognition');
    }

    if (config.unknownTokens) {
      developer.log(
        'Unknown tokens: ${diagnostics.unknownTokens}',
        name: 'Recognition',
      );
    }
  }

  void logGrammar(GrammarDiagnostics diagnostics) {
    if (!config.grammar) {
      return;
    }

    developer.log('Sentence: ${diagnostics.sentence}', name: 'Grammar');

    if (config.sentenceState) {
      developer.log(diagnostics.state.toString(), name: 'Grammar');
    }
  }
}
