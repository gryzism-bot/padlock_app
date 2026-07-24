import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/models/grammar/phrase/frequency_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/manner_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/recipient_placement.dart';
import 'package:padlock_app/models/grammar/recipient_preposition.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/phrase/place_phrase.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/adjective.dart';
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
  final NounPhrase? addressee;
  final NounPhrase? companion;
  final NounPhrase? destination;
  final NounPhrase? topic;
  final NounPhrase? beneficiary;
  final Verb? rightAction;
  final RecipientPlacement recipientPlacement;
  final RecipientPreposition recipientPreposition;
  final NounPhrase? objectComplement;
  final Adjective? objectAdjectiveComplement;
  final NounPhrase? complement;
  final Adjective? adjectiveComplement;

  final Voice voice;
  final PassiveFocus? passiveFocus;
  final bool showPassiveAgent;

  final Tense tense;
  final Aspect aspect;

  final Modal modal;
  final Polarity polarity;

  final SentenceForm sentenceForm;

  final TimePhrase? timePhrase;
  final PlacePhrase? placePhrase;
  final PlaceMeaning? placeMeaning;
  final FrequencyPhrase? frequencyPhrase;
  final MannerPhrase? mannerPhrase;

  const SentenceState({
    this.agent,
    required this.action,
    this.object,
    this.recipient,
    this.addressee,
    this.companion,
    this.destination,
    this.topic,
    this.beneficiary,
    this.rightAction,
    this.recipientPlacement = RecipientPlacement.beforeObject,
    this.recipientPreposition = RecipientPreposition.to,
    this.objectComplement,
    this.objectAdjectiveComplement,
    this.complement,
    this.adjectiveComplement,

    this.voice = Voice.active,
    this.passiveFocus,
    this.showPassiveAgent = true,

    required this.tense,
    required this.aspect,

    this.modal = noModal,
    this.polarity = Polarity.positive,

    this.sentenceForm = SentenceForm.statement,

    this.timePhrase,
    this.placePhrase,
    this.placeMeaning,
    this.frequencyPhrase,
    this.mannerPhrase,
  });

  String get summary {
    return [
      'agent=${_nounPhraseSummary(agent)}',
      'action=${action.infinitive}',
      'object=${_nounPhraseSummary(object)}',
      'recipient=${_nounPhraseSummary(recipient)}',
      'addressee=${_nounPhraseSummary(addressee)}',
      'companion=${_nounPhraseSummary(companion)}',
      'destination=${_nounPhraseSummary(destination)}',
      'topic=${_nounPhraseSummary(topic)}',
      'beneficiary=${_nounPhraseSummary(beneficiary)}',
      'rightAction=${rightAction?.infinitive}',
      'recipientPlacement=$recipientPlacement',
      'recipientPreposition=$recipientPreposition',
      'objectComplement=${_nounPhraseSummary(objectComplement)}',
      'objectAdjectiveComplement=${objectAdjectiveComplement?.text}',
      'complement=${_nounPhraseSummary(complement)}',
      'adjectiveComplement=${adjectiveComplement?.text}',
      'voice=$voice',
      'passiveFocus=$passiveFocus',
      'showPassiveAgent=$showPassiveAgent',
      'tense=$tense',
      'aspect=$aspect',
      'modal=${modal.text}',
      'polarity=$polarity',
      'form=$sentenceForm',
      'time=${timePhrase?.text}',
      'place=${placePhrase?.noun}',
      'placeMeaning=${placeMeaning?.name}',
      'frequency=${frequencyPhrase?.text}',
      'manner=${mannerPhrase?.text}',
    ].join(', ');
  }

  @override
  String toString() {
    return '''
Agent: ${agent?.text}
Action: ${action.infinitive}
Object: ${object?.text}
Recipient: ${recipient?.text}
Addressee: ${addressee?.text}
Companion: ${companion?.text}
Destination: ${destination?.text}
Topic: ${topic?.text}
Beneficiary: ${beneficiary?.text}
Right Action: ${rightAction?.infinitive}
Recipient Placement: $recipientPlacement
Recipient Preposition: $recipientPreposition
Object Complement: ${objectComplement?.text}
Object Adjective Complement: ${objectAdjectiveComplement?.text}
Complement: ${complement?.text}
Adjective Complement: ${adjectiveComplement?.text}
Tense: $tense
Aspect: $aspect
Modal: $modal
Polarity: $polarity
Form: $sentenceForm
Voice: $voice
Passive Focus: $passiveFocus
Show Passive Agent: $showPassiveAgent
Time Phrase: ${timePhrase?.text}
Place Phrase: ${placePhrase?.noun}
Place Meaning: ${placeMeaning?.name}
Frequency Phrase: ${frequencyPhrase?.text}
''';
  }
}

String? _nounPhraseSummary(NounPhrase? phrase) {
  if (phrase == null) {
    return null;
  }

  return [
    phrase.text,
    'person=${phrase.person}',
    'number=${phrase.number}',
    'determiner=${phrase.determiner?.text}',
    'adjectives=${phrase.adjectiveList.map((adjective) => adjective.text).join('|')}',
  ].join('/');
}
