part of '../home_screen.dart';

class _BottomDock extends StatelessWidget {
  final List<ConfigurationMessage> messages;
  final ValueListenable<List<_MoveTraceEntry>> moveTraceListenable;
  final bool isCollapsed;
  final ValueChanged<bool> onCollapsedChanged;
  final PreviewCacheMode cacheMode;
  final ValueChanged<PreviewCacheMode> onCacheModeChanged;
  final VoidCallback onClearCache;
  final ValueListenable<int> cacheEntryCountListenable;
  final int? cacheEntryLimit;
  final HeaderPreviewMode previewMode;
  final ValueChanged<HeaderPreviewMode> onPreviewModeChanged;
  final SuggestionDisplayMode displayMode;
  final ValueChanged<SuggestionDisplayMode> onDisplayModeChanged;
  final bool showTranslation;
  final VoidCallback onToggleTranslation;
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;
  final int idiomFoundCount;
  final int idiomTotal;
  final List<IdiomMatch> foundIdioms;
  final VoidCallback onReset;
  final VoidCallback onRandomSentence;
  final VoidCallback onGuessSentence;

  const _BottomDock({
    required this.messages,
    required this.moveTraceListenable,
    required this.isCollapsed,
    required this.onCollapsedChanged,
    required this.cacheMode,
    required this.onCacheModeChanged,
    required this.onClearCache,
    required this.cacheEntryCountListenable,
    required this.cacheEntryLimit,
    required this.previewMode,
    required this.onPreviewModeChanged,
    required this.displayMode,
    required this.onDisplayModeChanged,
    required this.showTranslation,
    required this.onToggleTranslation,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.idiomFoundCount,
    required this.idiomTotal,
    required this.foundIdioms,
    required this.onReset,
    required this.onRandomSentence,
    required this.onGuessSentence,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ValueListenableBuilder<List<_MoveTraceEntry>>(
      valueListenable: moveTraceListenable,
      builder: (context, moveTrace, child) {
        return ValueListenableBuilder<int>(
          valueListenable: cacheEntryCountListenable,
          builder: (context, cacheEntryCount, child) {
            final cacheStrip = _PreviewCacheDiagnosticsPanel(
              mode: cacheMode,
              entryCount: cacheEntryCount,
              entryLimit: cacheEntryLimit,
              onModeChanged: onCacheModeChanged,
              onClear: onClearCache,
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: colors.surface.withValues(alpha: 0.96),
                  elevation: 2,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: isCollapsed
                          ? _diagnosticsDockCollapsedHeight
                          : _diagnosticsDockReserveHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 1100;
                          final header = _DiagnosticsDockHeader(
                            messages: messages,
                            moveTrace: moveTrace,
                            isCollapsed: isCollapsed,
                            onCollapsedChanged: onCollapsedChanged,
                            previewMode: previewMode,
                            onPreviewModeChanged: onPreviewModeChanged,
                            displayMode: displayMode,
                            onDisplayModeChanged: onDisplayModeChanged,
                            showTranslation: showTranslation,
                            onToggleTranslation: onToggleTranslation,
                            isDarkMode: isDarkMode,
                            onToggleDarkMode: onToggleDarkMode,
                            idiomFoundCount: idiomFoundCount,
                            idiomTotal: idiomTotal,
                            foundIdioms: foundIdioms,
                            onReset: onReset,
                            onRandomSentence: onRandomSentence,
                            onGuessSentence: onGuessSentence,
                            cacheStrip: cacheStrip,
                          );

                          if (isCollapsed) {
                            return header;
                          }

                          if (compact) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                header,
                                const SizedBox(height: 8),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(
                                          height: 142,
                                          child: _GuidedMessages(
                                            messages: messages,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          height: 86,
                                          child: _MoveTracePanel(
                                            entries: moveTrace,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              header,
                              const SizedBox(height: 8),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: _GuidedMessages(
                                        messages: messages,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 5,
                                      child: _MoveTracePanel(
                                        entries: moveTrace,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const _StickyFooter(),
              ],
            );
          },
        );
      },
    );
  }
}

class _DiagnosticsDockHeader extends StatelessWidget {
  final List<ConfigurationMessage> messages;
  final List<_MoveTraceEntry> moveTrace;
  final bool isCollapsed;
  final ValueChanged<bool> onCollapsedChanged;
  final HeaderPreviewMode previewMode;
  final ValueChanged<HeaderPreviewMode> onPreviewModeChanged;
  final SuggestionDisplayMode displayMode;
  final ValueChanged<SuggestionDisplayMode> onDisplayModeChanged;
  final bool showTranslation;
  final VoidCallback onToggleTranslation;
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;
  final int idiomFoundCount;
  final int idiomTotal;
  final List<IdiomMatch> foundIdioms;
  final VoidCallback onReset;
  final VoidCallback onRandomSentence;
  final VoidCallback onGuessSentence;
  final Widget cacheStrip;

  const _DiagnosticsDockHeader({
    required this.messages,
    required this.moveTrace,
    required this.isCollapsed,
    required this.onCollapsedChanged,
    required this.previewMode,
    required this.onPreviewModeChanged,
    required this.displayMode,
    required this.onDisplayModeChanged,
    required this.showTranslation,
    required this.onToggleTranslation,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.idiomFoundCount,
    required this.idiomTotal,
    required this.foundIdioms,
    required this.onReset,
    required this.onRandomSentence,
    required this.onGuessSentence,
    required this.cacheStrip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final showCacheStrip = !isCollapsed;
        final compact = constraints.maxWidth < 720;
        final cacheWidth = showCacheStrip
            ? (constraints.maxWidth * 0.42).clamp(320.0, 560.0)
            : 0.0;
        final alertHeader = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: isCollapsed
                  ? 'Expand diagnostics bar'
                  : 'Collapse diagnostics bar',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              onPressed: () => onCollapsedChanged(!isCollapsed),
              icon: Icon(
                isCollapsed ? Icons.expand_less : Icons.expand_more,
                size: 18,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.notifications_none, size: 16, color: colors.primary),
            const SizedBox(width: 5),
            Text(
              'Language alert ${messages.length}',
              key: const Key('diagnostics-collapsed-alert-count'),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
        final toolStrip = _DiagnosticsToolStrip(
          previewMode: previewMode,
          onPreviewModeChanged: onPreviewModeChanged,
          displayMode: displayMode,
          onDisplayModeChanged: onDisplayModeChanged,
          showTranslation: showTranslation,
          onToggleTranslation: onToggleTranslation,
          isDarkMode: isDarkMode,
          onToggleDarkMode: onToggleDarkMode,
          idiomFoundCount: idiomFoundCount,
          idiomTotal: idiomTotal,
          foundIdioms: foundIdioms,
          onReset: onReset,
          onRandomSentence: onRandomSentence,
          onGuessSentence: onGuessSentence,
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  alertHeader,
                  if (isCollapsed) ...[
                    const SizedBox(width: 14),
                    Icon(
                      Icons.route_outlined,
                      size: 16,
                      color: colors.secondary,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: SelectableText(
                        moveTrace.isEmpty
                            ? 'No moves yet.'
                            : moveTrace.last.line,
                        key: const Key('diagnostics-collapsed-move-text'),
                        maxLines: 1,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              toolStrip,
              if (showCacheStrip) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: cacheStrip,
                  ),
                ),
              ],
            ],
          );
        }

        return Row(
          children: [
            alertHeader,
            const SizedBox(width: 12),
            Expanded(
              child: Align(alignment: Alignment.centerLeft, child: toolStrip),
            ),
            if (isCollapsed) ...[
              const SizedBox(width: 14),
              Icon(Icons.route_outlined, size: 16, color: colors.secondary),
              const SizedBox(width: 5),
              Flexible(
                child: SelectableText(
                  moveTrace.isEmpty ? 'No moves yet.' : moveTrace.last.line,
                  key: const Key('diagnostics-collapsed-move-text'),
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            if (showCacheStrip) ...[
              const SizedBox(width: 12),
              SizedBox(
                width: cacheWidth,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: cacheStrip,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DiagnosticsToolStrip extends StatelessWidget {
  final HeaderPreviewMode previewMode;
  final ValueChanged<HeaderPreviewMode> onPreviewModeChanged;
  final SuggestionDisplayMode displayMode;
  final ValueChanged<SuggestionDisplayMode> onDisplayModeChanged;
  final bool showTranslation;
  final VoidCallback onToggleTranslation;
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;
  final int idiomFoundCount;
  final int idiomTotal;
  final List<IdiomMatch> foundIdioms;
  final VoidCallback onReset;
  final VoidCallback onRandomSentence;
  final VoidCallback onGuessSentence;

  const _DiagnosticsToolStrip({
    required this.previewMode,
    required this.onPreviewModeChanged,
    required this.displayMode,
    required this.onDisplayModeChanged,
    required this.showTranslation,
    required this.onToggleTranslation,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.idiomFoundCount,
    required this.idiomTotal,
    required this.foundIdioms,
    required this.onReset,
    required this.onRandomSentence,
    required this.onGuessSentence,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('diagnostics-tool-strip'),
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HeaderPreviewModeSection(
            value: previewMode,
            onChanged: onPreviewModeChanged,
          ),
          const SizedBox(width: 8),
          _DisplayModeSection(
            value: displayMode,
            onChanged: onDisplayModeChanged,
          ),
          const SizedBox(width: 8),
          IconButton.outlined(
            tooltip: showTranslation
                ? 'Hide sentence translation'
                : 'Translate sentence',
            visualDensity: VisualDensity.compact,
            onPressed: onToggleTranslation,
            icon: Icon(showTranslation ? Icons.translate : Icons.g_translate),
          ),
          IconButton.outlined(
            tooltip: isDarkMode ? 'Light mode' : 'Dark mode',
            visualDensity: VisualDensity.compact,
            onPressed: onToggleDarkMode,
            icon: Icon(
              isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
          ),
          const SizedBox(width: 4),
          IconButton.outlined(
            tooltip: 'Reset',
            visualDensity: VisualDensity.compact,
            onPressed: onReset,
            icon: const Icon(Icons.restart_alt),
          ),
          const SizedBox(width: 4),
          IconButton.outlined(
            tooltip: 'Random sentence',
            visualDensity: VisualDensity.compact,
            onPressed: onRandomSentence,
            icon: const Icon(Icons.shuffle),
          ),
          const SizedBox(width: 4),
          IconButton.outlined(
            key: const Key('guess-sentence-button'),
            tooltip: 'Guess the sentence',
            visualDensity: VisualDensity.compact,
            onPressed: onGuessSentence,
            icon: const Icon(Icons.extension_outlined),
          ),
          const SizedBox(width: 6),
          _IdiomFoundCountBadge(
            found: idiomFoundCount,
            total: idiomTotal,
            foundIdioms: foundIdioms,
          ),
        ],
      ),
    );
  }
}

class _IdiomFoundCountBadge extends StatelessWidget {
  final int found;
  final int total;
  final List<IdiomMatch> foundIdioms;

  const _IdiomFoundCountBadge({
    required this.found,
    required this.total,
    required this.foundIdioms,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: found > 0 ? 'Show found idioms' : 'No idioms found yet',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('idiom-found-count'),
          borderRadius: BorderRadius.circular(999),
          onTap: () => _showFoundIdiomsOverlay(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: found > 0
                  ? colors.secondaryContainer
                  : colors.surfaceContainerHighest,
              border: Border.all(
                color: found > 0 ? colors.secondary : colors.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$found / $total idioms found',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: found > 0
                    ? colors.onSecondaryContainer
                    : colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFoundIdiomsOverlay(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) =>
          _FoundIdiomsOverlay(foundIdioms: foundIdioms, total: total),
    );
  }
}

class _FoundIdiomsOverlay extends StatelessWidget {
  final List<IdiomMatch> foundIdioms;
  final int total;

  const _FoundIdiomsOverlay({required this.foundIdioms, required this.total});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasManyIdioms = foundIdioms.length > 15;

    return Dialog(
      key: const Key('found-idioms-overlay'),
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 18,
                    color: colors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${foundIdioms.length} / $total idioms found',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('found-idioms-close'),
                    tooltip: 'Close found idioms',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (foundIdioms.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 8, 4, 12),
                  child: Text(
                    'No idioms found yet. Try a particle route like give up, write down, or take off.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: hasManyIdioms ? 460 : double.infinity,
                  ),
                  child: Scrollbar(
                    thumbVisibility: hasManyIdioms,
                    child: ListView.separated(
                      key: const Key('found-idioms-list'),
                      shrinkWrap: true,
                      itemCount: foundIdioms.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 10, color: colors.outlineVariant),
                      itemBuilder: (context, index) {
                        final pattern = foundIdioms[index].pattern;
                        return Tooltip(
                          message: pattern.meaning,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(2, 3, 4, 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectableText(
                                  pattern.label,
                                  key: Key('found-idiom-${pattern.id}'),
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: colors.secondary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                SelectableText(
                                  pattern.meaning,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 1),
                                SelectableText(
                                  '${pattern.pattern} - ${pattern.example}',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdiomToast extends StatelessWidget {
  final List<IdiomMatch> matches;

  const _IdiomToast({required this.matches});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final first = matches.first.pattern;
    final extraCount = matches.length - 1;

    return RepaintBoundary(
      child: Material(
        key: const Key('idiom-toast'),
        color: colors.secondaryContainer,
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 16,
                      color: colors.onSecondaryContainer,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      extraCount == 0
                          ? 'Idiom found'
                          : 'Idioms found (${matches.length})',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onSecondaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '${first.label}: ${first.meaning}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  first.pattern,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.onSecondaryContainer.withValues(alpha: 0.76),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _MoveTraceStatus { accepted, blocked, random, reset, recognized, guess }

class _MoveTraceEntry {
  final String label;
  final String sentence;
  final _MoveTraceStatus status;
  final Duration elapsed;
  final Duration? uiElapsed;

  const _MoveTraceEntry({
    required this.label,
    required this.sentence,
    required this.status,
    required this.elapsed,
    this.uiElapsed,
  });

  factory _MoveTraceEntry.random(String sentence, {required Duration elapsed}) {
    return _MoveTraceEntry(
      label: 'random sentence',
      sentence: sentence,
      status: _MoveTraceStatus.random,
      elapsed: elapsed,
    );
  }

  factory _MoveTraceEntry.reset(String sentence, {required Duration elapsed}) {
    return _MoveTraceEntry(
      label: 'reset',
      sentence: sentence,
      status: _MoveTraceStatus.reset,
      elapsed: elapsed,
    );
  }

  factory _MoveTraceEntry.guess({required Duration elapsed}) {
    return _MoveTraceEntry(
      label: 'guess sentence',
      sentence: 'SentenceState hint opened.',
      status: _MoveTraceStatus.guess,
      elapsed: elapsed,
    );
  }

  factory _MoveTraceEntry.recognition(
    String input,
    String sentence, {
    required Duration elapsed,
  }) {
    return _MoveTraceEntry(
      label: 'recognition input -> $input',
      sentence: sentence,
      status: _MoveTraceStatus.recognized,
      elapsed: elapsed,
    );
  }

  factory _MoveTraceEntry.fromMove({
    required ConfigurationMove move,
    required String sentence,
    required bool wasBlocked,
    required bool keptSentence,
    required Duration elapsed,
  }) {
    return _MoveTraceEntry(
      label: _moveTraceLabel(move),
      sentence: keptSentence && wasBlocked ? 'kept $sentence' : sentence,
      status: wasBlocked ? _MoveTraceStatus.blocked : _MoveTraceStatus.accepted,
      elapsed: elapsed,
    );
  }

  String get line {
    final statusText = switch (status) {
      _MoveTraceStatus.accepted => 'accepted',
      _MoveTraceStatus.blocked => 'blocked',
      _MoveTraceStatus.random => 'random',
      _MoveTraceStatus.reset => 'reset',
      _MoveTraceStatus.recognized => 'recognized',
      _MoveTraceStatus.guess => 'guess',
    };
    final uiText = uiElapsed == null
        ? 'pending'
        : _formatMoveTraceElapsed(uiElapsed!);

    return '[$statusText, logic ${_formatMoveTraceElapsed(elapsed)}, ui $uiText] $label | $sentence';
  }

  _MoveTraceEntry withUiElapsed(Duration elapsed) {
    return _MoveTraceEntry(
      label: label,
      sentence: sentence,
      status: status,
      elapsed: this.elapsed,
      uiElapsed: elapsed,
    );
  }
}

List<_MoveTraceEntry> _appendMoveTrace(
  List<_MoveTraceEntry> entries,
  _MoveTraceEntry entry,
) {
  return [...entries, entry].takeLast(_moveTraceLimit).toList();
}

extension _TakeLastExtension<T> on List<T> {
  Iterable<T> takeLast(int count) sync* {
    final start = length > count ? length - count : 0;
    for (var index = start; index < length; index++) {
      yield this[index];
    }
  }
}

String _moveTraceLabel(ConfigurationMove move) {
  return switch (move) {
    SetAgent(:final agent) => 'subject -> ${_nounTraceText(agent)}',
    SetAction(:final action) => 'verb -> ${action.infinitive}',
    SetObject(:final object) => 'object -> ${_nounTraceText(object)}',
    SetObjectComplement(:final objectComplement) =>
      'object complement -> ${_nounTraceText(objectComplement)}',
    SetRecipient(:final recipient) =>
      'recipient -> ${_nounTraceText(recipient)}',
    SetAddressee(:final addressee) =>
      'addressee -> ${_nounTraceText(addressee)}',
    SetCompanion(:final companion) =>
      'companion -> ${_nounTraceText(companion)}',
    SetInstrument(:final instrument) =>
      'instrument -> ${_nounTraceText(instrument)}',
    SetDestination(:final destination) =>
      'destination -> ${_nounTraceText(destination)}',
    SetTopic(:final topic, :final topicPreposition) =>
      'topic (${topicPreposition.text}) -> ${_nounTraceText(topic)}',
    SetBeneficiary(:final beneficiary) =>
      'beneficiary -> ${_nounTraceText(beneficiary)}',
    SetSource(:final source) => 'source -> ${_nounTraceText(source)}',
    SetPurpose(:final purpose) => 'purpose -> ${_nounTraceText(purpose)}',
    SetRightAction(:final rightAction) =>
      'right action -> ${rightAction?.infinitive ?? 'none'}',
    SetComplement(:final complement) =>
      'noun complement -> ${_nounTraceText(complement)}',
    SetNounPhraseDeterminer(:final target, :final determiner) =>
      '${_nounPhraseTargetTraceText(target)} determiner -> ${determiner?.text ?? 'none'}',
    SetNounPhraseAdjectives(:final target, :final adjectives) =>
      '${_nounPhraseTargetTraceText(target)} adjective -> ${adjectives.isEmpty ? 'none' : adjectives.map((adjective) => adjective.text).join(' ')}',
    SetAdjectiveComplement(:final adjectiveComplement) =>
      'adjective complement -> ${adjectiveComplement?.text ?? 'none'}',
    SetObjectAdjectiveComplement(:final objectAdjectiveComplement) =>
      'object adjective complement -> ${objectAdjectiveComplement?.text ?? 'none'}',
    SetLexicalBeComplement(:final complement) =>
      'noun complement -> ${complement.text}',
    SetLexicalBeAdjectiveComplement(:final adjectiveComplement) =>
      'adjective complement -> ${adjectiveComplement.text}',
    SetVoice(:final voice) => 'voice -> ${voice.name}',
    SetPassiveFocus(:final passiveFocus) =>
      'passive focus -> ${passiveFocus?.name ?? 'none'}',
    SetPassiveAgentVisibility(:final showPassiveAgent) =>
      showPassiveAgent ? 'passive agent -> show' : 'passive agent -> hide',
    SetTense(:final tense) => 'tense -> ${tense.name}',
    SetAspect(:final aspect) => 'aspect -> ${aspect.name}',
    SetModal(:final modal) =>
      modal.text == 'will'
          ? 'tense -> future (will)'
          : modal.isNone
          ? 'modal -> none'
          : 'modal -> ${modal.text}',
    SetPolarity(:final polarity) => 'polarity -> ${polarity.name}',
    SetSentenceForm(:final sentenceForm) => 'form -> ${sentenceForm.name}',
    SetTimePhrase(:final timePhrase) =>
      'time phrase -> ${timePhrase?.text ?? 'none'}',
    SetPlacePhrase(:final placePhrase, :final placeMeaning) =>
      'place phrase -> ${placePhrase == null ? 'none' : placePhrase.render(placeMeaning ?? PlaceMeaning.location)}',
    SetFrequencyPhrase(:final frequencyPhrase) =>
      'frequency phrase -> ${frequencyPhrase?.text ?? 'none'}',
    SetMannerPhrase(:final mannerPhrase) =>
      'manner phrase -> ${mannerPhrase?.text ?? 'none'}',
    SetRightParticle(:final rightParticle) =>
      'right particle -> ${rightParticle?.text ?? 'none'}',
  };
}

String _nounTraceText(NounPhrase? nounPhrase) {
  if (nounPhrase == null) {
    return 'none';
  }

  return [
    if (nounPhrase.determiner != null) nounPhrase.determiner!.text,
    ...nounPhrase.adjectiveList.map((adjective) => adjective.text),
    nounPhrase.text,
  ].join(' ');
}

String _nounPhraseTargetTraceText(NounPhraseTarget target) {
  return switch (target) {
    NounPhraseTarget.agent => 'subject',
    NounPhraseTarget.object => 'object',
    NounPhraseTarget.objectComplement => 'object complement',
    NounPhraseTarget.recipient => 'recipient',
    NounPhraseTarget.addressee => 'addressee',
    NounPhraseTarget.companion => 'companion',
    NounPhraseTarget.instrument => 'instrument',
    NounPhraseTarget.destination => 'destination',
    NounPhraseTarget.topic => 'topic',
    NounPhraseTarget.beneficiary => 'beneficiary',
    NounPhraseTarget.source => 'source',
    NounPhraseTarget.purpose => 'purpose',
    NounPhraseTarget.complement => 'complement',
  };
}
