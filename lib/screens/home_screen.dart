import 'package:flutter/material.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';

import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/verbs/essential.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ConfigurationEngine configurationEngine = const ConfigurationEngine();
  final GrammarEngine grammarEngine = GrammarEngine();

  late ConfigurationState configuration;

  @override
  void initState() {
    super.initState();
    configuration = ConfigurationState.initial();
  }

  void _move(ConfigurationMove move) {
    setState(() {
      configuration = configurationEngine.applyMove(configuration, move);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sentence = grammarEngine.generate(configuration.sentenceState);

    return Scaffold(
      appBar: AppBar(title: const Text('The Lock - Guided')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // SUBJECTS
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => _move(const SetAgent(he)),
                      child: const Text('HE'),
                    ),
                    ElevatedButton(
                      onPressed: () => _move(const SetAgent(they)),
                      child: const Text('THEY'),
                    ),
                    ElevatedButton(
                      onPressed: () => _move(const SetAgent(null)),
                      child: const Text('NO AGENT'),
                    ),
                  ],
                ),

                // VERBS
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => _move(const SetAction(work)),
                      child: const Text('WORK'),
                    ),
                    ElevatedButton(
                      onPressed: () => _move(const SetAction(go)),
                      child: const Text('GO'),
                    ),
                  ],
                ),

                // SENTENCE
                SizedBox(
                  width: 220,
                  child: Text(
                    sentence.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),

                // TENSES
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => _move(const SetTense(Tense.past)),
                      child: const Text('PAST'),
                    ),
                    ElevatedButton(
                      onPressed: () => _move(const SetTense(Tense.present)),
                      child: const Text('PRESENT'),
                    ),
                    ElevatedButton(
                      onPressed: () => _move(const SetTense(Tense.future)),
                      child: const Text('FUTURE'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _GuidedMessages(messages: configuration.messages),
          ],
        ),
      ),
    );
  }
}

class _GuidedMessages extends StatelessWidget {
  final List<ConfigurationMessage> messages;

  const _GuidedMessages({required this.messages});

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const SizedBox(height: 24);
    }

    return SizedBox(
      height: 48,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final message in messages.take(2))
            Text(
              message.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: message.kind == ConfigurationMessageKind.blocked
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
