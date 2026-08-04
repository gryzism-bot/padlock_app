part of '../home_screen.dart';

class _CompassSlotSection extends StatefulWidget {
  final ConfigurationCompassSlot slot;
  final String title;
  final String unlockHint;
  final String? surfaceMarker;
  final bool isExpanded;
  final VoidCallback? onToggle;
  final String currentSentence;
  final SuggestionDisplayMode displayMode;
  final bool showSuggestionTranslations;
  final VoidCallback? onToggleSuggestionTranslations;
  final String? translationLabel;
  final String? Function(ConfigurationSuggestion suggestion)
  translateSuggestion;
  final List<ConfigurationSuggestion> suggestions;
  final Number? nounNumber;
  final ValueChanged<Number>? onNounNumberChanged;
  final String Function(SentenceState state) renderPreview;
  final ValueChanged<ConfigurationMove> onMove;
  final ValueChanged<ConfigurationState?>? onPreviewChanged;
  final ValueChanged<String>? onFilterQueryChanged;

  const _CompassSlotSection({
    required this.slot,
    required this.title,
    required this.unlockHint,
    required this.surfaceMarker,
    required this.isExpanded,
    required this.onToggle,
    required this.currentSentence,
    required this.displayMode,
    required this.showSuggestionTranslations,
    required this.onToggleSuggestionTranslations,
    required this.translationLabel,
    required this.translateSuggestion,
    required this.suggestions,
    required this.nounNumber,
    required this.onNounNumberChanged,
    required this.renderPreview,
    required this.onMove,
    required this.onPreviewChanged,
    this.onFilterQueryChanged,
  });

  @override
  State<_CompassSlotSection> createState() => _CompassSlotSectionState();
}

class _CompassSlotSectionState extends State<_CompassSlotSection> {
  late String _suggestionsSignature;
  final TextEditingController _filterController = TextEditingController();
  String _filterQuery = '';

  @override
  void initState() {
    super.initState();
    _suggestionsSignature = _suggestionsSignatureFor(widget.suggestions);
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _CompassSlotSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextSignature = _suggestionsSignatureFor(widget.suggestions);
    if (oldWidget.isExpanded != widget.isExpanded ||
        oldWidget.title != widget.title ||
        nextSignature != _suggestionsSignature) {
      _suggestionsSignature = nextSignature;
      if (oldWidget.title != widget.title) {
        _filterController.clear();
        _filterQuery = '';
      }
    }
  }

  List<ConfigurationSuggestion> get _filteredSuggestions {
    final query = _filterQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.suggestions;
    }

    final terms = query.split(RegExp(r'\s+'));
    final matches = [
      for (final suggestion in widget.suggestions)
        if (_suggestionMatchesTerms(suggestion, terms)) suggestion,
    ];
    matches.sort((left, right) {
      final leftRank = _suggestionSearchRank(left, terms);
      final rightRank = _suggestionSearchRank(right, terms);
      return leftRank.compareTo(rightRank);
    });
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    final filteredSuggestions = _filteredSuggestions;
    final showSearch =
        widget.isExpanded &&
        (widget.suggestions.length > _railSearchThreshold ||
            _filterQuery.isNotEmpty);

    return _SectionFrame(
      title: widget.title,
      surfaceMarker: widget.surfaceMarker,
      isExpanded: widget.isExpanded,
      onToggle: widget.onToggle,
      collapsedHint: _collapsedRailHint(widget.title),
      expandIntoPage: widget.title == 'Verb',
      expandedMaxHeight: _railMaxHeightFor(
        title: widget.title,
        suggestionCount: filteredSuggestions.length,
        isFiltered: _filterQuery.trim().isNotEmpty,
      ),
      controls: [
        if (widget.onToggleSuggestionTranslations != null &&
            widget.translationLabel != null)
          _RailTranslationToggle(
            label: widget.translationLabel!,
            isActive: widget.showSuggestionTranslations,
            onPressed: widget.onToggleSuggestionTranslations!,
          ),
        if (showSearch)
          _RailSearchField(
            railTitle: widget.title,
            controller: _filterController,
            resultCount: filteredSuggestions.length,
            totalCount: widget.suggestions.length,
            onChanged: (value) {
              setState(() {
                _filterQuery = value;
              });
              widget.onFilterQueryChanged?.call(value);
            },
            onClear: _filterQuery.isEmpty
                ? null
                : () {
                    _filterController.clear();
                    setState(() {
                      _filterQuery = '';
                    });
                    widget.onFilterQueryChanged?.call('');
                  },
          ),
        if (widget.isExpanded &&
            filteredSuggestions.isNotEmpty &&
            widget.nounNumber != null &&
            widget.onNounNumberChanged != null)
          _NounNumberSwitch(
            railTitle: widget.title,
            value: widget.nounNumber!,
            onChanged: widget.onNounNumberChanged!,
          ),
      ],
      body: !widget.isExpanded
          ? null
          : filteredSuggestions.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                _filterQuery.isEmpty
                    ? widget.unlockHint
                    : 'No ${widget.title.toLowerCase()} choices match "$_filterQuery".',
                style: TextStyle(color: Theme.of(context).disabledColor),
              ),
            )
          : _VirtualizedSuggestionRail(
              railTitle: widget.title,
              suggestions: filteredSuggestions,
              currentSentence: widget.currentSentence,
              displayMode: widget.displayMode,
              showSuggestionTranslations: widget.showSuggestionTranslations,
              translateSuggestion: widget.translateSuggestion,
              renderPreview: widget.renderPreview,
              onMove: widget.onMove,
              onPreviewChanged: widget.onPreviewChanged,
              isFiltered: _filterQuery.trim().isNotEmpty,
            ),
      children: const [],
    );
  }
}

