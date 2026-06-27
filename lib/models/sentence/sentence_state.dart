import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/phrase/place_phrase.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/subject.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/phrase/time_phrase.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/grammar/voice.dart';

class SentenceState {
  final Subject subject; // open
  final Verb verb; // open
  final Tense tense;
  final Aspect aspect;
  final Modal modal;
  final Polarity polarity;
  final SentenceForm sentenceForm;
  final Voice voice;
  final TimePhrase? timePhrase; //open
  final PlacePhrase? placePhrase; //open

  const SentenceState({
    required this.subject,
    required this.verb,
    required this.tense,
    required this.aspect,
    required this.modal,
    required this.polarity,
    required this.sentenceForm,
    required this.voice,
    this.timePhrase,
    this.placePhrase,
  });

  @override
  String toString() {
    return '''
Subject: ${subject.text}
Verb: ${verb.infinitive}
Tense: $tense
Aspect: $aspect
Modal: $modal
Polarity: $polarity
Form: $sentenceForm
Voice: $voice
Time Phrase: ${timePhrase?.text}
Place Phrase: ${placePhrase?.text}
''';
  }
}
