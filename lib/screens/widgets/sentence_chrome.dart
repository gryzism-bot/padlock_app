part of '../home_screen.dart';

class _StickyFooter extends StatelessWidget {
  const _StickyFooter();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface.withValues(alpha: 0.96),
      elevation: 2,
      child: SizedBox(
        height: _stickyFooterHeight,
        child: Center(
          child: Text(
            'Verblock Developer Console, Logos Dynamics 2026',
            key: const Key('app-footer-brand'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 11,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _StickySentenceHeader extends StatelessWidget {
  final Widget child;

  const _StickySentenceHeader({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface.withValues(alpha: 0.96),
      elevation: 2,
      child: SizedBox(
        height: _stickyHeaderHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: child,
        ),
      ),
    );
  }
}

class _SentencePanel extends StatelessWidget {
  final String sentence;
  final String? translation;
  final String summary;
  final VoidCallback onRecognitionInput;

  const _SentencePanel({
    required this.sentence,
    required this.translation,
    required this.summary,
    required this.onRecognitionInput,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SelectableText(
                  sentence,
                  key: const Key('rendered-sentence'),
                  textAlign: TextAlign.center,
                  maxLines: translation == null ? 2 : 1,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (translation != null) ...[
                  const SizedBox(height: 3),
                  SelectableText(
                    translation!,
                    key: const Key('translation-gloss'),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                SelectableText(
                  summary,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(height: 1.15, fontSize: 11),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton.outlined(
              key: const Key('recognition-input-button'),
              tooltip: 'Recognition input',
              visualDensity: VisualDensity.standard,
              constraints: const BoxConstraints.tightFor(width: 44, height: 44),
              padding: const EdgeInsets.all(8),
              onPressed: onRecognitionInput,
              icon: const Icon(Icons.keyboard_alt_outlined, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
