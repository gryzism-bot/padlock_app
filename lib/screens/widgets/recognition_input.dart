part of '../home_screen.dart';

class _RecognitionCaptureLogger extends EngineLogger {
  RecognitionDiagnostics? diagnostics;
  String? failureText;

  _RecognitionCaptureLogger()
    : super(
        config: const EngineLogConfig(
          recognition: true,
          tokens: true,
          failures: true,
          unknownTokens: true,
        ),
      );

  @override
  void logRecognition(RecognitionDiagnostics diagnostics) {
    this.diagnostics = diagnostics;
  }

  @override
  void logRecognitionFailure(
    String phase,
    Object error,
    StackTrace stackTrace,
    String snapshot,
  ) {
    failureText = 'Recognition stopped during $phase.';
  }
}

class _RecognitionInputAttempt {
  final String input;
  final SentenceState? state;
  final String? canonicalSentence;
  final List<String> tokens;
  final List<String> unknownTokens;
  final String? error;

  const _RecognitionInputAttempt({
    required this.input,
    required this.state,
    required this.canonicalSentence,
    required this.tokens,
    required this.unknownTokens,
    required this.error,
  });

  const _RecognitionInputAttempt.empty()
    : this(
        input: '',
        state: null,
        canonicalSentence: null,
        tokens: const [],
        unknownTokens: const [],
        error: null,
      );

  factory _RecognitionInputAttempt.recognized({
    required String input,
    required SentenceState state,
    required String canonicalSentence,
    required List<String> tokens,
    required List<String> unknownTokens,
  }) {
    return _RecognitionInputAttempt(
      input: input,
      state: state,
      canonicalSentence: canonicalSentence,
      tokens: tokens,
      unknownTokens: unknownTokens,
      error: null,
    );
  }

  factory _RecognitionInputAttempt.failed({
    required String input,
    required List<String> tokens,
    required String error,
  }) {
    return _RecognitionInputAttempt(
      input: input,
      state: null,
      canonicalSentence: null,
      tokens: tokens,
      unknownTokens: const [],
      error: error,
    );
  }

  bool get canApply => state != null && unknownTokens.isEmpty && error == null;

  bool get isCanonical =>
      canonicalSentence != null &&
      _normalizedRecognitionText(input) ==
          _normalizedRecognitionText(canonicalSentence!);
}

class _RecognitionInputResult {
  final String input;
  final SentenceState state;
  final String canonicalSentence;

  const _RecognitionInputResult({
    required this.input,
    required this.state,
    required this.canonicalSentence,
  });

  String get message {
    if (_normalizedRecognitionText(input) ==
        _normalizedRecognitionText(canonicalSentence)) {
      return 'Recognized sentence: $canonicalSentence';
    }

    return 'Recognized "$input" as "$canonicalSentence".';
  }
}

List<String> _recognitionTokens(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) {
    return const [];
  }

  return trimmed
      .replaceAll(RegExp(r'[.!?]+$'), '')
      .split(RegExp(r'\s+'))
      .where((token) => token.isNotEmpty)
      .toList(growable: false);
}

String _normalizedRecognitionText(String value) {
  return value.trim().replaceAll(RegExp(r'[.!?]+$'), '').toLowerCase();
}

String _normalizedRecognitionToken(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'^[^\w]+|[^\w]+$'), '');
}

class _RecognitionInputDialog extends StatefulWidget {
  final String initialSentence;
  final String title;
  final String applyLabel;
  final String hintText;
  final _RecognitionInputAttempt Function(String input) recognize;

  const _RecognitionInputDialog({
    required this.initialSentence,
    this.title = 'Recognition input',
    this.applyLabel = 'Use sentence',
    this.hintText = 'Type a sentence the app can recognize',
    required this.recognize,
  });

  @override
  State<_RecognitionInputDialog> createState() =>
      _RecognitionInputDialogState();
}

