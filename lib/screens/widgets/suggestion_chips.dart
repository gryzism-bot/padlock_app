part of '../home_screen.dart';

class _SuggestionButton extends StatelessWidget {
  final ConfigurationSuggestion suggestion;
  final String currentSentence;
  final SuggestionDisplayMode displayMode;
  final String? verbTranslation;
  final String? preview;
  final VoidCallback onPressed;
  final ValueChanged<ConfigurationState?>? onPreviewChanged;

  const _SuggestionButton({
    required this.suggestion,
    required this.currentSentence,
    required this.displayMode,
    required this.verbTranslation,
    required this.preview,
    required this.onPressed,
    required this.onPreviewChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final wakeSignal = _verbWakeSignal(suggestion, colors);

    return MouseRegion(
      onEnter: (_) => onPreviewChanged?.call(suggestion.preview),
      onExit: (_) => onPreviewChanged?.call(null),
      child: Tooltip(
        message: _suggestionTooltipText(
          suggestion: suggestion,
          preview: preview,
        ),
        child: OutlinedButton(
          style: _compactOutlinedStyle(
            selected: suggestion.isSelected,
            colors: colors,
          ),
          onPressed: onPressed,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (wakeSignal != null) ...[
                _VerbWakeSignalView(signal: wakeSignal),
                const SizedBox(height: 1),
              ],
              _SuggestionLabel(
                suggestion: suggestion,
                currentSentence: currentSentence,
                displayMode: displayMode,
                verbTranslation: verbTranslation,
                preview: preview,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionLabel extends StatelessWidget {
  final ConfigurationSuggestion suggestion;
  final String currentSentence;
  final SuggestionDisplayMode displayMode;
  final String? verbTranslation;
  final String? preview;

  const _SuggestionLabel({
    required this.suggestion,
    required this.currentSentence,
    required this.displayMode,
    required this.verbTranslation,
    required this.preview,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final baseStyle = TextStyle(
      color: suggestion.isSelected ? colors.primary : colors.onSurface,
      fontWeight: displayMode == SuggestionDisplayMode.word
          ? suggestion.isSelected
                ? FontWeight.w700
                : FontWeight.w500
          : null,
    );
    final key = Key(_suggestionLabelKey(suggestion));

    if (displayMode == SuggestionDisplayMode.word) {
      return _SuggestionLabelText(
        label: suggestion.label,
        translation: verbTranslation,
        labelKey: key,
        textAlign: TextAlign.center,
        style: baseStyle,
      );
    }

    final renderedPreview = preview ?? suggestion.label;
    if (suggestion.isSelected || currentSentence == renderedPreview) {
      return _SuggestionLabelText(
        label: renderedPreview,
        translation: verbTranslation,
        labelKey: key,
        textAlign: TextAlign.center,
        style: baseStyle,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          _changedSuggestionSpan(
            currentSentence: currentSentence,
            preview: renderedPreview,
            suggestion: suggestion,
            colors: colors,
            baseStyle: baseStyle,
          ),
          key: key,
          textAlign: TextAlign.center,
        ),
        if (verbTranslation != null) _VerbTranslationGloss(verbTranslation!),
      ],
    );
  }
}

class _SuggestionLabelText extends StatelessWidget {
  final String label;
  final String? translation;
  final Key labelKey;
  final TextAlign textAlign;
  final TextStyle style;

  const _SuggestionLabelText({
    required this.label,
    required this.translation,
    required this.labelKey,
    required this.textAlign,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (translation == null) {
      return Text(label, key: labelKey, textAlign: textAlign, style: style);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, key: labelKey, textAlign: textAlign, style: style),
        _VerbTranslationGloss(translation!),
      ],
    );
  }
}

class _VerbTranslationGloss extends StatelessWidget {
  final String translation;

  const _VerbTranslationGloss(this.translation);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Text(
      '($translation)',
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: colors.onSurfaceVariant,
        fontSize: 10,
        height: 1.05,
      ),
    );
  }
}

String _suggestionTooltipText({
  required ConfigurationSuggestion suggestion,
  required String? preview,
}) {
  if (preview == null) {
    return suggestion.isSelected
        ? 'Current: ${suggestion.label}'
        : suggestion.label;
  }

  return suggestion.isSelected ? 'Current: $preview' : preview;
}

class _VerbWakeSignalView extends StatelessWidget {
  final _VerbWakeSignal signal;

  const _VerbWakeSignalView({required this.signal});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: signal.tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final entry in signal.icons.indexed) ...[
            _PredicateIconGlyph(
              slot: entry.$2,
              key: entry.$1 < signal.keySuffixes.length
                  ? Key('verb-wake-${signal.keySuffixes[entry.$1]}')
                  : null,
              color: signal.color,
            ),
            if (entry.$1 != signal.icons.length - 1) const SizedBox(width: 2),
          ],
          const SizedBox(width: 3),
          _VerbWakeOutputs(signal: signal),
        ],
      ),
    );
  }
}

