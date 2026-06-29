import 'package:flutter/material.dart';
import 'package:padlock_app/data/modals.dart';

import 'package:padlock_app/engine/grammar_engine.dart';

import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/phrase/place_phrase.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/phrase/time_phrase.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';

import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/verbs/essential.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NounPhrase subject = he;
  Verb verb = work;
  Tense tense = Tense.past;
  Aspect aspect = Aspect.simple;
  Modal modal = noModal;
  Polarity polarity = Polarity.positive;
  SentenceForm sentenceForm = SentenceForm.statement;
  Voice voice = Voice.active;
  TimePhrase? timePhrase;
  PlacePhrase? placePhrase;
  final GrammarEngine grammarEngine = GrammarEngine();

  @override
  Widget build(BuildContext context) {
    final state = SentenceState(
      agent: subject,
      action: verb,
      tense: tense,
      aspect: aspect,
      modal: modal,
      polarity: polarity,
      sentenceForm: sentenceForm,
      voice: voice,
      timePhrase: timePhrase,
      placePhrase: placePhrase,
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