class _VirtualizedSuggestionRail extends StatefulWidget {
  final String railTitle;
  final List<ConfigurationSuggestion> suggestions;
  final String currentSentence;
  final SuggestionDisplayMode displayMode;
  final bool showSuggestionTranslations;
  final String? Function(ConfigurationSuggestion suggestion)
  translateSuggestion;
  final String Function(SentenceState state) renderPreview;
  final ValueChanged<ConfigurationMove> onMove;
  final ValueChanged<ConfigurationState?>? onPreviewChanged;
  final bool isFiltered;

  const _VirtualizedSuggestionRail({
    required this.railTitle,
    required this.suggestions,
    required this.currentSentence,
    required this.displayMode,
    required this.showSuggestionTranslations,
    required this.translateSuggestion,
    required this.renderPreview,
    required this.onMove,
    required this.onPreviewChanged,
    required this.isFiltered,
  });

  @override
  State<_VirtualizedSuggestionRail> createState() =>
      _VirtualizedSuggestionRailState();
}

class _VirtualizedSuggestionRailState
    extends State<_VirtualizedSuggestionRail> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 4.0;
        final tileMaxWidth = _railTileMaxWidthFor(
          title: widget.railTitle,
          displayMode: widget.displayMode,
        );
        final tileHeight = _railTileHeightFor(
          title: widget.railTitle,
          displayMode: widget.displayMode,
          showSuggestionTranslations: widget.showSuggestionTranslations,
        );
        if (widget.suggestions.isEmpty ||
            !constraints.maxWidth.isFinite ||
            constraints.maxWidth <= 0) {
          return const SizedBox.shrink();
        }

        final availableWidth = constraints.maxWidth;
        final columnCount = max(
          1,
          ((availableWidth + spacing) / (tileMaxWidth + spacing)).floor(),
        );
        final rowCount = (widget.suggestions.length / columnCount).ceil();
        final naturalHeight =
            (rowCount * tileHeight) + (max(0, rowCount - 1) * spacing);
        final height = min(
          _railMaxHeightFor(
            title: widget.railTitle,
            suggestionCount: widget.suggestions.length,
            isFiltered: widget.isFiltered,
          ),
          naturalHeight,
        );
        final showScrollbar =
            widget.railTitle == 'Verb' && naturalHeight > height;

        return SizedBox(
          height: height,
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: showScrollbar,
            trackVisibility: showScrollbar,
            child: GridView.builder(
              key: Key('rail-virtual-grid-${widget.railTitle}'),
              controller: _scrollController,
              primary: false,
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: tileMaxWidth,
                mainAxisExtent: tileHeight,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
              ),
              itemCount: widget.suggestions.length,
              itemBuilder: (context, index) => Align(
                alignment: Alignment.centerLeft,
                child: _buttonFor(widget.suggestions[index]),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buttonFor(ConfigurationSuggestion suggestion) {
    final preview = widget.displayMode == SuggestionDisplayMode.change
        ? widget.renderPreview(suggestion.preview.sentenceState)
        : null;

    return _SuggestionButton(
      suggestion: suggestion,
      currentSentence: widget.currentSentence,
      displayMode: widget.displayMode,
      suggestionTranslation: widget.showSuggestionTranslations
          ? widget.translateSuggestion(suggestion)
          : null,
      preview: preview,
      dense: true,
      onPressed: () => widget.onMove(suggestion.move),
      onPreviewChanged: widget.onPreviewChanged,
    );
  }
}

double _railTileMaxWidthFor({
  required String title,
  required SuggestionDisplayMode displayMode,
}) {
  if (title == 'Verb') {
    return displayMode == SuggestionDisplayMode.word ? 82 : 126;
  }

  return displayMode == SuggestionDisplayMode.word ? 112 : 190;
}

double _railTileHeightFor({
  required String title,
  required SuggestionDisplayMode displayMode,
  required bool showSuggestionTranslations,
}) {
  final translationExtra = showSuggestionTranslations ? 16.0 : 0.0;
  if (title == 'Verb') {
    return (displayMode == SuggestionDisplayMode.word ? 52.0 : 56.0) +
        translationExtra;
  }

  return (displayMode == SuggestionDisplayMode.word ? 36.0 : 42.0) +
      translationExtra;
}

class _RailSearchField extends StatelessWidget {
  final String railTitle;
  final TextEditingController controller;
  final int resultCount;
  final int totalCount;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const _RailSearchField({
    required this.railTitle,
    required this.controller,
    required this.resultCount,
    required this.totalCount,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 300,
      height: 34,
      child: TextField(
        key: Key('rail-search-$railTitle'),
        controller: controller,
        onChanged: onChanged,
        style: Theme.of(context).textTheme.bodySmall,
        decoration: InputDecoration(
          isDense: true,
          prefixIcon: const Icon(Icons.search, size: 16),
          suffixIcon: onClear == null
              ? null
              : IconButton(
                  tooltip: 'Clear $railTitle search',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  onPressed: onClear,
                  icon: const Icon(Icons.close),
                ),
          suffixText: '$resultCount/$totalCount',
          hintText: 'filter $railTitle',
          helperText: totalCount == resultCount ? null : 'filtered',
          helperStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
            height: 0.8,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 7,
          ),
        ),
      ),
    );
  }
}

