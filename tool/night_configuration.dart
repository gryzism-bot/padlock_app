import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:padlock_app/data/modals.dart' as modal_data;
import 'package:padlock_app/data/phrases/frequency_phrases.dart'
    as frequency_data;
import 'package:padlock_app/data/phrases/manner_phrases.dart' as manner_data;
import 'package:padlock_app/data/phrases/place_phrases.dart' as place_data;
import 'package:padlock_app/data/phrases/time_phrases.dart' as time_data;
import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart'
    as fixed_object_data;
import 'package:padlock_app/data/subjects/adjectives/emotions.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/object_pronouns.dart' as object_data;
import 'package:padlock_app/data/subjects/third_person/objects.dart'
    as object_data;
import 'package:padlock_app/data/subjects/third_person/people.dart'
    as people_data;
import 'package:padlock_app/data/verbs/communication.dart'
    as communication_data;
import 'package:padlock_app/data/verbs/cooking.dart' as cooking_data;
import 'package:padlock_app/data/verbs/essential.dart' as verb_data;
import 'package:padlock_app/data/verbs/movement.dart' as movement_data;
import 'package:padlock_app/engine/configuration_compass.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/grammar/subject/determiner.dart';
import 'package:padlock_app/models/grammar/subject/noun.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

const _routeTraceLimit = 10;

Future<void> main(List<String> args) async {
  final options = _NightConfigurationOptions.parse(args);
  final runner = _NightConfigurationRunner(options);
  late final StreamSubscription<ProcessSignal> sigintSubscription;

  sigintSubscription = ProcessSignal.sigint.watch().listen((_) {
    stdout.writeln('Interrupt requested. Writing final checkpoint...');
    runner.requestStop();
  });

  final result = await runner.run();
  await sigintSubscription.cancel();

  stdout.writeln(result.consoleSummary);

  if (result.shouldExitWithFailure) {
    exitCode = 1;
  }
}

class _NightConfigurationOptions {
  final int minutes;
  final int seed;
  final int maxStepsPerWalk;
  final int checkpointEvery;
  final int probeEvery;
  final int sampleEvery;
  final String reportPath;
  final String jsonlPath;
  final bool failOnCompassLeak;
  final bool exitZero;

  const _NightConfigurationOptions({
    required this.minutes,
    required this.seed,
    required this.maxStepsPerWalk,
    required this.checkpointEvery,
    required this.probeEvery,
    required this.sampleEvery,
    required this.reportPath,
    required this.jsonlPath,
    required this.failOnCompassLeak,
    required this.exitZero,
  });

  factory _NightConfigurationOptions.parse(List<String> args) {
    var minutes = 1;
    var seed = DateTime.now().millisecondsSinceEpoch;
    var maxStepsPerWalk = 24;
    var checkpointEvery = 1000;
    var probeEvery = 3;
    var sampleEvery = 250;
    var reportPath = 'build/night_configuration_report.md';
    var jsonlPath = 'build/night_configuration_findings.jsonl';
    var failOnCompassLeak = false;
    var exitZero = false;

    for (final arg in args) {
      if (arg.startsWith('--minutes=')) {
        minutes = int.parse(arg.substring('--minutes='.length));
        if (minutes < 1) {
          throw ArgumentError('--minutes must be at least 1');
        }
      } else if (arg.startsWith('--seed=')) {
        seed = int.parse(arg.substring('--seed='.length));
      } else if (arg.startsWith('--max-steps=')) {
        maxStepsPerWalk = int.parse(arg.substring('--max-steps='.length));
        if (maxStepsPerWalk < 1) {
          throw ArgumentError('--max-steps must be at least 1');
        }
      } else if (arg.startsWith('--checkpoint-every=')) {
        checkpointEvery = int.parse(
          arg.substring('--checkpoint-every='.length),
        );
        if (checkpointEvery < 1) {
          throw ArgumentError('--checkpoint-every must be at least 1');
        }
      } else if (arg.startsWith('--probe-every=')) {
        probeEvery = int.parse(arg.substring('--probe-every='.length));
        if (probeEvery < 1) {
          throw ArgumentError('--probe-every must be at least 1');
        }
      } else if (arg.startsWith('--sample-every=')) {
        sampleEvery = int.parse(arg.substring('--sample-every='.length));
        if (sampleEvery < 1) {
          throw ArgumentError('--sample-every must be at least 1');
        }
      } else if (arg.startsWith('--report=')) {
        reportPath = arg.substring('--report='.length);
      } else if (arg.startsWith('--jsonl=')) {
        jsonlPath = arg.substring('--jsonl='.length);
      } else if (arg == '--fail-on-compass-leak') {
        failOnCompassLeak = true;
      } else if (arg == '--exit-zero') {
        exitZero = true;
      } else if (arg == '--help' || arg == '-h') {
        stdout.writeln('''
Night Configuration/Compass runner

Usage:
  dart run tool/night_configuration.dart [options]

Options:
  --minutes=N              Run for N minutes. Must be at least 1.
  --seed=N                 Deterministic random seed.
  --max-steps=N            Reset to initial state after N guided moves.
  --checkpoint-every=N     Refresh the markdown report every N guided moves.
  --probe-every=N          Run direct Lock probes every N guided moves.
  --sample-every=N         Stream accepted guided move samples every N moves.
  --report=PATH            Markdown report path.
  --jsonl=PATH             JSONL evidence path.
  --fail-on-compass-leak   Exit 1 if Compass exposes a move the Lock blocks.
  --exit-zero              Always exit 0 after writing reports.
''');
        exit(0);
      } else {
        throw ArgumentError('Unknown argument: $arg');
      }
    }

    return _NightConfigurationOptions(
      minutes: minutes,
      seed: seed,
      maxStepsPerWalk: maxStepsPerWalk,
      checkpointEvery: checkpointEvery,
      probeEvery: probeEvery,
      sampleEvery: sampleEvery,
      reportPath: reportPath,
      jsonlPath: jsonlPath,
      failOnCompassLeak: failOnCompassLeak,
      exitZero: exitZero,
    );
  }
}

