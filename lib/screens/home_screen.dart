import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:padlock_app/data/predicate/fixed_object_frames.dart';
import 'package:padlock_app/data/predicate/predicate_paths.dart';
import 'package:padlock_app/data/predicate/right_action_frames.dart';
import 'package:padlock_app/data/predicate/semantic_icons.dart';
import 'package:padlock_app/data/predicate/verb_influence.dart';
import 'package:padlock_app/data/subjects/adjectives/essential_adjectives.dart'
    as adjective_data;
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/animals.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/engine/configuration_compass.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/engine/crude_translation_engine.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/models/grammar/participant_surface.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

part 'widgets/control_cards.dart';
part 'widgets/control_deck.dart';
part 'widgets/noun_rail_state.dart';
part 'widgets/rail_policy.dart';
part 'widgets/suggestion_chips.dart';

enum SuggestionDisplayMode { change, word }

enum HeaderPreviewMode { clicked, hover }

enum PreviewCacheMode { unbounded, bounded }

const _stickyHeaderHeight = 120.0;
const _stickyFooterHeight = 28.0;
const _diagnosticsDockReserveHeight = 224.0;
const _diagnosticsDockCollapsedHeight = 52.0;
const _moveTraceLimit = 10;
const _suggestionLimit = 96;
const _actionSuggestionLimit = 192;
const _nounRailSuggestionLimit = _suggestionLimit * 2;
const _railSearchThreshold = 20;
const _smallRailMaxHeight = 92.0;
const _mediumRailMaxHeight = 132.0;
const _largeRailMaxHeight = 176.0;
const _verbRailMaxHeight = 216.0;

const _objectTranslationSlots = {
  ConfigurationCompassSlot.object,
  ConfigurationCompassSlot.objectComplement,
  ConfigurationCompassSlot.objectAdjectiveComplement,
  ConfigurationCompassSlot.complement,
  ConfigurationCompassSlot.adjectiveComplement,
  ConfigurationCompassSlot.passiveAgentNoun,
};

const _personTranslationSlots = {
  ConfigurationCompassSlot.recipient,
  ConfigurationCompassSlot.addressee,
  ConfigurationCompassSlot.companion,
  ConfigurationCompassSlot.beneficiary,
  ConfigurationCompassSlot.source,
};

const _predicateNounTranslationSlots = {
  ConfigurationCompassSlot.instrument,
  ConfigurationCompassSlot.destination,
  ConfigurationCompassSlot.topic,
  ConfigurationCompassSlot.purpose,
};

const _locationTranslationSlots = {
  ConfigurationCompassSlot.placePhrase,
  ConfigurationCompassSlot.sourcePlace,
};

const _phraseTranslationSlots = {
  ConfigurationCompassSlot.timePhrase,
  ConfigurationCompassSlot.frequencyPhrase,
  ConfigurationCompassSlot.mannerPhrase,
};

const _rightActionTranslationSlots = {ConfigurationCompassSlot.rightAction};

const _padlockIntellijDarkColors = ColorScheme.dark(
  primary: Color(0xFF8AADF4),
  onPrimary: Color(0xFF10151F),
  primaryContainer: Color(0xFF25324A),
  onPrimaryContainer: Color(0xFFD7E4FF),
  secondary: Color(0xFFA6DA95),
  onSecondary: Color(0xFF101C10),
  secondaryContainer: Color(0xFF243321),
  onSecondaryContainer: Color(0xFFD9F6CD),
  tertiary: Color(0xFFF5A97F),
  onTertiary: Color(0xFF251509),
  tertiaryContainer: Color(0xFF3B2A22),
  onTertiaryContainer: Color(0xFFFFDCC7),
  error: Color(0xFFFF7B86),
  onError: Color(0xFF2B0D11),
  errorContainer: Color(0xFF4B1D24),
  onErrorContainer: Color(0xFFFFD6DA),
  surface: Color(0xFF1E1F22),
  onSurface: Color(0xFFCED0D6),
  onSurfaceVariant: Color(0xFF9DA3AE),
  outline: Color(0xFF5E6470),
  outlineVariant: Color(0xFF3D424C),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFFDADCE3),
  onInverseSurface: Color(0xFF23252A),
  inversePrimary: Color(0xFF365FAD),
);

final _padlockIntellijDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: _padlockIntellijDarkColors,
  scaffoldBackgroundColor: const Color(0xFF2B2D30),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2B2D30),
    foregroundColor: Color(0xFFDADCE3),
    elevation: 0,
    surfaceTintColor: Colors.transparent,
  ),
  cardTheme: const CardThemeData(
    color: Color(0xFF1E1F22),
    surfaceTintColor: Colors.transparent,
  ),
  dividerTheme: const DividerThemeData(color: Color(0xFF3D424C)),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _padlockIntellijDarkColors.onSurface,
      backgroundColor: const Color(0xFF2B2D30),
      side: const BorderSide(color: Color(0xFF5E6470)),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: _padlockIntellijDarkColors.onSurfaceVariant,
    ),
  ),
  textTheme: Typography.material2021().white.apply(
    bodyColor: _padlockIntellijDarkColors.onSurface,
    displayColor: _padlockIntellijDarkColors.onSurface,
  ),
);

