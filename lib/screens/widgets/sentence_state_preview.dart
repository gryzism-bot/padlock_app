part of '../home_screen.dart';

class _SentenceStatePreview extends StatelessWidget {
  final SentenceState state;
  final int columns;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const _SentenceStatePreview({
    required this.state,
    this.columns = 2,
    this.style,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final entries = _sentenceStatePreviewEntries(state);
    final columnCount = columns.clamp(1, 4);
    final rowsPerColumn = (entries.length / columnCount).ceil();
    final textStyle =
        style ??
        Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(height: 1.18, letterSpacing: 0);
    final activeLabelStyle =
        labelStyle ??
        textStyle?.copyWith(color: colors.primary, fontWeight: FontWeight.w800);
    final activeValueStyle =
        valueStyle ?? textStyle?.copyWith(color: colors.onSurfaceVariant);
    final sleepingLabelStyle = activeLabelStyle?.copyWith(
      color: colors.onSurfaceVariant.withValues(alpha: 0.55),
      fontWeight: FontWeight.w600,
    );
    final sleepingValueStyle = activeValueStyle?.copyWith(
      color: colors.onSurfaceVariant.withValues(alpha: 0.42),
    );

    return Row(
      key: const Key('sentence-state-preview'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var column = 0; column < columnCount; column++) ...[
          Expanded(
            child: _SentenceStatePreviewColumn(
              entries: entries
                  .sublist(
                    column * rowsPerColumn,
                    min((column + 1) * rowsPerColumn, entries.length),
                  )
                  .toList(growable: false),
              activeLabelStyle: activeLabelStyle,
              activeValueStyle: activeValueStyle,
              sleepingLabelStyle: sleepingLabelStyle,
              sleepingValueStyle: sleepingValueStyle,
              key: Key('sentence-state-preview-column-$column'),
            ),
          ),
          if (column < columnCount - 1) const SizedBox(width: 22),
        ],
      ],
    );
  }
}

class _SentenceStatePreviewColumn extends StatelessWidget {
  final List<_SentenceStatePreviewEntry> entries;
  final TextStyle? activeLabelStyle;
  final TextStyle? activeValueStyle;
  final TextStyle? sleepingLabelStyle;
  final TextStyle? sleepingValueStyle;

