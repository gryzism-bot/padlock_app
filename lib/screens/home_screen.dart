import 'package:flutter/material.dart';

import '../engine/grammar_engine.dart';
import '../models/sentence_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = SentenceState(
      subject: 'he',
      verb: 'work',
      tense: 'past',
    );

    final grammarEngine = GrammarEngine();

    final sentence = grammarEngine.generate(state);

    return Scaffold(
      appBar: AppBar(
        title: const Text('English Padlock'),
      ),
      body: Center(
        child: Text(
          sentence,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}