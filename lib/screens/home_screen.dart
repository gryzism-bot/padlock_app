import 'dart:math';

import 'package:flutter/material.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/engine/configuration_compass.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';

enum SuggestionDisplayMode { sentence, change, word }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ConfigurationEngine lock = const ConfigurationEngine();
  final GrammarEngine grammar = GrammarEngine();

  late ConfigurationState configuration;
  SuggestionDisplayMode? suggestionDisplayMode;

  @override
  void initState() {
    super.initState();
    configuration = ConfigurationState.initial();
  }

  void _move(ConfigurationMove move) {
    setState(() {
      configuration = lock.applyMove(configuration, move);
    });
  }

  void _reset() {
    setState(() {
      configuration = ConfigurationState.initial();
    });
  }

  void _shuffle() {
    final compass = ConfigurationCompass();
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final compass = ConfigurationCompass();
    final displayMode = suggestionDisplayMode ?? SuggestionDisplayMode.change;
    final sentence = grammar.generate(configuration.sentenceState);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Padlock Guided Mode'),
        actions: [
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
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SentencePanel(
                sentence: sentence.text,
                summary: configuration.sentenceState.summary,
              ),
              const SizedBox(height: 12),
              _GuidedMessages(messages: configuration.messages),
              const SizedBox(height: 16),
              _DisplayModeSection(
                value: displayMode,
                onChanged: (mode) {
                  setState(() {
                    suggestionDisplayMode = mode;
                  });
                },
              ),
              const SizedBox(height: 16),
              _ManualSection(onMove: _move),
              const SizedBox(height: 16),
              for (final slot in ConfigurationCompassSlot.values) ...[
                _CompassSlotSection(
                  title: _slotTitle(slot),
                  currentValue: _currentValue(slot, configuration),
                  unlockHint: _unlockHint(slot, configuration),
                  currentSentence: sentence.text,
                  displayMode: displayMode,
                  suggestions: compass.suggestionsFor(
                    configuration,
                    slot,
                    limit: 6,
                  ),
                  grammar: grammar,
                  onMove: _move,
                ),
                const SizedBox(height: 10),
              ],
            ],
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sentence,
              key: const Key('rendered-sentence'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(summary, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ManualSection extends StatelessWidget {
  final ValueChanged<ConfigurationMove> onMove;

  const _ManualSection({required this.onMove});

  @override
  Widget build(BuildContext context) {
    return _SectionFrame(
      title: 'Manual lock probes',
      subtitle: 'These buttons can hit the lock directly.',
      children: [
        _MoveButton(label: 'he', onPressed: () => onMove(const SetAgent(he))),
        _MoveButton(
          label: 'they',
          onPressed: () => onMove(const SetAgent(they)),
        ),
        _MoveButton(
          label: 'no agent',
          onPressed: () => onMove(const SetAgent(null)),
        ),
        _MoveButton(
          label: 'present',
          onPressed: () => onMove(const SetTense(Tense.present)),
        ),
        _MoveButton(
          label: 'past',
          onPressed: () => onMove(const SetTense(Tense.past)),
        ),
        _MoveButton(
          label: 'future',
          onPressed: () => onMove(const SetTense(Tense.future)),
        ),
        _MoveButton(
          label: 'simple',
          onPressed: () => onMove(const SetAspect(Aspect.simple)),
        ),
        _MoveButton(
          label: 'continuous',
          onPressed: () => onMove(const SetAspect(Aspect.continuous)),
        ),
        _MoveButton(
          label: 'perfect',
          onPressed: () => onMove(const SetAspect(Aspect.perfect)),
        ),
        _MoveButton(
          label: 'negative',
          onPressed: () => onMove(const SetPolarity(Polarity.negative)),
        ),
        _MoveButton(
          label: 'positive',
          onPressed: () => onMove(const SetPolarity(Polarity.positive)),
        ),
        _MoveButton(
          label: 'statement',
          onPressed: () =>
              onMove(const SetSentenceForm(SentenceForm.statement)),
        ),
        _MoveButton(
          label: 'question',
          onPressed: () => onMove(const SetSentenceForm(SentenceForm.question)),
        ),
        _MoveButton(
          label: 'imperative',
          onPressed: () =>
              onMove(const SetSentenceForm(SentenceForm.imperative)),
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

class _CompassSlotSection extends StatelessWidget {
  final String title;
  final String currentValue;
  final String unlockHint;
  final String currentSentence;
  final SuggestionDisplayMode displayMode;
  final List<ConfigurationSuggestion> suggestions;
  final GrammarEngine grammar;
  final ValueChanged<ConfigurationMove> onMove;

  const _CompassSlotSection({
    required this.title,
    required this.currentValue,
    required this.unlockHint,
    required this.currentSentence,
    required this.displayMode,
    required this.suggestions,
    required this.grammar,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionFrame(
      title: title,
      subtitle: 'Current: $currentValue',
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
                ),
            ],
    );
  }
}

class _SectionFrame extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _SectionFrame({
    required this.title,
    required this.subtitle,
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: children),
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

  const _SuggestionButton({
    required this.suggestion,
    required this.currentSentence,
    required this.displayMode,
    required this.preview,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: suggestion.isSelected ? 'Current: $preview' : preview,
      child: OutlinedButton(
        style: suggestion.isSelected
            ? OutlinedButton.styleFrom(
                foregroundColor: colors.onPrimaryContainer,
                backgroundColor: colors.primaryContainer,
                side: BorderSide(color: colors.primary),
              )
            : null,
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
    color: suggestion.isSelected ? colors.onPrimaryContainer : colors.onSurface,
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

  return (start: start, end: previewEnd);
}

class _MoveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _MoveButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(onPressed: onPressed, child: Text(label));
  }
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
