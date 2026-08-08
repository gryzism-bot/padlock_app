import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/topic_preposition.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

const idiomTargetCount = 59;

const idiomPatterns = <IdiomPattern>[
  IdiomPattern(
    id: 'give-up-habit',
    label: 'give up',
    pattern: 'give up + habit',
    meaning: 'stop doing something',
    example: 'You give up smoking.',
    verb: 'give',
    rightParticle: 'up',
    objectTexts: ['smoking', 'gambling', 'drinking'],
  ),
  IdiomPattern(
    id: 'give-up',
    label: 'give up',
    pattern: 'give up',
    meaning: 'stop trying',
    example: 'You give up.',
    verb: 'give',
    rightParticle: 'up',
    forbidObject: true,
  ),
  IdiomPattern(
    id: 'give-back',
    label: 'give back',
    pattern: 'give back + thing',
    meaning: 'return something',
    example: 'You give back the book.',
    verb: 'give',
    rightParticle: 'back',
    requiresObject: true,
  ),
  IdiomPattern(
    id: 'give-away',
    label: 'give away',
    pattern: 'give away + thing',
    meaning: 'donate or reveal something',
    example: 'You give away a secret.',
    verb: 'give',
    rightParticle: 'away',
    requiresObject: true,
  ),
  IdiomPattern(
    id: 'find-out',
    label: 'find out',
    pattern: 'find out',
    meaning: 'discover information',
    example: 'You find out.',
    verb: 'find',
    rightParticle: 'out',
  ),
  IdiomPattern(
    id: 'work-out',
    label: 'work out',
    pattern: 'work out',
    meaning: 'exercise or solve something',
    example: 'You work out.',
    verb: 'work',
    rightParticle: 'out',
  ),
  IdiomPattern(
    id: 'open-up',
    label: 'open up',
    pattern: 'open up',
    meaning: 'become open or speak more freely',
    example: 'You open up.',
    verb: 'open',
    rightParticle: 'up',
  ),
  IdiomPattern(
    id: 'close-down',
    label: 'close down',
    pattern: 'close down',
    meaning: 'stop operating',
    example: 'The shop closes down.',
    verb: 'close',
    rightParticle: 'down',
  ),
  IdiomPattern(
    id: 'close-on',
    label: 'close on',
    pattern: 'close on + topic',
    meaning: 'come near to an agreement or capture',
    example: 'You close on a deal.',
    verb: 'close',
    topicPreposition: TopicPreposition.on,
    requiresTopic: true,
  ),
  IdiomPattern(
    id: 'lose-yourself-in',
    label: 'lose yourself',
    pattern: 'lose + reflexive object + in + place',
    meaning: 'become deeply absorbed in a place, activity, or situation',
    example: 'You lose yourself in the office.',
    verb: 'lose',
    objectTexts: [
      'myself',
      'yourself',
      'himself',
      'herself',
      'itself',
      'ourselves',
      'yourselves',
      'themselves',
    ],
    requiresInLocation: true,
  ),
  IdiomPattern(
    id: 'lose-it',
    label: 'lose it',
    pattern: 'lose + it',
    meaning: 'lose emotional control',
    example: 'You lose it.',
    verb: 'lose',
    objectTexts: ['it'],
  ),
  IdiomPattern(
    id: 'break-up',
    label: 'break up',
    pattern: 'break up',
    meaning: 'separate or end a relationship',
    example: 'They break up.',
    verb: 'break',
    rightParticle: 'up',
  ),
  IdiomPattern(
    id: 'break-out',
    label: 'break out',
    pattern: 'break out',
    meaning: 'escape or suddenly begin',
    example: 'You break out.',
    verb: 'break',
    rightParticle: 'out',
  ),
  IdiomPattern(
    id: 'turn-on',
    label: 'turn on',
    pattern: 'turn on + device',
    meaning: 'activate something',
    example: 'You turn on the light.',
    verb: 'turn',
    rightParticle: 'on',
    requiresObject: true,
  ),
  IdiomPattern(
    id: 'turn-off',
    label: 'turn off',
    pattern: 'turn off + device',
    meaning: 'deactivate something',
    example: 'You turn off the light.',
    verb: 'turn',
    rightParticle: 'off',
    requiresObject: true,
  ),
  IdiomPattern(
    id: 'pick-up',
    label: 'pick up',
    pattern: 'pick up + thing',
    meaning: 'lift or collect something',
    example: 'You pick up the phone.',
    verb: 'pick',
    rightParticle: 'up',
    requiresObject: true,
  ),
  IdiomPattern(
    id: 'put-down',
    label: 'put down',
    pattern: 'put down + thing',
    meaning: 'place something down',
    example: 'You put down the book.',
    verb: 'put',
    rightParticle: 'down',
    requiresObject: true,
  ),
  IdiomPattern(
    id: 'look-up',
    label: 'look up',
    pattern: 'look up + word',
    meaning: 'search for information',
    example: 'You look up a word.',
    verb: 'look',
    rightParticle: 'up',
    requiresObject: true,
  ),
  IdiomPattern(
    id: 'look-around',
    label: 'look around',
    pattern: 'look around',
    meaning: 'inspect the area',
    example: 'You look around.',
    verb: 'look',
    rightParticle: 'around',
  ),
  IdiomPattern(
    id: 'wake-up',
    label: 'wake up',
    pattern: 'wake up',
    meaning: 'stop sleeping',
    example: 'You wake up.',
    verb: 'wake',
    rightParticle: 'up',
  ),
  IdiomPattern(
    id: 'calm-down',
    label: 'calm down',
    pattern: 'calm down',
    meaning: 'become calmer',
    example: 'You calm down.',
    verb: 'calm',
    rightParticle: 'down',
  ),
  IdiomPattern(
    id: 'slow-down',
    label: 'slow down',
    pattern: 'slow down',
    meaning: 'move or act more slowly',
    example: 'You slow down.',
    verb: 'slow',
    rightParticle: 'down',
  ),
  IdiomPattern(
    id: 'stand-up',
    label: 'stand up',
    pattern: 'stand up',
    meaning: 'rise to a standing position',
    example: 'You stand up.',
    verb: 'stand',
    rightParticle: 'up',
  ),
  IdiomPattern(
    id: 'sit-down',
    label: 'sit down',
    pattern: 'sit down',
    meaning: 'take a seat',
    example: 'You sit down.',
    verb: 'sit',
    rightParticle: 'down',
  ),
  IdiomPattern(
    id: 'take-off',
    label: 'take off',
    pattern: 'take off',
    meaning: 'leave the ground or remove something',
    example: 'The plane takes off.',
    verb: 'take',
    rightParticle: 'off',
  ),
  IdiomPattern(
    id: 'take-away',
    label: 'take away',
    pattern: 'take away + thing',
    meaning: 'remove something',
    example: 'You take away the box.',
    verb: 'take',
    rightParticle: 'away',
    requiresObject: true,
  ),
  IdiomPattern(
    id: 'bring-back',
    label: 'bring back',
    pattern: 'bring back + thing',
    meaning: 'return something',
    example: 'You bring back the book.',
    verb: 'bring',
    rightParticle: 'back',
    requiresObject: true,
  ),
  IdiomPattern(
    id: 'call-back',
    label: 'call back',
    pattern: 'call back + person',
    meaning: 'return a call',
    example: 'You call back Mary.',
    verb: 'call',
    rightParticle: 'back',
    requiresObject: true,
  ),
  IdiomPattern(
    id: 'write-down',
    label: 'write down',
    pattern: 'write down + text',
    meaning: 'record in writing',
    example: 'You write down the note.',
    verb: 'write',
    rightParticle: 'down',
    requiresObject: true,
  ),
  IdiomPattern(
    id: 'write-back',
    label: 'write back',
    pattern: 'write back',
    meaning: 'reply in writing',
    example: 'You write back.',
    verb: 'write',
    rightParticle: 'back',
  ),
  IdiomPattern(
    id: 'throw-away',
    label: 'throw away',
    pattern: 'throw away + thing',
    meaning: 'discard something',
    example: 'You throw away the paper.',
    verb: 'throw',
    rightParticle: 'away',
    requiresObject: true,
  ),
  IdiomPattern(
    id: 'think-through',
    label: 'think through',
    pattern: 'think through',
    meaning: 'consider carefully from start to finish',
    example: 'You think through.',
    verb: 'think',
    rightParticle: 'through',
  ),
  IdiomPattern(
    id: 'come-back',
    label: 'come back',
    pattern: 'come back',
    meaning: 'return',
    example: 'You come back.',
    verb: 'come',
    rightParticle: 'back',
  ),
  IdiomPattern(
    id: 'go-away',
    label: 'go away',
    pattern: 'go away',
    meaning: 'leave',
    example: 'You go away.',
    verb: 'go',
    rightParticle: 'away',
  ),
  IdiomPattern(
    id: 'go-out',
    label: 'go out',
    pattern: 'go out',
    meaning: 'leave a place or spend time outside',
    example: 'You go out.',
    verb: 'go',
    rightParticle: 'out',
  ),
  IdiomPattern(
    id: 'go-back',
    label: 'go back',
    pattern: 'go back',
    meaning: 'return',
    example: 'You go back.',
    verb: 'go',
    rightParticle: 'back',
  ),
  IdiomPattern(
    id: 'come-in',
    label: 'come in',
    pattern: 'come in',
    meaning: 'enter',
    example: 'You come in.',
    verb: 'come',
    rightParticle: 'in',
  ),
  IdiomPattern(
    id: 'come-out',
    label: 'come out',
    pattern: 'come out',
    meaning: 'leave a place or become visible',
    example: 'You come out.',
    verb: 'come',
    rightParticle: 'out',
  ),
  IdiomPattern(
    id: 'look-out',
    label: 'look out',
    pattern: 'look out',
    meaning: 'be careful',
    example: 'You look out.',
    verb: 'look',
    rightParticle: 'out',
  ),
  IdiomPattern(
    id: 'look-back',
    label: 'look back',
    pattern: 'look back',
    meaning: 'think about the past',
    example: 'You look back.',
    verb: 'look',
    rightParticle: 'back',
  ),
  IdiomPattern(
    id: 'turn-around',
    label: 'turn around',
    pattern: 'turn around',
    meaning: 'face the other way or improve a situation',
    example: 'You turn around.',
    verb: 'turn',
    rightParticle: 'around',
  ),
  IdiomPattern(
    id: 'break-down',
    label: 'break down',
    pattern: 'break down',
    meaning: 'stop working or lose emotional control',
    example: 'You break down.',
    verb: 'break',
    rightParticle: 'down',
  ),
  IdiomPattern(
    id: 'fall-down',
    label: 'fall down',
    pattern: 'fall down',
    meaning: 'drop to the ground',
    example: 'You fall down.',
    verb: 'fall',
    rightParticle: 'down',
  ),
  IdiomPattern(
    id: 'put-away',
    label: 'put away',
    pattern: 'put away + thing',
    meaning: 'place something where it belongs',
    example: 'You put away the book.',
    verb: 'put',
    rightParticle: 'away',
    requiresObject: true,
  ),
  IdiomPattern(
    id: 'put-back',
    label: 'put back',
    pattern: 'put back + thing',
    meaning: 'return something to its place',
    example: 'You put back the book.',
    verb: 'put',
    rightParticle: 'back',
    requiresObject: true,
  ),
  IdiomPattern(
    id: 'take-out',
    label: 'take out',
    pattern: 'take out + thing',
    meaning: 'remove something',
    example: 'You take out the key.',
    verb: 'take',
    rightParticle: 'out',
    requiresObject: true,
  ),
  IdiomPattern(
    id: 'bring-in',
    label: 'bring in',
    pattern: 'bring in + thing',
    meaning: 'carry something inside or introduce something',
    example: 'You bring in the book.',
    verb: 'bring',
    rightParticle: 'in',
    requiresObject: true,
  ),
  IdiomPattern(
    id: 'bring-out',
    label: 'bring out',
    pattern: 'bring out + thing',
    meaning: 'make something visible or available',
    example: 'You bring out the book.',
    verb: 'bring',
    rightParticle: 'out',
    requiresObject: true,
  ),
  IdiomPattern(
    id: 'clean-up',
    label: 'clean up',
    pattern: 'clean up + thing',
    meaning: 'make something clean or tidy',
    example: 'You clean up the room.',
    verb: 'clean',
    rightParticle: 'up',
    requiresObject: true,
  ),
  IdiomPattern(
    id: 'sing-along',
    label: 'sing along',
    pattern: 'sing along',
    meaning: 'sing together with music or another person',
    example: 'You sing along.',
    verb: 'sing',
    rightParticle: 'along',
  ),
  IdiomPattern(
    id: 'work-on',
    label: 'work on',
    pattern: 'work on + topic',
    meaning: 'make progress on something',
    example: 'You work on grammar.',
    verb: 'work',
    topicPreposition: TopicPreposition.on,
    requiresTopic: true,
  ),
  IdiomPattern(
    id: 'think-about',
    label: 'think about',
    pattern: 'think about + topic',
    meaning: 'consider something',
    example: 'You think about grammar.',
    verb: 'think',
    topicPreposition: TopicPreposition.about,
    requiresTopic: true,
  ),
  IdiomPattern(
    id: 'think-of',
    label: 'think of',
    pattern: 'think of + someone/something',
    meaning: 'remember or imagine someone or something',
    example: 'You think of Mary.',
    verb: 'think',
    topicPreposition: TopicPreposition.of,
    requiresTopic: true,
  ),
  IdiomPattern(
    id: 'think-over',
    label: 'think over',
    pattern: 'think over + topic',
    meaning: 'consider before deciding',
    example: 'You think over the plan.',
    verb: 'think',
    topicPreposition: TopicPreposition.over,
    requiresTopic: true,
  ),
  IdiomPattern(
    id: 'help-with',
    label: 'help with',
    pattern: 'help with + topic',
    meaning: 'assist on a task',
    example: 'You help with homework.',
    verb: 'help',
    topicPreposition: TopicPreposition.withPrep,
    requiresTopic: true,
  ),
  IdiomPattern(
    id: 'hear-from',
    label: 'hear from',
    pattern: 'hear from + person',
    meaning: 'receive news from someone',
    example: 'You hear from Mary.',
    verb: 'hear',
    requiresSource: true,
  ),
  IdiomPattern(
    id: 'ask-for',
    label: 'ask for',
    pattern: 'ask for + thing',
    meaning: 'request something',
    example: 'You ask for help.',
    verb: 'ask',
    requiresPurpose: true,
  ),
  IdiomPattern(
    id: 'look-for',
    label: 'look for',
    pattern: 'look for + thing',
    meaning: 'search for something',
    example: 'You look for the key.',
    verb: 'look',
    requiresPurpose: true,
  ),
  IdiomPattern(
    id: 'go-for',
    label: 'go for',
    pattern: 'go for + activity',
    meaning: 'choose or leave to do something',
    example: 'You go for a walk.',
    verb: 'go',
    requiresPurpose: true,
  ),
];

