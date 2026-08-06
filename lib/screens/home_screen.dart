import 'dart:async';
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
import 'package:padlock_app/data/subjects/third_person/animal_categories.dart'
    as animal_categories;
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/subjects/third_person/people_categories.dart'
    as people_categories;
import 'package:padlock_app/engine/configuration_compass.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/engine/crude_translation_engine.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/engine/idiom_discovery.dart';
import 'package:padlock_app/engine/idiom_finder.dart';
import 'package:padlock_app/engine/idiom_progress_store.dart';
import 'package:padlock_app/engine/logger/engine_log_config.dart';
import 'package:padlock_app/engine/logger/engine_logger.dart';
import 'package:padlock_app/engine/logger/recognition_diagnostics.dart';
import 'package:padlock_app/engine/recognition_engine.dart';
import 'package:padlock_app/models/grammar/participant_surface.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/topic_preposition.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';
import 'package:padlock_app/models/sentence/sentence_state_diff.dart';

part 'widgets/control_cards.dart';
part 'widgets/control_deck.dart';
part 'widgets/core_participant_surface.dart';
part 'widgets/diagnostics_dock.dart';
part 'widgets/sentence_chrome.dart';
part 'widgets/sentence_state_preview.dart';
part 'widgets/sentence_target.dart';
part 'widgets/subject_controls.dart';
part 'widgets/compass_slot_section.dart';
part 'widgets/noun_rail_state.dart';
part 'widgets/rail_policy.dart';
part 'widgets/recognition_input.dart';
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
const _suggestionCacheEntryLimit = 192;
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
  ConfigurationCompassSlot.rightParticle,
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
  final SentenceState? initialGuessTarget;

  const HomeScreen({
    super.key,
    this.initialSuggestionDisplayMode = SuggestionDisplayMode.change,
    this.initialGuessTarget,
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
  final IdiomFinder idiomFinder = const IdiomFinder();
  final IdiomProgressStore idiomProgressStore = const IdiomProgressStore();

  late ConfigurationState configuration;
  late final _SentencePreviewCache previewCache;
  late final IdiomDiscovery idiomDiscovery;
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
  final Map<String, List<ConfigurationSuggestion>> suggestionCache = {};
  Map<ConfigurationCompassSlot, Number> nounNumbers = const {};
  List<_MoveTraceEntry> moveTrace = const [];
  List<IdiomMatch> newlyFoundIdioms = const [];
  Set<ConfigurationCompassSlot> expandedRails = const {};
  final _RailOpeningSequence railOpeningSequence = _RailOpeningSequence();
  bool isCoreSurfaceExpanded = true;
  bool isVerbRailExpanded = true;
  String verbFilterQuery = '';
  int previewCacheEntryCount = 0;

  @override
  void initState() {
    super.initState();
    configuration = ConfigurationState.initial();
    previewCache = _SentencePreviewCache(grammar, maxEntries: null);
    idiomDiscovery = IdiomDiscovery(
      finder: idiomFinder,
      foundIds: idiomProgressStore.loadFoundIds(),
    );
    moveTraceNotifier = ValueNotifier(moveTrace);
    previewCacheEntryCountNotifier = ValueNotifier(previewCacheEntryCount);
  }

  void _move(ConfigurationMove move) {
    _cancelPendingRailOpening();
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
      _recordIdiomDiscovery(nextConfiguration.sentenceState);
      suggestionCache.clear();
      final nextSentence = previewCache.render(nextConfiguration.sentenceState);
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
    _cancelPendingRailOpening();
    final logicStopwatch = Stopwatch()..start();
    final uiStopwatch = Stopwatch()..start();
    final sentence = previewCache.render(
      ConfigurationState.initial().sentenceState,
    );
    logicStopwatch.stop();

    setState(() {
      configuration = ConfigurationState.initial();
      suggestionCache.clear();
      nounNumbers = const {};
      hoveredConfiguration.value = null;
      newlyFoundIdioms = const [];
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
      suggestionCache.clear();
      _setPreviewCacheEntryCount(0);
    });
  }

  void _shuffle() {
    _cancelPendingRailOpening();
    final logicStopwatch = Stopwatch()..start();
    final uiStopwatch = Stopwatch()..start();
    final state = _randomConfigurationState();

    setState(() {
      configuration = state;
      suggestionCache.clear();
      nounNumbers = _syncNounNumbersWithState(nounNumbers, state.sentenceState);
      hoveredConfiguration.value = null;
      _recordIdiomDiscovery(state.sentenceState);
      final sentence = previewCache.render(state.sentenceState);
      logicStopwatch.stop();
      _setMoveTrace(const []);
      _appendTraceEntry(
        _MoveTraceEntry.random(sentence, elapsed: logicStopwatch.elapsed),
        uiStopwatch,
      );
      expandedRails = const {};
    });
  }

  Future<void> _startGuessSentence() async {
    _cancelPendingRailOpening();
    final logicStopwatch = Stopwatch()..start();
    final uiStopwatch = Stopwatch()..start();
    final initial = ConfigurationState.initial();
    final initialGuessTarget = widget.initialGuessTarget;
    var targetSentenceState = initialGuessTarget;
    var targetState = targetSentenceState == null
        ? _randomConfigurationState()
        : ConfigurationState(sentenceState: targetSentenceState);

    for (
      var attempt = 0;
      attempt < 8 &&
          initialGuessTarget == null &&
          targetState.sentenceState.summary == initial.sentenceState.summary;
      attempt++
    ) {
      targetState = _randomConfigurationState();
    }

    final targetSentence = previewCache.render(targetState.sentenceState);
    final target = _SentenceTarget.fromGuess(
      state: targetState.sentenceState,
      sentence: targetSentence,
    );
    logicStopwatch.stop();

    setState(() {
      configuration = initial;
      suggestionCache.clear();
      nounNumbers = const {};
      hoveredConfiguration.value = null;
      newlyFoundIdioms = const [];
      expandedRails = const {};
      _setMoveTrace(const []);
      _appendTraceEntry(
        _MoveTraceEntry.guess(elapsed: logicStopwatch.elapsed),
        uiStopwatch,
      );
    });

    final result = await showDialog<_RecognitionInputResult>(
      context: context,
      builder: (context) => _GuessSentenceDialog(
        target: target,
        recognize: _recognizeSentenceInput,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    _applyRecognizedSentence(result);
  }

  ConfigurationState _randomConfigurationState({int steps = 8}) {
    final random = Random();
    var state = ConfigurationState.initial();

    for (var step = 0; step < steps; step++) {
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

    state = lock.applyMove(
      state,
      SetTense(Tense.values[random.nextInt(Tense.values.length)]),
    );
    state = lock.applyMove(
      state,
      SetAspect(Aspect.values[random.nextInt(Aspect.values.length)]),
    );

    return state;
  }

  Future<void> _openRecognitionInput() async {
    final currentSentence = previewCache.render(configuration.sentenceState);
    final result = await showDialog<_RecognitionInputResult>(
      context: context,
      builder: (context) => _RecognitionInputDialog(
        initialSentence: currentSentence,
        recognize: _recognizeSentenceInput,
      ),
    );

    if (result == null) {
      return;
    }

    _applyRecognizedSentence(result);
  }

  _RecognitionInputAttempt _recognizeSentenceInput(String input) {
    final text = input.trim();
    if (text.isEmpty) {
      return const _RecognitionInputAttempt.empty();
    }

    final logger = _RecognitionCaptureLogger();
    final recognizer = RecognitionEngine(logger: logger);

    try {
      final state = recognizer.recognize(text);
      final canonicalSentence = grammar.generate(state).text;
      final unknownTokens = logger.diagnostics?.unknownTokens ?? const [];

      return _RecognitionInputAttempt.recognized(
        input: text,
        state: state,
        canonicalSentence: canonicalSentence,
        tokens: logger.diagnostics?.tokens ?? _recognitionTokens(text),
        unknownTokens: unknownTokens,
      );
    } catch (error) {
      return _RecognitionInputAttempt.failed(
        input: text,
        tokens: _recognitionTokens(text),
        error: logger.failureText ?? error.toString(),
      );
    }
  }

  void _applyRecognizedSentence(_RecognitionInputResult result) {
    _cancelPendingRailOpening();
    final logicStopwatch = Stopwatch()..start();
    final uiStopwatch = Stopwatch()..start();
    final target = _SentenceTarget.fromRecognizedSentence(result);

    setState(() {
      configuration = ConfigurationState(
        sentenceState: target.state,
        messages: [
          ConfigurationMessage.info(
            target.message,
            source: ConfigurationMessageSource.ui,
            lawCategory: ConfigurationLawCategory.stateUpdate,
          ),
        ],
      );
      nounNumbers = _syncNounNumbersWithState(nounNumbers, target.state);
      suggestionCache.clear();
      expandedRails = const {};
      hoveredConfiguration.value = null;
      _recordIdiomDiscovery(target.state);
      logicStopwatch.stop();
      _appendTraceEntry(
        _MoveTraceEntry.recognition(
          target.traceLabel,
          target.sentence,
          elapsed: logicStopwatch.elapsed,
        ),
        uiStopwatch,
      );
    });

    _openSentenceTargetRails(target.railPlan);
  }

  void _toggleRail(ConfigurationCompassSlot slot) {
    _cancelPendingRailOpening();
    setState(() {
      hoveredConfiguration.value = null;
      if (expandedRails.contains(slot)) {
        expandedRails = {...expandedRails}..remove(slot);
      } else {
        expandedRails = {...expandedRails, slot};
      }
    });
  }

  void _openSentenceTargetRails(_SentenceStateRailPlan railPlan) {
    railOpeningSequence.open(
      railPlan,
      isMounted: () => mounted,
      openSlot: (slot) {
        setState(() {
          expandedRails = {...expandedRails, slot};
        });
      },
    );
  }

  void _cancelPendingRailOpening() {
    railOpeningSequence.cancel();
  }

  void _recordIdiomDiscovery(SentenceState state) {
    final discovered = idiomDiscovery.record(state);
    newlyFoundIdioms = discovered;
    if (discovered.isNotEmpty) {
      idiomProgressStore.saveFoundIds(idiomDiscovery.foundIds);
    }
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
        SetRightParticle(:final rightParticle) when rightParticle != null =>
          translator.translateRightParticle(rightParticle),
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
    final limit = _suggestionLimitForSlot(slot);
    return _cachedSuggestionsForSlot(
      compass,
      slot,
      limit: limit,
      nounNumber: _nounNumberForSlot(slot),
      filterByNounNumber: _slotHasNounNumberSwitch(slot),
    );
  }

  List<ConfigurationSuggestion> _controlSuggestionsForSlot(
    ConfigurationCompassSlot slot, {
    required int limit,
  }) {
    return _cachedSuggestionsForSlot(compass, slot, limit: limit);
  }

  List<ConfigurationSuggestion> _cachedSuggestionsForSlot(
    ConfigurationCompass compass,
    ConfigurationCompassSlot slot, {
    required int limit,
    Number? nounNumber,
    bool filterByNounNumber = false,
  }) {
    final cacheKey = _SuggestionCacheKey(
      stateSummary: configuration.sentenceState.summary,
      slot: slot,
      limit: limit,
      nounNumber: nounNumber,
    );
    final cached = suggestionCache[cacheKey.value];
    if (cached != null) {
      return cached;
    }

    final suggestions = compass.suggestionsFor(
      configuration,
      slot,
      limit: limit,
    );

    if (!filterByNounNumber) {
      _cacheSuggestions(cacheKey, suggestions);
      return suggestions;
    }

    final targetNumber = nounNumber ?? Number.singular;

    final filtered = suggestions
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
    _cacheSuggestions(cacheKey, filtered);
    return filtered;
  }

  void _cacheSuggestions(
    _SuggestionCacheKey cacheKey,
    List<ConfigurationSuggestion> suggestions,
  ) {
    if (!suggestionCache.containsKey(cacheKey.value) &&
        suggestionCache.length >= _suggestionCacheEntryLimit) {
      suggestionCache.remove(suggestionCache.keys.first);
    }

    suggestionCache[cacheKey.value] = suggestions;
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
      suggestionCache.clear();

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
      suggestionCache.clear();
      final sentence = previewCache.render(configuration.sentenceState);
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
    railOpeningSequence.cancel();
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
        idiomFoundCount: idiomDiscovery.foundCount,
        idiomTotal: idiomDiscovery.total,
        foundIdioms: idiomDiscovery.foundMatches,
        onReset: _reset,
        onRandomSentence: _shuffle,
        onGuessSentence: _startGuessSentence,
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
                                        state:
                                            headerConfiguration.sentenceState,
                                        onRecognitionInput:
                                            _openRecognitionInput,
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
                                        modalSuggestions:
                                            _controlSuggestionsForSlot(
                                              ConfigurationCompassSlot.modal,
                                              limit: 9,
                                            ),
                                        passiveFocusSuggestions:
                                            _controlSuggestionsForSlot(
                                              ConfigurationCompassSlot
                                                  .passiveFocus,
                                              limit: 3,
                                            ),
                                        passiveAgentSuggestions:
                                            _controlSuggestionsForSlot(
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
                if (newlyFoundIdioms.isNotEmpty)
                  Positioned(
                    left: 16,
                    bottom: 12,
                    child: _IdiomToast(matches: newlyFoundIdioms),
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

class _SuggestionCacheKey {
  final String stateSummary;
  final ConfigurationCompassSlot slot;
  final int limit;
  final Number? nounNumber;

  const _SuggestionCacheKey({
    required this.stateSummary,
    required this.slot,
    required this.limit,
    required this.nounNumber,
  });

  String get value {
    return '$stateSummary|${slot.name}|$limit|${nounNumber?.name ?? '-'}';
  }
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
