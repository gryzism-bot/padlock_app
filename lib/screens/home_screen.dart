import 'package:flutter/material.dart';

import '../engine/grammar_engine.dart';

import '../models/aspect.dart';
import '../models/modal.dart';
import '../models/phrase.dart';
import '../models/polarity.dart';
import '../models/sentence_form.dart';
import '../models/sentence_state.dart';
import '../models/subject.dart';
import '../models/verb.dart';
import '../models/tense.dart';

import '../data/subjects.dart';
import '../data/verbs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Subject subject = he;
  Verb verb = work;
  Tense tense = Tense.past;
  Aspect aspect = Aspect.simple;
  Modal modal = Modal.none;
  Polarity polarity = Polarity.positive;
  SentenceForm sentenceForm = SentenceForm.statement;
  Phrase? phrase;
  final GrammarEngine grammarEngine = GrammarEngine();

  @override
  Widget build(BuildContext context) {
    final state = SentenceState(
      subject: subject,
      verb: verb,
      tense: tense,
      aspect: aspect,
      modal: modal,
      polarity: polarity,
      sentenceForm: sentenceForm,
      phrase: phrase,
    );

    final sentence = grammarEngine.generate(state);

    return Scaffold(
      appBar: AppBar(title: const Text('The Lock')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // SUBJECTS
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      subject = he;
                    });
                  },
                  child: const Text('HE'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      subject = they;
                    });
                  },
                  child: const Text('THEY'),
                ),
              ],
            ),

            // VERBS
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      verb = work;
                    });
                  },
                  child: const Text('WORK'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      verb = go;
                    });
                  },
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
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tense = Tense.future;
                    });
                  },
                  child: const Text('FUTURE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