class _VerbWakeOutputs extends StatelessWidget {
  final _VerbWakeSignal signal;

  const _VerbWakeOutputs({required this.signal});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: Key('verb-wake-output-${signal.actionKey}'),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < signal.outputCount; index++)
          Icon(_materialOutputIcon, size: 9, color: signal.color),
      ],
    );
  }
}

class _PredicateIconGlyph extends StatelessWidget {
  final PredicateIconSlot slot;
  final Color color;

  const _PredicateIconGlyph({
    super.key,
    required this.slot,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (slot.assetPath.isNotEmpty) {
      return Icon(Icons.image_outlined, size: 15, color: color);
    }

    return Icon(_materialIconFor(slot.materialIcon), size: 15, color: color);
  }
}

class _VerbWakeSignal {
  final List<String> keySuffixes;
  final String actionKey;
  final String tooltip;
  final List<PredicateIconSlot> icons;
  final Color color;
  final int outputCount;

  const _VerbWakeSignal({
    required this.keySuffixes,
    required this.actionKey,
    required this.tooltip,
    required this.icons,
    required this.color,
    required this.outputCount,
  });
}

_VerbWakeSignal? _verbWakeSignal(
  ConfigurationSuggestion suggestion,
  ColorScheme colors,
) {
  if (suggestion.slot != ConfigurationCompassSlot.action) {
    return null;
  }

  final move = suggestion.move;
  if (move is! SetAction) {
    return null;
  }

  final action = move.action;
  final influences = predicateInfluencesFor(action);
  if (influences.isEmpty) {
    return null;
  }

  final influenceKeys = [for (final influence in influences) influence.key];
  final coreInfluences = [
    for (final influence in influences)
      if (!_isPhraseInfluence(influence)) influence,
  ];
  final coreInfluenceKeys = [
    for (final influence in coreInfluences) influence.key,
  ];
  final profile = predicateSemanticIconProfileFor(
    infinitive: action.infinitive,
    influenceKeys: influenceKeys,
  );
  final outputCount = predicateSemanticOutputCount(
    infinitive: action.infinitive,
    influenceKeys: coreInfluenceKeys,
    profile: profile,
  );

  return _VerbWakeSignal(
    keySuffixes: [
      for (final influence in influences)
        '${action.infinitive}-${influence.key}',
    ],
    actionKey: action.infinitive,
    tooltip: _verbWakeTooltip(
      action.infinitive,
      influences,
      coreInfluences,
      outputCount,
    ),
    icons: profile.icons,
    color: _verbWakeSignalColor(influences, colors),
    outputCount: outputCount,
  );
}

String _verbWakeTooltip(
  String action,
  List<PredicateInfluence> influences,
  List<PredicateInfluence> coreInfluences,
  int outputCount,
) {
  final coreLabels = coreInfluences
      .map((influence) => influence.label)
      .join(', ');
  final phraseLabels = influences
      .where(_isPhraseInfluence)
      .map((influence) => influence.label)
      .join(', ');
  final grammarLabels = coreInfluences
      .where(
        (influence) =>
            influence.source == PredicateInfluenceSource.grammarFrame,
      )
      .map((influence) => influence.label)
      .join(', ');
  final propertyLabels = coreInfluences
      .where(
        (influence) =>
            influence.source == PredicateInfluenceSource.predicateProperty,
      )
      .map((influence) => influence.label)
      .join(', ');
  final railWord = outputCount == 1 ? 'rail' : 'rails';
  final sourceText = [
    if (grammarLabels.isNotEmpty) 'grammar frame: $grammarLabels',
    if (propertyLabels.isNotEmpty) 'predicate property: $propertyLabels',
  ].join('. ');
  return [
    if (coreLabels.isNotEmpty) '$action wakes core rails: $coreLabels',
    if (phraseLabels.isNotEmpty) 'Phrase tracks: $phraseLabels',
    if (sourceText.isNotEmpty) sourceText,
    'It can wake $outputCount core $railWord.',
  ].join('. ');
}

bool _isPhraseInfluence(PredicateInfluence influence) {
  return switch (influence.key) {
    'place' || 'time' || 'frequency' || 'manner' => true,
    _ => false,
  };
}

const _materialOutputIcon = Icons.keyboard_arrow_right;

IconData _materialIconFor(String materialIcon) {
  return switch (materialIcon) {
    MaterialIconKey.accountTreeOutlined => Icons.account_tree_outlined,
    MaterialIconKey.arrowDownward => Icons.arrow_downward,
    MaterialIconKey.arrowBack => Icons.arrow_back,
    MaterialIconKey.arrowForward => Icons.arrow_forward,
    MaterialIconKey.arrowUpward => Icons.arrow_upward,
    MaterialIconKey.backHandOutlined => Icons.back_hand_outlined,
    MaterialIconKey.callReceived => Icons.call_received,
    MaterialIconKey.directionsCar => Icons.directions_car,
    MaterialIconKey.directionsWalk => Icons.directions_walk,
    MaterialIconKey.editOutlined => Icons.edit_outlined,
    MaterialIconKey.euro => Icons.euro,
    MaterialIconKey.frontHandOutlined => Icons.front_hand_outlined,
    MaterialIconKey.groupsOutlined => Icons.groups_outlined,
    MaterialIconKey.handshakeOutlined => Icons.handshake_outlined,
    MaterialIconKey.inventory2Outlined => Icons.inventory_2_outlined,
    MaterialIconKey.lightbulbOutline => Icons.lightbulb_outline,
    MaterialIconKey.menuBookOutlined => Icons.menu_book_outlined,
    MaterialIconKey.movieOutlined => Icons.movie_outlined,
    MaterialIconKey.noCrashOutlined => Icons.no_crash_outlined,
    MaterialIconKey.panToolAltOutlined => Icons.pan_tool_alt_outlined,
    MaterialIconKey.panToolOutlined => Icons.pan_tool_outlined,
    MaterialIconKey.personOutline => Icons.person_outline,
    MaterialIconKey.placeOutlined => Icons.place_outlined,
    MaterialIconKey.recordVoiceOverOutlined => Icons.record_voice_over_outlined,
    MaterialIconKey.scheduleOutlined => Icons.schedule_outlined,
    MaterialIconKey.schoolOutlined => Icons.school_outlined,
    MaterialIconKey.speedOutlined => Icons.speed_outlined,
    MaterialIconKey.sportsSoccer => Icons.sports_soccer,
    _ => Icons.help_outline,
  };
}

Color _verbWakeSignalColor(
  List<PredicateInfluence> influences,
  ColorScheme colors,
) {
  final primaryInfluence = influences.first;
  return switch (primaryInfluence.key) {
    'complement' => colors.secondary,
    'recipient' => colors.tertiary,
    'destination' => colors.error,
    'addressee' ||
    'companion' ||
    'topic' ||
    'beneficiary' ||
    'source' => colors.secondary,
    _ => colors.primary,
  };
}

String _suggestionLabelKey(ConfigurationSuggestion suggestion) {
  final safeLabel = suggestion.label
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  return 'suggestion-label-${suggestion.slot.name}-$safeLabel';
}

TextSpan _changedSuggestionSpan({
  required String currentSentence,
  required String preview,
  required ConfigurationSuggestion suggestion,
  required ColorScheme colors,
  required TextStyle baseStyle,
}) {
  final change = _changedRange(currentSentence, preview);
  final highlightStyle = TextStyle(
    color: colors.onTertiaryContainer,
    backgroundColor: colors.tertiaryContainer,
    fontWeight: FontWeight.w800,
  );

  if (change.start == change.end) {
    return TextSpan(
      style: baseStyle,
      children: [
        TextSpan(text: preview),
        TextSpan(text: '  ', style: baseStyle),
        TextSpan(text: suggestion.label, style: highlightStyle),
      ],
    );
  }

  return TextSpan(
    style: baseStyle,
    children: [
      TextSpan(text: preview.substring(0, change.start)),
      TextSpan(
        text: preview.substring(change.start, change.end),
        style: highlightStyle,
      ),
      TextSpan(text: preview.substring(change.end)),
    ],
  );
}

({int start, int end}) _changedRange(String current, String preview) {
  var start = 0;
  while (start < current.length &&
      start < preview.length &&
      current.codeUnitAt(start) == preview.codeUnitAt(start)) {
    start++;
  }

  var currentEnd = current.length;
  var previewEnd = preview.length;
  while (currentEnd > start &&
      previewEnd > start &&
      current.codeUnitAt(currentEnd - 1) ==
          preview.codeUnitAt(previewEnd - 1)) {
    currentEnd--;
    previewEnd--;
  }

  while (start > 0 && _isWordCodeUnit(preview.codeUnitAt(start - 1))) {
    start--;
  }

  while (previewEnd < preview.length &&
      _isWordCodeUnit(preview.codeUnitAt(previewEnd))) {
    previewEnd++;
  }

  return (start: start, end: previewEnd);
}

bool _isWordCodeUnit(int codeUnit) {
  return (codeUnit >= 65 && codeUnit <= 90) ||
      (codeUnit >= 97 && codeUnit <= 122);
}

class _GuidedMessages extends StatelessWidget {
  final List<ConfigurationMessage> messages;