class _NightConfigurationRunner {
  final _NightConfigurationOptions options;
  final ConfigurationEngine lock = const ConfigurationEngine();
  final ConfigurationCompass compass = ConfigurationCompass();
  final GrammarEngine grammar = GrammarEngine();
  final Random random;
  var _stopRequested = false;

  _NightConfigurationRunner(this.options) : random = Random(options.seed);

  void requestStop() {
    _stopRequested = true;
  }

  Future<_NightConfigurationResult> run() async {
    final startedAt = DateTime.now();
    final deadline = startedAt.add(Duration(minutes: options.minutes));
    final stats = _ConfigurationNightStats();
    var state = ConfigurationState.initial();
    var stepsInWalk = 0;
    var route = <String>[];

    _prepareOutputFiles(startedAt);
    _writeJsonl({
      'type': 'run_started',
      'startedAt': startedAt.toIso8601String(),
      'minutes': options.minutes,
      'seed': options.seed,
      'maxStepsPerWalk': options.maxStepsPerWalk,
      'probeEvery': options.probeEvery,
    });

    while (!_stopRequested && DateTime.now().isBefore(deadline)) {
      final collectStopwatch = Stopwatch()..start();
      final suggestions = _collectSuggestions(state, stats);
      collectStopwatch.stop();
      stats.compassCollections.record(collectStopwatch.elapsed);

      if (stats.guidedMoves % options.probeEvery == 0) {
        _probeLaws(state, stats, route);
      }

      final moves = suggestions
          .where((suggestion) => !suggestion.isSelected)
          .toList();

      if (moves.isEmpty || stepsInWalk >= options.maxStepsPerWalk) {
        stats.resets++;
        stepsInWalk = 0;
        state = ConfigurationState.initial();
        route = const [];
        continue;
      }

      final suggestion = moves[random.nextInt(moves.length)];
      final moveStopwatch = Stopwatch()..start();
      final next = lock.applyMove(state, suggestion.move);
      final blockers = _blockedMessages(next);

      if (blockers.isNotEmpty) {
        moveStopwatch.stop();
        stats.lockTransitions.record(moveStopwatch.elapsed);
        stats.compassLeaks++;
        _recordCompassLeak(state, suggestion, blockers, stats, route);
        state = ConfigurationState.initial();
        stepsInWalk = 0;
        route = const [];
        continue;
      }

      final render = _render(next.sentenceState);
      moveStopwatch.stop();
      stats.lockTransitions.record(moveStopwatch.elapsed);
      stats.guidedTimingsBySlot
          .putIfAbsent(suggestion.slot.name, _TimingStats.new)
          .record(moveStopwatch.elapsed);
      if (!render.ok) {
        stats.renderFailures++;
        _writeJsonl({
          'type': 'render_failure',
          'move': _moveLabel(suggestion.move),
          'slot': suggestion.slot.name,
          'error': render.error,
          'state': next.sentenceState.summary,
        });
        state = ConfigurationState.initial();
        stepsInWalk = 0;
        route = const [];
        continue;
      }

      state = next;
      stepsInWalk++;
      stats.guidedMoves++;
      route = _appendRoute(
        route,
        '${suggestion.slot.name}: ${_moveLabel(suggestion.move)} -> ${render.text}',
      );
      stats.guidedMovesBySlot.update(
        suggestion.slot.name,
        (count) => count + 1,
        ifAbsent: () => 1,
      );

      if (stats.guidedMoves % options.sampleEvery == 0) {
        _writeJsonl({
          'type': 'guided_move_sample',
          'moveNumber': stats.guidedMoves,
          'slot': suggestion.slot.name,
          'move': _moveLabel(suggestion.move),
          'elapsedMs': _elapsedMs(moveStopwatch.elapsed),
          'sentence': render.text,
          'state': state.sentenceState.summary,
          'route': route,
        });
      }

      if (stats.guidedMoves % options.checkpointEvery == 0) {
        _writeReport(startedAt, stats, interrupted: false);
      }
    }

    _probeLaws(state, stats, route);
    _writeReport(startedAt, stats, interrupted: _stopRequested);
    _writeJsonl({
      'type': 'run_finished',
      'finishedAt': DateTime.now().toIso8601String(),
      'interrupted': _stopRequested,
      'guidedMoves': stats.guidedMoves,
      'lawProbeAttempts': stats.lawProbeAttempts,
      'uniqueLawFamilies': stats.lawFamilies.length,
      'uniqueLawMessages': stats.lawMessages.length,
      'compassLeaks': stats.compassLeaks,
      'renderFailures': stats.renderFailures,
      'compassCollectionAverageMs': stats.compassCollections.averageMs,
      'lockTransitionAverageMs': stats.lockTransitions.averageMs,
    });

    return _NightConfigurationResult(
      consoleSummary: [
        'Configuration night run finished.',
        'Guided moves: ${stats.guidedMoves}',
        'Law probes: ${stats.lawProbeAttempts}',
        'Unique law families: ${stats.lawFamilies.length}',
        'Unique law messages: ${stats.lawMessages.length}',
        'Compass leaks: ${stats.compassLeaks}',
        'Render failures: ${stats.renderFailures}',
        'Report: ${options.reportPath}',
        'JSONL: ${options.jsonlPath}',
      ].join('\n'),
      shouldExitWithFailure:
          !options.exitZero &&
          ((options.failOnCompassLeak && stats.compassLeaks > 0) ||
              stats.renderFailures > 0),
    );
  }