class _RecognitionInputDialogState extends State<_RecognitionInputDialog> {
  late final TextEditingController _controller;
  late _RecognitionInputAttempt _attempt;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialSentence);
    _attempt = widget.recognize(widget.initialSentence);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final unknownTokenSet = {
      for (final token in _attempt.unknownTokens)
        _normalizedRecognitionToken(token),
    };

    return Dialog(
      key: const Key('recognition-input-dialog'),
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.keyboard_alt_outlined,
                    size: 18,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('recognition-input-close'),
                    tooltip: 'Close recognition input',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                key: const Key('recognition-input-field'),
                controller: _controller,
                autofocus: true,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onChanged: _recognize,
                onSubmitted: (_) => _applyIfPossible(),
                decoration: InputDecoration(
                  labelText: 'Sentence',
                  hintText: widget.hintText,
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              if (_attempt.tokens.isNotEmpty)
                Wrap(
                  key: const Key('recognition-token-preview'),
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final token in _attempt.tokens)
                      _RecognitionTokenChip(
                        token: token,
                        isUnknown: unknownTokenSet.contains(
                          _normalizedRecognitionToken(token),
                        ),
                      ),
                  ],
                )
              else
                Text(
                  'Write a sentence to probe the Recognition Engine.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 12),
              _RecognitionAttemptStatus(attempt: _attempt),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    key: const Key('recognition-apply-button'),
                    onPressed: _attempt.canApply ? _applyIfPossible : null,
                    icon: const Icon(Icons.check),
                    label: Text(widget.applyLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _recognize(String input) {
    setState(() {
      _attempt = widget.recognize(input);
    });
  }

  void _applyIfPossible() {
    final state = _attempt.state;
    final canonicalSentence = _attempt.canonicalSentence;
    if (!_attempt.canApply || state == null || canonicalSentence == null) {
      return;
    }

    Navigator.of(context).pop(
      _RecognitionInputResult(
        input: _attempt.input,
        state: state,
        canonicalSentence: canonicalSentence,
      ),
    );
  }
}

class _GuessSentenceDialog extends StatefulWidget {
  final _SentenceTarget target;
  final _RecognitionInputAttempt Function(String input) recognize;

  const _GuessSentenceDialog({required this.target, required this.recognize});

  @override
  State<_GuessSentenceDialog> createState() => _GuessSentenceDialogState();
}

class _GuessSentenceDialogState extends State<_GuessSentenceDialog> {
  late final TextEditingController _controller;
  late _RecognitionInputAttempt _attempt;
  bool _hasChecked = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _attempt = widget.recognize('');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isCorrect {
    final state = _attempt.state;
    if (!_attempt.canApply || state == null) {
      return false;
    }

    return SentenceStateDiff.between(
      current: state,
      target: widget.target.state,
    ).isSolved;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final unknownTokenSet = {
      for (final token in _attempt.unknownTokens)
        _normalizedRecognitionToken(token),
    };

    return Dialog(
      key: const Key('guess-sentence-dialog'),
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.extension_outlined,
                    size: 18,
                    color: colors.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Guess the sentence',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('guess-sentence-close'),
                    tooltip: 'Close guess',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'SentenceState hint',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.tertiary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.42,
                    ),
                    border: Border.all(color: colors.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: SelectableText(
                      _formattedGuessStateHint(widget.target.statePrompt),
                      key: const Key('guess-target-state-hint'),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.35),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('guess-answer-field'),
                controller: _controller,
                autofocus: true,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onChanged: _recognize,
                onSubmitted: (_) => _checkAnswer(),
                decoration: const InputDecoration(
                  labelText: 'Answer',
                  hintText: 'Type the sentence',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              if (_attempt.tokens.isNotEmpty)
                Wrap(
                  key: const Key('guess-token-preview'),
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final token in _attempt.tokens)
                      _RecognitionTokenChip(
                        token: token,
                        isUnknown: unknownTokenSet.contains(
                          _normalizedRecognitionToken(token),
                        ),
                      ),
                  ],
                )
              else
                Text(
                  'Read the state, then type the sentence it describes.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 12),
              _GuessAnswerStatus(
                attempt: _attempt,
                isCorrect: _isCorrect,
                hasChecked: _hasChecked,
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    key: const Key('guess-set-answer-button'),
                    onPressed: _isCorrect ? _checkAnswer : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Set answer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _recognize(String input) {
    setState(() {
      _hasChecked = false;
      _attempt = widget.recognize(input);
    });
  }

  void _checkAnswer() {
    final state = _attempt.state;
    final canonicalSentence = _attempt.canonicalSentence;
    if (!_attempt.canApply || state == null || canonicalSentence == null) {
      return;
    }

    if (!_isCorrect) {
      setState(() {
        _hasChecked = true;
      });
      return;
    }

    Navigator.of(context).pop(
      _RecognitionInputResult(
        input: _attempt.input,
        state: state,
        canonicalSentence: canonicalSentence,
      ),
    );
  }
}

class _RecognitionTokenChip extends StatelessWidget {
  final String token;
  final bool isUnknown;

  const _RecognitionTokenChip({required this.token, required this.isUnknown});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = isUnknown ? colors.error : colors.secondary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.72)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          token,
          key: Key('recognition-token-${_normalizedRecognitionToken(token)}'),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _RecognitionAttemptStatus extends StatelessWidget {
  final _RecognitionInputAttempt attempt;

  const _RecognitionAttemptStatus({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (attempt.input.isEmpty) {
      return const SizedBox.shrink();
    }

    if (attempt.error != null) {
      return _RecognitionStatusBox(
        key: const Key('recognition-error'),
        icon: Icons.error_outline,
        color: colors.error,
        title: 'Recognition stopped',
        body: attempt.error!,
      );
    }

    if (attempt.unknownTokens.isNotEmpty) {
      return _RecognitionStatusBox(
        key: const Key('recognition-unknown-tokens'),
        icon: Icons.report_problem_outlined,
        color: colors.error,
        title: 'Unknown vocabulary',
        body: attempt.unknownTokens.join(', '),
      );
    }

    final canonical = attempt.canonicalSentence;
    if (canonical == null) {
      return const SizedBox.shrink();
    }

    return _RecognitionStatusBox(
      key: const Key('recognition-canonical-sentence'),
      icon: attempt.isCanonical
          ? Icons.check_circle_outline
          : Icons.auto_fix_high_outlined,
      color: attempt.isCanonical ? colors.secondary : colors.tertiary,
      title: attempt.isCanonical ? 'Recognized' : 'Canonical app sentence',
      body: canonical,
    );
  }
}

class _GuessAnswerStatus extends StatelessWidget {
  final _RecognitionInputAttempt attempt;
  final bool isCorrect;
  final bool hasChecked;

  const _GuessAnswerStatus({
    required this.attempt,
    required this.isCorrect,
    required this.hasChecked,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (attempt.input.isEmpty) {
      return const SizedBox.shrink();
    }

    if (attempt.error != null || attempt.unknownTokens.isNotEmpty) {
      return _RecognitionAttemptStatus(attempt: attempt);
    }

    if (isCorrect) {
      return _RecognitionStatusBox(
        key: const Key('guess-answer-correct'),
        icon: Icons.check_circle_outline,
        color: _successGreen,
        title: 'Correct',
        body: attempt.canonicalSentence ?? attempt.input,
      );
    }

    if (!hasChecked) {
      return _RecognitionAttemptStatus(attempt: attempt);
    }

    return _RecognitionStatusBox(
      key: const Key('guess-answer-wrong'),
      icon: Icons.close_outlined,
      color: colors.error,
      title: 'Not this SentenceState',
      body: 'Recognition got: ${attempt.canonicalSentence ?? attempt.input}',
    );
  }
}

const _successGreen = Color(0xFF5DBB63);

class _RecognitionStatusBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _RecognitionStatusBox({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.62)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SelectableText(
                    body,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formattedGuessStateHint(String prompt) {
  return prompt
      .split(', ')
      .where((entry) => entry.isNotEmpty)
      .map((entry) {
        final separator = entry.indexOf('=');
        if (separator == -1) {
          return entry;
        }

        final label = entry.substring(0, separator);
        final value = entry.substring(separator + 1);
        return '$label: $value';
      })
      .join('\n');
}