class HomeScreen extends StatefulWidget {
  final SuggestionDisplayMode initialSuggestionDisplayMode;

  const HomeScreen({
    super.key,
    this.initialSuggestionDisplayMode = SuggestionDisplayMode.change,
  });

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
  bool showTranslation = true;
  bool showVerbTranslations = false;
  Set<ConfigurationCompassSlot> translatedRails = const {};
  bool isDarkMode = true;
  bool diagnosticsCollapsed = false;
  final ValueNotifier<ConfigurationState?> hoveredConfiguration = ValueNotifier(
    null,
  );
  late final ValueNotifier<List<_MoveTraceEntry>> moveTraceNotifier;
  late final ValueNotifier<int> previewCacheEntryCountNotifier;
  Map<ConfigurationCompassSlot, Number> nounNumbers = const {};
  List<_MoveTraceEntry> moveTrace = const [];
  Set<ConfigurationCompassSlot> expandedRails = const {};
  bool isCoreSurfaceExpanded = true;
  bool isVerbRailExpanded = true;
  String verbFilterQuery = '';
  int previewCacheEntryCount = 0;

  @override
  void initState() {
    super.initState();
    configuration = ConfigurationState.initial();
    previewCache = _SentencePreviewCache(grammar, maxEntries: null);
    moveTraceNotifier = ValueNotifier(moveTrace);
    previewCacheEntryCountNotifier = ValueNotifier(previewCacheEntryCount);
  }

