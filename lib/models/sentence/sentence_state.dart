import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/models/grammar/phrase/frequency_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/manner_phrase.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/phrase/place_phrase.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/phrase/time_phrase.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/grammar/voice.dart';

class SentenceState {
  final NounPhrase? agent;
  final Verb action;
  final NounPhrase? object;
  final NounPhrase? recipient;

  final Voice voice;
  final PassiveFocus? passiveFocus;

  final Tense tense;
  final Aspect aspect;

  final Modal modal;
  final Polarity polarity;

  final SentenceForm sentenceForm;

  final TimePhrase? timePhrase;
  final PlacePhrase? placePhrase;
  final FrequencyPhrase? frequencyPhrase;
  final MannerPhrase? mannerPhrase;

  const SentenceState({
    this.agent,
    required this.action,
    this.object,
    this.recipient,

    this.voice = Voice.active,
    this.passiveFocus,

    required this.tense,
    required this.aspect,

    this.modal = noModal,
    this.polarity = Polarity.positive,

    this.sentenceForm = SentenceForm.statement,

    this.timePhrase,
    this.placePhrase,
    this.frequencyPhrase,
    this.mannerPhrase,
  });

  @override
  String toString() {
    return '''
Agent: ${agent?.text}
Action: ${action.infinitive}
Object: ${object?.text}
Recipient: ${recipient?.text}
Tense: $tense
Aspect: $aspect
Modal: $modal
Polarity: $polarity
Form: $sentenceForm
Voice: $voice
Passive Focus: $passiveFocus
Time Phrase: ${timePhrase?.text}
Place Phrase: ${placePhrase?.noun}
Frequency Phrase: ${frequencyPhrase?.text}
''';
  }
}
