import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/frequency_phrases.dart';
import 'package:padlock_app/data/phrases/manner_phrases.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/adjectives/appearance.dart';
import 'package:padlock_app/data/subjects/adjectives/quality.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/engine/logger/engine_log_config.dart';
import 'package:padlock_app/engine/logger/engine_logger.dart';
import 'package:padlock_app/engine/logger/recognition_diagnostics.dart';
import 'package:padlock_app/engine/recognition_engine.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/phrase/frequency_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/manner_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/place_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/time_phrase.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

Future<void> main(List<String> args) async {
  final options = _NightRunOptions.parse(args);
  final runner = _NightContractRunner(options);
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

class _NightRunOptions {
  final int limit;
  final int? minutes;
  final int checkpointEvery;
  final bool failFast;
  final bool stateDriftFails;
  final bool exitZero;
  final String reportPath;
  final String jsonlPath;

  const _NightRunOptions({
    required this.limit,
    required this.minutes,
    required this.checkpointEvery,
    required this.failFast,
    required this.stateDriftFails,
    required this.exitZero,
    required this.reportPath,
    required this.jsonlPath,
  });

  factory _NightRunOptions.parse(List<String> args) {
    var limit = 0;
    int? minutes;
    var checkpointEvery = 1000;
    var failFast = false;
    var stateDriftFails = false;
    var exitZero = false;
    var reportPath = 'build/night_contract_report.md';
    var jsonlPath = 'build/night_contract_findings.jsonl';

    for (final arg in args) {
      if (arg == '--fail-fast') {
        failFast = true;
      } else if (arg == '--exit-zero') {
        exitZero = true;
      } else if (arg == '--state-drift-fails') {
        stateDriftFails = true;
      } else if (arg.startsWith('--limit=')) {
        limit = int.parse(arg.substring('--limit='.length));
      } else if (arg.startsWith('--minutes=')) {
        minutes = int.parse(arg.substring('--minutes='.length));
        if (minutes < 1) {
          throw ArgumentError('--minutes must be at least 1');
        }
      } else if (arg.startsWith('--checkpoint-every=')) {
        checkpointEvery = int.parse(
          arg.substring('--checkpoint-every='.length),
        );
        if (checkpointEvery < 1) {
          throw ArgumentError('--checkpoint-every must be at least 1');
        }
      } else if (arg.startsWith('--report=')) {
        reportPath = arg.substring('--report='.length);
      } else if (arg.startsWith('--jsonl=')) {
        jsonlPath = arg.substring('--jsonl='.length);
      } else if (arg == '--help' || arg == '-h') {
        stdout.writeln('''
Night one-predicate contract runner

Usage:
  dart run tool/night_contract.dart [options]

Options:
  --limit=N              Stop after N checked generated states. 0 means all.
  --minutes=N            Run repeatedly for N minutes. Must be at least 1.
  --checkpoint-every=N   Refresh the markdown report every N checked states.
  --report=PATH          Markdown report path.
  --jsonl=PATH           JSONL findings path.
  --fail-fast            Stop on first failure.
  --exit-zero            Always exit 0 after writing reports.
  --state-drift-fails    Treat state drift as a failing outcome.
''');
        exit(0);
      } else {
        throw ArgumentError('Unknown argument: $arg');
      }
    }

    return _NightRunOptions(
      limit: limit,
      minutes: minutes,
      checkpointEvery: checkpointEvery,
      failFast: failFast,
      stateDriftFails: stateDriftFails,
      exitZero: exitZero,
      reportPath: reportPath,
      jsonlPath: jsonlPath,
    );
  }
}

class _NightContractRunner {
  final _NightRunOptions options;
  final GrammarEngine grammar = GrammarEngine();
  late final _CapturingRecognitionLogger recognitionLogger;
  late final RecognitionEngine recognition;
  var _stopRequested = false;

  _NightContractRunner(this.options) {
    recognitionLogger = _CapturingRecognitionLogger();
    recognition = RecognitionEngine(logger: recognitionLogger);
  }

  void requestStop() {
    _stopRequested = true;
  }

  Future<_NightRunResult> run() async {
    final startedAt = DateTime.now();
    final deadline = options.minutes == null
        ? null
        : startedAt.add(Duration(minutes: options.minutes!));
    final stats = _NightRunStats();
    final findings = <_Finding>[];
    var cycles = 0;

    _prepareOutputFiles();

    while (!_stopRequested) {
      cycles++;
      var checkedAnyInCycle = false;

      for (final candidate in _generateCandidates(cycles)) {
        if (_stopRequested || _deadlineReached(deadline)) {
          return _finish(
            startedAt,
            stats,
            findings,
            interrupted: _stopRequested,
          );
        }

        if (candidate.skipReason != null) {
          stats.skipped++;
          stats.skipReasons.update(
            candidate.skipReason!,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
          continue;
        }

        if (options.limit > 0 && stats.checked >= options.limit) {
          return _finish(startedAt, stats, findings);
        }

        checkedAnyInCycle = true;
        stats.checked++;
        final finding = _check(candidate);

        switch (finding.outcome) {
          case _Outcome.pass:
            stats.passed++;
            break;
          case _Outcome.stateDrift:
            stats.stateDrift++;
            _recordFinding(findings, finding);
            if (options.stateDriftFails && options.failFast) {
              return _finish(startedAt, stats, findings);
            }
            break;
          case _Outcome.grammarThrow:
          case _Outcome.recognitionThrow:
          case _Outcome.rerenderThrow:
          case _Outcome.sentenceMismatch:
            stats.failed++;
            _recordFinding(findings, finding);
            if (options.failFast) {
              return _finish(startedAt, stats, findings);
            }
            break;
        }

        if (stats.checked % options.checkpointEvery == 0) {
          _writeCheckpoint(startedAt, stats, findings);
          await Future<void>.delayed(Duration.zero);
        }
      }

      if (!checkedAnyInCycle || options.minutes == null) {
        break;
      }
    }

    return _finish(startedAt, stats, findings, interrupted: _stopRequested);
  }

  bool _deadlineReached(DateTime? deadline) {
    return deadline != null && DateTime.now().isAfter(deadline);
  }

  void _prepareOutputFiles() {
    final jsonlFile = File(options.jsonlPath);
    jsonlFile.parent.createSync(recursive: true);
    jsonlFile.writeAsStringSync('');
  }

  void _recordFinding(List<_Finding> findings, _Finding finding) {
    findings.add(finding);

    File(options.jsonlPath).writeAsStringSync(
      '${jsonEncode(finding.toJson())}\n',
      mode: FileMode.append,
      flush: true,
    );
  }

  void _writeCheckpoint(
    DateTime startedAt,
    _NightRunStats stats,
    List<_Finding> findings,
  ) {
    final result = _NightRunResult(
      options: options,
      startedAt: startedAt,
      finishedAt: DateTime.now(),
      stats: stats,
      findings: findings,
      interrupted: _stopRequested,
    );

    _writeTextFile(options.reportPath, result.markdownReport);
  }

  _NightRunResult _finish(
    DateTime startedAt,
    _NightRunStats stats,
    List<_Finding> findings, {
    bool interrupted = false,
  }) {
    final finishedAt = DateTime.now();
    final result = _NightRunResult(
      options: options,
      startedAt: startedAt,
      finishedAt: finishedAt,
      stats: stats,
      findings: findings,
      interrupted: interrupted,
    );

    _writeTextFile(options.reportPath, result.markdownReport);

    return result;
  }

  _Finding _check(_Candidate candidate) {
    final state = candidate.state!;
    String firstSentence;
    SentenceState recognized;
    String secondSentence;

    try {
      firstSentence = grammar.generate(state).text;
    } catch (error, stackTrace) {
      return _Finding(
        candidate: candidate,
        outcome: _Outcome.grammarThrow,
        error: error.toString(),
        stackTrace: stackTrace.toString(),
      );
    }

    try {
      recognitionLogger.lastDiagnostics = null;
      recognized = recognition.recognize(firstSentence);
    } catch (error, stackTrace) {
      return _Finding(
        candidate: candidate,
        outcome: _Outcome.recognitionThrow,
        firstSentence: firstSentence,
        error: error.toString(),
        stackTrace: stackTrace.toString(),
      );
    }

    try {
      secondSentence = grammar.generate(recognized).text;
    } catch (error, stackTrace) {
      return _Finding(
        candidate: candidate,
        outcome: _Outcome.rerenderThrow,
        firstSentence: firstSentence,
        recognizedSummary: recognized.summary,
        unknownTokens: recognitionLogger.lastDiagnostics?.unknownTokens,
        error: error.toString(),
        stackTrace: stackTrace.toString(),
      );
    }

    if (firstSentence != secondSentence) {
      return _Finding(
        candidate: candidate,
        outcome: _Outcome.sentenceMismatch,
        firstSentence: firstSentence,
        secondSentence: secondSentence,
        recognizedSummary: recognized.summary,
        unknownTokens: recognitionLogger.lastDiagnostics?.unknownTokens,
      );
    }

    final expected = _stateFingerprint(state);
    final actual = _stateFingerprint(recognized);

    if (expected != actual) {
      return _Finding(
        candidate: candidate,
        outcome: _Outcome.stateDrift,
        firstSentence: firstSentence,
        secondSentence: secondSentence,
        expectedFingerprint: expected,
        actualFingerprint: actual,
        recognizedSummary: recognized.summary,
        unknownTokens: recognitionLogger.lastDiagnostics?.unknownTokens,
      );
    }

    return _Finding(candidate: candidate, outcome: _Outcome.pass);
  }

  Iterable<_Candidate> _generateCandidates(int cycle) sync* {
    final cyclePrefix = options.minutes == null ? '' : 'cycle-$cycle:';

    yield _Candidate.skip(
      id: '${cyclePrefix}known-gap:imperative-recognition',
      bucket: 'known-gap',
      skipReason: 'imperative recognition is not implemented yet',
    );

    var index = 0;

    for (final verb in verbs) {
      if (verb.infinitive == 'be') {
        yield _Candidate.skip(
          id: '${cyclePrefix}known-gap:lexical-be',
          bucket: 'known-gap',
          skipReason: 'lexical be is not implemented as a regular predicate',
        );
        continue;
      }

      if (!verb.takesObject) {
        yield _Candidate.skip(
          id: '${cyclePrefix}configuration-interlock:${verb.infinitive}:passive',
          bucket: 'configuration-interlock',
          skipReason: 'passive voice requires an object-capable verb',
        );
      }

      for (final modal in _modalSamples) {
        for (final tense in Tense.values) {
          if (!modal.isNone && tense != Tense.present) {
            yield _Candidate.skip(
              id: '${cyclePrefix}configuration-interlock:${verb.infinitive}:${modal.text}:$tense',
              bucket: 'configuration-interlock',
              skipReason: 'modal samples are constrained to present tense',
            );
            continue;
          }

          for (final aspect in Aspect.values) {
            for (final polarity in Polarity.values) {
              for (final form in _sentenceForms) {
                final agent = _agents[index % _agents.length];
                final object = verb.takesObject
                    ? _objects[index % _objects.length]
                    : null;
                final recipient = verb.takesRecipient
                    ? _recipients[index % _recipients.length]
                    : null;

                yield _Candidate(
                  id: '${cyclePrefix}active:${verb.infinitive}:$index',
                  bucket: 'active',
                  state: SentenceState(
                    agent: agent,
                    action: verb,
                    object: object,
                    recipient: recipient,
                    tense: tense,
                    aspect: aspect,
                    modal: modal,
                    polarity: polarity,
                    sentenceForm: form,
                  ),
                );
                index++;

                if (!verb.takesObject) {
                  continue;
                }

                if (verb.takesRecipient) {
                  for (final focus in PassiveFocus.values) {
                    yield _Candidate(
                      id: '${cyclePrefix}passive:${verb.infinitive}:$focus:$index',
                      bucket: 'passive-recipient',
                      state: SentenceState(
                        agent: agent,
                        action: verb,
                        object: object,
                        recipient: recipient,
                        voice: Voice.passive,
                        passiveFocus: focus,
                        tense: tense,
                        aspect: aspect,
                        modal: modal,
                        polarity: polarity,
                        sentenceForm: form,
                      ),
                    );
                    index++;
                  }
                } else {
                  yield _Candidate(
                    id: '${cyclePrefix}passive:${verb.infinitive}:$index',
                    bucket: 'passive',
                    state: SentenceState(
                      agent: agent,
                      action: verb,
                      object: object,
                      voice: Voice.passive,
                      passiveFocus: PassiveFocus.object,
                      tense: tense,
                      aspect: aspect,
                      modal: modal,
                      polarity: polarity,
                      sentenceForm: form,
                    ),
                  );
                  index++;
                }
              }
            }
          }
        }
      }

      yield* _phraseCandidates(verb, index, cyclePrefix);
      index += 1000;
    }
  }

  Iterable<_Candidate> _phraseCandidates(
    Verb verb,
    int index,
    String cyclePrefix,
  ) sync* {
    final agent = _agents[index % _agents.length];
    final object = verb.takesObject ? _objects[index % _objects.length] : null;
    final recipient = verb.takesRecipient
        ? _recipients[index % _recipients.length]
        : null;

    for (final phrase in _timePhraseSamples) {
      yield _Candidate(
        id: '${cyclePrefix}phrase-time:${verb.infinitive}:$index',
        bucket: 'phrase-time',
        state: _activePhraseState(
          verb,
          agent,
          object,
          recipient,
          timePhrase: phrase,
        ),
      );
      index++;
    }

    for (final phrase in _placePhraseSamples) {
      yield _Candidate(
        id: '${cyclePrefix}phrase-place:${verb.infinitive}:$index',
        bucket: 'phrase-place',
        state: _activePhraseState(
          verb,
          agent,
          object,
          recipient,
          placePhrase: phrase,
        ),
      );
      index++;
    }

    for (final phrase in _frequencyPhraseSamples) {
      yield _Candidate(
        id: '${cyclePrefix}phrase-frequency:${verb.infinitive}:$index',
        bucket: 'phrase-frequency',
        state: _activePhraseState(
          verb,
          agent,
          object,
          recipient,
          frequencyPhrase: phrase,
        ),
      );
      index++;
    }

    for (final phrase in _mannerPhraseSamples) {
      yield _Candidate(
        id: '${cyclePrefix}phrase-manner:${verb.infinitive}:$index',
        bucket: 'phrase-manner',
        state: _activePhraseState(
          verb,
          agent,
          object,
          recipient,
          mannerPhrase: phrase,
        ),
      );
      index++;
    }
  }

  SentenceState _activePhraseState(
    Verb verb,
    NounPhrase agent,
    NounPhrase? object,
    NounPhrase? recipient, {
    TimePhrase? timePhrase,
    PlacePhrase? placePhrase,
    FrequencyPhrase? frequencyPhrase,
    MannerPhrase? mannerPhrase,
  }) {
    return SentenceState(
      agent: agent,
      action: verb,
      object: object,
      recipient: recipient,
      tense: Tense.present,
      aspect: Aspect.simple,
      timePhrase: timePhrase,
      placePhrase: placePhrase,
      frequencyPhrase: frequencyPhrase,
      mannerPhrase: mannerPhrase,
    );
  }
}

class _CapturingRecognitionLogger extends EngineLogger {
  RecognitionDiagnostics? lastDiagnostics;

  _CapturingRecognitionLogger()
    : super(
        config: const EngineLogConfig(
          recognition: true,
          tokens: false,
          verbChain: false,
          sentenceState: false,
          unknownTokens: false,
        ),
      );

  @override
  void logRecognition(RecognitionDiagnostics diagnostics) {
    lastDiagnostics = diagnostics;
  }
}

class _Candidate {
  final String id;
  final String bucket;
  final SentenceState? state;
  final String? skipReason;

  const _Candidate({
    required this.id,
    required this.bucket,
    required this.state,
  }) : skipReason = null;

  const _Candidate.skip({
    required this.id,
    required this.bucket,
    required String this.skipReason,
  }) : state = null;
}

class _Finding {
  final _Candidate candidate;
  final _Outcome outcome;
  final String? firstSentence;
  final String? secondSentence;
  final String? expectedFingerprint;
  final String? actualFingerprint;
  final String? recognizedSummary;
  final List<String>? unknownTokens;
  final String? error;
  final String? stackTrace;

  const _Finding({
    required this.candidate,
    required this.outcome,
    this.firstSentence,
    this.secondSentence,
    this.expectedFingerprint,
    this.actualFingerprint,
    this.recognizedSummary,
    this.unknownTokens,
    this.error,
    this.stackTrace,
  });

  Map<String, Object?> toJson() {
    return {
      'outcome': outcome.name,
      'id': candidate.id,
      'bucket': candidate.bucket,
      'state': candidate.state?.summary,
      'firstSentence': firstSentence,
      'secondSentence': secondSentence,
      'expectedFingerprint': expectedFingerprint,
      'actualFingerprint': actualFingerprint,
      'recognizedSummary': recognizedSummary,
      'unknownTokens': unknownTokens,
      'error': error,
      'stackTrace': stackTrace,
    };
  }
}

enum _Outcome {
  pass,
  stateDrift,
  grammarThrow,
  recognitionThrow,
  rerenderThrow,
  sentenceMismatch,
}

class _NightRunStats {
  int checked = 0;
  int passed = 0;
  int stateDrift = 0;
  int failed = 0;
  int skipped = 0;
  final Map<String, int> skipReasons = {};
}

class _NightRunResult {
  final _NightRunOptions options;
  final DateTime startedAt;
  final DateTime finishedAt;
  final _NightRunStats stats;
  final List<_Finding> findings;
  final bool interrupted;

  const _NightRunResult({
    required this.options,
    required this.startedAt,
    required this.finishedAt,
    required this.stats,
    required this.findings,
    required this.interrupted,
  });

  bool get shouldExitWithFailure =>
      !options.exitZero &&
      (stats.failed > 0 || (options.stateDriftFails && stats.stateDrift > 0));

  Duration get duration => finishedAt.difference(startedAt);

  String get consoleSummary {
    return [
      'Night contract run finished in ${duration.inMilliseconds} ms',
      'checked=${stats.checked}',
      'passed=${stats.passed}',
      'stateDrift=${stats.stateDrift}',
      'failed=${stats.failed}',
      'skipped=${stats.skipped}',
      'interrupted=$interrupted',
      'report=${options.reportPath}',
      'jsonl=${options.jsonlPath}',
    ].join(' ');
  }

  String get markdownReport {
    final buffer = StringBuffer()
      ..writeln('# Night Contract Report')
      ..writeln()
      ..writeln('- Started: $startedAt')
      ..writeln('- Finished: $finishedAt')
      ..writeln('- Duration: ${duration.inMilliseconds} ms')
      ..writeln('- Limit: ${options.limit == 0 ? 'all' : options.limit}')
      ..writeln('- Minutes: ${options.minutes ?? 'not set'}')
      ..writeln('- Interrupted: $interrupted')
      ..writeln('- Checkpoint every: ${options.checkpointEvery} checked states')
      ..writeln()
      ..writeln('## Summary')
      ..writeln()
      ..writeln('| Bucket | Count |')
      ..writeln('| --- | ---: |')
      ..writeln('| Checked | ${stats.checked} |')
      ..writeln('| Passed | ${stats.passed} |')
      ..writeln('| State drift | ${stats.stateDrift} |')
      ..writeln('| Failed | ${stats.failed} |')
      ..writeln('| Skipped | ${stats.skipped} |')
      ..writeln();

    if (stats.skipReasons.isNotEmpty) {
      buffer
        ..writeln('## Skips')
        ..writeln()
        ..writeln('| Reason | Count |')
        ..writeln('| --- | ---: |');

      for (final entry in stats.skipReasons.entries) {
        buffer.writeln('| ${entry.key} | ${entry.value} |');
      }

      buffer.writeln();
    }

    _writeFindingSection(buffer, _Outcome.sentenceMismatch);
    _writeFindingSection(buffer, _Outcome.grammarThrow);
    _writeFindingSection(buffer, _Outcome.recognitionThrow);
    _writeFindingSection(buffer, _Outcome.rerenderThrow);
    _writeFindingSection(buffer, _Outcome.stateDrift);

    return buffer.toString();
  }

  void _writeFindingSection(StringBuffer buffer, _Outcome outcome) {
    final matches = findings
        .where((finding) => finding.outcome == outcome)
        .take(50)
        .toList();

    if (matches.isEmpty) {
      return;
    }

    buffer
      ..writeln('## ${outcome.name}')
      ..writeln()
      ..writeln('Showing first ${matches.length} findings.')
      ..writeln();

    for (final finding in matches) {
      buffer
        ..writeln('### ${finding.candidate.id}')
        ..writeln()
        ..writeln('- Bucket: `${finding.candidate.bucket}`')
        ..writeln('- State: `${finding.candidate.state?.summary}`');

      if (finding.firstSentence != null) {
        buffer.writeln('- First sentence: `${finding.firstSentence}`');
      }

      if (finding.secondSentence != null) {
        buffer.writeln('- Second sentence: `${finding.secondSentence}`');
      }

      if (finding.expectedFingerprint != null) {
        buffer.writeln('- Expected: `${finding.expectedFingerprint}`');
      }

      if (finding.actualFingerprint != null) {
        buffer.writeln('- Actual: `${finding.actualFingerprint}`');
      }

      if (finding.unknownTokens?.isNotEmpty == true) {
        buffer.writeln('- Unknown tokens: `${finding.unknownTokens}`');
      }

      if (finding.error != null) {
        buffer.writeln('- Error: `${finding.error}`');
      }

      buffer.writeln();
    }
  }
}

void _writeTextFile(String path, String contents) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(contents);
}

String _stateFingerprint(SentenceState state) {
  return [
    'agent=${_nounFingerprint(state.agent)}',
    'action=${state.action.infinitive}',
    'object=${_nounFingerprint(state.object)}',
    'recipient=${_nounFingerprint(state.recipient)}',
    'voice=${state.voice}',
    'passiveFocus=${state.passiveFocus}',
    'tense=${state.tense}',
    'aspect=${state.aspect}',
    'modal=${state.modal.text}',
    'polarity=${state.polarity}',
    'form=${state.sentenceForm}',
    'time=${state.timePhrase?.text}',
    'place=${state.placePhrase?.render()}',
    'frequency=${state.frequencyPhrase?.text}',
    'manner=${state.mannerPhrase?.text}',
  ].join('|');
}

String _nounFingerprint(NounPhrase? phrase) {
  if (phrase == null) {
    return 'null';
  }

  return [
    phrase.text,
    phrase.person,
    phrase.number,
    phrase.determiner?.text,
    phrase.adjectiveList.map((adjective) => adjective.text).join('+'),
  ].join('/');
}

final _agents = [
  i,
  you,
  he,
  she,
  it,
  we,
  they,
  john.toNounPhrase(Number.singular),
  mary.toNounPhrase(Number.singular),
  teacher.toNounPhrase(
    Number.singular,
    determiner: theDeterminer,
    adjectives: [beautiful, young],
  ),
  worker.toNounPhrase(Number.plural, determiner: theDeterminer, adjective: old),
];

final _objects = [
  it,
  book.toNounPhrase(Number.singular, determiner: aDeterminer),
  bridge.toNounPhrase(
    Number.singular,
    determiner: theDeterminer,
    adjective: newAdjective,
  ),
  house.toNounPhrase(
    Number.singular,
    determiner: aDeterminer,
    adjectives: [beautiful, newAdjective],
  ),
  letter.toNounPhrase(Number.singular, determiner: theDeterminer),
  gift.toNounPhrase(Number.singular, determiner: aDeterminer),
];

final _recipients = [
  i,
  you,
  he,
  she,
  we,
  they,
  mary.toNounPhrase(Number.singular),
  child.toNounPhrase(Number.singular, determiner: theDeterminer),
];

const _modalSamples = [noModal, can, should, must];

const _sentenceForms = [
  SentenceForm.statement,
  SentenceForm.question,
  SentenceForm.exclamation,
];

final _timePhraseSamples = [
  yesterdayTimePhrase,
  tomorrowTimePhrase,
  nowTimePhrase,
];

final _placePhraseSamples = [
  homePlacePhrase,
  schoolPlacePhrase,
  workPlacePhrase,
];

final _frequencyPhraseSamples = [
  alwaysFrequencyPhrase,
  everyDayFrequencyPhrase,
];

final _mannerPhraseSamples = [quicklyMannerPhrase, carefullyMannerPhrase];
