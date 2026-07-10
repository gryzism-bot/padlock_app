import 'dart:math';

import 'package:flutter/material.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/animals.dart';
import 'package:padlock_app/engine/configuration_compass.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/voice.dart';

enum SuggestionDisplayMode { sentence, change, word }

enum HeaderPreviewMode { clicked, hover }

const _stickyHeaderHeight = 120.0;
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
  ConfigurationState? hoveredConfiguration;
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
      hoveredConfiguration = null;
    });
  }

  void _reset() {
    setState(() {
      configuration = ConfigurationState.initial();
      objectNumber = Number.singular;
      hoveredConfiguration = null;
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
      hoveredConfiguration = null;
    });
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
      hoveredConfiguration = null;

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
  Widget build(BuildContext context) {
    final displayMode = suggestionDisplayMode ?? SuggestionDisplayMode.change;
    final previewMode = headerPreviewMode ?? HeaderPreviewMode.clicked;
    final headerConfiguration =
        previewMode == HeaderPreviewMode.hover && hoveredConfiguration != null
        ? hoveredConfiguration!
        : configuration;
    final sentence = grammar.generate(configuration.sentenceState);
    final headerSentence = grammar.generate(headerConfiguration.sentenceState);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Padlock Guided Mode'),
        actions: [
          _AppBarTools(
            previewMode: previewMode,
            onPreviewModeChanged: (mode) {
              setState(() {
                headerPreviewMode = mode;
                hoveredConfiguration = null;
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
                  _GuidedMessages(messages: configuration.messages),
                  const SizedBox(height: 8),
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
                    grammar: grammar,
                    configuration: configuration,
                    onMove: _move,
                    onPreviewChanged: previewMode == HeaderPreviewMode.hover
                        ? (preview) {
                            setState(() {
                              hoveredConfiguration = preview;
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: 8),
                  for (final slot in ConfigurationCompassSlot.values.where(
                    (slot) =>
                        slot != ConfigurationCompassSlot.voice &&
                        slot != ConfigurationCompassSlot.modal &&
                        slot != ConfigurationCompassSlot.passiveFocus,
                  )) ...[
                    _CompassSlotSection(
                      title: _slotTitle(slot),
                      currentValue: _currentValue(slot, configuration),
                      unlockHint: _unlockHint(slot, configuration),
                      currentSentence: sentence.text,
                      displayMode: displayMode,
                      suggestions: _suggestionsForSlot(compass, slot),
                      nounNumber: slot == ConfigurationCompassSlot.object
                          ? objectNumber
                          : null,
                      onNounNumberChanged:
                          slot == ConfigurationCompassSlot.object
                          ? (number) => _changeObjectNumber(compass, number)
                          : null,
                      grammar: grammar,
                      onMove: _move,
                      onPreviewChanged: previewMode == HeaderPreviewMode.hover
                          ? (preview) {
                              setState(() {
                                hoveredConfiguration = preview;
                              });
                            }
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
              child: _StickySentenceHeader(
                child: _SentencePanel(
                  sentence: headerSentence.text,
                  summary: headerConfiguration.sentenceState.summary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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

class _StickySentenceHeader extends StatelessWidget {
  final Widget child;

  const _StickySentenceHeader({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: Material(
        color: colors.surface.withValues(alpha: 0.96),
        elevation: 2,
        child: SizedBox(
          height: _stickyHeaderHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: child,
          ),
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
            Text(
              sentence,
              key: const Key('rendered-sentence'),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              summary,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
  final GrammarEngine grammar;
  final ConfigurationState configuration;
  final ValueChanged<ConfigurationMove> onMove;
  final ValueChanged<ConfigurationState?>? onPreviewChanged;

  const _ControlDeck({
    required this.currentSentence,
    required this.modalSuggestions,
    required this.passiveFocusSuggestions,
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
        final cardWidth = width >= 1160
            ? (width - 40) / 6
            : width >= 1040
            ? (width - 20) / 3
            : width >= 760
            ? (width - 10) / 2
            : width;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SizedBox(
              width: cardWidth,
              child: _TenseAspectSection(
                tense: configuration.sentenceState.tense,
                aspect: configuration.sentenceState.aspect,
                onMove: onMove,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _PronounSection(
                agent: configuration.sentenceState.agent,
                onMove: onMove,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _ModalSection(
                currentSentence: currentSentence,
                modalSuggestions: modalSuggestions,
                grammar: grammar,
                onMove: onMove,
                onPreviewChanged: onPreviewChanged,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _VoiceSection(
                currentSentence: currentSentence,
                voice: configuration.sentenceState.voice,
                passiveFocusSuggestions: passiveFocusSuggestions,
                grammar: grammar,
                onMove: onMove,
                onPreviewChanged: onPreviewChanged,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _PolaritySection(
                polarity: configuration.sentenceState.polarity,
                onMove: onMove,
              ),
            ),
            SizedBox(
              width: cardWidth,
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
    return _VerticalControlCard(
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
    return _VerticalControlCard(
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
                      _ChipCluster(
                        label: '3rd person',
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
                      _ChipCluster(
                        label: '3rd person',
                        children: [
                          _MoveButton(
                            label: 'they',
                            selected: _sameNounPhrase(agent, they),
                            onPressed: () => onMove(const SetAgent(they)),
                          ),
                        ],
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
        _ChipCluster(
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
        _ChipCluster(
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
    return _ControlCard(
      title: 'Modal',
      children: [
        if (modalSuggestions.isEmpty)
          Text(
            'No modal from here.',
            style: TextStyle(color: Theme.of(context).disabledColor),
          )
        else
          for (final suggestion in modalSuggestions)
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

class _VoiceSection extends StatelessWidget {
  final String currentSentence;
  final Voice voice;
  final List<ConfigurationSuggestion> passiveFocusSuggestions;
  final GrammarEngine grammar;
  final ValueChanged<ConfigurationMove> onMove;
  final ValueChanged<ConfigurationState?>? onPreviewChanged;

  const _VoiceSection({
    required this.currentSentence,
    required this.voice,
    required this.passiveFocusSuggestions,
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
  final String currentValue;
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
    required this.currentValue,
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
      subtitle: 'Current: $currentValue',
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

class _VerticalControlCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _VerticalControlCard({required this.title, required this.children});

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
            for (final child in children) ...[child, const SizedBox(height: 6)],
          ],
        ),
      ),
    );
  }
}

class _SectionFrame extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> controls;
  final List<Widget> children;

  const _SectionFrame({
    required this.title,
    required this.subtitle,
    this.controls = const [],
    required this.children,
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
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (controls.isNotEmpty)
                  Wrap(spacing: 6, runSpacing: 6, children: controls),
              ],
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: _chipRailMaxHeight),
              child: SingleChildScrollView(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(spacing: 6, runSpacing: 6, children: children),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipCluster extends StatelessWidget {
  final String label;
  final List<Widget> children;
  final String? expandedLabel;
  final List<Widget> expandedChildren;

  const _ChipCluster({
    required this.label,
    required this.children,
    this.expandedLabel,
    this.expandedChildren = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (expandedChildren.isNotEmpty) {
      return _ExpandableChipCluster(
        label: label,
        expandedLabel: expandedLabel ?? label,
        children: children,
        expandedChildren: expandedChildren,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 4),
            Wrap(spacing: 6, runSpacing: 6, children: children),
          ],
        ),
      ),
    );
  }
}

class _ExpandableChipCluster extends StatefulWidget {
  final String label;
  final String expandedLabel;
  final List<Widget> children;
  final List<Widget> expandedChildren;

  const _ExpandableChipCluster({
    required this.label,
    required this.expandedLabel,
    required this.children,
    required this.expandedChildren,
  });

  @override
  State<_ExpandableChipCluster> createState() => _ExpandableChipClusterState();
}

class _ExpandableChipClusterState extends State<_ExpandableChipCluster> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                const SizedBox(width: 2),
                IconButton(
                  tooltip: isExpanded
                      ? 'Hide ${widget.expandedLabel}'
                      : 'Show ${widget.expandedLabel}',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 24,
                    height: 24,
                  ),
                  iconSize: 16,
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(spacing: 6, runSpacing: 6, children: widget.children),
            if (isExpanded) ...[
              const SizedBox(height: 6),
              Text(
                widget.expandedLabel,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: colors.primary),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.expandedChildren,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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

    return MouseRegion(
      onEnter: (_) => onPreviewChanged?.call(suggestion.preview),
      onHover: (_) => onPreviewChanged?.call(suggestion.preview),
      onExit: (_) => onPreviewChanged?.call(null),
      child: Tooltip(
        message: suggestion.isSelected ? 'Current: $preview' : preview,
        child: OutlinedButton(
          style: _compactOutlinedStyle(
            selected: suggestion.isSelected,
            colors: colors,
          ),
          onPressed: onPressed,
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
      ),
    );
  }
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

class _GuidedMessages extends StatelessWidget {
  final List<ConfigurationMessage> messages;

  const _GuidedMessages({required this.messages});

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final message in messages)
          Text(
            message.text,
            style: TextStyle(
              color: message.kind == ConfigurationMessageKind.blocked
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }
}

String _slotTitle(ConfigurationCompassSlot slot) {
  return switch (slot) {
    ConfigurationCompassSlot.action => 'Verb',
    ConfigurationCompassSlot.object => 'Object',
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
    ConfigurationCompassSlot.modal => 'Modal',
    ConfigurationCompassSlot.placePhrase => 'Place phrase',
    ConfigurationCompassSlot.timePhrase => 'Time phrase',
  };
}

String _currentValue(
  ConfigurationCompassSlot slot,
  ConfigurationState configuration,
) {
  final state = configuration.sentenceState;

  return switch (slot) {
    ConfigurationCompassSlot.action => state.action.infinitive,
    ConfigurationCompassSlot.object => state.object?.text ?? '-',
    ConfigurationCompassSlot.objectDeterminer =>
      state.object?.determiner?.text ?? '-',
    ConfigurationCompassSlot.objectAdjective => _adjectiveValue(
      state.object?.adjectiveList,
    ),
    ConfigurationCompassSlot.recipient => state.recipient?.text ?? '-',
    ConfigurationCompassSlot.recipientDeterminer =>
      state.recipient?.determiner?.text ?? '-',
    ConfigurationCompassSlot.recipientAdjective => _adjectiveValue(
      state.recipient?.adjectiveList,
    ),
    ConfigurationCompassSlot.complement => state.complement?.text ?? '-',
    ConfigurationCompassSlot.complementDeterminer =>
      state.complement?.determiner?.text ?? '-',
    ConfigurationCompassSlot.complementAdjective => _adjectiveValue(
      state.complement?.adjectiveList,
    ),
    ConfigurationCompassSlot.adjectiveComplement =>
      state.adjectiveComplement?.text ?? '-',
    ConfigurationCompassSlot.voice => state.voice.name,
    ConfigurationCompassSlot.passiveFocus => state.passiveFocus?.name ?? '-',
    ConfigurationCompassSlot.modal =>
      state.modal.isNone ? 'no modal' : state.modal.text,
    ConfigurationCompassSlot.placePhrase => state.placePhrase?.noun ?? '-',
    ConfigurationCompassSlot.timePhrase => state.timePhrase?.text ?? '-',
  };
}

String _unlockHint(
  ConfigurationCompassSlot slot,
  ConfigurationState configuration,
) {
  final state = configuration.sentenceState;

  return switch (slot) {
    ConfigurationCompassSlot.object =>
      'Choose a verb that can take an object, like build, give, need, see, or use.',
    ConfigurationCompassSlot.objectDeterminer ||
    ConfigurationCompassSlot.objectAdjective =>
      'Choose an object first. Noun phrase modifiers wake after a noun exists.',
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
    ConfigurationCompassSlot.modal =>
      'No modal fits this tense/frame from here.',
    ConfigurationCompassSlot.action ||
    ConfigurationCompassSlot.placePhrase ||
    ConfigurationCompassSlot.timePhrase => 'No open move from here.',
  };
}

String _adjectiveValue(List<Adjective>? adjectives) {
  if (adjectives == null || adjectives.isEmpty) {
    return '-';
  }

  return adjectives.map((adjective) => adjective.text).join(', ');
}