const intentionalLiteralParticleRoutes = <IntentionalLiteralParticleRoute>[
  IntentionalLiteralParticleRoute(
    verb: 'go',
    rightParticle: 'in',
    note: 'literal movement into a place',
  ),
  IntentionalLiteralParticleRoute(
    verb: 'go',
    rightParticle: 'around',
    note: 'literal movement around an area',
  ),
  IntentionalLiteralParticleRoute(
    verb: 'read',
    rightParticle: 'through',
    note: 'literal completion of a text from start to finish',
  ),
  IntentionalLiteralParticleRoute(
    verb: 'take',
    rightParticle: 'back',
    note: 'literal return route for objects',
  ),
  IntentionalLiteralParticleRoute(
    verb: 'turn',
    rightParticle: 'back',
    note: 'literal direction change or return',
  ),
  IntentionalLiteralParticleRoute(
    verb: 'look',
    rightParticle: 'down',
    note: 'literal gaze direction',
  ),
  IntentionalLiteralParticleRoute(
    verb: 'help',
    rightParticle: 'out',
    note: 'support route kept literal until idiom copy is authored',
  ),
];

class IdiomPattern {
  final String id;
  final String label;
  final String pattern;
  final String meaning;
  final String example;
  final String verb;
  final String? rightParticle;
  final TopicPreposition? topicPreposition;
  final List<String> objectTexts;
  final bool requiresObject;
  final bool forbidObject;
  final bool requiresTopic;
  final bool requiresSource;
  final bool requiresPurpose;
  final bool requiresInLocation;