bool _suggestionMatchesTerms(
  ConfigurationSuggestion suggestion,
  List<String> terms,
) {
  return _suggestionSearchRank(suggestion, terms) < 1000;
}

int _suggestionSearchRank(
  ConfigurationSuggestion suggestion,
  List<String> terms,
) {
  final text = _suggestionSearchText(suggestion).toLowerCase();
  final tokens = text
      .split(RegExp(r'[^a-z0-9]+'))
      .where((token) => token.isNotEmpty)
      .toList();
  var rank = 0;
  for (final term in terms) {
    if (tokens.any((token) => token == term)) {
      continue;
    }
    if (tokens.any((token) => token.startsWith(term))) {
      rank += 1;
      continue;
    }
    return 1000;
  }
  return rank;
}

String _suggestionSearchText(ConfigurationSuggestion suggestion) {
  final parts = <String>[suggestion.slot.name, suggestion.label];
  final move = suggestion.move;

  if (move is SetAction) {
    final action = move.action;
    parts.add(action.infinitive);
    for (final influence in predicateInfluencesFor(action)) {
      parts
        ..add(influence.key)
        ..add(influence.label)
        ..add(influence.tooltip);
    }
  }

  return parts.join(' ');
}

String _suggestionsSignatureFor(List<ConfigurationSuggestion> suggestions) {
  final buffer = StringBuffer(suggestions.length);
  for (final suggestion in suggestions) {
    buffer
      ..write('|')
      ..write(suggestion.label)
      ..write(suggestion.isSelected ? '*' : '');
  }
  return buffer.toString();
}

double _railMaxHeightFor({
  required String title,
  required int suggestionCount,
  bool isFiltered = false,
}) {
  if (title == 'Verb') {
    if (isFiltered) {
      if (suggestionCount <= 8) {
        return _smallRailMaxHeight;
      }
      if (suggestionCount <= 18) {
        return _mediumRailMaxHeight;
      }
    }
    return _verbRailMaxHeight;
  }

  if (suggestionCount <= 8) {
    return _smallRailMaxHeight;
  }

  if (suggestionCount <= 18) {
    return _mediumRailMaxHeight;
  }

  return _largeRailMaxHeight;
}

int _filteredSuggestionCount(
  List<ConfigurationSuggestion> suggestions, {
  required String query,
}) {
  final trimmedQuery = query.trim().toLowerCase();
  if (trimmedQuery.isEmpty) {
    return suggestions.length;
  }

  final terms = trimmedQuery.split(RegExp(r'\s+'));
  return suggestions
      .where((suggestion) => _suggestionMatchesTerms(suggestion, terms))
      .length;
}

String? _railTranslationLabel(ConfigurationCompassSlot slot) {
  if (slot == ConfigurationCompassSlot.action) {
    return 'verbs';
  }
  if (_objectTranslationSlots.contains(slot)) {
    return 'objects';
  }
  if (_personTranslationSlots.contains(slot)) {
    return switch (slot) {
      ConfigurationCompassSlot.recipient => 'recipients',
      ConfigurationCompassSlot.addressee => 'addressees',
      ConfigurationCompassSlot.companion => 'companions',
      ConfigurationCompassSlot.beneficiary => 'beneficiaries',
      ConfigurationCompassSlot.source => 'sources',
      _ => 'people',
    };
  }
  if (_predicateNounTranslationSlots.contains(slot)) {
    return switch (slot) {
      ConfigurationCompassSlot.instrument => 'instruments',
      ConfigurationCompassSlot.destination => 'destinations',
      ConfigurationCompassSlot.topic => 'topics',
      ConfigurationCompassSlot.purpose => 'purposes',
      _ => 'nouns',
    };
  }
  if (_locationTranslationSlots.contains(slot)) {
    return 'location';
  }
  if (_phraseTranslationSlots.contains(slot)) {
    return switch (slot) {
      ConfigurationCompassSlot.timePhrase => 'time',
      ConfigurationCompassSlot.frequencyPhrase => 'frequency',
      ConfigurationCompassSlot.mannerPhrase => 'manner',
      ConfigurationCompassSlot.rightParticle => 'particles',
      _ => 'phrases',
    };
  }
  if (_rightActionTranslationSlots.contains(slot)) {
    return 'right actions';
  }

  return null;
}
