part of '../home_screen.dart';

class _SuggestionButton extends StatelessWidget {
  final ConfigurationSuggestion suggestion;
  final String currentSentence;
  final SuggestionDisplayMode displayMode;
  final String preview;
  final VoidCallback onPressed;
  final ValueChanged<ConfigurationState?>? onPreviewChanged;

  const _SuggestionButton({
    required this.suggestion,
    required this.currentSentence,
    required this.displayMode,
    required this.preview,
    required this.onPressed,
    required this.onPreviewChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final wakeBadges = _verbWakeBadges(suggestion, colors);

    return MouseRegion(
      onEnter: (_) => onPreviewChanged?.call(suggestion.preview),
      onExit: (_) => onPreviewChanged?.call(null),
      child: Tooltip(
        message: suggestion.isSelected ? 'Current: $preview' : preview,
        child: OutlinedButton(
          style: _compactOutlinedStyle(
            selected: suggestion.isSelected,
            colors: colors,
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text.rich(
                  _suggestionSpan(
                    currentSentence: currentSentence,
                    preview: preview,
                    suggestion: suggestion,
                    displayMode: displayMode,
                    colors: colors,
                  ),
                ),
              ),
              if (wakeBadges.isNotEmpty) ...[
                const SizedBox(width: 5),
                _VerbWakeBadgeGroup(badges: wakeBadges),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _VerbWakeBadgeGroup extends StatelessWidget {
  final List<_VerbWakeBadge> badges;

  const _VerbWakeBadgeGroup({required this.badges});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2,
      children: [
        for (final badge in badges)
          Tooltip(
            message: badge.tooltip,
            child: Icon(
              Icons.expand_more,
              key: Key('verb-wake-${badge.keySuffix}'),
              size: 15,
              color: badge.color,
            ),
          ),
      ],
    );
  }
}

class _VerbWakeBadge {
  final String keySuffix;
  final String tooltip;
  final Color color;

  const _VerbWakeBadge({
    required this.keySuffix,
    required this.tooltip,
    required this.color,
  });
}

List<_VerbWakeBadge> _verbWakeBadges(
  ConfigurationSuggestion suggestion,
  ColorScheme colors,
) {
  if (suggestion.slot != ConfigurationCompassSlot.action) {
    return const [];
  }

  final move = suggestion.move;
  if (move is! SetAction) {
    return const [];
  }

  final action = move.action;

  return [
    for (final influence in predicateInfluencesFor(action))
      _VerbWakeBadge(
        keySuffix: '${action.infinitive}-${influence.key}',
        tooltip: influence.tooltip,
        color: _verbWakeBadgeColor(influence, colors),
      ),
  ];
}

Color _verbWakeBadgeColor(PredicateInfluence influence, ColorScheme colors) {
  return switch (influence.key) {
    'complement' => colors.secondary,
    'recipient' => colors.tertiary,
    'destination' => colors.error,
    _ => colors.primary,
  };
}

TextSpan _suggestionSpan({
  required String currentSentence,
  required String preview,
  required ConfigurationSuggestion suggestion,
  required SuggestionDisplayMode displayMode,
  required ColorScheme colors,
}) {
  final baseStyle = TextStyle(
    color: suggestion.isSelected ? colors.primary : colors.onSurface,
  );

  if (displayMode == SuggestionDisplayMode.word) {
    return TextSpan(
      text: suggestion.label,
      style: baseStyle.copyWith(
        fontWeight: suggestion.isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }

  if (displayMode == SuggestionDisplayMode.sentence) {
    return TextSpan(text: preview, style: baseStyle);
  }

  if (suggestion.isSelected || currentSentence == preview) {
    return TextSpan(text: preview, style: baseStyle);
  }

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
    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        for (final message in messages) _GuidedMessageChip(message: message),
      ],
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
    final foreground = isBlocked ? colors.error : colors.primary;
    final background = isBlocked
        ? colors.errorContainer.withValues(alpha: 0.34)
        : colors.primaryContainer.withValues(alpha: 0.34);
    final border = isBlocked ? colors.error : colors.primary;

    return Tooltip(
      message: message.tooltip,
      waitDuration: const Duration(milliseconds: 350),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: border.withValues(alpha: 0.62)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isBlocked ? Icons.lock : Icons.check_circle_outline,
                size: 16,
                color: foreground,
              ),
              const SizedBox(width: 6),
              Text(
                message.title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Text(
                  message.text,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colors.onSurface),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
