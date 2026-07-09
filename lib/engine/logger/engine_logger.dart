import 'dart:async';
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
      _log('Recognition', 'Sentence: ${diagnostics.sentence}');

      _log('Recognition', 'Tokens: ${diagnostics.tokens}');
    }

    if (config.verbChain) {
      _log(
        'Recognition',
        'Verb chain: ${diagnostics.verbChainStart} -> ${diagnostics.verbChainEnd}',
      );
    }

    if (config.sentenceState) {
      _log('Recognition', diagnostics.state.toString());
    }

    if (config.unknownTokens) {
      _log('Recognition', 'Unknown tokens: ${diagnostics.unknownTokens}');
    }
  }

  void logRecognitionPhase(String phase, String snapshot) {
    if (!config.recognition || !config.phases) {
      return;
    }

    _log('Recognition', '[$phase]\n$snapshot');
  }

  void logRecognitionFailure(
    String phase,
    Object error,
    StackTrace stackTrace,
    String snapshot,
  ) {
    if (!config.recognition || !config.failures) {
      return;
    }

    _log(
      'Recognition',
      'Failed during $phase\n$snapshot',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void logGrammar(GrammarDiagnostics diagnostics) {
    if (!config.grammar) {
      return;
    }

    _log('Grammar', 'Sentence: ${diagnostics.sentence}');

    if (config.sentenceState) {
      _log('Grammar', diagnostics.state.toString());
    }
  }

  void logGrammarPhase(String phase, String snapshot) {
    if (!config.grammar || !config.phases) {
      return;
    }

    _log('Grammar', '[$phase]\n$snapshot');
  }

  void logGrammarFailure(
    String phase,
    Object error,
    StackTrace stackTrace,
    String snapshot,
  ) {
    if (!config.grammar || !config.failures) {
      return;
    }

    _log(
      'Grammar',
      'Failed during $phase\n$snapshot',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _log(
    String name,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (config.consoleOutput) {
      Zone.current.print('[$name] $message');

      if (error != null) {
        Zone.current.print('[$name] Error: $error');
      }

      if (stackTrace != null) {
        Zone.current.print('[$name] $stackTrace');
      }

      return;
    }

    developer.log(message, name: name, error: error, stackTrace: stackTrace);
  }
}
