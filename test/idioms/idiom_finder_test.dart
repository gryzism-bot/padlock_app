import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/idioms/idiom_patterns.dart';
import 'package:padlock_app/data/phrases/manner_phrases.dart';
import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart'
    as fixed_object;
import 'package:padlock_app/data/subjects/third_person/objects.dart'
    as object_data;
import 'package:padlock_app/data/verbs/communication.dart' as communication;
import 'package:padlock_app/data/verbs/essential.dart';
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
        rightParticle: upMannerPhrase,
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

  test('plain verb with unrelated particle is not treated as an idiom', () {
    final matches = finder.find(
      const SentenceState(
        action: give,
        rightParticle: downMannerPhrase,
        tense: Tense.present,
        aspect: Aspect.simple,
      ),
    );

    expect(matches, isEmpty);
  });

  test('discovery count accumulates unique idioms across moves', () {
    final discovery = IdiomDiscovery();

    expect(
      discovery
          .record(
            const SentenceState(
              action: give,
              rightParticle: upMannerPhrase,
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
              rightParticle: downMannerPhrase,
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
              rightParticle: offMannerPhrase,
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
          rightParticle: offMannerPhrase,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      ),
      isEmpty,
    );
    expect(discovery.foundCount, 3);
  });
}
