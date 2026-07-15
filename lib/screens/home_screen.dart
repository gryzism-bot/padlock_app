import 'dart:math';

import 'package:flutter/material.dart';
import 'package:padlock_app/data/predicate/fixed_object_frames.dart';
import 'package:padlock_app/data/predicate/predicate_paths.dart';
import 'package:padlock_app/data/predicate/right_action_frames.dart';
import 'package:padlock_app/data/predicate/semantic_icons.dart';
import 'package:padlock_app/data/predicate/verb_influence.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/third_person/animals.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/engine/configuration_compass.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/engine/crude_translation_engine.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

part 'widgets/control_cards.dart';
part 'widgets/noun_rail_state.dart';
part 'widgets/rail_policy.dart';
part 'widgets/suggestion_chips.dart';

enum SuggestionDisplayMode { sentence, change, word }

enum HeaderPreviewMode { clicked, hover }

enum PreviewCacheMode { unbounded, bounded }

const _stickyHeaderHeight = 120.0;
const _stickyFooterHeight = 28.0;
const _diagnosticsDockReserveHeight = 224.0;
const _moveTraceLimit = 10;
const _suggestionLimit = 96;
const _actionSuggestionLimit = 192;
const _smallRailMaxHeight = 92.0;
const _mediumRailMaxHeight = 132.0;
const _largeRailMaxHeight = 176.0;
const _verbRailMaxHeight = 214.0;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ConfigurationEngine lock = const ConfigurationEngine();
  final ConfigurationCompass compass = ConfigurationCompass(
    predicatePathMode: PredicatePathMode.authoredTracks,
  );
  final GrammarEngine grammar = GrammarEngine();
  final CrudeTranslationEngine translator = const CrudeTranslationEngine();

  late ConfigurationState configuration;
  late final _SentencePreviewCache previewCache;
  SuggestionDisplayMode? suggestionDisplayMode;
  HeaderPreviewMode? headerPreviewMode;
  PreviewCacheMode? previewCacheMode;
  bool showTranslation = false;
  final ValueNotifier<ConfigurationState?> hoveredConfiguration = ValueNotifier(
    null,
  );
  Map<ConfigurationCompassSlot, Number> nounNumbers = const {};
  List<_MoveTraceEntry> moveTrace = const [];
  Set<ConfigurationCompassSlot> expandedRails = const {};
  int previewCacheEntryCount = 0;

  @override
  void initState() {
    super.initState();
    configuration = ConfigurationState.initial();
    previewCache = _SentencePreviewCache(grammar, maxEntries: null);
  }

  void _move(ConfigurationMove move) {
    final stopwatch = Stopwatch()..start();

    setState(() {
      final previousConfiguration = configuration;
      final nextConfiguration = lock.applyMove(configuration, move);
      configuration = nextConfiguration;
      if (move is SetAction) {
        expandedRails = const {};
      }
      if (move case SetObject(:final object)) {
        nounNumbers = _updatedNounNumbers(
          nounNumbers,
          ConfigurationCompassSlot.object,
          object,
        );
      }
      if (move case SetAddressee(:final addressee)) {
        nounNumbers = _updatedNounNumbers(
          nounNumbers,
          ConfigurationCompassSlot.addressee,
          addressee,
        );
      }
      nounNumbers = _updatedNounNumbersFromMove(nounNumbers, move);
      if (move is SetAction) {
        nounNumbers = _syncNounNumbersWithState(
          nounNumbers,
          nextConfiguration.sentenceState,
        );
      }
      hoveredConfiguration.value = null;
      final nextSentence = grammar
          .generate(nextConfiguration.sentenceState)
          .text;
      stopwatch.stop();
      moveTrace = _appendMoveTrace(
        moveTrace,
        _MoveTraceEntry.fromMove(
          move: move,
          sentence: nextSentence,
          wasBlocked: nextConfiguration.messages.any(
            (message) => message.kind == ConfigurationMessageKind.blocked,
          ),
          keptSentence:
              previousConfiguration.sentenceState.summary ==
              nextConfiguration.sentenceState.summary,
          elapsed: stopwatch.elapsed,
        ),
      );
    });
  }

  void _reset() {
    setState(() {
      configuration = ConfigurationState.initial();
      nounNumbers = const {};
      hoveredConfiguration.value = null;
      moveTrace = const [];
      expandedRails = const {};
    });
  }

  void _setPreviewCacheMode(PreviewCacheMode mode) {
    setState(() {
      previewCacheMode = mode;
      previewCache.setMaxEntries(_cacheEntryLimitForMode(mode));
      previewCacheEntryCount = previewCache.size;
    });
  }

  void _clearPreviewCache() {
    setState(() {
      previewCache.clear();
      previewCacheEntryCount = 0;
    });
  }

  void _shuffle() {
    final stopwatch = Stopwatch()..start();
    final random = Random();
    var state = ConfigurationState.initial();

    for (var step = 0; step < 8; step++) {
      final suggestions = [
        for (final slot in ConfigurationCompassSlot.values)
          ...compass
              .suggestionsFor(state, slot, limit: 0)
              .where((suggestion) => !suggestion.isSelected),
      ];

      if (suggestions.isEmpty) {
        break;
      }

      state = suggestions[random.nextInt(suggestions.length)].preview;
    }

    setState(() {
      configuration = state;
      nounNumbers = _syncNounNumbersWithState(nounNumbers, state.sentenceState);
      hoveredConfiguration.value = null;
      final sentence = grammar.generate(state.sentenceState).text;
      stopwatch.stop();
      moveTrace = [
        _MoveTraceEntry.random(sentence, elapsed: stopwatch.elapsed),
      ];
      expandedRails = const {};
    });
  }

  void _toggleRail(ConfigurationCompassSlot slot) {
    setState(() {
      hoveredConfiguration.value = null;
      if (expandedRails.contains(slot)) {
        expandedRails = {...expandedRails}..remove(slot);
      } else {
        expandedRails = {...expandedRails, slot};
      }
    });
  }

  void _setHoveredConfiguration(ConfigurationState? preview) {
    if (hoveredConfiguration.value == preview) {
      return;
    }

    hoveredConfiguration.value = preview;
  }

  List<ConfigurationSuggestion> _suggestionsForSlot(
    ConfigurationCompass compass,
    ConfigurationCompassSlot slot,
  ) {
    final suggestions = compass.suggestionsFor(
      configuration,
      slot,
      limit: _suggestionLimitForSlot(slot),
    );

    if (!_slotHasNounNumberSwitch(slot)) {
      return suggestions;
    }

    final targetNumber = _nounNumberForSlot(slot);

    return suggestions
        .where((suggestion) {
          final nounPhrase = _nounPhraseForSlot(
            suggestion.preview.sentenceState,
            slot,
          );
          return nounPhrase == null ||
              nounPhrase.number == targetNumber ||
              suggestion.isSelected;
        })
        .take(_suggestionLimit)
        .toList();
  }

  int _suggestionLimitForSlot(ConfigurationCompassSlot slot) {
    return switch (slot) {
      ConfigurationCompassSlot.action => _actionSuggestionLimit,
      _ when _slotHasNounNumberSwitch(slot) => 0,
      _ => _suggestionLimit,
    };
  }

  Number? _nounNumberForSlot(ConfigurationCompassSlot slot) {
    if (!_slotHasNounNumberSwitch(slot)) {
      return null;
    }

    return nounNumbers[slot] ?? Number.singular;
  }

  void _changeNounNumber(
    ConfigurationCompass compass,
    ConfigurationCompassSlot slot,
    Number number,
  ) {
    final stopwatch = Stopwatch()..start();

    setState(() {
      switch (slot) {
        case ConfigurationCompassSlot.object:
        case ConfigurationCompassSlot.objectComplement:
        case ConfigurationCompassSlot.addressee:
        case ConfigurationCompassSlot.recipient:
        case ConfigurationCompassSlot.companion:
        case ConfigurationCompassSlot.destination:
        case ConfigurationCompassSlot.passiveAgentNoun:
        case ConfigurationCompassSlot.complement:
          break;
        default:
          return;
      }
      nounNumbers = {...nounNumbers, slot: number};

      hoveredConfiguration.value = null;

      final nounPhrase = _nounPhraseForSlot(configuration.sentenceState, slot);
      if (nounPhrase == null || nounPhrase.number == number) {
        return;
      }

      final variant = _nounVariant(
        _nounChoicesForConfigurationSlot(compass, configuration, slot),
        nounPhrase,
        number,
      );
      if (variant == null) {
        return;
      }

      configuration = lock.applyMove(
        configuration,
        _setNounPhraseMove(slot, _carrySafeNounModifiers(nounPhrase, variant)),
      );
      final sentence = grammar.generate(configuration.sentenceState).text;
      stopwatch.stop();
      moveTrace = _appendMoveTrace(
        moveTrace,
        _MoveTraceEntry(
          label: '${_slotTraceLabel(slot)} number -> ${number.name}',
          sentence: sentence,
          status: _MoveTraceStatus.accepted,
          elapsed: stopwatch.elapsed,
        ),
      );
    });
  }

  @override
  void dispose() {
    hoveredConfiguration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayMode = suggestionDisplayMode ?? SuggestionDisplayMode.change;
    final previewMode = headerPreviewMode ?? HeaderPreviewMode.clicked;
    final cacheMode = previewCacheMode ?? PreviewCacheMode.unbounded;
    previewCache.setMaxEntries(_cacheEntryLimitForMode(cacheMode));
    final sentenceText = previewCache.render(configuration.sentenceState);
    _syncPreviewCacheSizeAfterFrame();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Padlock Guided Mode'),
        actions: [
          _AppBarTools(
            previewMode: previewMode,
            onPreviewModeChanged: (mode) {
              setState(() {
                headerPreviewMode = mode;
                hoveredConfiguration.value = null;
              });
            },
            displayMode: displayMode,
            onDisplayModeChanged: (mode) {
              setState(() {
                suggestionDisplayMode = mode;
              });
            },
          ),
          IconButton(
            tooltip: showTranslation
                ? 'Show English sentence'
                : 'Translate sentence',
            onPressed: () {
              setState(() {
                showTranslation = !showTranslation;
              });
            },
            icon: Icon(showTranslation ? Icons.translate : Icons.g_translate),
          ),
          IconButton(
            tooltip: 'Reset',
            onPressed: _reset,
            icon: const Icon(Icons.restart_alt),
          ),
          IconButton(
            tooltip: 'Random sentence',
            onPressed: _shuffle,
            icon: const Icon(Icons.shuffle),
          ),
          const SizedBox(width: 36),
        ],
      ),
      bottomNavigationBar: _BottomDock(
        messages: configuration.messages,
        moveTrace: moveTrace,
        cacheMode: cacheMode,
        cacheEntryCount: previewCacheEntryCount,
        cacheEntryLimit: previewCache.maxEntries,
        onCacheModeChanged: _setPreviewCacheMode,
        onClearCache: _clearPreviewCache,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              key: const Key('main-scroll'),
              padding: const EdgeInsets.fromLTRB(
                12,
                _stickyHeaderHeight + 8,
                12,
                12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ControlDeck(
                    currentSentence: sentenceText,
                    modalSuggestions: compass.suggestionsFor(
                      configuration,
                      ConfigurationCompassSlot.modal,
                      limit: 9,
                    ),
                    passiveFocusSuggestions: compass.suggestionsFor(
                      configuration,
                      ConfigurationCompassSlot.passiveFocus,
                      limit: 3,
                    ),
                    passiveAgentSuggestions: compass.suggestionsFor(
                      configuration,
                      ConfigurationCompassSlot.passiveAgent,
                      limit: 2,
                    ),
                    configuration: configuration,
                    onMove: _move,
                    onPreviewChanged: previewMode == HeaderPreviewMode.hover
                        ? _setHoveredConfiguration
                        : null,
                  ),
                  const SizedBox(height: 8),
                  _CoreParticipantSurfaceMap(
                    configuration: configuration,
                    expandedRails: expandedRails,
                    onToggleRail: _toggleRail,
                  ),
                  const SizedBox(height: 8),
                  for (final section in _visibleSlotSections(compass)) ...[
                    _CompassSlotSection(
                      title: section.title,
                      unlockHint: section.unlockHint,
                      isExpanded: section.isExpanded,
                      onToggle: section.canToggle
                          ? () => _toggleRail(section.slot)
                          : null,
                      currentSentence: sentenceText,
                      displayMode: displayMode,
                      suggestions: section.suggestions,
                      nounNumber: _nounNumberForSlot(section.slot),
                      onNounNumberChanged:
                          _nounNumberForSlot(section.slot) == null
                          ? null
                          : (number) => _changeNounNumber(
                              compass,
                              section.slot,
                              number,
                            ),
                      renderPreview: previewCache.render,
                      onMove: _move,
                      onPreviewChanged: previewMode == HeaderPreviewMode.hover
                          ? _setHoveredConfiguration
                          : null,
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<ConfigurationState?>(
                valueListenable: hoveredConfiguration,
                builder: (context, hovered, child) {
                  final headerConfiguration =
                      previewMode == HeaderPreviewMode.hover && hovered != null
                      ? hovered
                      : configuration;
                  final headerSentence = previewCache.render(
                    headerConfiguration.sentenceState,
                  );
                  final displayedHeaderSentence = showTranslation
                      ? translator.translateSentence(
                          renderedSentence: headerSentence,
                          state: headerConfiguration.sentenceState,
                        )
                      : headerSentence;

                  return _StickySentenceHeader(
                    child: _SentencePanel(
                      sentence: headerSentence,
                      translation: showTranslation
                          ? displayedHeaderSentence
                          : null,
                      summary: headerConfiguration.sentenceState.summary,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_VisibleCompassSlot> _visibleSlotSections(ConfigurationCompass compass) {
    return _visibleRailSections(
      configuration: configuration,
      expandedRails: expandedRails,
      suggestionsForSlot: (slot) => _suggestionsForSlot(compass, slot),
    );
  }

  void _syncPreviewCacheSizeAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || previewCacheEntryCount == previewCache.size) {
        return;
      }

      setState(() {
        previewCacheEntryCount = previewCache.size;
      });
    });
  }
}

int? _cacheEntryLimitForMode(PreviewCacheMode mode) {
  return switch (mode) {
    PreviewCacheMode.unbounded => null,
    PreviewCacheMode.bounded => _SentencePreviewCache.defaultMaxEntries,
  };
}

class _SentencePreviewCache {
  static const defaultMaxEntries = 500;

  final GrammarEngine grammar;
  int? _maxEntries;
  final Map<String, String> _renderedBySummary = {};

  _SentencePreviewCache(this.grammar, {int? maxEntries = defaultMaxEntries})
    : assert(maxEntries == null || maxEntries > 0),
      _maxEntries = maxEntries;

  int get size => _renderedBySummary.length;

  int? get maxEntries => _maxEntries;

  void clear() {
    _renderedBySummary.clear();
  }

  void setMaxEntries(int? maxEntries) {
    assert(maxEntries == null || maxEntries > 0);
    _maxEntries = maxEntries;
    _trim();
  }

  String render(SentenceState state) {
    final key = state.summary;
    final cached = _renderedBySummary.remove(key);
    if (cached != null) {
      _renderedBySummary[key] = cached;
      return cached;
    }

    final rendered = grammar.generate(state).text;
    _renderedBySummary[key] = rendered;
    _trim();

    return rendered;
  }

  void _trim() {
    final limit = _maxEntries;
    while (limit != null && _renderedBySummary.length > limit) {
      _renderedBySummary.remove(_renderedBySummary.keys.first);
    }
  }
}

class _CoreParticipantSurfaceMap extends StatelessWidget {
  final ConfigurationState configuration;
  final Set<ConfigurationCompassSlot> expandedRails;
  final ValueChanged<ConfigurationCompassSlot> onToggleRail;

  const _CoreParticipantSurfaceMap({
    required this.configuration,
    required this.expandedRails,
    required this.onToggleRail,
  });

  @override
  Widget build(BuildContext context) {
    final participantDoors = _coreParticipantDoors(configuration);

    return _SectionFrame(
      title: 'Core participant surface',
      children: [
        for (final door in participantDoors)
          _ParticipantDoorChip(
            door: door,
            isExpanded: door.slot != null && expandedRails.contains(door.slot),
            onPressed:
                door.slot == null ||
                    door.status == _ParticipantDoorStatus.asleep
                ? null
                : () => onToggleRail(door.slot!),
          ),
      ],
    );
  }
}

class _ParticipantDoor {
  final String label;
  final String value;
  final _ParticipantDoorStatus status;
  final ConfigurationCompassSlot? slot;

  const _ParticipantDoor({
    required this.label,
    required this.value,
    required this.status,
    this.slot,
  });
}

enum _ParticipantDoorStatus { asleep, awake, filled }

class _ParticipantDoorChip extends StatelessWidget {
  final _ParticipantDoor door;
  final bool isExpanded;
  final VoidCallback? onPressed;

  const _ParticipantDoorChip({
    required this.door,
    required this.isExpanded,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusLabel = switch (door.status) {
      _ParticipantDoorStatus.asleep => 'asleep',
      _ParticipantDoorStatus.awake => isExpanded ? 'open' : 'awake',
      _ParticipantDoorStatus.filled => isExpanded ? 'open' : 'filled',
    };
    final statusColor = switch (door.status) {
      _ParticipantDoorStatus.asleep => colors.onSurfaceVariant,
      _ParticipantDoorStatus.awake => colors.tertiary,
      _ParticipantDoorStatus.filled => colors.primary,
    };

    return Tooltip(
      message: onPressed == null
          ? '${door.label}: ${door.value}'
          : '${door.label}: ${door.value}. Click to ${isExpanded ? 'close' : 'open'} rail.',
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          minimumSize: const Size(0, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: door.status == _ParticipantDoorStatus.asleep
              ? colors.onSurfaceVariant
              : null,
          side: BorderSide(
            color: isExpanded ? colors.primary : colors.outlineVariant,
            width: isExpanded ? 2 : 1,
          ),
        ),
        onPressed: onPressed,
        icon: Icon(
          switch (door.status) {
            _ParticipantDoorStatus.asleep => Icons.lock_outline,
            _ParticipantDoorStatus.awake => Icons.meeting_room_outlined,
            _ParticipantDoorStatus.filled => Icons.radio_button_checked,
          },
          size: 16,
          color: statusColor,
        ),
        label: Text('${door.label}: ${door.value} ($statusLabel)'),
      ),
    );
  }
}

class _VisibleCompassSlot {
  final ConfigurationCompassSlot slot;
  final List<ConfigurationSuggestion> suggestions;
  final String title;
  final String unlockHint;
  final bool isExpanded;
  final bool canToggle;

  const _VisibleCompassSlot(
    this.slot,
    this.suggestions, {
    required this.title,
    required this.unlockHint,
    required this.isExpanded,
    required this.canToggle,
  });
}

class _AppBarTools extends StatelessWidget {
  final HeaderPreviewMode previewMode;
  final ValueChanged<HeaderPreviewMode> onPreviewModeChanged;
  final SuggestionDisplayMode displayMode;
  final ValueChanged<SuggestionDisplayMode> onDisplayModeChanged;

  const _AppBarTools({
    required this.previewMode,
    required this.onPreviewModeChanged,
    required this.displayMode,
    required this.onDisplayModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return SizedBox(
      width: min(width * 0.58, 760),
      child: SingleChildScrollView(
        key: const Key('app-bar-tools-scroll'),
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
          ],
        ),
      ),
    );
  }
}

class _BottomDock extends StatelessWidget {
  final List<ConfigurationMessage> messages;
  final List<_MoveTraceEntry> moveTrace;
  final PreviewCacheMode cacheMode;
  final ValueChanged<PreviewCacheMode> onCacheModeChanged;
  final VoidCallback onClearCache;
  final int cacheEntryCount;
  final int? cacheEntryLimit;

  const _BottomDock({
    required this.messages,
    required this.moveTrace,
    required this.cacheMode,
    required this.onCacheModeChanged,
    required this.onClearCache,
    required this.cacheEntryCount,
    required this.cacheEntryLimit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: colors.surface.withValues(alpha: 0.96),
          elevation: 2,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: _diagnosticsDockReserveHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final hasLanguageAlerts = messages.isNotEmpty;
                  final hasMoveTrace = moveTrace.isNotEmpty;
                  final compact = constraints.maxWidth < 1100;
                  final cacheStrip = _PreviewCacheDiagnosticsPanel(
                    mode: cacheMode,
                    entryCount: cacheEntryCount,
                    entryLimit: cacheEntryLimit,
                    onModeChanged: onCacheModeChanged,
                    onClear: onClearCache,
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: min(constraints.maxWidth, 560),
                            child: cacheStrip,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (hasLanguageAlerts) ...[
                                  SizedBox(
                                    height: 142,
                                    child: _GuidedMessages(messages: messages),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                if (hasMoveTrace) ...[
                                  SizedBox(
                                    height: 86,
                                    child: _MoveTracePanel(entries: moveTrace),
                                  ),
                                ],
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(width: 560, child: cacheStrip),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (hasLanguageAlerts) ...[
                              Expanded(
                                flex: 6,
                                child: _GuidedMessages(messages: messages),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (hasMoveTrace) ...[
                              Expanded(
                                flex: 5,
                                child: _MoveTracePanel(entries: moveTrace),
                              ),
                            ],
                            if (!hasLanguageAlerts && !hasMoveTrace)
                              const Spacer(),
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
  }
}

enum _MoveTraceStatus { accepted, blocked, random }

class _MoveTraceEntry {
  final String label;
  final String sentence;
  final _MoveTraceStatus status;
  final Duration elapsed;

  const _MoveTraceEntry({
    required this.label,
    required this.sentence,
    required this.status,
    required this.elapsed,
  });

  factory _MoveTraceEntry.random(String sentence, {required Duration elapsed}) {
    return _MoveTraceEntry(
      label: 'random sentence',
      sentence: sentence,
      status: _MoveTraceStatus.random,
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
    SetDestination(:final destination) =>
      'destination -> ${_nounTraceText(destination)}',
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
    SetPlacePhrase(:final placePhrase) =>
      'place phrase -> ${placePhrase?.render() ?? 'none'}',
    SetFrequencyPhrase(:final frequencyPhrase) =>
      'frequency phrase -> ${frequencyPhrase?.text ?? 'none'}',
    SetMannerPhrase(:final mannerPhrase) =>
      'manner phrase -> ${mannerPhrase?.text ?? 'none'}',
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
    NounPhraseTarget.destination => 'destination',
    NounPhraseTarget.complement => 'complement',
  };
}

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
            'Logos Dynamics 2026',
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

  const _SentencePanel({
    required this.sentence,
    required this.translation,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            const SizedBox(height: 4),
            SelectableText(
              summary,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlDeck extends StatelessWidget {
  final String currentSentence;
  final List<ConfigurationSuggestion> modalSuggestions;
  final List<ConfigurationSuggestion> passiveFocusSuggestions;
  final List<ConfigurationSuggestion> passiveAgentSuggestions;
  final ConfigurationState configuration;
  final ValueChanged<ConfigurationMove> onMove;
  final ValueChanged<ConfigurationState?>? onPreviewChanged;

  const _ControlDeck({
    required this.currentSentence,
    required this.modalSuggestions,
    required this.passiveFocusSuggestions,
    required this.passiveAgentSuggestions,
    required this.configuration,
    required this.onMove,
    required this.onPreviewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final useSingleRowControls = width >= 1800;
        final cardWidth = useSingleRowControls
            ? (width - 40) / 6
            : width >= 1040
            ? (width - 20) / 3
            : width >= 760
            ? (width - 10) / 2
            : width;
        final unitWidth = useSingleRowControls
            ? (width - 40) / 10.35
            : cardWidth;
        final tenseWidth = useSingleRowControls ? unitWidth * 1.55 : cardWidth;
        final subjectWidth = useSingleRowControls
            ? unitWidth * 3.15
            : cardWidth;
        final modalWidth = useSingleRowControls ? unitWidth * 2.1 : cardWidth;
        final voiceWidth = useSingleRowControls ? unitWidth * 1.9 : cardWidth;
        final polarityWidth = useSingleRowControls
            ? unitWidth * 0.65
            : cardWidth;
        final formWidth = useSingleRowControls ? unitWidth : cardWidth;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SizedBox(
              width: tenseWidth,
              child: _TenseAspectSection(
                tense: configuration.sentenceState.tense,
                aspect: configuration.sentenceState.aspect,
                onMove: onMove,
              ),
            ),
            SizedBox(
              width: subjectWidth,
              child: _PronounSection(
                agent: configuration.sentenceState.agent,
                onMove: onMove,
              ),
            ),
            SizedBox(
              width: modalWidth,
              child: _ModalSection(
                currentSentence: currentSentence,
                modalSuggestions: modalSuggestions,
                onMove: onMove,
                onPreviewChanged: onPreviewChanged,
              ),
            ),
            SizedBox(
              width: voiceWidth,
              child: _VoiceSection(
                currentSentence: currentSentence,
                voice: configuration.sentenceState.voice,
                passiveFocusSuggestions: passiveFocusSuggestions,
                passiveAgentSuggestions: passiveAgentSuggestions,
                onMove: onMove,
                onPreviewChanged: onPreviewChanged,
              ),
            ),
            SizedBox(
              width: polarityWidth,
              child: _PolaritySection(
                polarity: configuration.sentenceState.polarity,
                onMove: onMove,
              ),
            ),
            SizedBox(
              width: formWidth,
              child: _SentenceFormSection(
                sentenceForm: configuration.sentenceState.sentenceForm,
                onMove: onMove,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PolaritySection extends StatelessWidget {
  final Polarity polarity;
  final ValueChanged<ConfigurationMove> onMove;

  const _PolaritySection({required this.polarity, required this.onMove});

  @override
  Widget build(BuildContext context) {
    return _ControlCard(
      title: 'Polarity',
      children: [
        _MoveButton(
          label: 'negative',
          selected: polarity == Polarity.negative,
          onPressed: () => onMove(const SetPolarity(Polarity.negative)),
        ),
        _MoveButton(
          label: 'positive',
          selected: polarity == Polarity.positive,
          onPressed: () => onMove(const SetPolarity(Polarity.positive)),
        ),
      ],
    );
  }
}

class _SentenceFormSection extends StatelessWidget {
  final SentenceForm sentenceForm;
  final ValueChanged<ConfigurationMove> onMove;

  const _SentenceFormSection({
    required this.sentenceForm,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return _ControlCard(
      title: 'Form',
      children: [
        _MoveButton(
          label: 'statement',
          selected: sentenceForm == SentenceForm.statement,
          onPressed: () =>
              onMove(const SetSentenceForm(SentenceForm.statement)),
        ),
        _MoveButton(
          label: 'question',
          selected: sentenceForm == SentenceForm.question,
          onPressed: () => onMove(const SetSentenceForm(SentenceForm.question)),
        ),
        _MoveButton(
          label: 'exclamation',
          selected: sentenceForm == SentenceForm.exclamation,
          onPressed: () =>
              onMove(const SetSentenceForm(SentenceForm.exclamation)),
        ),
        _MoveButton(
          label: 'imperative',
          selected: sentenceForm == SentenceForm.imperative,
          onPressed: () =>
              onMove(const SetSentenceForm(SentenceForm.imperative)),
        ),
      ],
    );
  }
}

class _PronounSection extends StatelessWidget {
  final NounPhrase? agent;
  final ValueChanged<ConfigurationMove> onMove;

  const _PronounSection({required this.agent, required this.onMove});

  @override
  Widget build(BuildContext context) {
    return _ControlCard(
      title: 'Subject',
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final laneWidth = constraints.maxWidth >= 360
                ? (constraints.maxWidth - 6) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                SizedBox(
                  width: laneWidth,
                  child: _CompactChipCluster(
                    label: 'singular',
                    children: [
                      _MoveButton(
                        label: 'I',
                        selected: _sameNounPhrase(agent, i),
                        onPressed: () => onMove(const SetAgent(i)),
                      ),
                      _MoveButton(
                        label: 'you',
                        selected: _sameNounPhrase(agent, you),
                        onPressed: () => onMove(const SetAgent(you)),
                      ),
                      _InlineExpandableChipCluster(
                        expandedLabel: '3rd person singular nouns',
                        expandedChildren: [
                          _MoveButton(
                            label: 'cat',
                            selected: _sameNounPhrase(
                              agent,
                              cat.toNounPhrase(Number.singular),
                            ),
                            onPressed: () => onMove(
                              SetAgent(cat.toNounPhrase(Number.singular)),
                            ),
                          ),
                          _MoveButton(
                            label: 'dog',
                            selected: _sameNounPhrase(
                              agent,
                              dog.toNounPhrase(Number.singular),
                            ),
                            onPressed: () => onMove(
                              SetAgent(dog.toNounPhrase(Number.singular)),
                            ),
                          ),
                          _MoveButton(
                            label: 'John',
                            selected: _sameNounPhrase(
                              agent,
                              john.toNounPhrase(Number.singular),
                            ),
                            onPressed: () => onMove(
                              SetAgent(john.toNounPhrase(Number.singular)),
                            ),
                          ),
                          _MoveButton(
                            label: 'Mary',
                            selected: _sameNounPhrase(
                              agent,
                              mary.toNounPhrase(Number.singular),
                            ),
                            onPressed: () => onMove(
                              SetAgent(mary.toNounPhrase(Number.singular)),
                            ),
                          ),
                          _MoveButton(
                            label: 'a friend',
                            selected: _sameNounPhrase(
                              agent,
                              friend.toNounPhrase(
                                Number.singular,
                                determiner: aDeterminer,
                              ),
                            ),
                            onPressed: () => onMove(
                              SetAgent(
                                friend.toNounPhrase(
                                  Number.singular,
                                  determiner: aDeterminer,
                                ),
                              ),
                            ),
                          ),
                          _MoveButton(
                            label: 'my friend',
                            selected: _sameNounPhrase(
                              agent,
                              friend.toNounPhrase(
                                Number.singular,
                                determiner: myDeterminer,
                              ),
                            ),
                            onPressed: () => onMove(
                              SetAgent(
                                friend.toNounPhrase(
                                  Number.singular,
                                  determiner: myDeterminer,
                                ),
                              ),
                            ),
                          ),
                          _MoveButton(
                            label: 'our friend',
                            selected: _sameNounPhrase(
                              agent,
                              friend.toNounPhrase(
                                Number.singular,
                                determiner: ourDeterminer,
                              ),
                            ),
                            onPressed: () => onMove(
                              SetAgent(
                                friend.toNounPhrase(
                                  Number.singular,
                                  determiner: ourDeterminer,
                                ),
                              ),
                            ),
                          ),
                          _MoveButton(
                            label: 'that enemy',
                            selected: _sameNounPhrase(
                              agent,
                              enemy.toNounPhrase(
                                Number.singular,
                                determiner: thatDeterminer,
                              ),
                            ),
                            onPressed: () => onMove(
                              SetAgent(
                                enemy.toNounPhrase(
                                  Number.singular,
                                  determiner: thatDeterminer,
                                ),
                              ),
                            ),
                          ),
                          _MoveButton(
                            label: 'someone',
                            selected: _sameNounPhrase(agent, someone),
                            onPressed: () => onMove(const SetAgent(someone)),
                          ),
                          _MoveButton(
                            label: 'anyone',
                            selected: _sameNounPhrase(agent, anyone),
                            onPressed: () => onMove(const SetAgent(anyone)),
                          ),
                          _MoveButton(
                            label: 'nobody',
                            selected: _sameNounPhrase(agent, nobody),
                            onPressed: () => onMove(const SetAgent(nobody)),
                          ),
                          _MoveButton(
                            label: 'everyone',
                            selected: _sameNounPhrase(agent, everyone),
                            onPressed: () => onMove(const SetAgent(everyone)),
                          ),
                        ],
                        children: [
                          _MoveButton(
                            label: 'he',
                            selected: _sameNounPhrase(agent, he),
                            onPressed: () => onMove(const SetAgent(he)),
                          ),
                          _MoveButton(
                            label: 'she',
                            selected: _sameNounPhrase(agent, she),
                            onPressed: () => onMove(const SetAgent(she)),
                          ),
                          _MoveButton(
                            label: 'it',
                            selected: _sameNounPhrase(agent, it),
                            onPressed: () => onMove(const SetAgent(it)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: laneWidth,
                  child: _CompactChipCluster(
                    label: 'plural',
                    children: [
                      _MoveButton(
                        label: 'we',
                        selected: _sameNounPhrase(agent, we),
                        onPressed: () => onMove(const SetAgent(we)),
                      ),
                      _MoveButton(
                        label: 'you',
                        selected: _sameNounPhrase(agent, you),
                        onPressed: () => onMove(const SetAgent(you)),
                      ),
                      _InlineExpandableChipCluster(
                        expandedLabel: '3rd person plural nouns',
                        expandedChildren: [
                          _MoveButton(
                            label: 'cats',
                            selected: _sameNounPhrase(
                              agent,
                              cat.toNounPhrase(Number.plural),
                            ),
                            onPressed: () => onMove(
                              SetAgent(cat.toNounPhrase(Number.plural)),
                            ),
                          ),
                          _MoveButton(
                            label: 'dogs',
                            selected: _sameNounPhrase(
                              agent,
                              dog.toNounPhrase(Number.plural),
                            ),
                            onPressed: () => onMove(
                              SetAgent(dog.toNounPhrase(Number.plural)),
                            ),
                          ),
                          _MoveButton(
                            label: 'friends',
                            selected: _sameNounPhrase(
                              agent,
                              friend.toNounPhrase(Number.plural),
                            ),
                            onPressed: () => onMove(
                              SetAgent(friend.toNounPhrase(Number.plural)),
                            ),
                          ),
                          _MoveButton(
                            label: 'enemies',
                            selected: _sameNounPhrase(
                              agent,
                              enemy.toNounPhrase(Number.plural),
                            ),
                            onPressed: () => onMove(
                              SetAgent(enemy.toNounPhrase(Number.plural)),
                            ),
                          ),
                          _MoveButton(
                            label: 'people',
                            selected: _sameNounPhrase(
                              agent,
                              person.toNounPhrase(Number.plural),
                            ),
                            onPressed: () => onMove(
                              SetAgent(person.toNounPhrase(Number.plural)),
                            ),
                          ),
                        ],
                        children: [
                          _MoveButton(
                            label: 'they',
                            selected: _sameNounPhrase(agent, they),
                            onPressed: () => onMove(const SetAgent(they)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TenseAspectSection extends StatelessWidget {
  final Tense tense;
  final Aspect aspect;
  final ValueChanged<ConfigurationMove> onMove;

  const _TenseAspectSection({
    required this.tense,
    required this.aspect,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return _ControlCard(
      title: 'Tense and aspect',
      children: [
        _InlineOptionRow(
          label: 'tense',
          children: [
            _MoveButton(
              label: 'present',
              selected: tense == Tense.present,
              onPressed: () => onMove(const SetTense(Tense.present)),
            ),
            _MoveButton(
              label: 'past',
              selected: tense == Tense.past,
              onPressed: () => onMove(const SetTense(Tense.past)),
            ),
            _MoveButton(
              label: 'future',
              selected: tense == Tense.future,
              onPressed: () => onMove(const SetTense(Tense.future)),
            ),
          ],
        ),
        _InlineOptionRow(
          label: 'aspect',
          children: [
            _MoveButton(
              label: 'simple',
              selected: aspect == Aspect.simple,
              onPressed: () => onMove(const SetAspect(Aspect.simple)),
            ),
            _MoveButton(
              label: 'continuous',
              selected: aspect == Aspect.continuous,
              onPressed: () => onMove(const SetAspect(Aspect.continuous)),
            ),
            _MoveButton(
              label: 'perfect',
              selected: aspect == Aspect.perfect,
              onPressed: () => onMove(const SetAspect(Aspect.perfect)),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModalSection extends StatelessWidget {
  final String currentSentence;
  final List<ConfigurationSuggestion> modalSuggestions;
  final ValueChanged<ConfigurationMove> onMove;
  final ValueChanged<ConfigurationState?>? onPreviewChanged;

  const _ModalSection({
    required this.currentSentence,
    required this.modalSuggestions,
    required this.onMove,
    required this.onPreviewChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primarySuggestions = modalSuggestions
        .where((suggestion) => !_isSecondModalRow(suggestion))
        .toList();
    final secondarySuggestions = modalSuggestions
        .where(_isSecondModalRow)
        .toList();

    return _ControlCard(
      title: 'Modal',
      children: [
        if (modalSuggestions.isEmpty)
          Text(
            'No modal from here.',
            style: TextStyle(color: Theme.of(context).disabledColor),
          )
        else
          _ModalSuggestionRows(
            primarySuggestions: primarySuggestions,
            secondarySuggestions: secondarySuggestions,
            currentSentence: currentSentence,
            onMove: onMove,
            onPreviewChanged: onPreviewChanged,
          ),
      ],
    );
  }
}

class _ModalSuggestionRows extends StatelessWidget {
  final List<ConfigurationSuggestion> primarySuggestions;
  final List<ConfigurationSuggestion> secondarySuggestions;
  final String currentSentence;
  final ValueChanged<ConfigurationMove> onMove;
  final ValueChanged<ConfigurationState?>? onPreviewChanged;

  const _ModalSuggestionRows({
    required this.primarySuggestions,
    required this.secondarySuggestions,
    required this.currentSentence,
    required this.onMove,
    required this.onPreviewChanged,
  });

  @override
  Widget build(BuildContext context) {
    final firstRowSuggestions = [
      ...primarySuggestions.where((suggestion) => suggestion.label != 'must'),
    ];
    final secondRowSuggestions = [
      ...primarySuggestions.where((suggestion) => suggestion.label == 'must'),
      ...secondarySuggestions,
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModalSuggestionWrap(
          suggestions: firstRowSuggestions,
          currentSentence: currentSentence,
          onMove: onMove,
          onPreviewChanged: onPreviewChanged,
        ),
        if (secondRowSuggestions.isNotEmpty) ...[
          const SizedBox(height: 4),
          _ModalSuggestionWrap(
            suggestions: secondRowSuggestions,
            currentSentence: currentSentence,
            onMove: onMove,
            onPreviewChanged: onPreviewChanged,
          ),
        ],
      ],
    );
  }
}

class _ModalSuggestionWrap extends StatelessWidget {
  final List<ConfigurationSuggestion> suggestions;
  final String currentSentence;
  final ValueChanged<ConfigurationMove> onMove;
  final ValueChanged<ConfigurationState?>? onPreviewChanged;

  const _ModalSuggestionWrap({
    required this.suggestions,
    required this.currentSentence,
    required this.onMove,
    required this.onPreviewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final suggestion in suggestions)
          _SuggestionButton(
            suggestion: suggestion,
            currentSentence: currentSentence,
            displayMode: SuggestionDisplayMode.word,
            preview: null,
            onPressed: () => onMove(suggestion.move),
            onPreviewChanged: onPreviewChanged,
          ),
      ],
    );
  }
}

bool _isSecondModalRow(ConfigurationSuggestion suggestion) {
  return const {'shall', 'should', 'will', 'would'}.contains(suggestion.label);
}

List<ConfigurationSuggestion> _fixedPassiveAgentSuggestions(
  List<ConfigurationSuggestion> suggestions,
) {
  final ordered = [...suggestions]
    ..sort((left, right) {
      return _passiveAgentOrder(
        left.label,
      ).compareTo(_passiveAgentOrder(right.label));
    });

  return ordered;
}

int _passiveAgentOrder(String label) {
  return switch (label) {
    'show by-agent' => 0,
    'hide by-agent' => 1,
    _ => 2,
  };
}

class _VoiceSection extends StatelessWidget {
  final String currentSentence;
  final Voice voice;
  final List<ConfigurationSuggestion> passiveFocusSuggestions;
  final List<ConfigurationSuggestion> passiveAgentSuggestions;
  final ValueChanged<ConfigurationMove> onMove;
  final ValueChanged<ConfigurationState?>? onPreviewChanged;

  const _VoiceSection({
    required this.currentSentence,
    required this.voice,
    required this.passiveFocusSuggestions,
    required this.passiveAgentSuggestions,
    required this.onMove,
    required this.onPreviewChanged,
  });

  @override
  Widget build(BuildContext context) {
    final orderedPassiveAgentSuggestions = _fixedPassiveAgentSuggestions(
      passiveAgentSuggestions,
    );

    return _ControlCard(
      title: 'Voice',
      children: [
        _InlineOptionRow(
          label: 'voice',
          labelWidth: 36,
          runSpacing: 4,
          children: [
            _MoveButton(
              label: 'active',
              selected: voice == Voice.active,
              onPressed: () => onMove(const SetVoice(Voice.active)),
            ),
            _MoveButton(
              label: 'passive',
              selected: voice == Voice.passive,
              onPressed: () => onMove(const SetVoice(Voice.passive)),
            ),
          ],
        ),
        if (passiveFocusSuggestions.isNotEmpty)
          _InlineOptionRow(
            label: 'focus',
            labelWidth: 36,
            runSpacing: 4,
            children: [
              for (final suggestion in passiveFocusSuggestions)
                _SuggestionButton(
                  suggestion: suggestion,
                  currentSentence: currentSentence,
                  displayMode: SuggestionDisplayMode.word,
                  preview: null,
                  onPressed: () => onMove(suggestion.move),
                  onPreviewChanged: onPreviewChanged,
                ),
            ],
          ),
        if (orderedPassiveAgentSuggestions.isNotEmpty)
          _InlineOptionRow(
            label: 'agent',
            labelWidth: 36,
            runSpacing: 4,
            children: [
              for (final suggestion in orderedPassiveAgentSuggestions)
                _SuggestionButton(
                  suggestion: suggestion,
                  currentSentence: currentSentence,
                  displayMode: SuggestionDisplayMode.word,
                  preview: null,
                  onPressed: () => onMove(suggestion.move),
                  onPreviewChanged: onPreviewChanged,
                ),
            ],
          ),
      ],
    );
  }
}

class _DisplayModeSection extends StatelessWidget {
  final SuggestionDisplayMode value;
  final ValueChanged<SuggestionDisplayMode> onChanged;

  const _DisplayModeSection({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<SuggestionDisplayMode>(
      segments: const [
        ButtonSegment(
          value: SuggestionDisplayMode.sentence,
          label: Text('Sentence'),
          icon: Icon(Icons.subject),
        ),
        ButtonSegment(
          value: SuggestionDisplayMode.change,
          label: Text('Change'),
          icon: Icon(Icons.highlight),
        ),
        ButtonSegment(
          value: SuggestionDisplayMode.word,
          label: Text('Word'),
          icon: Icon(Icons.short_text),
        ),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.single),
    );
  }
}

class _PreviewCacheModeSection extends StatelessWidget {
  final PreviewCacheMode value;
  final ValueChanged<PreviewCacheMode> onChanged;

  const _PreviewCacheModeSection({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PreviewCacheMode>(
      segments: const [
        ButtonSegment(
          value: PreviewCacheMode.unbounded,
          label: Text('Full cache'),
          icon: Icon(Icons.all_inclusive),
        ),
        ButtonSegment(
          value: PreviewCacheMode.bounded,
          label: Text('Bounded'),
          icon: Icon(Icons.memory),
        ),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.single),
    );
  }
}

class _PreviewCacheDiagnosticsPanel extends StatelessWidget {
  final PreviewCacheMode mode;
  final ValueChanged<PreviewCacheMode> onModeChanged;
  final VoidCallback onClear;
  final int entryCount;
  final int? entryLimit;

  const _PreviewCacheDiagnosticsPanel({
    required this.mode,
    required this.onModeChanged,
    required this.onClear,
    required this.entryCount,
    required this.entryLimit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final limitText = entryLimit == null ? 'full' : entryLimit.toString();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.34),
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.memory, size: 16, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                'Preview cache',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              SelectableText(
                '$entryCount / $limitText',
                key: const Key('preview-cache-size'),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              _PreviewCacheModeSection(value: mode, onChanged: onModeChanged),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                key: const Key('wipe-preview-cache-button'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: const Size(0, 30),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                ),
                onPressed: onClear,
                icon: const Icon(Icons.cleaning_services_outlined, size: 16),
                label: const Text('Wipe cache'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderPreviewModeSection extends StatelessWidget {
  final HeaderPreviewMode value;
  final ValueChanged<HeaderPreviewMode> onChanged;

  const _HeaderPreviewModeSection({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<HeaderPreviewMode>(
      segments: const [
        ButtonSegment(
          value: HeaderPreviewMode.clicked,
          label: Text('Clicked header'),
          icon: Icon(Icons.touch_app),
        ),
        ButtonSegment(
          value: HeaderPreviewMode.hover,
          label: Text('Hover header'),
          icon: Icon(Icons.ads_click),
        ),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.single),
    );
  }
}

class _NounNumberSwitch extends StatelessWidget {
  final Number value;
  final ValueChanged<Number> onChanged;

  const _NounNumberSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: SegmentedButton<Number>(
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        segments: const [
          ButtonSegment(value: Number.singular, label: Text('sg')),
          ButtonSegment(value: Number.plural, label: Text('pl')),
        ],
        selected: {value},
        onSelectionChanged: (selection) => onChanged(selection.single),
      ),
    );
  }
}

class _CompassSlotSection extends StatelessWidget {
  final String title;
  final String unlockHint;
  final bool isExpanded;
  final VoidCallback? onToggle;
  final String currentSentence;
  final SuggestionDisplayMode displayMode;
  final List<ConfigurationSuggestion> suggestions;
  final Number? nounNumber;
  final ValueChanged<Number>? onNounNumberChanged;
  final String Function(SentenceState state) renderPreview;
  final ValueChanged<ConfigurationMove> onMove;
  final ValueChanged<ConfigurationState?>? onPreviewChanged;

  const _CompassSlotSection({
    required this.title,
    required this.unlockHint,
    required this.isExpanded,
    required this.onToggle,
    required this.currentSentence,
    required this.displayMode,
    required this.suggestions,
    required this.nounNumber,
    required this.onNounNumberChanged,
    required this.renderPreview,
    required this.onMove,
    required this.onPreviewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionFrame(
      title: title,
      isExpanded: isExpanded,
      onToggle: onToggle,
      collapsedHint: _collapsedRailHint(title),
      expandedMaxHeight: _railMaxHeightFor(
        title: title,
        suggestionCount: suggestions.length,
      ),
      controls: [
        if (isExpanded &&
            suggestions.isNotEmpty &&
            nounNumber != null &&
            onNounNumberChanged != null)
          _NounNumberSwitch(
            value: nounNumber!,
            onChanged: onNounNumberChanged!,
          ),
      ],
      children: !isExpanded
          ? const []
          : suggestions.isEmpty
          ? [
              Text(
                unlockHint,
                style: TextStyle(color: Theme.of(context).disabledColor),
              ),
            ]
          : [
              for (final suggestion in suggestions)
                _SuggestionButton(
                  suggestion: suggestion,
                  currentSentence: currentSentence,
                  displayMode: displayMode,
                  preview: displayMode == SuggestionDisplayMode.word
                      ? null
                      : renderPreview(suggestion.preview.sentenceState),
                  onPressed: () => onMove(suggestion.move),
                  onPreviewChanged: onPreviewChanged,
                ),
            ],
    );
  }
}

double _railMaxHeightFor({
  required String title,
  required int suggestionCount,
}) {
  if (title == 'Verb') {
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