  const _SentenceStatePreviewColumn({
    super.key,
    required this.entries,
    required this.activeLabelStyle,
    required this.activeValueStyle,
    required this.sleepingLabelStyle,
    required this.sleepingValueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {0: FixedColumnWidth(126), 1: FlexColumnWidth()},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (final entry in entries)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 3, right: 8),
                child: Text(
                  '${entry.label}:',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: entry.isActive ? activeLabelStyle : sleepingLabelStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  entry.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: entry.isActive ? activeValueStyle : sleepingValueStyle,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _CompactSentenceStatePreview extends StatelessWidget {
  final SentenceState state;

  const _CompactSentenceStatePreview({required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final entries = _compactSentenceStatePreviewEntries(state);
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      height: 1.18,
      fontSize: 11,
      letterSpacing: 0,
      color: colors.onSurfaceVariant,
    );
    final labelStyle = textStyle?.copyWith(
      color: colors.primary,
      fontWeight: FontWeight.w800,
    );
    final sleepingLabelStyle = labelStyle?.copyWith(
      color: colors.onSurfaceVariant.withValues(alpha: 0.55),
      fontWeight: FontWeight.w600,
    );
    final sleepingValueStyle = textStyle?.copyWith(
      color: colors.onSurfaceVariant.withValues(alpha: 0.46),
    );

    return SelectableText.rich(
      TextSpan(
        style: textStyle,
        children: [
          for (var index = 0; index < entries.length; index++) ...[
            TextSpan(
              text: entries[index].label,
              style: entries[index].isActive ? labelStyle : sleepingLabelStyle,
            ),
            const TextSpan(text: ': '),
            TextSpan(
              text: entries[index].value,
              style: entries[index].isActive ? textStyle : sleepingValueStyle,
            ),
            if (index < entries.length - 1) const TextSpan(text: '   '),
          ],
        ],
      ),
      key: const Key('sentence-state-compact-preview'),
      textAlign: TextAlign.center,
      maxLines: 3,
    );
  }
}

class _SentenceStatePreviewEntry {
  final String label;
  final String value;
  final bool isActive;

  const _SentenceStatePreviewEntry(
    this.label,
    this.value, {
    required this.isActive,
  });
}

List<_SentenceStatePreviewEntry> _compactSentenceStatePreviewEntries(
  SentenceState state,
) {
  final coreEntries = [
    _statePreviewEntry('subject', _nounPhrasePreview(state.agent), true),
    _statePreviewEntry('verb', state.action.infinitive, true),
    _statePreviewEntry('tense', _enumPreview(state.tense.name), true),
    _statePreviewEntry('aspect', _enumPreview(state.aspect.name), true),
    _statePreviewEntry('modal', _modalPreview(state.modal), _hasModal(state)),
    _statePreviewEntry('voice', _enumPreview(state.voice.name), true),
    _statePreviewEntry('polarity', _enumPreview(state.polarity.name), true),
    _statePreviewEntry('form', _enumPreview(state.sentenceForm.name), true),
  ];
  final surfaceEntries = [
    _statePreviewEntry(
      'object',
      _nounPhrasePreview(state.object),
      _hasObject(state),
    ),
    _statePreviewEntry(
      'recipient',
      _nounPhrasePreview(state.recipient),
      _hasRecipient(state),
    ),
    _statePreviewEntry(
      'to person',
      _nounPhrasePreview(state.addressee),
      _hasAddressee(state),
    ),
    _statePreviewEntry(
      'with person',
      _nounPhrasePreview(state.companion),
      _hasCompanion(state),
    ),
    _statePreviewEntry(
      'with tool',
      _nounPhrasePreview(state.instrument),
      _hasInstrument(state),
    ),
    _statePreviewEntry(
      'destination',
      _nounPhrasePreview(state.destination),
      _hasDestination(state),
    ),
    _statePreviewEntry(
      'topic',
      _topicPreview(state.topicPreposition, state.topic),
      _hasTopic(state),
    ),
    _statePreviewEntry(
      'for person',
      _nounPhrasePreview(state.beneficiary),
      _hasBeneficiary(state),
    ),
    _statePreviewEntry(
      'source',
      _nounPhrasePreview(state.source),
      _hasSource(state),
    ),
    _statePreviewEntry(
      'purpose',
      _nounPhrasePreview(state.purpose),
      _hasPurpose(state),
    ),
    _statePreviewEntry(
      'right action',
      state.rightAction?.infinitive ?? 'none',
      _hasRightAction(state),
    ),
    _statePreviewEntry(
      'particle',
      state.rightParticle?.text ?? 'none',
      _hasRightParticle(state),
    ),
    _statePreviewEntry(
      'object noun result',
      _nounPhrasePreview(state.objectComplement),
      _hasObjectComplement(state),
    ),
    _statePreviewEntry(
      'object adjective result',
      state.objectAdjectiveComplement?.text ?? 'none',
      _hasObjectAdjectiveComplement(state),
    ),
    _statePreviewEntry(
      'noun complement',
      _nounPhrasePreview(state.complement),
      _hasComplement(state),
    ),
    _statePreviewEntry(
      'adjective complement',
      state.adjectiveComplement?.text ?? 'none',
      _hasAdjectiveComplement(state),
    ),
    _statePreviewEntry(
      'passive focus',
      state.passiveFocus?.name ?? 'none',
      _hasPassiveFocus(state),
    ),
    _statePreviewEntry(
      'passive agent',
      state.showPassiveAgent ? 'shown' : 'hidden',
      _hasPassiveAgentControl(state),
    ),
    _statePreviewEntry(
      'time',
      state.timePhrase?.text ?? 'none',
      _hasTime(state),
    ),
    _statePreviewEntry('place', _placePhrasePreview(state), _hasPlace(state)),
    _statePreviewEntry(
      'place meaning',
      state.placeMeaning?.name ?? 'auto',
      _hasPlaceMeaning(state),
    ),
    _statePreviewEntry(
      'frequency',
      state.frequencyPhrase?.text ?? 'none',
      _hasFrequency(state),
    ),
    _statePreviewEntry(
      'manner',
      state.mannerPhrase?.text ?? 'none',
      _hasManner(state),
    ),
  ];

  return [
    ...coreEntries,
    ...surfaceEntries.where((entry) => entry.isActive),
    ...surfaceEntries.where((entry) => !entry.isActive),
  ];
}

List<_SentenceStatePreviewEntry> _sentenceStatePreviewEntries(
  SentenceState state,
) {
  return [
    _statePreviewEntry('subject', _nounPhrasePreview(state.agent), true),
    _statePreviewEntry('verb', state.action.infinitive, true),
    _statePreviewEntry(
      'object',
      _nounPhrasePreview(state.object),
      _hasObject(state),
    ),
    _statePreviewEntry(
      'recipient',
      _nounPhrasePreview(state.recipient),
      _hasRecipient(state),
    ),
    _statePreviewEntry(
      'to person',
      _nounPhrasePreview(state.addressee),
      _hasAddressee(state),
    ),
    _statePreviewEntry(
      'with person',
      _nounPhrasePreview(state.companion),
      _hasCompanion(state),
    ),
    _statePreviewEntry(
      'with tool',
      _nounPhrasePreview(state.instrument),
      _hasInstrument(state),
    ),
    _statePreviewEntry(
      'destination',
      _nounPhrasePreview(state.destination),
      _hasDestination(state),
    ),
    _statePreviewEntry(
      'topic',
      _topicPreview(state.topicPreposition, state.topic),
      _hasTopic(state),
    ),
    _statePreviewEntry(
      'for person',
      _nounPhrasePreview(state.beneficiary),
      _hasBeneficiary(state),
    ),
    _statePreviewEntry(
      'source',
      _nounPhrasePreview(state.source),
      _hasSource(state),
    ),
    _statePreviewEntry(
      'purpose',
      _nounPhrasePreview(state.purpose),
      _hasPurpose(state),
    ),
    _statePreviewEntry(
      'right action',
      state.rightAction?.infinitive ?? 'none',
      _hasRightAction(state),
    ),
    _statePreviewEntry(
      'particle',
      state.rightParticle?.text ?? 'none',
      _hasRightParticle(state),
    ),
    _statePreviewEntry(
      'object noun result',
      _nounPhrasePreview(state.objectComplement),
      _hasObjectComplement(state),
    ),
    _statePreviewEntry(
      'object adjective result',
      state.objectAdjectiveComplement?.text ?? 'none',
      _hasObjectAdjectiveComplement(state),
    ),
    _statePreviewEntry(
      'noun complement',
      _nounPhrasePreview(state.complement),
      _hasComplement(state),
    ),
    _statePreviewEntry(
      'adjective complement',
      state.adjectiveComplement?.text ?? 'none',
      _hasAdjectiveComplement(state),
    ),
    _statePreviewEntry('voice', _enumPreview(state.voice.name), true),
    _statePreviewEntry(
      'passive focus',
      state.passiveFocus?.name ?? 'none',
      _hasPassiveFocus(state),
    ),
    _statePreviewEntry(
      'passive agent',
      state.showPassiveAgent ? 'shown' : 'hidden',
      _hasPassiveAgentControl(state),
    ),
    _statePreviewEntry('tense', _enumPreview(state.tense.name), true),
    _statePreviewEntry('aspect', _enumPreview(state.aspect.name), true),
    _statePreviewEntry('modal', _modalPreview(state.modal), _hasModal(state)),
    _statePreviewEntry('polarity', _enumPreview(state.polarity.name), true),
    _statePreviewEntry('form', _enumPreview(state.sentenceForm.name), true),
    _statePreviewEntry(
      'time',
      state.timePhrase?.text ?? 'none',
      _hasTime(state),
    ),
    _statePreviewEntry('place', _placePhrasePreview(state), _hasPlace(state)),
    _statePreviewEntry(
      'place meaning',
      state.placeMeaning?.name ?? 'auto',
      _hasPlaceMeaning(state),
    ),
    _statePreviewEntry(
      'frequency',
      state.frequencyPhrase?.text ?? 'none',
      _hasFrequency(state),
    ),
    _statePreviewEntry(
      'manner',
      state.mannerPhrase?.text ?? 'none',
      _hasManner(state),
    ),
  ];
}

_SentenceStatePreviewEntry _statePreviewEntry(
  String label,
  String value,
  bool isActive,
) {
  return _SentenceStatePreviewEntry(label, value, isActive: isActive);
}

bool _hasObject(SentenceState state) => state.object != null;
bool _hasRecipient(SentenceState state) => state.recipient != null;
bool _hasAddressee(SentenceState state) => state.addressee != null;
bool _hasCompanion(SentenceState state) => state.companion != null;
bool _hasInstrument(SentenceState state) => state.instrument != null;
bool _hasDestination(SentenceState state) => state.destination != null;
bool _hasTopic(SentenceState state) => state.topic != null;
bool _hasBeneficiary(SentenceState state) => state.beneficiary != null;
bool _hasSource(SentenceState state) => state.source != null;
bool _hasPurpose(SentenceState state) => state.purpose != null;
bool _hasRightAction(SentenceState state) => state.rightAction != null;
bool _hasRightParticle(SentenceState state) => state.rightParticle != null;
bool _hasObjectComplement(SentenceState state) =>
    state.objectComplement != null;
bool _hasObjectAdjectiveComplement(SentenceState state) =>
    state.objectAdjectiveComplement != null;
bool _hasComplement(SentenceState state) => state.complement != null;
bool _hasAdjectiveComplement(SentenceState state) =>
    state.adjectiveComplement != null;
bool _hasPassiveFocus(SentenceState state) => state.passiveFocus != null;
bool _hasPassiveAgentControl(SentenceState state) =>
    state.voice == Voice.passive;
bool _hasModal(SentenceState state) =>
    !state.modal.isNone && state.modal.text.isNotEmpty;
bool _hasTime(SentenceState state) => state.timePhrase != null;
bool _hasPlace(SentenceState state) => state.placePhrase != null;
bool _hasPlaceMeaning(SentenceState state) => state.placePhrase != null;
bool _hasFrequency(SentenceState state) => state.frequencyPhrase != null;
bool _hasManner(SentenceState state) => state.mannerPhrase != null;

String _nounPhrasePreview(NounPhrase? phrase) {
  if (phrase == null) {
    return 'none';
  }

  final words = [
    if (phrase.determiner != null) phrase.determiner!.text,
    ...phrase.adjectiveList.map((adjective) => adjective.text),
    phrase.text,
  ].join(' ');
  return '$words (${phrase.number.name})';
}

String _topicPreview(TopicPreposition preposition, NounPhrase? topic) {
  if (topic == null) {
    return 'none';
  }

  return '${preposition.name} ${_nounPhrasePreview(topic)}';
}

String _placePhrasePreview(SentenceState state) {
  final phrase = state.placePhrase;
  if (phrase == null) {
    return 'none';
  }

  final meaning =
      state.placeMeaning ??
      (state.action.usesDestinationPlace
          ? PlaceMeaning.destination
          : PlaceMeaning.location);
  return phrase.render(meaning);
}

String _modalPreview(Modal modal) {
  if (modal.isNone || modal.text.isEmpty) {
    return 'none';
  }

  return modal.text;
}

String _enumPreview(String value) {
  return value.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'),
    (match) => '${match.group(1)} ${match.group(2)}',
  );
}
