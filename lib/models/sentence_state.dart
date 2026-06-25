import '../models/phrase.dart';

import '../models/tense.dart';
import '../models/subject.dart';
import '../models/verb.dart';

class SentenceState {
  final Subject subject;
  final Verb verb;
  final Tense tense;
  final Phrase? phrase;

  const SentenceState({
    required this.subject,
    required this.verb,
    required this.tense,
    this.phrase,
  });

  @override
  String toString() {
    return 'Subject: $subject, Verb: $verb, Tense: $tense';
  }
}
