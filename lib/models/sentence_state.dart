import '../models/aspect.dart';
import '../models/modal.dart';
import '../models/phrase.dart';
import '../models/polarity.dart';
import '../models/sentence_form.dart';
import '../models/subject.dart';
import '../models/tense.dart';
import '../models/verb.dart';

class SentenceState {
  final Subject subject;
  final Verb verb;
  final Tense tense;
  final Aspect aspect;
  final Modal modal;
  final Polarity polarity;
  final SentenceForm sentenceForm;
  final Phrase? phrase;

  const SentenceState({
    required this.subject,
    required this.verb,
    required this.tense,
    required this.aspect,
    required this.modal,
    required this.polarity,
    required this.sentenceForm,
    this.phrase,
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
Phrase: ${phrase?.text}
''';
  }
}