import 'package:flutter/material.dart';

import '../engine/grammar_engine.dart';
import '../models/sentence_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String tense = 'past';

  @override
  Widget build(BuildContext context) {
    final state = SentenceState(subject: 'he', verb: 'work', tense: tense);

    final grammarEngine = GrammarEngine();

    final sentence = grammarEngine.generate(state);

    return Scaffold(
      appBar: AppBar(title: const Text('English Padlock')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(sentence, style: const TextStyle(fontSize: 32)),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  tense = 'present';
                });
              },
              child: const Text('PRESENT'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  tense = 'past';
                });
              },
              child: const Text('PAST'),
            ),
          ],
        ),
      ),
    );
  }
}