  List<ConfigurationSuggestion> _collectSuggestions(
    ConfigurationState state,
    _ConfigurationNightStats stats,
  ) {
    final suggestions = <ConfigurationSuggestion>[];

    for (final slot in ConfigurationCompassSlot.values) {
      final slotSuggestions = compass.suggestionsFor(state, slot, limit: 0);
      suggestions.addAll(slotSuggestions);

      final rail = stats.rails.putIfAbsent(slot.name, _RailStats.new);
      rail.observations++;
      rail.totalCandidates += slotSuggestions.length;
      if (slotSuggestions.isNotEmpty) {
        rail.awakeObservations++;
      }
      if (slotSuggestions.length > rail.maxCandidates) {
        rail.maxCandidates = slotSuggestions.length;
        rail.exampleSentence = _render(state.sentenceState).text;
      }
    }

    return suggestions;
  }

  void _probeLaws(
    ConfigurationState state,
    _ConfigurationNightStats stats,
    List<String> route,
  ) {
    final sentenceBefore = _render(state.sentenceState).text;

    for (final probe in _lawProbes) {
      stats.lawProbeAttempts++;
      final result = lock.applyMove(state, probe.move);
      final blockers = _blockedMessages(result);

      if (blockers.isEmpty) {
        stats.acceptedProbes.update(
          probe.label,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
        continue;
      }

      for (final message in blockers) {
        final key = '${message.source.name}|${message.text}';
        final stat = stats.lawMessages.putIfAbsent(
          key,
          () => _LawMessageStats(
            source: message.source.label,
            text: message.text,
            firstMove: probe.label,
            firstSentence: sentenceBefore,
            firstState: state.sentenceState.summary,
            firstRoute: route,
          ),
        );
        stat.count++;

        final familyText = _lawFamily(message.text);
        final familyKey = '${message.source.name}|$familyText';
        final family = stats.lawFamilies.putIfAbsent(
          familyKey,
          () => _LawMessageStats(
            source: message.source.label,
            text: familyText,
            firstMove: probe.label,
            firstSentence: sentenceBefore,
            firstState: state.sentenceState.summary,
            firstRoute: route,
          ),
        );
        family.count++;

        if (stat.count == 1) {
          _writeJsonl({
            'type': 'law_probe_blocked',
            'source': message.source.label,
            'message': message.text,
            'move': probe.label,
            'sentenceBefore': sentenceBefore,
            'stateBefore': state.sentenceState.summary,
            'route': route,
          });
        }
      }
    }
  }

  void _recordCompassLeak(
    ConfigurationState state,
    ConfigurationSuggestion suggestion,
    List<ConfigurationMessage> blockers,
    _ConfigurationNightStats stats,
    List<String> route,
  ) {
    for (final message in blockers) {
      final key =
          '${suggestion.slot.name}|${message.source.name}|${message.text}';
      final leak = stats.compassLeakMessages.putIfAbsent(
        key,
        () => _CompassLeakStats(
          slot: suggestion.slot.name,
          message: message.text,
          firstMove: _moveLabel(suggestion.move),
          firstSentence: _render(state.sentenceState).text,
          firstState: state.sentenceState.summary,
          firstRoute: route,
        ),
      );
      leak.count++;
    }

    _writeJsonl({
      'type': 'compass_exposed_blocked_move',
      'slot': suggestion.slot.name,
      'label': suggestion.label,
      'move': _moveLabel(suggestion.move),
      'sentenceBefore': _render(state.sentenceState).text,
      'stateBefore': state.sentenceState.summary,
      'route': route,
      'messages': blockers
          .map(
            (message) => {
              'source': message.source.label,
              'kind': message.kind.name,
              'text': message.text,
            },
          )
          .toList(),
    });
  }

  void _prepareOutputFiles(DateTime startedAt) {
    for (final path in [options.reportPath, options.jsonlPath]) {
      final file = File(path);
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('');
    }

    File(options.reportPath).writeAsStringSync(
      '# Configuration Night Contract\n\n'
      'Started: ${startedAt.toIso8601String()}\n\n'
      'Run in progress. Press Ctrl+C for a graceful checkpoint.\n',
    );
  }

  void _writeJsonl(Map<String, Object?> event) {
    File(options.jsonlPath).writeAsStringSync(
      '${jsonEncode(event)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }

  void _writeReport(
    DateTime startedAt,
    _ConfigurationNightStats stats, {
    required bool interrupted,
  }) {
    final now = DateTime.now();
    final elapsed = now.difference(startedAt);
    final laws = stats.lawMessages.values.toList()
      ..sort((left, right) => right.count.compareTo(left.count));
    final lawFamilies = stats.lawFamilies.values.toList()
      ..sort((left, right) => right.count.compareTo(left.count));
    final leaks = stats.compassLeakMessages.values.toList()
      ..sort((left, right) => right.count.compareTo(left.count));
    final guided = stats.guidedMovesBySlot.entries.toList()
      ..sort((left, right) => right.value.compareTo(left.value));
    final guidedTimings = stats.guidedTimingsBySlot.entries.toList()
      ..sort((left, right) => right.value.max.compareTo(left.value.max));
    final rails = stats.rails.entries.toList()
      ..sort(
        (left, right) =>
            right.value.maxCandidates.compareTo(left.value.maxCandidates),
      );

    final buffer = StringBuffer()
      ..writeln('# Configuration Night Contract')
      ..writeln()
      ..writeln('Started: ${startedAt.toIso8601String()}')
      ..writeln('Updated: ${now.toIso8601String()}')
      ..writeln('Elapsed: ${elapsed.inSeconds}s')
      ..writeln('Interrupted: $interrupted')
      ..writeln('Seed: ${options.seed}')
      ..writeln()
      ..writeln('## Totals')
      ..writeln()
      ..writeln('- Guided moves accepted: ${stats.guidedMoves}')
      ..writeln('- Guided resets: ${stats.resets}')
      ..writeln('- Direct law probe attempts: ${stats.lawProbeAttempts}')
      ..writeln('- Unique law families: ${stats.lawFamilies.length}')
      ..writeln('- Unique law messages: ${stats.lawMessages.length}')
      ..writeln('- Compass exposed blocked moves: ${stats.compassLeaks}')
      ..writeln('- Render failures: ${stats.renderFailures}')
      ..writeln(
        '- Compass collection average: ${stats.compassCollections.averageMs.toStringAsFixed(2)} ms',
      )
      ..writeln(
        '- Lock/render transition average: ${stats.lockTransitions.averageMs.toStringAsFixed(2)} ms',
      )
      ..writeln()
      ..writeln('## Candidate Law Families')
      ..writeln()
      ..writeln(
        '| Count | Source | Law family | First probe | First sentence | First route |',
      )
      ..writeln('| ---: | --- | --- | --- | --- | --- |');

    for (final law in lawFamilies.take(40)) {
      buffer.writeln(
        '| ${law.count} | ${_md(law.source)} | ${_md(law.text)} | '
        '${_md(law.firstMove)} | ${_md(law.firstSentence)} | '
        '${_md(_routeSummary(law.firstRoute))} |',
      );
    }

    if (lawFamilies.isEmpty) {
      buffer.writeln('| 0 | - | No blocked law probes observed. | - | - | - |');
    }

    buffer
      ..writeln()
      ..writeln('## Candidate Law Messages')
      ..writeln()
      ..writeln(
        '| Count | Source | Message | First probe | First sentence | First route |',
      )
      ..writeln('| ---: | --- | --- | --- | --- | --- |');

    for (final law in laws.take(40)) {
      buffer.writeln(
        '| ${law.count} | ${_md(law.source)} | ${_md(law.text)} | '
        '${_md(law.firstMove)} | ${_md(law.firstSentence)} | '
        '${_md(_routeSummary(law.firstRoute))} |',
      );
    }

    if (laws.isEmpty) {
      buffer.writeln('| 0 | - | No blocked law probes observed. | - | - | - |');
    }

    buffer
      ..writeln()
      ..writeln('## Compass Leaks')
      ..writeln()
      ..writeln(
        'These are bugs: Compass offered a move that the Lock rejected.',
      )
      ..writeln()
      ..writeln(
        '| Count | Slot | Message | First move | First sentence | First route |',
      )
      ..writeln('| ---: | --- | --- | --- | --- | --- |');

    for (final leak in leaks.take(20)) {
      buffer.writeln(
        '| ${leak.count} | ${_md(leak.slot)} | ${_md(leak.message)} | '
        '${_md(leak.firstMove)} | ${_md(leak.firstSentence)} | '
        '${_md(_routeSummary(leak.firstRoute))} |',
      );
    }

    if (leaks.isEmpty) {
      buffer.writeln('| 0 | - | No Compass leaks observed. | - | - | - |');
    }

    buffer
      ..writeln()
      ..writeln('## Guided Move Distribution')
      ..writeln()
      ..writeln('| Slot | Accepted moves |')
      ..writeln('| --- | ---: |');

    for (final entry in guided) {
      buffer.writeln('| ${_md(entry.key)} | ${entry.value} |');
    }

    buffer
      ..writeln()
      ..writeln('## Timing')
      ..writeln()
      ..writeln('| Layer / slot | Count | Average ms | Max ms |')
      ..writeln('| --- | ---: | ---: | ---: |')
      ..writeln(
        '| Compass collection | ${stats.compassCollections.count} | '
        '${stats.compassCollections.averageMs.toStringAsFixed(2)} | '
        '${_elapsedMs(stats.compassCollections.max).toStringAsFixed(2)} |',
      )
      ..writeln(
        '| Lock/render transition | ${stats.lockTransitions.count} | '
        '${stats.lockTransitions.averageMs.toStringAsFixed(2)} | '
        '${_elapsedMs(stats.lockTransitions.max).toStringAsFixed(2)} |',
      );

    for (final entry in guidedTimings.take(20)) {
      buffer.writeln(
        '| ${_md(entry.key)} | ${entry.value.count} | '
        '${entry.value.averageMs.toStringAsFixed(2)} | '
        '${_elapsedMs(entry.value.max).toStringAsFixed(2)} |',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Rail Observations')
      ..writeln()
      ..writeln(
        '| Slot | Awake observations | Max candidates | Example sentence |',
      )
      ..writeln('| --- | ---: | ---: | --- |');

    for (final entry in rails) {
      buffer.writeln(
        '| ${_md(entry.key)} | ${entry.value.awakeObservations} | '
        '${entry.value.maxCandidates} | ${_md(entry.value.exampleSentence)} |',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Accepted Probe Distribution')
      ..writeln()
      ..writeln('| Probe | Accepted count |')
      ..writeln('| --- | ---: |');

    final acceptedProbes = stats.acceptedProbes.entries.toList()
      ..sort((left, right) => right.value.compareTo(left.value));
    for (final entry in acceptedProbes.take(30)) {
      buffer.writeln('| ${_md(entry.key)} | ${entry.value} |');
    }

    File(options.reportPath).writeAsStringSync(buffer.toString());
  }

  _RenderResult _render(SentenceState state) {
    try {
      return _RenderResult._(grammar.generate(state).text, null);
    } catch (error) {
      return _RenderResult._('<render failed>', error.toString());
    }
  }
}

class _ConfigurationNightStats {
  var guidedMoves = 0;
  var lawProbeAttempts = 0;
  var resets = 0;
  var compassLeaks = 0;
  var renderFailures = 0;
  final guidedMovesBySlot = <String, int>{};
  final acceptedProbes = <String, int>{};
  final rails = <String, _RailStats>{};
  final lawFamilies = <String, _LawMessageStats>{};
  final lawMessages = <String, _LawMessageStats>{};
  final compassLeakMessages = <String, _CompassLeakStats>{};
  final compassCollections = _TimingStats();
  final lockTransitions = _TimingStats();
  final guidedTimingsBySlot = <String, _TimingStats>{};
}

class _TimingStats {
  var count = 0;
  var total = Duration.zero;
  var max = Duration.zero;

  void record(Duration elapsed) {
    count++;
    total += elapsed;
    if (elapsed > max) {
      max = elapsed;
    }
  }

  double get averageMs {
    if (count == 0) {
      return 0;
    }

    return _elapsedMs(total) / count;
  }
}

class _RailStats {
  var observations = 0;
  var awakeObservations = 0;
  var totalCandidates = 0;
  var maxCandidates = 0;
  var exampleSentence = '';
}

class _LawMessageStats {
  final String source;
  final String text;
  final String firstMove;
  final String firstSentence;
  final String firstState;
  final List<String> firstRoute;
  var count = 0;

  _LawMessageStats({
    required this.source,
    required this.text,
    required this.firstMove,
    required this.firstSentence,
    required this.firstState,
    required List<String> firstRoute,
  }) : firstRoute = List.unmodifiable(firstRoute);
}

class _CompassLeakStats {
  final String slot;
  final String message;
  final String firstMove;
  final String firstSentence;
  final String firstState;
  final List<String> firstRoute;
  var count = 0;

  _CompassLeakStats({
    required this.slot,
    required this.message,
    required this.firstMove,
    required this.firstSentence,
    required this.firstState,
    required List<String> firstRoute,
  }) : firstRoute = List.unmodifiable(firstRoute);
}

class _LawProbe {
  final String label;
  final ConfigurationMove move;

  const _LawProbe(this.label, this.move);
}

class _RenderResult {
  final String text;
  final String? error;

  const _RenderResult._(this.text, this.error);

  bool get ok => error == null;
}

class _NightConfigurationResult {
  final String consoleSummary;
  final bool shouldExitWithFailure;

  const _NightConfigurationResult({
    required this.consoleSummary,
    required this.shouldExitWithFailure,
  });
}

final _lawProbes = <_LawProbe>[
  _LawProbe('agent -> no agent', const SetAgent(null)),
  _LawProbe('verb -> be', const SetAction(verb_data.be)),
  _LawProbe('verb -> learn', const SetAction(verb_data.learn)),
  _LawProbe('verb -> play', const SetAction(verb_data.play)),
  _LawProbe('verb -> read', const SetAction(verb_data.read)),
  _LawProbe('verb -> write', const SetAction(communication_data.write)),
  _LawProbe('verb -> close', const SetAction(verb_data.close)),
  _LawProbe('verb -> chop', const SetAction(cooking_data.chop)),
  _LawProbe('object -> book', SetObject(_object(object_data.book))),
  _LawProbe('object -> books', SetObject(_objectPlural(object_data.book))),
  _LawProbe('object -> apple', SetObject(_object(object_data.apple))),
  _LawProbe('object -> bridge', SetObject(_object(object_data.bridge))),
  _LawProbe('object -> English', const SetObject(fixed_object_data.english)),
  _LawProbe('object -> football', const SetObject(fixed_object_data.football)),
  _LawProbe('object -> no object', const SetObject(null)),
  _LawProbe('recipient -> Mary', SetRecipient(_person(people_data.mary))),
  _LawProbe('recipient -> us', const SetRecipient(object_data.us)),
  _LawProbe('recipient -> no recipient', const SetRecipient(null)),
  _LawProbe('addressee -> Mary', SetAddressee(_person(people_data.mary))),
  _LawProbe('addressee -> no addressee', const SetAddressee(null)),
  _LawProbe('companion -> Mary', SetCompanion(_person(people_data.mary))),
  _LawProbe('companion -> no companion', const SetCompanion(null)),
  _LawProbe('destination -> Mary', SetDestination(_person(people_data.mary))),
  _LawProbe('destination -> no destination', const SetDestination(null)),
  _LawProbe(
    'complement -> teacher',
    SetComplement(_person(people_data.teacher)),
  ),
  _LawProbe('complement -> no complement', const SetComplement(null)),
  _LawProbe(
    'adjective complement -> happy',
    SetAdjectiveComplement(_adjective('happy')),
  ),
  _LawProbe('right action -> go', const SetRightAction(verb_data.go)),
  _LawProbe(
    'right action -> speak',
    const SetRightAction(communication_data.speak),
  ),
  _LawProbe('right action -> swim', const SetRightAction(movement_data.swim)),
  _LawProbe('right action -> none', const SetRightAction(null)),
  _LawProbe(
    'object determiner -> a',
    const SetNounPhraseDeterminer(NounPhraseTarget.object, aDeterminer),
  ),
  _LawProbe(
    'object determiner -> many',
    const SetNounPhraseDeterminer(NounPhraseTarget.object, manyDeterminer),
  ),
  _LawProbe(
    'object determiner -> all',
    const SetNounPhraseDeterminer(NounPhraseTarget.object, allDeterminer),
  ),
  _LawProbe(
    'object determiner -> none',
    const SetNounPhraseDeterminer(NounPhraseTarget.object, null),
  ),
  _LawProbe(
    'object adjective -> calm',
    SetNounPhraseAdjectives(NounPhraseTarget.object, [_adjective('calm')]),
  ),
  _LawProbe(
    'agent determiner -> the',
    const SetNounPhraseDeterminer(NounPhraseTarget.agent, theDeterminer),
  ),
  _LawProbe(
    'agent adjective -> calm',
    SetNounPhraseAdjectives(NounPhraseTarget.agent, [_adjective('calm')]),
  ),
  _LawProbe(
    'recipient determiner -> the',
    const SetNounPhraseDeterminer(NounPhraseTarget.recipient, theDeterminer),
  ),
  _LawProbe(
    'recipient adjective -> calm',
    SetNounPhraseAdjectives(NounPhraseTarget.recipient, [_adjective('calm')]),
  ),
  _LawProbe(
    'addressee determiner -> the',
    const SetNounPhraseDeterminer(NounPhraseTarget.addressee, theDeterminer),
  ),
  _LawProbe(
    'addressee adjective -> calm',
    SetNounPhraseAdjectives(NounPhraseTarget.addressee, [_adjective('calm')]),
  ),
  _LawProbe(
    'companion determiner -> the',
    const SetNounPhraseDeterminer(NounPhraseTarget.companion, theDeterminer),
  ),
  _LawProbe(
    'companion adjective -> calm',
    SetNounPhraseAdjectives(NounPhraseTarget.companion, [_adjective('calm')]),
  ),
  _LawProbe(
    'destination determiner -> the',
    const SetNounPhraseDeterminer(NounPhraseTarget.destination, theDeterminer),
  ),
  _LawProbe(
    'destination adjective -> calm',
    SetNounPhraseAdjectives(NounPhraseTarget.destination, [_adjective('calm')]),
  ),
  _LawProbe(
    'complement determiner -> the',
    const SetNounPhraseDeterminer(NounPhraseTarget.complement, theDeterminer),
  ),
  _LawProbe(
    'complement adjective -> calm',
    SetNounPhraseAdjectives(NounPhraseTarget.complement, [_adjective('calm')]),
  ),
  _LawProbe('voice -> passive', const SetVoice(Voice.passive)),
  _LawProbe('voice -> active', const SetVoice(Voice.active)),
  _LawProbe(
    'passive focus -> object',
    const SetPassiveFocus(PassiveFocus.object),
  ),
  _LawProbe(
    'passive focus -> recipient',
    const SetPassiveFocus(PassiveFocus.recipient),
  ),
  _LawProbe('passive focus -> none', const SetPassiveFocus(null)),
  _LawProbe('passive agent -> hide', const SetPassiveAgentVisibility(false)),
  _LawProbe('passive agent -> show', const SetPassiveAgentVisibility(true)),
  _LawProbe('tense -> future', const SetTense(Tense.future)),
  _LawProbe('aspect -> perfect', const SetAspect(Aspect.perfect)),
  _LawProbe('modal -> will', const SetModal(modal_data.will)),
  _LawProbe('modal -> can', const SetModal(modal_data.can)),
  _LawProbe('modal -> no modal', const SetModal(modal_data.noModal)),
  _LawProbe('polarity -> negative', const SetPolarity(Polarity.negative)),
  _LawProbe(
    'form -> imperative',
    const SetSentenceForm(SentenceForm.imperative),
  ),
  _LawProbe('form -> statement', const SetSentenceForm(SentenceForm.statement)),
  _LawProbe(
    'place phrase -> school',
    const SetPlacePhrase(place_data.schoolPlacePhrase),
  ),
  _LawProbe('place phrase -> none', const SetPlacePhrase(null)),
  _LawProbe(
    'time phrase -> tomorrow',
    const SetTimePhrase(time_data.tomorrowTimePhrase),
  ),
  _LawProbe('time phrase -> none', const SetTimePhrase(null)),
  _LawProbe(
    'frequency phrase -> always',
    const SetFrequencyPhrase(frequency_data.alwaysFrequencyPhrase),
  ),
  _LawProbe('frequency phrase -> none', const SetFrequencyPhrase(null)),
  _LawProbe(
    'manner phrase -> carefully',
    const SetMannerPhrase(manner_data.carefullyMannerPhrase),
  ),
  _LawProbe('manner phrase -> none', const SetMannerPhrase(null)),
];

NounPhrase _object(Noun noun) {
  return noun.toNounPhrase(Number.singular);
}

NounPhrase _objectPlural(Noun noun) {
  return noun.toNounPhrase(Number.plural);
}

NounPhrase _person(Noun noun) {
  return noun.toNounPhrase(Number.singular);
}

Adjective _adjective(String text) {
  return emotionsAdjectives.firstWhere((adjective) => adjective.text == text);
}

List<ConfigurationMessage> _blockedMessages(ConfigurationState state) {
  return state.messages
      .where((message) => message.kind == ConfigurationMessageKind.blocked)
      .toList();
}

String _moveLabel(ConfigurationMove move) {
  return switch (move) {
    SetAgent(:final agent) => 'agent -> ${_nounPhraseLabel(agent)}',
    SetAction(:final action) => 'verb -> ${action.infinitive}',
    SetObject(:final object) => 'object -> ${_nounPhraseLabel(object)}',
    SetRecipient(:final recipient) =>
      'recipient -> ${_nounPhraseLabel(recipient)}',
    SetAddressee(:final addressee) =>
      'addressee -> ${_nounPhraseLabel(addressee)}',
    SetCompanion(:final companion) =>
      'companion -> ${_nounPhraseLabel(companion)}',
    SetDestination(:final destination) =>
      'destination -> ${_nounPhraseLabel(destination)}',
    SetRightAction(:final rightAction) =>
      'right action -> ${rightAction?.infinitive ?? 'none'}',
    SetComplement(:final complement) =>
      'complement -> ${_nounPhraseLabel(complement)}',
    SetObjectComplement(:final objectComplement) =>
      'object complement -> ${_nounPhraseLabel(objectComplement)}',
    SetNounPhraseDeterminer(:final target, :final determiner) =>
      '${target.name} determiner -> ${_determinerLabel(determiner)}',
    SetNounPhraseAdjectives(:final target, :final adjectives) =>
      '${target.name} adjective -> ${_adjectivesLabel(adjectives)}',
    SetAdjectiveComplement(:final adjectiveComplement) =>
      'adjective complement -> ${adjectiveComplement?.text ?? 'none'}',
    SetObjectAdjectiveComplement(:final objectAdjectiveComplement) =>
      'object adjective complement -> ${objectAdjectiveComplement?.text ?? 'none'}',
    SetLexicalBeComplement(:final complement) =>
      'be complement -> ${_nounPhraseLabel(complement)}',
    SetLexicalBeAdjectiveComplement(:final adjectiveComplement) =>
      'be adjective complement -> ${adjectiveComplement.text}',
    SetVoice(:final voice) => 'voice -> ${voice.name}',
    SetPassiveFocus(:final passiveFocus) =>
      'passive focus -> ${passiveFocus?.name ?? 'none'}',
    SetPassiveAgentVisibility(:final showPassiveAgent) =>
      'passive agent -> ${showPassiveAgent ? 'show' : 'hide'}',
    SetTense(:final tense) => 'tense -> ${tense.name}',
    SetAspect(:final aspect) => 'aspect -> ${aspect.name}',
    SetModal(:final modal) => 'modal -> ${_modalLabel(modal)}',
    SetPolarity(:final polarity) => 'polarity -> ${polarity.name}',
    SetSentenceForm(:final sentenceForm) => 'form -> ${sentenceForm.name}',
    SetTimePhrase(:final timePhrase) =>
      'time phrase -> ${timePhrase?.text ?? 'none'}',
    SetPlacePhrase(:final placePhrase) =>
      'place phrase -> ${placePhrase?.noun ?? 'none'}',
    SetFrequencyPhrase(:final frequencyPhrase) =>
      'frequency phrase -> ${frequencyPhrase?.text ?? 'none'}',
    SetMannerPhrase(:final mannerPhrase) =>
      'manner phrase -> ${mannerPhrase?.text ?? 'none'}',
  };
}

String _nounPhraseLabel(NounPhrase? phrase) {
  if (phrase == null) {
    return 'none';
  }

  return [
    if (phrase.determiner != null) phrase.determiner!.text,
    ...phrase.adjectiveList.map((adjective) => adjective.text),
    phrase.text,
  ].join(' ');
}

String _determinerLabel(Determiner? determiner) {
  return determiner?.text ?? 'none';
}

String _adjectivesLabel(List<Adjective> adjectives) {
  if (adjectives.isEmpty) {
    return 'none';
  }

  return adjectives.map((adjective) => adjective.text).join(' ');
}

String _modalLabel(Modal modal) {
  return modal.isNone ? 'no modal' : modal.text;
}

List<String> _appendRoute(List<String> route, String entry) {
  return [...route, entry].takeLast(_routeTraceLimit).toList();
}

String _routeSummary(List<String> route) {
  if (route.isEmpty) {
    return '-';
  }

  return route.join(' -> ');
}

double _elapsedMs(Duration elapsed) {
  return elapsed.inMicroseconds / Duration.microsecondsPerMillisecond;
}

String _md(String text) {
  return text.replaceAll('|', r'\|').replaceAll('\n', ' ');
}

String _lawFamily(String text) {
  final verbDoesNotTake = RegExp(
    r'^.+? does not take (an? .+)\.$',
  ).firstMatch(text);
  if (verbDoesNotTake != null) {
    return '<verb> does not take ${verbDoesNotTake.group(1)}.';
  }

  final fixedObject = RegExp(
    r'^.+? only takes fixed (.+) objects\.$',
  ).firstMatch(text);
  if (fixedObject != null) {
    return '<verb> only takes fixed ${fixedObject.group(1)} objects.';
  }

  if (RegExp(r'^.+? cannot be passive in this frame\.$').hasMatch(text)) {
    return '<verb> cannot be passive in this frame.';
  }

  if (RegExp(r'^.+? has no recipient focus\.$').hasMatch(text)) {
    return '<verb> has no recipient focus.';
  }

  if (RegExp(r'^.+? belongs to the present modal frame\.$').hasMatch(text)) {
    return '<modal> belongs to the present modal frame.';
  }

  return text;
}

extension _TakeLastExtension<T> on List<T> {
  Iterable<T> takeLast(int count) sync* {
    final start = length > count ? length - count : 0;
    for (var index = start; index < length; index++) {
      yield this[index];
    }
  }
}
