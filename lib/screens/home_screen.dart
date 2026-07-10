import 'package:flutter/material.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/engine/configuration_compass.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';

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

  @override
  Widget build(BuildContext context) {
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
              _ManualSection(onMove: _move),
              const SizedBox(height: 16),
              for (final slot in ConfigurationCompassSlot.values) ...[
                _CompassSlotSection(
                  title: _slotTitle(slot),
                  currentValue: _currentValue(slot, configuration),
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
            Text(sentence, style: Theme.of(context).textTheme.headlineMedium),
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

class _CompassSlotSection extends StatelessWidget {
  final String title;
  final String currentValue;
  final List<ConfigurationSuggestion> suggestions;
  final GrammarEngine grammar;
  final ValueChanged<ConfigurationMove> onMove;

  const _CompassSlotSection({
    required this.title,
    required this.currentValue,
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
                'No open move from here.',
                style: TextStyle(color: Theme.of(context).disabledColor),
              ),
            ]
          : [
              for (final suggestion in suggestions)
                _SuggestionButton(
                  suggestion: suggestion,
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
  final String preview;
  final VoidCallback onPressed;

  const _SuggestionButton({
    required this.suggestion,
    required this.preview,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: preview,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text('${suggestion.label} -> $preview'),
      ),
    );
  }
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
    ConfigurationCompassSlot.recipient => 'Recipient',
    ConfigurationCompassSlot.complement => 'Noun complement',
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
    ConfigurationCompassSlot.recipient => state.recipient?.text ?? '-',
    ConfigurationCompassSlot.complement => state.complement?.text ?? '-',
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
