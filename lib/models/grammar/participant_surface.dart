import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

enum PrepositionalParticipantKind {
  addressee,
  companion,
  destination,
  topic,
  beneficiary,
  source,
}

class PrepositionalParticipantSurface {
  final PrepositionalParticipantKind kind;
  final String label;
  final String preposition;
  final String blockedNounLabel;
  final bool lexicalBeAllows;

  const PrepositionalParticipantSurface({
    required this.kind,
    required this.label,
    required this.preposition,
    required this.blockedNounLabel,
    this.lexicalBeAllows = false,
  });

  NounPhrase? read(SentenceState state) {
    return switch (kind) {
      PrepositionalParticipantKind.addressee => state.addressee,
      PrepositionalParticipantKind.companion => state.companion,
      PrepositionalParticipantKind.destination => state.destination,
      PrepositionalParticipantKind.topic => state.topic,
      PrepositionalParticipantKind.beneficiary => state.beneficiary,
      PrepositionalParticipantKind.source => state.source,
    };
  }

  bool isSupportedBy(Verb verb) {
    return switch (kind) {
      PrepositionalParticipantKind.addressee => verb.takesAddressee,
      PrepositionalParticipantKind.companion => verb.takesCompanion,
      PrepositionalParticipantKind.destination => verb.usesDestinationPlace,
      PrepositionalParticipantKind.topic => verb.takesTopic,
      PrepositionalParticipantKind.beneficiary => verb.takesBeneficiary,
      PrepositionalParticipantKind.source => verb.takesSource,
    };
  }

  bool isSupportedByState(
    SentenceState state, {
    bool includeRightAction = true,
  }) {
    final owner = includeRightAction
        ? state.rightAction ?? state.action
        : state.action;
    return isSupportedBy(owner);
  }
}

const addresseeSurface = PrepositionalParticipantSurface(
  kind: PrepositionalParticipantKind.addressee,
  label: 'addressee',
  preposition: 'to',
  blockedNounLabel: 'an addressee',
);

const companionSurface = PrepositionalParticipantSurface(
  kind: PrepositionalParticipantKind.companion,
  label: 'companion',
  preposition: 'with',
  blockedNounLabel: 'a companion',
  lexicalBeAllows: true,
);

const destinationSurface = PrepositionalParticipantSurface(
  kind: PrepositionalParticipantKind.destination,
  label: 'destination',
  preposition: 'to',
  blockedNounLabel: 'a destination',
);

const topicSurface = PrepositionalParticipantSurface(
  kind: PrepositionalParticipantKind.topic,
  label: 'about-topic',
  preposition: 'about',
  blockedNounLabel: 'an about-topic',
);

const beneficiarySurface = PrepositionalParticipantSurface(
  kind: PrepositionalParticipantKind.beneficiary,
  label: 'beneficiary',
  preposition: 'for',
  blockedNounLabel: 'a beneficiary',
);

const sourceSurface = PrepositionalParticipantSurface(
  kind: PrepositionalParticipantKind.source,
  label: 'source',
  preposition: 'from',
  blockedNounLabel: 'a source',
);

const prepositionalParticipantSurfaces = [
  addresseeSurface,
  companionSurface,
  destinationSurface,
  topicSurface,
  beneficiarySurface,
  sourceSurface,
];

const predicateFrameValidatedPrepositionalSurfaces = [
  companionSurface,
  destinationSurface,
  topicSurface,
  beneficiarySurface,
  sourceSurface,
];

const activeVoicePrepositionalSurfaces = [
  addresseeSurface,
  topicSurface,
  beneficiarySurface,
  sourceSurface,
];
