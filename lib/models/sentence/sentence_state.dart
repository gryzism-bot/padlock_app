import '../grammar/aspect.dart';
import '../grammar/modal.dart';
import '../grammar/phrase.dart';
import '../grammar/polarity.dart';
import '../grammar/sentence_form.dart';
import '../grammar/subject.dart';
import '../grammar/tense.dart';
import '../grammar/verb.dart';

class SentenceState {
  final Subject subject; // open
  final Verb verb; // open
  final Tense tense; 
  final Aspect aspect; 
  final Modal modal; 
  final Polarity polarity; 
  final SentenceForm sentenceForm; 
  final Phrase? phrase; // open

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
