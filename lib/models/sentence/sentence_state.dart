import '../grammar/verb/aspect.dart';
import '../grammar/verb/modal.dart';
import '../grammar/phrase/place_phrase.dart';
import '../grammar/verb/polarity.dart';
import '../grammar/sentence_form.dart';
import '../grammar/subject/subject.dart';
import '../grammar/verb/tense.dart';
import '../grammar/phrase/time_phrase.dart';
import '../grammar/verb/verb.dart';

class SentenceState {
  final Subject subject; // open
  final Verb verb; // open
  final Tense tense;
  final Aspect aspect;
  final Modal modal;
  final Polarity polarity;
  final SentenceForm sentenceForm;
  final TimePhrase? timePhrase;
  final PlacePhrase? placePhrase;

  const SentenceState({
    required this.subject,
    required this.verb,
    required this.tense,
    required this.aspect,
    required this.modal,
    required this.polarity,
    required this.sentenceForm,
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
Time Phrase: ${timePhrase?.text}
Place Phrase: ${placePhrase?.text}
''';
  }
}
