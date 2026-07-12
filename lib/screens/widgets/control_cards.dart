part of '../home_screen.dart';

class _ControlCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ControlCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: children),
          ],
        ),
      ),
    );
  }
}

class _SectionFrame extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback? onToggle;
  final String? collapsedHint;
  final List<Widget> controls;
  final List<Widget> children;
  final double? expandedMaxHeight;

  const _SectionFrame({
    required this.title,
    this.isExpanded = true,
    this.onToggle,
    this.collapsedHint,
    this.controls = const [],
    this.expandedMaxHeight,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final content = DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: onToggle == null || isExpanded
              ? colors.outlineVariant
              : colors.primary.withValues(alpha: 0.62),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: isExpanded
                ? expandedMaxHeight ?? _largeRailMaxHeight
                : 56,
          ),
          child: SingleChildScrollView(
            physics: isExpanded
                ? const ClampingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$title:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (onToggle != null) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: isExpanded
                            ? 'Close $title rail'
                            : 'Open $title rail',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 24,
                          height: 24,
                        ),
                        iconSize: 18,
                        onPressed: onToggle,
                        color: isExpanded
                            ? colors.onSurfaceVariant
                            : colors.primary,
                        icon: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                        ),
                      ),
                    ],
                  ],
                ),
                if (!isExpanded && collapsedHint != null)
                  Text(
                    collapsedHint!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                if (isExpanded) ...[
                  if (controls.isNotEmpty) ...controls,
                  ...children,
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (onToggle == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: isExpanded ? null : onToggle,
        child: content,
      ),
    );
  }
}

class _InlineExpandableChipCluster extends StatefulWidget {
  final List<Widget> children;
  final String expandedLabel;
  final List<Widget> expandedChildren;

  const _InlineExpandableChipCluster({
    required this.children,
    required this.expandedLabel,
    required this.expandedChildren,
  });

  @override
  State<_InlineExpandableChipCluster> createState() =>
      _InlineExpandableChipClusterState();
}

class _InlineExpandableChipClusterState
    extends State<_InlineExpandableChipCluster> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...widget.children,
        IconButton(
          tooltip: isExpanded
              ? 'Hide ${widget.expandedLabel}'
              : 'Show ${widget.expandedLabel}',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 28, height: 28),
          iconSize: 16,
          onPressed: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
        ),
        if (isExpanded) ...widget.expandedChildren,
      ],
    );
  }
}

class _InlineOptionRow extends StatelessWidget {
  final String label;
  final List<Widget> children;
  final double? labelWidth;
  final double runSpacing;

  const _InlineOptionRow({
    required this.label,
    required this.children,
    this.labelWidth,
    this.runSpacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedLabelWidth = labelWidth ?? (label.length > 8 ? 76.0 : 42.0);

    return Wrap(
      spacing: 6,
      runSpacing: runSpacing,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: resolvedLabelWidth,
          child: Text(label, style: Theme.of(context).textTheme.labelSmall),
        ),
        ...children,
      ],
    );
  }
}

class _CompactChipCluster extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _CompactChipCluster({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        child: Wrap(
          spacing: 5,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _MoveButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const _MoveButton({
    required this.label,
    this.selected = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return OutlinedButton(
      style: _compactOutlinedStyle(selected: selected, colors: colors),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(fontWeight: selected ? FontWeight.w700 : null),
      ),
    );
  }
}

ButtonStyle _compactOutlinedStyle({
  required bool selected,
  required ColorScheme colors,
}) {
  return OutlinedButton.styleFrom(
    visualDensity: VisualDensity.compact,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    minimumSize: const Size(0, 34),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    foregroundColor: selected ? colors.primary : null,
    side: selected ? BorderSide(color: colors.primary, width: 2) : null,
  );
}
