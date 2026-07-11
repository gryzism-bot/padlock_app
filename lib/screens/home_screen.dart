import 'dart:math';

import 'package:flutter/material.dart';
import 'package:padlock_app/data/predicate/fixed_object_frames.dart';
import 'package:padlock_app/data/predicate/semantic_icons.dart';
import 'package:padlock_app/data/predicate/verb_influence.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/animals.dart';
import 'package:padlock_app/engine/configuration_compass.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/voice.dart';

part 'widgets/control_cards.dart';
part 'widgets/suggestion_chips.dart';

enum SuggestionDisplayMode { sentence, change, word }

enum HeaderPreviewMode { clicked, hover }

const _stickyHeaderHeight = 120.0;
const _stickyFooterHeight = 28.0;
const _testingPromptReserveHeight = 132.0;
const _suggestionLimit = 24;
const _chipRailMaxHeight = 164.0;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ConfigurationEngine lock = const ConfigurationEngine();
  final ConfigurationCompass compass = ConfigurationCompass();
  final GrammarEngine grammar = GrammarEngine();

  late ConfigurationState configuration;
  SuggestionDisplayMode? suggestionDisplayMode;
  HeaderPreviewMode? headerPreviewMode;
  final ValueNotifier<ConfigurationState?> hoveredConfiguration = ValueNotifier(
    null,
  );
  Number objectNumber = Number.singular;

  @override
  void initState() {
    super.initState();
    configuration = ConfigurationState.initial();
  }

  void _move(ConfigurationMove move) {
    setState(() {
      configuration = lock.applyMove(configuration, move);
      if (move case SetObject(:final object?)) {
        objectNumber = object.number;
      }
      hoveredConfiguration.value = null;
    });
  }

  void _reset() {
    setState(() {
      configuration = ConfigurationState.initial();
      objectNumber = Number.singular;
      hoveredConfiguration.value = null;
    });
  }

  void _shuffle() {
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
      objectNumber = state.sentenceState.object?.number ?? Number.singular;
      hoveredConfiguration.value = null;
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
      limit: slot == ConfigurationCompassSlot.object ? 0 : _suggestionLimit,
    );

    if (slot != ConfigurationCompassSlot.object) {
      return suggestions;
    }

    return suggestions
        .where(
          (suggestion) =>
              suggestion.preview.sentenceState.object?.number == objectNumber,
        )
        .take(_suggestionLimit)
        .toList();
  }

  void _changeObjectNumber(ConfigurationCompass compass, Number number) {
    setState(() {
      objectNumber = number;
      hoveredConfiguration.value = null;

      final object = configuration.sentenceState.object;
      if (object == null || object.number == number) {
        return;
      }

      final variant = _nounVariant(compass.objects, object, number);
      if (variant == null) {
        return;
      }

      configuration = lock.applyMove(
        configuration,
        SetObject(_carrySafeNounModifiers(object, variant)),
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
    final sentence = grammar.generate(configuration.sentenceState);

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
      bottomNavigationBar: _BottomDock(messages: configuration.messages),
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
                    currentSentence: sentence.text,
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
                    grammar: grammar,
                    configuration: configuration,
                    onMove: _move,
                    onPreviewChanged: previewMode == HeaderPreviewMode.hover
                        ? _setHoveredConfiguration
                        : null,
                  ),
                  const SizedBox(height: 8),
                  for (final section in _visibleSlotSections(compass)) ...[
                    _CompassSlotSection(
                      title: _slotTitle(section.slot, configuration),
                      unlockHint: _unlockHint(section.slot, configuration),
                      currentSentence: sentence.text,
                      displayMode: displayMode,
                      suggestions: section.suggestions,
                      nounNumber:
                          section.slot == ConfigurationCompassSlot.object
                          ? objectNumber
                          : null,
                      onNounNumberChanged:
                          section.slot == ConfigurationCompassSlot.object
                          ? (number) => _changeObjectNumber(compass, number)
                          : null,
                      grammar: grammar,
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
                  final headerSentence = grammar.generate(
                    headerConfiguration.sentenceState,
                  );

                  return _StickySentenceHeader(
                    child: _SentencePanel(
                      sentence: headerSentence.text,
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
    final sections = <_VisibleCompassSlot>[];

    for (final slot in ConfigurationCompassSlot.values.where(
      (slot) =>
          slot != ConfigurationCompassSlot.voice &&
          slot != ConfigurationCompassSlot.modal &&
          slot != ConfigurationCompassSlot.passiveFocus &&
          slot != ConfigurationCompassSlot.passiveAgent,
    )) {
      final suggestions = _suggestionsForSlot(compass, slot);
      if (!_shouldRenderSlot(slot, configuration, suggestions)) {
        continue;
      }

      sections.add(_VisibleCompassSlot(slot, suggestions));
    }

    return sections;
  }
}

class _VisibleCompassSlot {
  final ConfigurationCompassSlot slot;
  final List<ConfigurationSuggestion> suggestions;

  const _VisibleCompassSlot(this.slot, this.suggestions);
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

  const _BottomDock({required this.messages});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (messages.isNotEmpty)
          Material(
            color: colors.surface.withValues(alpha: 0.96),
            elevation: 2,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: _testingPromptReserveHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                child: SingleChildScrollView(
                  child: _GuidedMessages(messages: messages),
                ),
              ),
            ),
          ),
        const _StickyFooter(),
      ],
    );
  }
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
  final String summary;

  const _SentencePanel({required this.sentence, required this.summary});

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
              maxLines: 2,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
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
  final GrammarEngine grammar;
  final ConfigurationState configuration;
  final ValueChanged<ConfigurationMove> onMove;
  final ValueChanged<ConfigurationState?>? onPreviewChanged;

  const _ControlDeck({
    required this.currentSentence,
    required this.modalSuggestions,
    required this.passiveFocusSuggestions,
    required this.passiveAgentSuggestions,
    required this.grammar,
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
        final tenseWidth = useSingleRowControls ? unitWidth * 1.75 : cardWidth;
        final subjectWidth = useSingleRowControls ? unitWidth * 3.4 : cardWidth;
        final modalWidth = useSingleRowControls ? unitWidth * 1.85 : cardWidth;
        final voiceWidth = useSingleRowControls ? unitWidth * 1.35 : cardWidth;
        final polarityWidth = useSingleRowControls
            ? unitWidth * 0.75
            : cardWidth;
        final formWidth = useSingleRowControls ? unitWidth * 1.25 : cardWidth;

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
                grammar: grammar,
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
                grammar: grammar,
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
                  child: _ChipCluster(
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
                  child: _ChipCluster(
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
  final GrammarEngine grammar;
  final ValueChanged<ConfigurationMove> onMove;
  final ValueChanged<ConfigurationState?>? onPreviewChanged;

  const _ModalSection({
    required this.currentSentence,
    required this.modalSuggestions,
    required this.grammar,
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
            grammar: grammar,
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
  final GrammarEngine grammar;
  final ValueChanged<ConfigurationMove> onMove;
  final ValueChanged<ConfigurationState?>? onPreviewChanged;

  const _ModalSuggestionRows({
    required this.primarySuggestions,
    required this.secondarySuggestions,
    required this.currentSentence,
    required this.grammar,
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
          grammar: grammar,
          onMove: onMove,
          onPreviewChanged: onPreviewChanged,
        ),
        if (secondRowSuggestions.isNotEmpty) ...[
          const SizedBox(height: 4),
          _ModalSuggestionWrap(
            suggestions: secondRowSuggestions,
            currentSentence: currentSentence,
            grammar: grammar,
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
  final GrammarEngine grammar;
  final ValueChanged<ConfigurationMove> onMove;
  final ValueChanged<ConfigurationState?>? onPreviewChanged;

  const _ModalSuggestionWrap({
    required this.suggestions,
    required this.currentSentence,
    required this.grammar,
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
            preview: grammar.generate(suggestion.preview.sentenceState).text,
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

class _VoiceSection extends StatelessWidget {
  final String currentSentence;
  final Voice voice;
  final List<ConfigurationSuggestion> passiveFocusSuggestions;
  final List<ConfigurationSuggestion> passiveAgentSuggestions;
  final GrammarEngine grammar;
  final ValueChanged<ConfigurationMove> onMove;
  final ValueChanged<ConfigurationState?>? onPreviewChanged;

  const _VoiceSection({
    required this.currentSentence,
    required this.voice,
    required this.passiveFocusSuggestions,
    required this.passiveAgentSuggestions,
    required this.grammar,
    required this.onMove,
    required this.onPreviewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _ControlCard(
      title: 'Voice',
      children: [
        _ChipCluster(
          label: 'voice',
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
          _ChipCluster(
            label: 'passive focus',
            children: [
              for (final suggestion in passiveFocusSuggestions)
                _SuggestionButton(
                  suggestion: suggestion,
                  currentSentence: currentSentence,
                  displayMode: SuggestionDisplayMode.word,
                  preview: grammar
                      .generate(suggestion.preview.sentenceState)
                      .text,
                  onPressed: () => onMove(suggestion.move),
                  onPreviewChanged: onPreviewChanged,
                ),
            ],
          ),
        if (passiveAgentSuggestions.isNotEmpty)
          _ChipCluster(
            label: 'passive agent',
            children: [
              for (final suggestion in passiveAgentSuggestions)
                _SuggestionButton(
                  suggestion: suggestion,
                  currentSentence: currentSentence,
                  displayMode: SuggestionDisplayMode.word,
                  preview: grammar
                      .generate(suggestion.preview.sentenceState)
                      .text,
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
  final String currentSentence;
  final SuggestionDisplayMode displayMode;
  final List<ConfigurationSuggestion> suggestions;
  final Number? nounNumber;
  final ValueChanged<Number>? onNounNumberChanged;
  final GrammarEngine grammar;
  final ValueChanged<ConfigurationMove> onMove;
  final ValueChanged<ConfigurationState?>? onPreviewChanged;

  const _CompassSlotSection({
    required this.title,
    required this.unlockHint,
    required this.currentSentence,
    required this.displayMode,
    required this.suggestions,
    required this.nounNumber,
    required this.onNounNumberChanged,
    required this.grammar,
    required this.onMove,
    required this.onPreviewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionFrame(
      title: title,
      controls: [
        if (suggestions.isNotEmpty &&
            nounNumber != null &&
            onNounNumberChanged != null)
          _NounNumberSwitch(
            value: nounNumber!,
            onChanged: onNounNumberChanged!,
          ),
      ],
      children: suggestions.isEmpty
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
                  preview: grammar
                      .generate(suggestion.preview.sentenceState)
                      .text,
                  onPressed: () => onMove(suggestion.move),
                  onPreviewChanged: onPreviewChanged,
                ),
            ],
    );
  }
}

bool _sameNounPhrase(NounPhrase? left, NounPhrase right) {
  return left != null &&
      left.text == right.text &&
      left.person == right.person &&
      left.number == right.number;
}

NounPhrase? _nounVariant(
  List<NounPhrase> candidates,
  NounPhrase current,
  Number number,
) {
  for (final candidate in candidates) {
    if (candidate.number == number && _sameNounFamily(candidate, current)) {
      return candidate;
    }
  }

  return null;
}

bool _sameNounFamily(NounPhrase left, NounPhrase right) {
  return _nounFamilyKey(left.text) == _nounFamilyKey(right.text);
}

String _nounFamilyKey(String text) {
  final lower = text.toLowerCase();

  if (lower.endsWith('ies')) {
    return '${lower.substring(0, lower.length - 3)}y';
  }

  if (lower.endsWith('ves')) {
    return '${lower.substring(0, lower.length - 3)}fe';
  }

  if (lower.endsWith('ses')) {
    return lower.substring(0, lower.length - 1);
  }

  if (lower.endsWith('es')) {
    return lower.substring(0, lower.length - 2);
  }

  if (lower.endsWith('s')) {
    return lower.substring(0, lower.length - 1);
  }

  return lower;
}

NounPhrase _carrySafeNounModifiers(NounPhrase previous, NounPhrase next) {
  final adjectives = previous.adjectiveList;

  return next.copyWith(
    determiner: _safeDeterminerForNumber(previous, next.number),
    adjective: adjectives.isEmpty ? null : adjectives.first,
    adjectives: adjectives,
  );
}

Object? _safeDeterminerForNumber(NounPhrase previous, Number number) {
  final determiner = previous.determiner;
  if (determiner == null) {
    return null;
  }

  final text = determiner.text;
  if (number == Number.plural &&
      const {'a', 'an', 'this', 'that', 'each', 'every'}.contains(text)) {
    return null;
  }

  if (number == Number.singular &&
      const {'these', 'those', 'many'}.contains(text)) {
    return null;
  }

  return determiner;
}

String _slotTitle(
  ConfigurationCompassSlot slot,
  ConfigurationState configuration,
) {
  return switch (slot) {
    ConfigurationCompassSlot.action => 'Verb',
    ConfigurationCompassSlot.object =>
      _fixedObjectSlotTitle(configuration) ?? 'Object',
    ConfigurationCompassSlot.objectDeterminer => 'Object determiner',
    ConfigurationCompassSlot.objectAdjective => 'Object adjective',
    ConfigurationCompassSlot.recipient => 'Recipient',
    ConfigurationCompassSlot.recipientDeterminer => 'Recipient determiner',
    ConfigurationCompassSlot.recipientAdjective => 'Recipient adjective',
    ConfigurationCompassSlot.complement => 'Noun complement',
    ConfigurationCompassSlot.complementDeterminer => 'Complement determiner',
    ConfigurationCompassSlot.complementAdjective => 'Complement adjective',
    ConfigurationCompassSlot.adjectiveComplement => 'Adjective complement',
    ConfigurationCompassSlot.voice => 'Voice',
    ConfigurationCompassSlot.passiveFocus => 'Passive focus',
    ConfigurationCompassSlot.passiveAgent => 'Passive agent',
    ConfigurationCompassSlot.modal => 'Modal',
    ConfigurationCompassSlot.placePhrase => 'Place phrase',
    ConfigurationCompassSlot.timePhrase => 'Time phrase',
  };
}

bool _shouldRenderSlot(
  ConfigurationCompassSlot slot,
  ConfigurationState configuration,
  List<ConfigurationSuggestion> suggestions,
) {
  if (suggestions.isNotEmpty) {
    return true;
  }

  final state = configuration.sentenceState;

  return switch (slot) {
    ConfigurationCompassSlot.action ||
    ConfigurationCompassSlot.placePhrase ||
    ConfigurationCompassSlot.timePhrase => true,
    ConfigurationCompassSlot.object => state.object != null,
    ConfigurationCompassSlot.objectDeterminer ||
    ConfigurationCompassSlot.objectAdjective =>
      state.object != null && !hasFixedObjectFrame(state.action),
    ConfigurationCompassSlot.recipient => state.recipient != null,
    ConfigurationCompassSlot.recipientDeterminer ||
    ConfigurationCompassSlot.recipientAdjective => state.recipient != null,
    ConfigurationCompassSlot.complement => state.complement != null,
    ConfigurationCompassSlot.complementDeterminer ||
    ConfigurationCompassSlot.complementAdjective => state.complement != null,
    ConfigurationCompassSlot.adjectiveComplement =>
      state.adjectiveComplement != null,
    ConfigurationCompassSlot.voice ||
    ConfigurationCompassSlot.passiveFocus ||
    ConfigurationCompassSlot.passiveAgent ||
    ConfigurationCompassSlot.modal => false,
  };
}

String _unlockHint(
  ConfigurationCompassSlot slot,
  ConfigurationState configuration,
) {
  final state = configuration.sentenceState;

  return switch (slot) {
    ConfigurationCompassSlot.object =>
      fixedObjectFrameLabel(state.action) == null
          ? 'Choose a verb that can take an object, like build, give, need, see, or use.'
          : 'Choose a fixed ${fixedObjectFrameLabel(state.action)} for ${state.action.infinitive}.',
    ConfigurationCompassSlot.objectDeterminer ||
    ConfigurationCompassSlot.objectAdjective =>
      hasFixedObjectFrame(state.action)
          ? '${state.action.infinitive} fixed ${fixedObjectFrameLabel(state.action)} choices stay bare.'
          : 'Choose an object first. Noun phrase modifiers wake after a noun exists.',
    ConfigurationCompassSlot.recipient =>
      'Choose a ditransitive verb like give, tell, teach, write, or buy, then keep an object active.',
    ConfigurationCompassSlot.recipientDeterminer ||
    ConfigurationCompassSlot.recipientAdjective =>
      'Choose a recipient first. Recipient modifiers wake after that noun exists.',
    ConfigurationCompassSlot.complement =>
      'Choose verb be first. Noun complements belong to the be frame.',
    ConfigurationCompassSlot.complementDeterminer ||
    ConfigurationCompassSlot.complementAdjective =>
      'Choose verb be, then choose a noun complement. Complement modifiers wake after that noun exists.',
    ConfigurationCompassSlot.adjectiveComplement =>
      'Choose verb be first. Adjective complements belong to the be frame.',
    ConfigurationCompassSlot.voice =>
      'Choose an object-capable verb and an object first. Passive opens after there is something to promote.',
    ConfigurationCompassSlot.passiveFocus =>
      'Turn passive voice on first. Recipient focus also needs a recipient-capable verb and a recipient.',
    ConfigurationCompassSlot.passiveAgent =>
      'Turn passive voice on first. The by-agent phrase can be hidden while the agent stays in state.',
    ConfigurationCompassSlot.modal =>
      'No modal fits this tense/frame from here.',
    ConfigurationCompassSlot.action ||
    ConfigurationCompassSlot.placePhrase ||
    ConfigurationCompassSlot.timePhrase => 'No open move from here.',
  };
}

String? _fixedObjectSlotTitle(ConfigurationState configuration) {
  final label = fixedObjectFrameLabel(configuration.sentenceState.action);
  if (label == null) {
    return null;
  }

  return '${label[0].toUpperCase()}${label.substring(1)}';
}