  const IdiomPattern({
    required this.id,
    required this.label,
    required this.pattern,
    required this.meaning,
    required this.example,
    required this.verb,
    this.rightParticle,
    this.topicPreposition,
    this.objectTexts = const [],
    this.requiresObject = false,
    this.forbidObject = false,
    this.requiresTopic = false,
    this.requiresSource = false,
    this.requiresPurpose = false,
    this.requiresInLocation = false,
  });

  bool matches(SentenceState state) {
    if (state.action.infinitive.toLowerCase() != verb) {
      return false;
    }

    if (rightParticle != null &&
        state.rightParticle?.text.toLowerCase() != rightParticle) {
      return false;
    }

    if (topicPreposition != null &&
        state.topicPreposition != topicPreposition) {
      return false;
    }

    if (requiresObject && state.object == null) {
      return false;
    }

    if (forbidObject && state.object != null) {
      return false;
    }

    if (objectTexts.isNotEmpty && !_matchesAnyText(state.object, objectTexts)) {
      return false;
    }

    if (requiresTopic && state.topic == null) {
      return false;
    }

    if (requiresSource && state.source == null) {
      return false;
    }

    if (requiresPurpose && state.purpose == null) {
      return false;
    }

    if (requiresInLocation && !_hasInLocation(state)) {
      return false;
    }

    return true;
  }
}

class IntentionalLiteralParticleRoute {
  final String verb;
  final String rightParticle;
  final String note;

  const IntentionalLiteralParticleRoute({
    required this.verb,
    required this.rightParticle,
    required this.note,
  });
}

bool _matchesAnyText(NounPhrase? phrase, List<String> candidates) {
  final text = phrase?.text.toLowerCase();
  if (text == null) {
    return false;
  }

  return candidates.any((candidate) => candidate.toLowerCase() == text);
}

bool _hasInLocation(SentenceState state) {
  final place = state.placePhrase;
  if (place == null) {
    return false;
  }

  final meaning = state.placeMeaning ?? PlaceMeaning.location;
  if (meaning != PlaceMeaning.location) {
    return false;
  }

  return place.render(PlaceMeaning.location).toLowerCase().startsWith('in ');
}
