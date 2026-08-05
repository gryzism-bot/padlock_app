import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/idioms/idiom_patterns.dart';
import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart'
    as fixed_object;
import 'package:padlock_app/data/subjects/third_person/objects.dart'
    as object_data;
import 'package:padlock_app/data/verbs/communication.dart' as communication;
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/data/verbs/particle.dart' as particle_data;
import 'package:padlock_app/data/verbs/right_particles.dart';
import 'package:padlock_app/data/verbs/work.dart' as work_data;
import 'package:padlock_app/engine/idiom_discovery.dart';
import 'package:padlock_app/engine/idiom_finder.dart';
import 'package:padlock_app/models/grammar/topic_preposition.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

void main() {
  const finder = IdiomFinder();

  test('idiom catalog carries the presentation target count', () {
    expect(idiomPatterns, hasLength(idiomTargetCount));
    expect(finder.total, idiomTargetCount);
  });

  test('right particle habit idiom is found from sentence state', () {
    final matches = finder.find(
      const SentenceState(
        action: give,
        object: fixed_object.smoking,
        rightParticle: upParticle,
        tense: Tense.present,
        aspect: Aspect.simple,
      ),
    );

    expect(matches.map((match) => match.pattern.id), contains('give-up-habit'));
  });

  test('topic preposition idiom is found from sentence state', () {
    final matches = finder.find(
      const SentenceState(
        action: work,
        topic: fixed_object.grammar,
        topicPreposition: TopicPreposition.on,
        tense: Tense.present,
        aspect: Aspect.simple,
      ),
    );

    expect(matches.map((match) => match.pattern.id), contains('work-on'));
  });

  test('close on idiom is found from on-topic sentence state', () {
    final matches = finder.find(
      SentenceState(
        action: close,
        topic: object_data.deal.toNounPhrase(Number.singular),
        topicPreposition: TopicPreposition.on,
        tense: Tense.present,
        aspect: Aspect.simple,
      ),
    );

    expect(matches.map((match) => match.pattern.id), contains('close-on'));
  });

  test('plain verb with unrelated particle is not treated as an idiom', () {
    final matches = finder.find(
      const SentenceState(
        action: give,
        rightParticle: downParticle,
        tense: Tense.present,
        aspect: Aspect.simple,
      ),
    );

    expect(matches, isEmpty);
  });

  test('second batch particle idioms are found as right particles', () {
    final cases = [
      (
        id: 'find-out',
        state: const SentenceState(
          action: findVerb,
          rightParticle: outParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'work-out',
        state: const SentenceState(
          action: work,
          rightParticle: outParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'think-through',
        state: const SentenceState(
          action: think,
          rightParticle: throughParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'stand-up',
        state: const SentenceState(
          action: stand,
          rightParticle: upParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'sit-down',
        state: const SentenceState(
          action: sit,
          rightParticle: downParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'come-back',
        state: const SentenceState(
          action: come,
          rightParticle: backParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'go-away',
        state: const SentenceState(
          action: go,
          rightParticle: awayParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
    ];

    for (final caseData in cases) {
      expect(
        finder.find(caseData.state).map((match) => match.pattern.id),
        contains(caseData.id),
        reason: caseData.id,
      );
    }
  });

  test('high frequency phrasal verb batch is found from sentence state', () {
    final cases = [
      (
        id: 'go-out',
        state: const SentenceState(
          action: go,
          rightParticle: outParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'go-back',
        state: const SentenceState(
          action: go,
          rightParticle: backParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'come-in',
        state: const SentenceState(
          action: come,
          rightParticle: inParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'come-out',
        state: const SentenceState(
          action: come,
          rightParticle: outParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'look-out',
        state: const SentenceState(
          action: particle_data.look,
          rightParticle: outParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'look-back',
        state: const SentenceState(
          action: particle_data.look,
          rightParticle: backParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'turn-around',
        state: const SentenceState(
          action: particle_data.turn,
          rightParticle: aroundParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'break-down',
        state: const SentenceState(
          action: breakVerb,
          rightParticle: downParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'fall-down',
        state: const SentenceState(
          action: fall,
          rightParticle: downParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'put-away',
        state: SentenceState(
          action: particle_data.put,
          object: object_data.book.toNounPhrase(Number.singular),
          rightParticle: awayParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'put-back',
        state: SentenceState(
          action: particle_data.put,
          object: object_data.book.toNounPhrase(Number.singular),
          rightParticle: backParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'take-out',
        state: SentenceState(
          action: take,
          object: object_data.key.toNounPhrase(Number.singular),
          rightParticle: outParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'bring-in',
        state: SentenceState(
          action: bring,
          object: object_data.book.toNounPhrase(Number.singular),
          rightParticle: inParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'bring-out',
        state: SentenceState(
          action: bring,
          object: object_data.book.toNounPhrase(Number.singular),
          rightParticle: outParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      (
        id: 'clean-up',
        state: const SentenceState(
          action: work_data.clean,
          object: fixed_object.room,
          rightParticle: upParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
    ];

    for (final caseData in cases) {
      expect(
        finder.find(caseData.state).map((match) => match.pattern.id),
        contains(caseData.id),
        reason: caseData.id,
      );
    }
  });

  test('discovery count accumulates unique idioms across moves', () {
    final discovery = IdiomDiscovery();

    expect(
      discovery
          .record(
            const SentenceState(
              action: give,
              rightParticle: upParticle,
              tense: Tense.present,
              aspect: Aspect.simple,
            ),
          )
          .map((match) => match.pattern.id),
      contains('give-up'),
    );
    expect(discovery.foundCount, 1);

    expect(
      discovery
          .record(
            SentenceState(
              action: communication.write,
              object: object_data.letter.toNounPhrase(Number.singular),
              rightParticle: downParticle,
              tense: Tense.present,
              aspect: Aspect.simple,
            ),
          )
          .map((match) => match.pattern.id),
      contains('write-down'),
    );
    expect(discovery.foundCount, 2);

    expect(
      discovery
          .record(
            const SentenceState(
              action: take,
              rightParticle: offParticle,
              tense: Tense.present,
              aspect: Aspect.simple,
            ),
          )
          .map((match) => match.pattern.id),
      contains('take-off'),
    );
    expect(discovery.foundCount, 3);

    expect(
      discovery.record(
        const SentenceState(
          action: take,
          rightParticle: offParticle,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      isEmpty,
    );
    expect(discovery.foundCount, 3);
  });
}