  void _move(ConfigurationMove move) {
    final logicStopwatch = Stopwatch()..start();
    final uiStopwatch = Stopwatch()..start();

    setState(() {
      final previousConfiguration = configuration;
      final nextConfiguration = lock.applyMove(configuration, move);
      configuration = nextConfiguration;
      if (move is SetAction) {
        expandedRails = const {};
      }
      if (move is SetRightAction) {
        expandedRails = _expandedRailsAfterRightActionMove(
          expandedRails,
          nextConfiguration.sentenceState,
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
      logicStopwatch.stop();
      _appendTraceEntry(
        _MoveTraceEntry.fromMove(
          move: move,
          sentence: nextSentence,
          wasBlocked: nextConfiguration.messages.any(
            (message) => message.kind == ConfigurationMessageKind.blocked,
          ),
          keptSentence:
              previousConfiguration.sentenceState.summary ==
              nextConfiguration.sentenceState.summary,
          elapsed: logicStopwatch.elapsed,
        ),
        uiStopwatch,
      );
    });
  }

  void _reset() {
    final logicStopwatch = Stopwatch()..start();
    final uiStopwatch = Stopwatch()..start();
    final sentence = grammar
        .generate(ConfigurationState.initial().sentenceState)
        .text;
    logicStopwatch.stop();

    setState(() {
      configuration = ConfigurationState.initial();
      nounNumbers = const {};
      hoveredConfiguration.value = null;
      _setMoveTrace(const []);
      _appendTraceEntry(
        _MoveTraceEntry.reset(sentence, elapsed: logicStopwatch.elapsed),
        uiStopwatch,
      );
      expandedRails = const {};
    });
  }

  void _setPreviewCacheMode(PreviewCacheMode mode) {
    setState(() {
      previewCacheMode = mode;
      previewCache.setMaxEntries(_cacheEntryLimitForMode(mode));
      _setPreviewCacheEntryCount(previewCache.size);
    });
  }

  void _clearPreviewCache() {
    setState(() {
      previewCache.clear();
      _setPreviewCacheEntryCount(0);
    });
  }

  void _shuffle() {
    final logicStopwatch = Stopwatch()..start();
    final uiStopwatch = Stopwatch()..start();
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
      logicStopwatch.stop();
      _setMoveTrace(const []);
      _appendTraceEntry(
        _MoveTraceEntry.random(sentence, elapsed: logicStopwatch.elapsed),
        uiStopwatch,
      );
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

  void _toggleRailTranslation(ConfigurationCompassSlot slot) {
    setState(() {
      if (translatedRails.contains(slot)) {
        translatedRails = {...translatedRails}..remove(slot);
      } else {
        translatedRails = {...translatedRails, slot};
      }
    });
  }

  String? _translationForSuggestion(
    ConfigurationCompassSlot slot,
    ConfigurationSuggestion suggestion,
  ) {
    final move = suggestion.move;

    if (slot == ConfigurationCompassSlot.action && move is SetAction) {
      return translator.translateVerb(move.action);
    }

    if (_objectTranslationSlots.contains(slot)) {
      if (move is SetObjectAdjectiveComplement &&
          move.objectAdjectiveComplement != null) {
        return translator.translateAdjective(move.objectAdjectiveComplement!);
      }
      if (move is SetAdjectiveComplement && move.adjectiveComplement != null) {
        return translator.translateAdjective(move.adjectiveComplement!);
      }
      return _nounTranslationFromMove(move);
    }

    if (_personTranslationSlots.contains(slot)) {
      return _nounTranslationFromMove(move);
    }

    if (_predicateNounTranslationSlots.contains(slot)) {
      return _nounTranslationFromMove(move);
    }

    if (_rightActionTranslationSlots.contains(slot) &&
        move is SetRightAction &&
        move.rightAction != null) {
      return translator.translateVerb(move.rightAction!);
    }

    if (_locationTranslationSlots.contains(slot)) {
      if (move is SetPlacePhrase && move.placePhrase != null) {
        return translator.translatePlacePhrase(
          move.placePhrase!,
          meaning: move.placeMeaning ?? PlaceMeaning.location,
        );
      }

      return null;
    }

    if (_phraseTranslationSlots.contains(slot)) {
      return switch (move) {
        SetTimePhrase(:final timePhrase) when timePhrase != null =>
          translator.translateTimePhrase(timePhrase),
        SetFrequencyPhrase(:final frequencyPhrase)
            when frequencyPhrase != null =>
          translator.translateFrequencyPhrase(frequencyPhrase),
        SetMannerPhrase(:final mannerPhrase) when mannerPhrase != null =>
          translator.translateMannerPhrase(mannerPhrase),
        _ => null,
      };
    }

    return null;
  }

  String? _nounTranslationFromMove(ConfigurationMove move) {
    final nounPhrase = switch (move) {
      SetObject(:final object) => object,
      SetObjectComplement(:final objectComplement) => objectComplement,
      SetRecipient(:final recipient) => recipient,
      SetAddressee(:final addressee) => addressee,
      SetCompanion(:final companion) => companion,
      SetInstrument(:final instrument) => instrument,
      SetDestination(:final destination) => destination,
      SetTopic(:final topic) => topic,
      SetBeneficiary(:final beneficiary) => beneficiary,
      SetSource(:final source) => source,
      SetPurpose(:final purpose) => purpose,
      SetComplement(:final complement) => complement,
      _ => null,
    };

    if (nounPhrase == null) {
      return null;
    }

    return translator.translateNounPhrase(nounPhrase);
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
      _ when _slotHasNounNumberSwitch(slot) => _nounRailSuggestionLimit,
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
    final logicStopwatch = Stopwatch()..start();
    final uiStopwatch = Stopwatch()..start();

    setState(() {
      switch (slot) {
        case ConfigurationCompassSlot.object:
        case ConfigurationCompassSlot.objectComplement:
        case ConfigurationCompassSlot.addressee:
        case ConfigurationCompassSlot.recipient:
        case ConfigurationCompassSlot.companion:
        case ConfigurationCompassSlot.instrument:
        case ConfigurationCompassSlot.destination:
        case ConfigurationCompassSlot.topic:
        case ConfigurationCompassSlot.beneficiary:
        case ConfigurationCompassSlot.source:
        case ConfigurationCompassSlot.purpose:
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
        _setNounPhraseMove(
          configuration.sentenceState,
          slot,
          _carrySafeNounModifiers(nounPhrase, variant),
        ),
      );
      final sentence = grammar.generate(configuration.sentenceState).text;
      logicStopwatch.stop();
      _appendTraceEntry(
        _MoveTraceEntry(
          label: '${_slotTraceLabel(slot)} number -> ${number.name}',
          sentence: sentence,
          status: _MoveTraceStatus.accepted,
          elapsed: logicStopwatch.elapsed,
        ),
        uiStopwatch,
      );
    });
  }

  void _appendTraceEntry(_MoveTraceEntry entry, Stopwatch uiStopwatch) {
    _setMoveTrace(_appendMoveTrace(moveTrace, entry));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      uiStopwatch.stop();
      _setMoveTrace([
        for (final current in moveTrace)
          if (identical(current, entry))
            current.withUiElapsed(uiStopwatch.elapsed)
          else
            current,
      ]);
    });
  }

  void _setMoveTrace(List<_MoveTraceEntry> entries) {
    moveTrace = entries;
    moveTraceNotifier.value = entries;
  }

  void _setPreviewCacheEntryCount(int value) {
    previewCacheEntryCount = value;
    previewCacheEntryCountNotifier.value = value;
  }

  @override
  void dispose() {
    hoveredConfiguration.dispose();
    moveTraceNotifier.dispose();
    previewCacheEntryCountNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayMode =
        suggestionDisplayMode ?? widget.initialSuggestionDisplayMode;
    final previewMode = headerPreviewMode ?? HeaderPreviewMode.clicked;
    final cacheMode = previewCacheMode ?? PreviewCacheMode.unbounded;
    previewCache.setMaxEntries(_cacheEntryLimitForMode(cacheMode));
    final sentenceText = previewCache.render(configuration.sentenceState);
    final sections = _visibleSlotSections(compass);
    _VisibleCompassSlot? verbSection;
    for (final section in sections) {
      if (section.slot == ConfigurationCompassSlot.action) {
        verbSection = section;
        break;
      }
    }
    final lowerSections = [
      for (final section in sections)
        if (section.slot != ConfigurationCompassSlot.action) section,
    ];
    final filteredVerbCount = verbSection == null
        ? 0
        : _filteredSuggestionCount(
            verbSection.suggestions,
            query: verbFilterQuery,
          );
    final fixedHeadHeight = _fixedWorkbenchHeadHeight(
      isCoreSurfaceExpanded: isCoreSurfaceExpanded,
      isVerbRailExpanded: isVerbRailExpanded,
      verbSuggestionCount: filteredVerbCount,
      isVerbRailFiltered: verbFilterQuery.trim().isNotEmpty,
    );
    _syncPreviewCacheSizeAfterFrame();

    final scaffold = Scaffold(
      bottomNavigationBar: _BottomDock(
        messages: configuration.messages,
        moveTraceListenable: moveTraceNotifier,
        isCollapsed: diagnosticsCollapsed,
        onCollapsedChanged: (value) {
          setState(() {
            diagnosticsCollapsed = value;
          });
        },
        cacheMode: cacheMode,
        cacheEntryCountListenable: previewCacheEntryCountNotifier,
        cacheEntryLimit: previewCache.maxEntries,
        onCacheModeChanged: _setPreviewCacheMode,
        onClearCache: _clearPreviewCache,
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
        showTranslation: showTranslation,
        onToggleTranslation: () {
          setState(() {
            showTranslation = !showTranslation;
          });
        },
        isDarkMode: isDarkMode,
        onToggleDarkMode: () {
          setState(() {
            isDarkMode = !isDarkMode;
          });
        },
        onReset: _reset,
        onRandomSentence: _shuffle,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final effectiveFixedHeadHeight = min(
              fixedHeadHeight,
              max(_stickyHeaderHeight, constraints.maxHeight - 64),
            );
            final fixedHeadNeedsScroll =
                fixedHeadHeight > effectiveFixedHeadHeight;

            return Stack(
              children: [
                Positioned(
                  top: effectiveFixedHeadHeight + 8,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: RepaintBoundary(
                    child: SingleChildScrollView(
                      key: const Key('main-scroll'),
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final section in lowerSections) ...[
                            _CompassSlotSection(
                              slot: section.slot,
                              title: section.title,
                              unlockHint: section.unlockHint,
                              surfaceMarker: section.surfaceMarker,
                              isExpanded: section.isExpanded,
                              onToggle: section.canToggle
                                  ? () => _toggleRail(section.slot)
                                  : null,
                              currentSentence: sentenceText,
                              displayMode: displayMode,
                              showSuggestionTranslations: translatedRails
                                  .contains(section.slot),
                              onToggleSuggestionTranslations:
                                  _railTranslationLabel(section.slot) == null
                                  ? null
                                  : () => _toggleRailTranslation(section.slot),
                              translationLabel: _railTranslationLabel(
                                section.slot,
                              ),
                              translateSuggestion: (suggestion) =>
                                  _translationForSuggestion(
                                    section.slot,
                                    suggestion,
                                  ),
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
                              onPreviewChanged:
                                  previewMode == HeaderPreviewMode.hover
                                  ? _setHoveredConfiguration
                                  : null,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: effectiveFixedHeadHeight,
                    child: RepaintBoundary(
                      child: Material(
                        color: _pinnedWorkbenchColor(
                          Theme.of(context).colorScheme,
                        ),
                        elevation: 2,
                        child: ClipRect(
                          child: SingleChildScrollView(
                            physics: fixedHeadNeedsScroll
                                ? const ClampingScrollPhysics()
                                : const NeverScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ValueListenableBuilder<ConfigurationState?>(
                                  valueListenable: hoveredConfiguration,
                                  builder: (context, hovered, child) {
                                    final headerConfiguration =
                                        previewMode ==
                                                HeaderPreviewMode.hover &&
                                            hovered != null
                                        ? hovered
                                        : configuration;
                                    final headerSentence = previewCache.render(
                                      headerConfiguration.sentenceState,
                                    );
                                    final displayedHeaderSentence =
                                        showTranslation
                                        ? translator.translateSentence(
                                            renderedSentence: headerSentence,
                                            state: headerConfiguration
                                                .sentenceState,
                                          )
                                        : headerSentence;

                                    return _StickySentenceHeader(
                                      child: _SentencePanel(
                                        sentence: headerSentence,
                                        translation: showTranslation
                                            ? displayedHeaderSentence
                                            : null,
                                        summary: headerConfiguration
                                            .sentenceState
                                            .summary,
                                      ),
                                    );
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    8,
                                    12,
                                    0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _ControlDeck(
                                        currentSentence: sentenceText,
                                        modalSuggestions: compass
                                            .suggestionsFor(
                                              configuration,
                                              ConfigurationCompassSlot.modal,
                                              limit: 9,
                                            ),
                                        passiveFocusSuggestions: compass
                                            .suggestionsFor(
                                              configuration,
                                              ConfigurationCompassSlot
                                                  .passiveFocus,
                                              limit: 3,
                                            ),
                                        passiveAgentSuggestions: compass
                                            .suggestionsFor(
                                              configuration,
                                              ConfigurationCompassSlot
                                                  .passiveAgent,
                                              limit: 2,
                                            ),
                                        configuration: configuration,
                                        onMove: _move,
                                        onPreviewChanged:
                                            previewMode ==
                                                HeaderPreviewMode.hover
                                            ? _setHoveredConfiguration
                                            : null,
                                      ),
                                      const SizedBox(height: 8),
                                      _CoreParticipantSurfaceMap(
                                        configuration: configuration,
                                        expandedRails: expandedRails,
                                        isExpanded: isCoreSurfaceExpanded,
                                        onToggleSection: () {
                                          setState(() {
                                            isCoreSurfaceExpanded =
                                                !isCoreSurfaceExpanded;
                                          });
                                        },
                                        onToggleRail: _toggleRail,
                                      ),
                                      const SizedBox(height: 8),
                                      if (verbSection != null)
                                        _CompassSlotSection(
                                          slot: verbSection.slot,
                                          title: verbSection.title,
                                          unlockHint: verbSection.unlockHint,
                                          surfaceMarker:
                                              verbSection.surfaceMarker,
                                          isExpanded: isVerbRailExpanded,
                                          onToggle: () {
                                            setState(() {
                                              isVerbRailExpanded =
                                                  !isVerbRailExpanded;
                                            });
                                          },
                                          currentSentence: sentenceText,
                                          displayMode: displayMode,
                                          showSuggestionTranslations:
                                              showVerbTranslations,
                                          onToggleSuggestionTranslations: () {
                                            setState(() {
                                              showVerbTranslations =
                                                  !showVerbTranslations;
                                            });
                                          },
                                          translationLabel: 'verbs',
                                          translateSuggestion: (suggestion) =>
                                              _translationForSuggestion(
                                                ConfigurationCompassSlot.action,
                                                suggestion,
                                              ),
                                          suggestions: verbSection.suggestions,
                                          nounNumber: null,
                                          onNounNumberChanged: null,
                                          renderPreview: previewCache.render,
                                          onMove: _move,
                                          onPreviewChanged:
                                              previewMode ==
                                                  HeaderPreviewMode.hover
                                              ? _setHoveredConfiguration
                                              : null,
                                          onFilterQueryChanged: (query) {
                                            setState(() {
                                              verbFilterQuery = query;
                                            });
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

    if (!isDarkMode) {
      return scaffold;
    }

    return Theme(data: _padlockIntellijDarkTheme, child: scaffold);
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

      _setPreviewCacheEntryCount(previewCache.size);
    });
  }
}

int? _cacheEntryLimitForMode(PreviewCacheMode mode) {
  return switch (mode) {
    PreviewCacheMode.unbounded => null,
    PreviewCacheMode.bounded => _SentencePreviewCache.defaultMaxEntries,
  };
}

Color _pinnedWorkbenchColor(ColorScheme colors) {
  if (colors.brightness == Brightness.dark) {
    return colors.surface;
  }

  return Color.alphaBlend(
    colors.primary.withValues(alpha: 0.035),
    colors.surfaceContainerHighest,
  );
}

double _fixedWorkbenchHeadHeight({
  required bool isCoreSurfaceExpanded,
  required bool isVerbRailExpanded,
  required int verbSuggestionCount,
  required bool isVerbRailFiltered,
}) {
  const controlDeckHeight = 104.0;
  const expandedCoreSurfaceHeight = 70.0;
  const collapsedCoreSurfaceHeight = 46.0;
  final expandedVerbRailHeight =
      _railMaxHeightFor(
        title: 'Verb',
        suggestionCount: verbSuggestionCount,
        isFiltered: isVerbRailFiltered,
      ) +
      64.0;
  const collapsedVerbRailHeight = 46.0;

  return _stickyHeaderHeight +
      8 +
      controlDeckHeight +
      8 +
      (isCoreSurfaceExpanded
          ? expandedCoreSurfaceHeight
          : collapsedCoreSurfaceHeight) +
      8 +
      (isVerbRailExpanded ? expandedVerbRailHeight : collapsedVerbRailHeight) +
      8;
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
  final bool isExpanded;
  final VoidCallback onToggleSection;
  final ValueChanged<ConfigurationCompassSlot> onToggleRail;

  const _CoreParticipantSurfaceMap({
    required this.configuration,
    required this.expandedRails,
    required this.isExpanded,
    required this.onToggleSection,
    required this.onToggleRail,
  });

  @override
  Widget build(BuildContext context) {
    final participantDoors = _coreParticipantDoors(configuration);

    return _SectionFrame(
      title: 'Core participant surface',
      isExpanded: isExpanded,
      onToggle: onToggleSection,
      collapsedHint: 'Click to show participant doors.',
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
        key: door.slot == null
            ? null
            : Key('participant-door-${door.slot!.name}'),
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
  final String? surfaceMarker;
  final bool isExpanded;
  final bool canToggle;

  const _VisibleCompassSlot(
    this.slot,
    this.suggestions, {
    required this.title,
    required this.unlockHint,
    required this.surfaceMarker,
    required this.isExpanded,
    required this.canToggle,
  });
}

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
  final VoidCallback onReset;
  final VoidCallback onRandomSentence;

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
    required this.onReset,
    required this.onRandomSentence,
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
                            onReset: onReset,
                            onRandomSentence: onRandomSentence,
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
  final VoidCallback onReset;
  final VoidCallback onRandomSentence;
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
    required this.onReset,
    required this.onRandomSentence,
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
          onReset: onReset,
          onRandomSentence: onRandomSentence,
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
  final VoidCallback onReset;
  final VoidCallback onRandomSentence;

  const _DiagnosticsToolStrip({
    required this.previewMode,
    required this.onPreviewModeChanged,
    required this.displayMode,
    required this.onDisplayModeChanged,
    required this.showTranslation,
    required this.onToggleTranslation,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.onReset,
    required this.onRandomSentence,
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
        ],
      ),
    );
  }
}

enum _MoveTraceStatus { accepted, blocked, random, reset }

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
            'Padlock Developer Console, Logos Dynamics 2026',
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
                      _SubjectNounMenuButton(
                        tooltip: 'Choose 3rd person singular noun',
                        agent: agent,
                        isSelected: _isSelectedSubjectNoun(
                          agent,
                          _singularSubjectNounGroups,
                        ),
                        groups: _singularSubjectNounGroups,
                        onMove: onMove,
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
                        selected: _sameNounPhrase(agent, youPlural),
                        onPressed: () => onMove(const SetAgent(youPlural)),
                      ),
                      _MoveButton(
                        label: 'they',
                        selected: _sameNounPhrase(agent, they),
                        onPressed: () => onMove(const SetAgent(they)),
                      ),
                      _SubjectNounMenuButton(
                        tooltip: 'Choose 3rd person plural noun',
                        agent: agent,
                        isSelected: _isSelectedSubjectNoun(
                          agent,
                          _pluralSubjectNounGroups,
                        ),
                        groups: _pluralSubjectNounGroups,
                        onMove: onMove,
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

class _SubjectNounChoice {
  final String label;
  final NounPhrase phrase;

  const _SubjectNounChoice({required this.label, required this.phrase});
}

class _SubjectNounGroup {
  final String label;
  final List<_SubjectNounChoice> choices;

  const _SubjectNounGroup({required this.label, required this.choices});
}

final _singularSubjectNounGroups = [
  _SubjectNounGroup(
    label: 'animals',
    choices: [
      _SubjectNounChoice(
        label: 'cat',
        phrase: cat.toNounPhrase(Number.singular),
      ),
      _SubjectNounChoice(
        label: 'dog',
        phrase: dog.toNounPhrase(Number.singular),
      ),
    ],
  ),
  _SubjectNounGroup(
    label: 'people',
    choices: [
      _SubjectNounChoice(
        label: 'John',
        phrase: john.toNounPhrase(Number.singular),
      ),
      _SubjectNounChoice(
        label: 'Mary',
        phrase: mary.toNounPhrase(Number.singular),
      ),
      _SubjectNounChoice(
        label: 'friend',
        phrase: friend.toNounPhrase(Number.singular),
      ),
      _SubjectNounChoice(
        label: 'enemy',
        phrase: enemy.toNounPhrase(Number.singular),
      ),
    ],
  ),
  _SubjectNounGroup(
    label: 'someone words',
    choices: [
      _SubjectNounChoice(label: 'someone', phrase: someone),
      _SubjectNounChoice(label: 'anyone', phrase: anyone),
      _SubjectNounChoice(label: 'nobody', phrase: nobody),
      _SubjectNounChoice(label: 'everyone', phrase: everyone),
    ],
  ),
];

final _pluralSubjectNounGroups = [
  _SubjectNounGroup(
    label: 'animals',
    choices: [
      _SubjectNounChoice(
        label: 'cats',
        phrase: cat.toNounPhrase(Number.plural),
      ),
      _SubjectNounChoice(
        label: 'dogs',
        phrase: dog.toNounPhrase(Number.plural),
      ),
    ],
  ),
  _SubjectNounGroup(
    label: 'people',
    choices: [
      _SubjectNounChoice(
        label: 'friends',
        phrase: friend.toNounPhrase(Number.plural),
      ),
      _SubjectNounChoice(
        label: 'enemies',
        phrase: enemy.toNounPhrase(Number.plural),
      ),
      _SubjectNounChoice(
        label: 'people',
        phrase: person.toNounPhrase(Number.plural),
      ),
    ],
  ),
];

class _SubjectOverlayChoice {
  final String label;
  final ConfigurationMove move;
  final bool isSelected;

  const _SubjectOverlayChoice({
    required this.label,
    required this.move,
    this.isSelected = false,
  });
}

class _SubjectNounMenuButton extends StatelessWidget {
  final String tooltip;
  final NounPhrase? agent;
  final bool isSelected;
  final List<_SubjectNounGroup> groups;
  final ValueChanged<ConfigurationMove> onMove;

  const _SubjectNounMenuButton({
    required this.tooltip,
    required this.agent,
    required this.isSelected,
    required this.groups,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PopupMenuButton<ConfigurationMove>(
      tooltip: tooltip,
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(maxHeight: 420, minWidth: 560),
      onSelected: onMove,
      itemBuilder: (context) => [
        _SubjectPopupColumnsEntry(
          agent: agent,
          isSelected: isSelected,
          groups: groups,
          onMove: onMove,
        ),
      ],
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? colors.primary : colors.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          child: Icon(
            Icons.expand_more,
            size: 16,
            color: isSelected ? colors.primary : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SubjectPopupColumnsEntry extends PopupMenuEntry<ConfigurationMove> {
  final NounPhrase? agent;
  final bool isSelected;
  final List<_SubjectNounGroup> groups;
  final ValueChanged<ConfigurationMove> onMove;

  const _SubjectPopupColumnsEntry({
    required this.agent,
    required this.isSelected,
    required this.groups,
    required this.onMove,
  });

  @override
  double get height => 380;

  @override
  bool represents(ConfigurationMove? value) => false;

  @override
  State<_SubjectPopupColumnsEntry> createState() =>
      _SubjectPopupColumnsEntryState();
}

class _SubjectPopupColumnsEntryState extends State<_SubjectPopupColumnsEntry> {
  bool isDeterminerExpanded = true;
  bool isAdjectiveExpanded = true;
  late NounPhrase? localAgent = widget.agent;

  bool get isLocalSelected =>
      localAgent != null &&
      widget.groups
          .expand((group) => group.choices)
          .any((choice) => _sameNounPhrase(localAgent, choice.phrase));

  List<_SubjectOverlayChoice> get determinerChoices {
    return _subjectDeterminerSuggestionsFor(localAgent);
  }

  List<_SubjectOverlayChoice> get adjectiveChoices {
    return _subjectAdjectiveSuggestionsFor(localAgent);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 540,
      height: 380,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _SubjectPopupNounColumn(
                agent: localAgent,
                groups: widget.groups,
                onNounSelected: (phrase) {
                  final move = SetAgent(phrase);
                  widget.onMove(move);
                  setState(() {
                    localAgent = phrase;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SubjectPopupSuggestionColumn(
                label: 'determiner',
                enabled: isLocalSelected,
                isExpanded: isDeterminerExpanded,
                choices: determinerChoices,
                onChoiceSelected: (choice) {
                  widget.onMove(choice.move);
                  setState(() {
                    localAgent = _applyLocalSubjectModifier(
                      localAgent,
                      choice.move,
                    );
                  });
                },
                onToggle: () {
                  setState(() {
                    isDeterminerExpanded = !isDeterminerExpanded;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SubjectPopupSuggestionColumn(
                label: 'adjective',
                enabled: isLocalSelected,
                isExpanded: isAdjectiveExpanded,
                choices: adjectiveChoices,
                onChoiceSelected: (choice) {
                  widget.onMove(choice.move);
                  setState(() {
                    localAgent = _applyLocalSubjectModifier(
                      localAgent,
                      choice.move,
                    );
                  });
                },
                onToggle: () {
                  setState(() {
                    isAdjectiveExpanded = !isAdjectiveExpanded;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectPopupNounColumn extends StatelessWidget {
  final NounPhrase? agent;
  final List<_SubjectNounGroup> groups;
  final ValueChanged<NounPhrase> onNounSelected;

  const _SubjectPopupNounColumn({
    required this.agent,
    required this.groups,
    required this.onNounSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _SubjectPopupColumnShell(
      label: 'noun',
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          for (final group in groups) ...[
            _SubjectPopupGroupLabel(group.label),
            for (final choice in group.choices)
              _SubjectPopupMoveCell(
                label: choice.label,
                isSelected: _sameNounPhrase(agent, choice.phrase),
                onTap: () => onNounSelected(choice.phrase),
              ),
          ],
        ],
      ),
    );
  }
}

class _SubjectPopupSuggestionColumn extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool isExpanded;
  final List<_SubjectOverlayChoice> choices;
  final ValueChanged<_SubjectOverlayChoice> onChoiceSelected;
  final VoidCallback onToggle;

  const _SubjectPopupSuggestionColumn({
    required this.label,
    required this.enabled,
    required this.isExpanded,
    required this.choices,
    required this.onChoiceSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return _SubjectPopupColumnShell(
      label: label,
      isExpanded: isExpanded,
      canExpand: enabled && choices.isNotEmpty,
      onToggle: enabled && choices.isNotEmpty ? onToggle : null,
      child: !enabled
          ? Text(
              'choose noun',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            )
          : !isExpanded
          ? const SizedBox.shrink()
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final choice in choices)
                  _SubjectPopupMoveCell(
                    label: choice.label,
                    isSelected: choice.isSelected,
                    onTap: () => onChoiceSelected(choice),
                  ),
              ],
            ),
    );
  }
}

class _SubjectPopupColumnShell extends StatelessWidget {
  final String label;
  final Widget child;
  final bool? isExpanded;
  final bool canExpand;
  final VoidCallback? onToggle;

  const _SubjectPopupColumnShell({
    required this.label,
    required this.child,
    this.isExpanded,
    this.canExpand = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final header = _SubjectPopupHeader(
      label,
      isExpanded: isExpanded,
      canExpand: canExpand,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        onToggle == null
            ? header
            : InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: onToggle,
                child: header,
              ),
        const SizedBox(height: 6),
        Expanded(child: child),
      ],
    );
  }
}

class _SubjectPopupMoveCell extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubjectPopupMoveCell({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                child: isSelected
                    ? Icon(Icons.check, size: 14, color: colors.primary)
                    : null,
              ),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectPopupGroupLabel extends StatelessWidget {
  final String label;

  const _SubjectPopupGroupLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 4, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

List<_SubjectOverlayChoice> _subjectDeterminerSuggestionsFor(
  NounPhrase? phrase,
) {
  if (phrase == null || !phrase.canTakeModifiers) {
    return const [];
  }

  return [
    _SubjectOverlayChoice(
      move: const SetNounPhraseDeterminer(NounPhraseTarget.agent, null),
      label: 'no determiner',
      isSelected: phrase.determiner == null,
    ),
    for (final determiner in allDeterminers)
      if (_subjectDeterminerFits(phrase, determiner.text))
        _SubjectOverlayChoice(
          move: SetNounPhraseDeterminer(NounPhraseTarget.agent, determiner),
          label: determiner.text,
          isSelected: phrase.determiner == determiner,
        ),
  ];
}

List<_SubjectOverlayChoice> _subjectAdjectiveSuggestionsFor(
  NounPhrase? phrase,
) {
  if (phrase == null || !phrase.canTakeModifiers) {
    return const [];
  }

  final current = phrase.adjectiveList;

  return [
    _SubjectOverlayChoice(
      move: const SetNounPhraseAdjectives(NounPhraseTarget.agent, []),
      label: 'no adjective',
      isSelected: current.isEmpty,
    ),
    for (final adjective in current)
      _SubjectOverlayChoice(
        move: SetNounPhraseAdjectives(NounPhraseTarget.agent, current),
        label: adjective.text,
        isSelected: true,
      ),
    for (final adjective in adjective_data.adjectives)
      if (!current.contains(adjective) &&
          _subjectDeterminerFits(
            phrase.copyWith(adjectives: [...current, adjective]),
            phrase.determiner?.text,
          ))
        _SubjectOverlayChoice(
          move: SetNounPhraseAdjectives(NounPhraseTarget.agent, [
            ...current,
            adjective,
          ]),
          label: adjective.text,
        ),
  ];
}

NounPhrase? _applyLocalSubjectModifier(
  NounPhrase? phrase,
  ConfigurationMove move,
) {
  if (phrase == null) {
    return null;
  }

  return switch (move) {
    SetNounPhraseDeterminer(:final target, :final determiner)
        when target == NounPhraseTarget.agent =>
      phrase.copyWith(determiner: determiner),
    SetNounPhraseAdjectives(:final target, :final adjectives)
        when target == NounPhraseTarget.agent =>
      phrase.copyWith(
        adjective: adjectives.isEmpty ? null : adjectives.first,
        adjectives: adjectives,
      ),
    _ => phrase,
  };
}

bool _subjectDeterminerFits(NounPhrase phrase, String? determinerText) {
  if (determinerText == null) {
    return true;
  }

  if (_subjectSingularDeterminers.contains(determinerText) && phrase.isPlural) {
    return false;
  }

  if (_subjectPluralDeterminers.contains(determinerText) && !phrase.isPlural) {
    return false;
  }

  final firstSpokenWord = phrase.adjectiveList.isEmpty
      ? phrase.text
      : phrase.adjectiveList.first.text;

  if (determinerText == 'a' && _subjectStartsWithVowelLetter(firstSpokenWord)) {
    return false;
  }

  if (determinerText == 'an' &&
      !_subjectStartsWithVowelLetter(firstSpokenWord)) {
    return false;
  }

  return true;
}

const _subjectSingularDeterminers = {
  'a',
  'an',
  'this',
  'that',
  'each',
  'every',
};
const _subjectPluralDeterminers = {'these', 'those', 'all', 'many'};

bool _subjectStartsWithVowelLetter(String text) {
  final normalized = text.trim().toLowerCase();
  if (normalized.isEmpty) {
    return false;
  }

  return 'aeiou'.contains(normalized[0]);
}

class _SubjectPopupHeader extends StatelessWidget {
  final String label;
  final bool? isExpanded;
  final bool canExpand;

  const _SubjectPopupHeader(
    this.label, {
    this.isExpanded,
    this.canExpand = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (canExpand && isExpanded != null)
          Icon(
            isExpanded! ? Icons.expand_less : Icons.expand_more,
            size: 16,
            color: colors.primary,
          ),
      ],
    );
  }
}

bool _isSelectedSubjectNoun(NounPhrase? agent, List<_SubjectNounGroup> groups) {
  if (agent == null) {
    return false;
  }

  return groups
      .expand((group) => group.choices)
      .any((choice) => _sameNounPhrase(agent, choice.phrase));
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
            suggestionTranslation: null,
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
                  suggestionTranslation: null,
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
                  suggestionTranslation: null,
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
  final String railTitle;
  final Number value;
  final ValueChanged<Number> onChanged;

  const _NounNumberSwitch({
    required this.railTitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: SegmentedButton<Number>(
        key: Key('noun-number-switch-$railTitle'),
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

class _RailTranslationToggle extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _RailTranslationToggle({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final tooltip = isActive ? 'Hide $label translations' : 'Translate $label';

    return SizedBox(
      height: 32,
      child: Tooltip(
        message: tooltip,
        child: OutlinedButton.icon(
          key: Key('rail-translation-toggle-$label'),
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: const Size(0, 30),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          ),
          onPressed: onPressed,
          icon: Icon(
            isActive ? Icons.subtitles_off_outlined : Icons.subtitles_outlined,
            size: 16,
          ),
          label: Text(label),
        ),
      ),
    );
  }
}

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
    return [
      for (final suggestion in widget.suggestions)
        if (_suggestionMatchesTerms(suggestion, terms)) suggestion,
    ];
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
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
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
  final text = _suggestionSearchText(suggestion).toLowerCase();
  return terms.every(text.contains);
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
      _ => 'phrases',
    };
  }
  if (_rightActionTranslationSlots.contains(slot)) {
    return 'right actions';
  }

  return null;
}
