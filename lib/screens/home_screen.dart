import 'package:flutter/material.dart';

import '../engine/grammar_engine.dart';
import '../models/sentence_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Subject subject = Subject.he;
  Tense tense = Tense.past;
  Verb verb = Verb.work;

  @override
  Widget build(BuildContext context) {
    final state = SentenceState(subject: subject, verb: verb, tense: tense);

    final grammarEngine = GrammarEngine();

    final sentence = grammarEngine.generate(state);

    print('Generated sentence: $sentence');
    return Scaffold(
      appBar: AppBar(title: const Text('English Padlock')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Left column
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      subject = Subject.he;
                    });
                  },
                  child: const Text('HE'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      subject = Subject.they;
                    });
                  },
                  child: const Text('THEY'),
                ),
              ],
            ),

            // Middle column
            Text(sentence, style: const TextStyle(fontSize: 32)),

            // Right column
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tense = Tense.past;
                    });
                  },
                  child: const Text('PAST'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tense = Tense.present;
                    });
                  },
                  child: const Text('PRESENT'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