  const _GuidedMessages({required this.messages});

  @override
  Widget build(BuildContext context) {
    return _GuidedMessagePanel(messages: messages);
  }
}

class _GuidedMessagePanel extends StatelessWidget {
  final List<ConfigurationMessage> messages;

  const _GuidedMessagePanel({required this.messages});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasBlocked = messages.any(
      (message) => message.kind == ConfigurationMessageKind.blocked,
    );
    final foreground = hasBlocked ? colors.error : colors.primary;
    final background = hasBlocked
        ? colors.errorContainer.withValues(alpha: 0.24)
        : colors.primaryContainer.withValues(alpha: 0.24);
    final border = hasBlocked ? colors.error : colors.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border.withValues(alpha: 0.62)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasBlocked ? Icons.lock : Icons.check_circle_outline,
                  size: 16,
                  color: foreground,
                ),
                const SizedBox(width: 6),
                Text(
                  'Language alert',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${messages.length} ${messages.length == 1 ? 'signal' : 'signals'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            if (messages.isEmpty)
              Text(
                'No language alerts.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 5,
                    children: [
                      for (final message in messages)
                        _GuidedMessageChip(message: message),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GuidedMessageChip extends StatelessWidget {
  final ConfigurationMessage message;

  const _GuidedMessageChip({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isBlocked = message.kind == ConfigurationMessageKind.blocked;
    final lawAlert = _lockLawAlertFor(message);
    final foreground = isBlocked ? colors.error : colors.primary;
    final background = colors.surface.withValues(alpha: 0.62);
    final border = foreground;

    return Tooltip(
      message: message.tooltip,
      waitDuration: const Duration(milliseconds: 350),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: border.withValues(alpha: 0.62)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      isBlocked ? Icons.lock : Icons.check_circle_outline,
                      size: 14,
                      color: foreground,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Lock law alert:',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: SelectableText(
                        lawAlert.label,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      'Example nearby:',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: SelectableText(
                        message.text,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoveTracePanel extends StatelessWidget {
  final List<_MoveTraceEntry> entries;

  const _MoveTracePanel({required this.entries});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withValues(alpha: 0.18),
        border: Border.all(color: colors.secondary.withValues(alpha: 0.54)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.route_outlined, size: 16, color: colors.secondary),
                const SizedBox(width: 6),
                Text(
                  'Move trace',
                  key: const Key('move-trace-title'),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${entries.length} ${entries.length == 1 ? 'move' : 'moves'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            if (entries.isEmpty)
              Text(
                'No moves since reset.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    _moveTraceText(entries),
                    key: const Key('move-trace-text'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurface,
                      fontSize: 11,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _moveTraceText(List<_MoveTraceEntry> entries) {
  return entries.indexed
      .map((entry) {
        return '${entry.$1 + 1}. ${entry.$2.line}';
      })
      .join('\n');
}

String _formatMoveTraceElapsed(Duration elapsed) {
  final microseconds = elapsed.inMicroseconds;
  if (microseconds < 1000) {
    return '<1 ms';
  }

  return '${elapsed.inMilliseconds} ms';
}

class _LockLawAlert {
  final String label;

  const _LockLawAlert(this.label);
}

_LockLawAlert _lockLawAlertFor(ConfigurationMessage message) {
  return _LockLawAlert(message.lawCategory.label);
}
