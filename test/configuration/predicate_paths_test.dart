import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/idioms/idiom_patterns.dart';
import 'package:padlock_app/data/predicate/fixed_object_frames.dart';
import 'package:padlock_app/data/predicate/particle_object_order.dart';
import 'package:padlock_app/data/predicate/predicate_paths.dart';
import 'package:padlock_app/data/predicate/predicate_route_audit.dart';
import 'package:padlock_app/data/predicate/right_action_frames.dart';
import 'package:padlock_app/data/predicate/semantic_object_filter.dart';
import 'package:padlock_app/data/predicate/verb_influence.dart';
import 'package:padlock_app/data/phrases/manner_phrases.dart';
import 'package:padlock_app/data/phrases/phrase_classification.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/subjects/third_person/animal_categories.dart'
    as animal_categories;
import 'package:padlock_app/data/subjects/third_person/animals.dart'
    as animal_data;
import 'package:padlock_app/data/subjects/third_person/object_categories.dart'
    as object_categories;
import 'package:padlock_app/data/subjects/third_person/objects.dart'
    as object_data;
import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart'
    as fixed_object;
import 'package:padlock_app/data/subjects/object_pronouns.dart'
    as object_pronouns;
import 'package:padlock_app/data/subjects/third_person/people_categories.dart'
    as people_categories;
import 'package:padlock_app/data/subjects/third_person/people.dart'
    as people_data;
import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/cooking.dart' as cooking_data;
import 'package:padlock_app/data/verbs/education.dart' as education_data;
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/data/verbs/particle.dart' as particle_data;
import 'package:padlock_app/data/verbs/right_particles.dart';
import 'package:padlock_app/data/verbs/sport.dart' as sport_data;
import 'package:padlock_app/data/verbs/travel.dart' as travel_data;
import 'package:padlock_app/data/verbs/work.dart' as work_data;
import 'package:padlock_app/engine/configuration_compass.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/engine/predicate_path_compiler.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/topic_preposition.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

void main() {
  final lock = ConfigurationEngine();
  final grammar = GrammarEngine();

  bool wasBlocked(ConfigurationState state) {
    return state.messages.any(
      (message) => message.kind == ConfigurationMessageKind.blocked,
    );
  }

  ConfigurationState stateAfterPath(
    PredicateUnlocks unlocks,
    PredicatePath path,
  ) {
    return compileFirstPredicatePathChoice(unlocks, path, lock: lock);
  }

  Verb? verbForIdiom(IdiomPattern pattern) {
    for (final verb in verbs) {
      if (verb.infinitive == pattern.verb) {
        return verb;
      }
    }
    return null;
  }

  bool hasPathKind(PredicateUnlocks unlocks, PredicatePathKind kind) {
    return unlocks.paths.any((path) => path.kind == kind);
  }

  bool hasRightParticle(PredicateUnlocks unlocks, String particle) {
    return unlocks.paths.any(
      (path) =>
          path.kind == PredicatePathKind.rightParticle &&
          path.particles.any(
            (choice) => choice.text.toLowerCase() == particle.toLowerCase(),
          ),
    );
  }

  bool hasObjectChoice(
    PredicateUnlocks unlocks,
    String objectText, {
    String? rightParticle,
  }) {
    final nouns = [
      ...predicateNounChoicesFor(unlocks.verb, PredicatePathKind.directObject),
      if (rightParticle != null)
        for (final path in unlocks.paths)
          if (path.kind == PredicatePathKind.rightParticle &&
              path.particles.any(
                (choice) =>
                    choice.text.toLowerCase() == rightParticle.toLowerCase(),
              ))
            ...path.particleObjectNouns,
    ];

    return nouns.any(
      (choice) => choice.text.toLowerCase() == objectText.toLowerCase(),
    );
  }

  PredicatePathKind topicKindFor(TopicPreposition preposition) {
    return switch (preposition) {
      TopicPreposition.about => PredicatePathKind.aboutTopic,
      TopicPreposition.of => PredicatePathKind.ofTopic,
      TopicPreposition.on => PredicatePathKind.onTopic,
      TopicPreposition.over => PredicatePathKind.overTopic,
      TopicPreposition.withPrep => PredicatePathKind.withTopic,
    };
  }

  String particleRouteKey(String verb, String rightParticle) {
    return '${verb.toLowerCase()} ${rightParticle.toLowerCase()}';
  }

  group('Predicate paths', () {
    test('predicate path mode is explicit and switchable', () {
      expect(
        PredicatePathMode.values,
        containsAll([
          PredicatePathMode.authoredTracks,
          PredicatePathMode.legacyCompassFallback,
        ]),
      );
    });

    test('idiom patterns are reachable through authored predicate paths', () {
      final failures = <String>[];

      for (final pattern in idiomPatterns) {
        final verb = verbForIdiom(pattern);
        if (verb == null) {
          failures.add('${pattern.id}: unknown verb ${pattern.verb}');
          continue;
        }

        final unlocks = predicateUnlocksFor(verb);
        if (unlocks == null) {
          failures.add('${pattern.id}: no PredicatePaths for ${pattern.verb}');
          continue;
        }

        final rightParticle = pattern.rightParticle;
        if (rightParticle != null &&
            !hasRightParticle(unlocks, rightParticle)) {
          failures.add(
            '${pattern.id}: missing right particle $rightParticle '
            'for ${pattern.verb}',
          );
        }

        if (pattern.requiresObject &&
            !hasPathKind(unlocks, PredicatePathKind.directObject)) {
          failures.add(
            '${pattern.id}: missing object route for ${pattern.verb}',
          );
        }

        for (final objectText in pattern.objectTexts) {
          if (!hasObjectChoice(
            unlocks,
            objectText,
            rightParticle: pattern.rightParticle,
          )) {
            failures.add(
              '${pattern.id}: missing object $objectText for ${pattern.verb}',
            );
          }
        }

        final topicPreposition = pattern.topicPreposition;
        if (topicPreposition != null &&
            !hasPathKind(unlocks, topicKindFor(topicPreposition))) {
          failures.add(
            '${pattern.id}: missing ${topicPreposition.text} topic route '
            'for ${pattern.verb}',
          );
        }

        if (pattern.requiresTopic && topicPreposition == null) {
          failures.add('${pattern.id}: topic idiom has no topic preposition');
        }

        if (pattern.requiresSource &&
            !hasPathKind(unlocks, PredicatePathKind.fromSource) &&
            !hasPathKind(unlocks, PredicatePathKind.fromLocation)) {
          failures.add(
            '${pattern.id}: missing source route for ${pattern.verb}',
          );
        }

        if (pattern.requiresPurpose &&
            !hasPathKind(unlocks, PredicatePathKind.forPurpose)) {
          failures.add(
            '${pattern.id}: missing purpose route for ${pattern.verb}',
          );
        }

        if (pattern.requiresInLocation &&
            !hasPathKind(unlocks, PredicatePathKind.inLocation)) {
          failures.add(
            '${pattern.id}: missing in-location route for ${pattern.verb}',
          );
        }
      }

      if (failures.isNotEmpty) {
        fail(failures.join('\n'));
      }
    });

    test('authored particle routes are idioms or intentionally literal', () {
      final idiomParticleRoutes = {
        for (final pattern in idiomPatterns)
          if (pattern.rightParticle != null)
            particleRouteKey(pattern.verb, pattern.rightParticle!),
      };
      final literalParticleRoutes = {
        for (final route in intentionalLiteralParticleRoutes)
          particleRouteKey(route.verb, route.rightParticle),
      };
      final authoredParticleRoutes = <String>{};

      for (final unlocks in guidedPredicateUnlocks) {
        for (final path in unlocks.paths) {
          if (path.kind != PredicatePathKind.rightParticle) {
            continue;
          }

          for (final particle in path.particles) {
            authoredParticleRoutes.add(
              particleRouteKey(unlocks.verb.infinitive, particle.text),
            );
          }
        }
      }

      final unclassifiedRoutes = [
        for (final route in authoredParticleRoutes)
          if (!idiomParticleRoutes.contains(route) &&
              !literalParticleRoutes.contains(route))
            route,
      ]..sort();
      final orphanLiteralRoutes = [
        for (final route in literalParticleRoutes)
          if (!authoredParticleRoutes.contains(route)) route,
      ]..sort();

      expect(
        unclassifiedRoutes,
        isEmpty,
        reason:
            'Every rightParticle PredicatePath must be an IdiomPattern or '
            'an IntentionalLiteralParticleRoute.',
      );
      expect(
        orphanLiteralRoutes,
        isEmpty,
        reason:
            'Literal particle route records should point at real authored '
            'PredicatePaths.',
      );
    });

    test('predicate path compiler maps authored routes into state moves', () {
      for (final unlocks in guidedPredicateUnlocks) {
        for (final path in unlocks.paths) {
          final move = firstMoveForPredicatePath(path, owner: unlocks.verb);
          final expectedMove = switch (path.kind) {
            PredicatePathKind.directObject => isA<SetObject>(),
            PredicatePathKind.toRightAction => isA<SetRightAction>(),
            PredicatePathKind.toRecipient => isA<SetRecipient>(),
            PredicatePathKind.toAddressee => isA<SetAddressee>(),
            PredicatePathKind.withCompanion => isA<SetCompanion>(),
            PredicatePathKind.withInstrument => isA<SetInstrument>(),
            PredicatePathKind.toDestination => isA<SetDestination>(),
            PredicatePathKind.aboutTopic => isA<SetTopic>(),
            PredicatePathKind.ofTopic => isA<SetTopic>(),
            PredicatePathKind.onTopic => isA<SetTopic>(),
            PredicatePathKind.overTopic => isA<SetTopic>(),
            PredicatePathKind.withTopic => isA<SetTopic>(),
            PredicatePathKind.forBeneficiary => isA<SetBeneficiary>(),
            PredicatePathKind.fromSource => isA<SetSource>(),
            PredicatePathKind.forPurpose => isA<SetPurpose>(),
            PredicatePathKind.atLocation => isA<SetPlacePhrase>(),
            PredicatePathKind.inLocation => isA<SetPlacePhrase>(),
            PredicatePathKind.onLocation => isA<SetPlacePhrase>(),
            PredicatePathKind.fromLocation => isA<SetPlacePhrase>(),
            PredicatePathKind.placePhrase => isA<SetPlacePhrase>(),
            PredicatePathKind.timePhrase => isA<SetTimePhrase>(),
            PredicatePathKind.frequencyPhrase => isA<SetFrequencyPhrase>(),
            PredicatePathKind.mannerPhrase => isA<SetMannerPhrase>(),
            PredicatePathKind.rightParticle => isA<SetRightParticle>(),
          };

          expect(
            move,
            expectedMove,
            reason: '${unlocks.verb.infinitive} ${path.kind}',
          );
        }
      }
    });

    test(
      'predicate path compiler renders route choices through SentenceState',
      () {
        final examples = [
          (
            action: learn,
            kind: PredicatePathKind.directObject,
            text: 'You learn English.',
          ),
          (
            action: learn,
            kind: PredicatePathKind.toRightAction,
            text: 'You learn to speak.',
          ),
          (
            action: write,
            kind: PredicatePathKind.toAddressee,
            text: 'You write to John.',
          ),
          (
            action: work,
            kind: PredicatePathKind.forBeneficiary,
            text: 'You work for John.',
          ),
          (
            action: make,
            kind: PredicatePathKind.forBeneficiary,
            text: 'You make something for John.',
          ),
          (
            action: use,
            kind: PredicatePathKind.forPurpose,
            text: 'You use for work.',
          ),
          (
            action: make,
            kind: PredicatePathKind.forPurpose,
            text: 'You make something for work.',
          ),
          (
            action: learn,
            kind: PredicatePathKind.forPurpose,
            text: 'You learn for school.',
          ),
          (
            action: work,
            kind: PredicatePathKind.onTopic,
            text: 'You work on English.',
          ),
          (
            action: listen,
            kind: PredicatePathKind.onTopic,
            text: 'You listen on speakers.',
          ),
          (
            action: think,
            kind: PredicatePathKind.overTopic,
            text: 'You think over problem.',
          ),
          (
            action: help,
            kind: PredicatePathKind.withTopic,
            text: 'You help with homework.',
          ),
          (
            action: work,
            kind: PredicatePathKind.atLocation,
            text: 'You work at home.',
          ),
          (
            action: buy,
            kind: PredicatePathKind.inLocation,
            text: 'You buy in the shop.',
          ),
          (
            action: sleep,
            kind: PredicatePathKind.onLocation,
            text: 'You sleep on the bed.',
          ),
          (
            action: come,
            kind: PredicatePathKind.fromLocation,
            text: 'You come from home.',
          ),
          (
            action: go,
            kind: PredicatePathKind.placePhrase,
            text: 'You go home.',
          ),
          (
            action: go,
            kind: PredicatePathKind.mannerPhrase,
            text: 'You go quickly.',
          ),
          (
            action: give,
            kind: PredicatePathKind.rightParticle,
            text: 'You give up.',
          ),
        ];

        for (final example in examples) {
          final unlocks = predicateUnlocksFor(example.action)!;
          final paths = unlocks.paths.where(
            (path) => path.kind == example.kind,
          );
          final path =
              example.action == give &&
                  example.kind == PredicatePathKind.rightParticle
              ? paths.singleWhere(
                  (path) => path.particles.any(
                    (particle) => particle.text == upParticle.text,
                  ),
                )
              : paths.single;
          final state = compileFirstPredicatePathChoice(
            unlocks,
            path,
            lock: lock,
          );

          expect(wasBlocked(state), isFalse);
          expect(grammar.generate(state.sentenceState).text, example.text);
        }
      },
    );

    test('guided predicate unlocks are authored per visible verb', () {
      final verbs = guidedPredicateUnlocks
          .map((unlocks) => unlocks.verb.infinitive)
          .toList();

      expect(verbs, containsAll(['learn', 'talk', 'write', 'go']));
      expect(verbs.toSet(), hasLength(verbs.length));
    });

    test('every visible verb has at least one predicate influence', () {
      final silentVerbs = [
        for (final verb in verbs)
          if (predicateInfluencesFor(verb).isEmpty) verb.infinitive,
      ];

      expect(silentVerbs, isEmpty);
    });

    test('predicate paths consume reusable noun pools from data files', () {
      expect(
        people_data.singularPeople.map((noun) => noun.text),
        containsAll([
          'John',
          'Mary',
          'Alice',
          'David',
          'friend',
          'someone',
          'boss',
          'mother',
          'lawyer',
          'guest',
          'Sophia',
          'Adam',
          'aunt',
          'cashier',
          'developer',
          'firefighter',
        ]),
      );
      expect(
        animal_data.singularAnimals.map((noun) => noun.text),
        containsAll([
          'cat',
          'dog',
          'puppy',
          'dolphin',
          'hamster',
          'swan',
          'penguin',
          'rhino',
          'seal',
        ]),
      );
      expect(
        object_data.singularTextObjects.map((noun) => noun.text),
        containsAll([
          'book',
          'newspaper',
          'letter',
          'story',
          'magazine',
          'email',
          'message',
          'article',
          'note',
          'report',
          'poem',
          'diary',
          'list',
          'card',
        ]),
      );

      final talkAddressees = predicatePathsFor(talk)
          .where((path) => path.kind == PredicatePathKind.toAddressee)
          .single
          .nouns
          .map((noun) => noun.text);

      expect(
        talkAddressees,
        containsAll([
          'John',
          'Mary',
          'Alice',
          'boss',
          'cat',
          'dog',
          'hamster',
          'dolphin',
          'cashier',
          'aunt',
          'penguin',
          'rhino',
        ]),
      );
    });

    test('predicate path shelves expose semantic noun categories', () {
      expect(
        people_categories.singularWorkPeople.map((noun) => noun.text),
        containsAll([
          'boss',
          'colleague',
          'programmer',
          'police officer',
          'lawyer',
          'mechanic',
          'guard',
          'cashier',
          'developer',
          'plumber',
          'electrician',
        ]),
      );
      expect(
        people_categories.singularFamilyPeople.map((noun) => noun.text),
        containsAll([
          'mother',
          'father',
          'grandmother',
          'grandfather',
          'sister',
          'brother',
          'aunt',
          'uncle',
          'cousin',
          'wife',
          'husband',
          'daughter',
        ]),
      );
      expect(
        animal_categories.singularPetAnimals.map((noun) => noun.text),
        containsAll(['cat', 'dog', 'puppy', 'kitten', 'parrot', 'hamster']),
      );
      expect(
        animal_categories.singularWaterAnimals.map((noun) => noun.text),
        containsAll(['fish', 'dolphin', 'whale', 'shark', 'otter', 'seal']),
      );
      expect(
        object_categories.singularFoodObjects.map((noun) => noun.text),
        containsAll([
          'apple',
          'bread',
          'rice',
          'egg',
          'coffee',
          'juice',
          'water',
          'milk',
          'pizza',
          'salad',
          'pasta',
          'vegetable',
          'sugar',
          'salt',
          'oil',
          'tomato',
          'chicken',
          'chocolate',
          'cookie',
          'cereal',
        ]),
      );
      expect(
        object_categories.singularToolObjects.map((noun) => noun.text),
        containsAll([
          'phone',
          'computer',
          'pen',
          'keyboard',
          'camera',
          'knife',
          'hammer',
          'tablet',
          'charger',
          'cable',
          'notebook',
          'ruler',
          'screwdriver',
          'saw',
          'glue',
          'tape',
          'pot',
          'pan',
          'bowl',
          'microphone',
        ]),
      );
      expect(
        object_categories.singularOpenableObjects.map((noun) => noun.text),
        containsAll([
          'door',
          'window',
          'box',
          'wallet',
          'drawer',
          'folder',
          'envelope',
          'package',
          'suitcase',
          'fridge',
          'app',
          'file',
        ]),
      );
      expect(
        object_categories.singularMediaObjects.map((noun) => noun.text),
        containsAll([
          'movie',
          'video',
          'episode',
          'series',
          'scene',
          'script',
          'song',
          'photo',
          'painting',
          'website',
          'podcast',
          'playlist',
        ]),
      );
      expect(
        object_categories.singularPlaceObjects.map((noun) => noun.text),
        containsAll(['city', 'road', 'street', 'station', 'airport', 'hotel']),
      );
      expect(
        object_categories.singularAbstractObjects.map((noun) => noun.text),
        containsAll([
          'idea',
          'project',
          'plan',
          'problem',
          'question',
          'answer',
          'lesson',
          'language',
          'skill',
          'task',
          'goal',
          'rule',
          'system',
          'route',
          'topic',
          'decision',
        ]),
      );
      expect(
        object_categories.singularVehicleObjects.map((noun) => noun.text),
        containsAll(['car', 'bus', 'train', 'bicycle', 'motorcycle', 'truck']),
      );
      expect(
        object_categories.singularDrivableObjects.map((noun) => noun.text),
        containsAll(['car', 'bus', 'train', 'motorcycle', 'truck', 'taxi']),
      );
      expect(
        object_categories.singularDrivableObjects.map((noun) => noun.text),
        isNot(contains('bicycle')),
      );
      expect(
        object_categories.singularRideableObjects.map((noun) => noun.text),
        containsAll(['bicycle', 'bus', 'train', 'motorcycle']),
      );
    });

    test('second vocabulary batch reaches authored predicate routes', () {
      expect(
        predicateNounChoicesFor(
          learn,
          PredicatePathKind.directObject,
        ).map((object) => object.text),
        containsAll(['language', 'languages', 'skill', 'skills', 'lesson']),
      );
      expect(
        predicateNounChoicesFor(
          read,
          PredicatePathKind.directObject,
        ).map((object) => object.text),
        containsAll(['script', 'scripts']),
      );
      expect(
        predicateNounChoicesFor(
          watch,
          PredicatePathKind.directObject,
        ).map((object) => object.text),
        containsAll(['video', 'episode', 'series', 'scene']),
      );
      expect(
        predicateNounChoicesFor(
          use,
          PredicatePathKind.directObject,
        ).map((object) => object.text),
        containsAll(['charger', 'cable', 'notebook', 'ruler']),
      );
      expect(
        predicateNounChoicesFor(
          cooking_data.cook,
          PredicatePathKind.directObject,
        ).map((object) => object.text),
        containsAll(['pasta', 'vegetable', 'sugar', 'salt', 'oil']),
      );
      expect(
        predicateNounChoicesFor(
          work,
          PredicatePathKind.onTopic,
        ).map((object) => object.text),
        containsAll(['project', 'projects', 'tool', 'tools']),
      );
      expect(
        predicatePlaceChoicesFor(
          go,
          PredicatePathKind.placePhrase,
        ).map((place) => place.noun),
        containsAll(['station', 'airport', 'hotel', 'city', 'forest']),
      );
      expect(
        predicatePlaceChoicesFor(
          run,
          PredicatePathKind.onLocation,
        ).map((place) => place.noun),
        containsAll(['road', 'street', 'beach']),
      );
    });

    test('third vocabulary batch widens reusable place route shelves', () {
      expect(
        placePhrases.map((place) => place.noun),
        containsAll([
          'market',
          'bank',
          'gym',
          'classroom',
          'garage',
          'bus stop',
          'playground',
        ]),
      );
      expect(
        predicatePlaceChoicesFor(
          go,
          PredicatePathKind.fromLocation,
        ).map((place) => place.noun),
        containsAll([
          'market',
          'bank',
          'gym',
          'classroom',
          'garage',
          'bus stop',
          'station',
          'airport',
          'hotel',
        ]),
      );
      expect(
        predicatePlaceChoicesFor(
          travel_data.pack,
          PredicatePathKind.fromLocation,
        ).map((place) => place.noun),
        containsAll(['market', 'bank', 'gym', 'bus stop', 'airport']),
      );
      expect(
        predicatePlaceChoicesFor(
          run,
          PredicatePathKind.onLocation,
        ).map((place) => place.noun),
        containsAll(['road', 'street', 'beach', 'playground']),
      );
    });

    test('fourth vocabulary batch widens everyday object route shelves', () {
      expect(
        predicateNounChoicesFor(
          read,
          PredicatePathKind.directObject,
        ).map((object) => object.text),
        containsAll(['recipe', 'menu', 'contract', 'file', 'website', 'code']),
      );
      expect(
        predicateNounChoicesFor(
          write,
          PredicatePathKind.directObject,
        ).map((object) => object.text),
        containsAll(['recipe', 'contract', 'file', 'page', 'code']),
      );
      expect(
        predicateNounChoicesFor(
          write,
          PredicatePathKind.directObject,
        ).map((object) => object.text),
        isNot(contains('receipt')),
      );
      expect(
        predicateNounChoicesFor(
          use,
          PredicatePathKind.directObject,
        ).map((object) => object.text),
        containsAll(['screwdriver', 'saw', 'glue', 'tape', 'microphone']),
      );
      expect(
        predicateNounChoicesFor(
          open,
          PredicatePathKind.directObject,
        ).map((object) => object.text),
        containsAll(['envelope', 'package', 'suitcase', 'fridge', 'app']),
      );
      expect(
        predicateNounChoicesFor(
          cooking_data.cook,
          PredicatePathKind.directObject,
        ).map((object) => object.text),
        containsAll(['tomato', 'chicken', 'chocolate', 'cookie', 'cereal']),
      );
      expect(
        predicateNounChoicesFor(
          work,
          PredicatePathKind.onTopic,
        ).map((object) => object.text),
        containsAll(['task', 'goal', 'rule', 'system', 'route', 'topic']),
      );
      expect(
        predicateNounChoicesFor(
          drive,
          PredicatePathKind.directObject,
        ).map((object) => object.text),
        containsAll(['motorcycle', 'truck', 'taxi']),
      );
    });

    test('fixed object frames consume semantic category shelves', () {
      final examples = [
        (action: write, object: object_data.email),
        (action: write, object: object_data.message),
        (action: write, object: object_data.report),
        (action: write, object: object_data.page),
        (action: read, object: object_data.article),
        (action: read, object: object_data.document),
        (action: read, object: object_data.recipe),
        (action: use, object: object_data.camera),
        (action: use, object: object_data.tablet),
        (action: use, object: object_data.screwdriver),
        (action: open, object: object_data.box),
        (action: open, object: object_data.drawer),
        (action: open, object: object_data.suitcase),
        (action: close, object: object_data.wallet),
        (action: close, object: object_data.folder),
        (action: close, object: object_data.fridge),
        (action: watch, object: object_data.movie),
        (action: watch, object: object_data.photo),
      ];

      for (final example in examples) {
        expect(
          fixedObjectFitsAction(
            example.object.toNounPhrase(Number.singular),
            example.action,
          ),
          isTrue,
          reason: '${example.action.infinitive} ${example.object.singular}',
        );
      }
    });

    test('authored Compass mode narrows rails to predicate paths', () {
      final authoredCompass = ConfigurationCompass(
        predicatePathMode: PredicatePathMode.authoredTracks,
        objects: [
          object_data.book.toNounPhrase(Number.singular),
          object_data.bridge.toNounPhrase(Number.singular),
        ],
      );

      final suggestions = authoredCompass.suggestionsFor(
        ConfigurationState.initial(),
        ConfigurationCompassSlot.object,
        limit: 0,
      );
      final labels = suggestions.map((suggestion) => suggestion.label).toList();

      expect(
        labels,
        containsAll([
          'English',
          'Polish',
          'Spanish',
          'grammar',
          'history',
          'math',
          'science',
          'language',
          'skill',
          'lesson',
        ]),
      );
      expect(labels, isNot(contains('book')));
      expect(
        grammar.generate(suggestions.first.preview.sentenceState).text,
        'You learn English.',
      );
    });

    test(
      'authored Compass mode pulls addressees from predicate path shelves',
      () {
        final authoredCompass = ConfigurationCompass(
          predicatePathMode: PredicatePathMode.authoredTracks,
          recipients: [people_data.john.toNounPhrase(Number.singular)],
        );
        var state = ConfigurationState.initial();
        state = lock.applyMove(state, const SetAction(talk));

        final suggestions = authoredCompass.suggestionsFor(
          state,
          ConfigurationCompassSlot.addressee,
          limit: 0,
        );
        final labels = suggestions
            .map((suggestion) => suggestion.label)
            .toList();
        final johnSuggestion = suggestions.singleWhere(
          (suggestion) => suggestion.label == 'John',
        );

        expect(
          labels,
          containsAll(['John', 'Mary', 'Alice', 'boss', 'cat', 'hamster']),
        );
        expect(
          grammar.generate(johnSuggestion.preview.sentenceState).text,
          'You talk to John.',
        );
      },
    );

    test('legacy Compass mode remains available as broad fallback', () {
      final legacyCompass = ConfigurationCompass(
        predicatePathMode: PredicatePathMode.legacyCompassFallback,
        recipients: [people_data.john.toNounPhrase(Number.singular)],
      );
      var state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetAction(talk));

      final suggestions = legacyCompass.suggestionsFor(
        state,
        ConfigurationCompassSlot.addressee,
        limit: 0,
      );
      final labels = suggestions.map((suggestion) => suggestion.label).toList();

      expect(labels, ['John']);
      expect(labels, isNot(contains('cat')));
    });

    test('every essential verb has a predicate path migration decision', () {
      final expected = essentialVerbs.map((verb) => verb.infinitive).toSet();
      final actual = essentialPredicatePathMigration
          .map((decision) => decision.verb.infinitive)
          .toSet();

      expect(actual, expected);
      expect(
        essentialPredicatePathMigration,
        everyElement(
          predicate<PredicatePathMigrationDecision>(
            (decision) => decision.note.isNotEmpty,
            'has a migration note',
          ),
        ),
      );
    });

    test('seeded migration decisions match authored unlock data', () {
      final seeded = essentialPredicatePathMigration
          .where(
            (decision) => decision.readiness == PredicatePathReadiness.seeded,
          )
          .map((decision) => decision.verb.infinitive)
          .toSet();
      final authored = guidedPredicateUnlocks
          .map((unlocks) => unlocks.verb.infinitive)
          .where(essentialVerbs.map((verb) => verb.infinitive).contains)
          .toSet();

      expect(seeded, authored);
      expect(seeded, containsAll(['learn', 'go']));
    });

    test('predicate route audit covers every essential verb', () {
      final rows = essentialPredicateRouteAuditRows();

      expect(
        rows.map((row) => row.infinitive).toSet(),
        essentialVerbs.map((verb) => verb.infinitive).toSet(),
      );
      expect(
        rows,
        everyElement(
          predicate<PredicateRouteAuditRow>(
            (row) => row.migration != null,
            'has a migration decision',
          ),
        ),
      );
    });

    test('predicate route audit exposes thin and gated verb buckets', () {
      final rows = predicateRouteAuditRows();
      final buckets = predicateRouteAuditBuckets(rows);
      final teachRow = rows.singleWhere((row) => row.infinitive == 'teach');
      final learnRow = rows.singleWhere((row) => row.infinitive == 'learn');

      expect(teachRow.hasRecipientGatedRightAction, isTrue);
      expect(
        teachRow.pathSummaries,
        contains('to + verb: 6 (needs recipient)'),
      );
      expect(learnRow.kindLabels, containsAll(['object', 'to + verb']));
      expect(buckets['recipient-gated right action'], contains(teachRow));
      expect(
        rows.indexWhere((row) => row.isThin),
        lessThan(rows.indexOf(learnRow)),
      );
    });

    test(
      'authored direct objects are not inferred from broad object grammar',
      () {
        final learnDirectObjects = predicatePathsFor(learn)
            .where((path) => path.kind == PredicatePathKind.directObject)
            .single
            .nouns
            .map((noun) => noun.text)
            .toList();

        expect(learn.takesObject, isTrue);
        expect(
          learnDirectObjects,
          containsAll([
            'English',
            'Polish',
            'Spanish',
            'grammar',
            'math',
            'history',
            'science',
          ]),
        );
        expect(learnDirectObjects, isNot(contains('book')));
      },
    );

    test('semantic object filter reads authored direct-object paths', () {
      expect(
        semanticDirectObjectFitsAction(fixed_object.english, learn),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.book.toNounPhrase(Number.singular),
          learn,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.apple.toNounPhrase(Number.singular),
          cooking_data.eat,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.book.toNounPhrase(Number.singular),
          cooking_data.eat,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.car.toNounPhrase(Number.singular),
          drive,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.book.toNounPhrase(Number.singular),
          drive,
        ),
        isFalse,
      );
    });

    test('wide essential verbs use narrowed semantic object shelves', () {
      expect(
        semanticDirectObjectFitsAction(
          object_data.phone.toNounPhrase(Number.singular),
          have,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(fixed_object.waiting, have),
        isFalse,
      );

      expect(
        semanticDirectObjectFitsAction(
          object_data.message.toNounPhrase(Number.singular),
          get,
        ),
        isTrue,
      );
      expect(semanticDirectObjectFitsAction(fixed_object.noise, get), isFalse);

      expect(
        semanticDirectObjectFitsAction(
          object_data.apple.toNounPhrase(Number.singular),
          buy,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(fixed_object.waiting, buy),
        isFalse,
      );

      expect(
        semanticDirectObjectFitsAction(
          object_data.house.toNounPhrase(Number.singular),
          sell,
        ),
        isTrue,
      );
      expect(semanticDirectObjectFitsAction(fixed_object.yes, sell), isFalse);

      expect(
        semanticDirectObjectFitsAction(
          object_data.book.toNounPhrase(Number.singular),
          want,
        ),
        isTrue,
      );
      expect(semanticDirectObjectFitsAction(fixed_object.noise, want), isFalse);
      expect(semanticDirectObjectFitsAction(fixed_object.yes, want), isFalse);

      expect(
        semanticDirectObjectFitsAction(
          object_data.key.toNounPhrase(Number.singular),
          need,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(fixed_object.helpNoun, need),
        isTrue,
      );
      expect(semanticDirectObjectFitsAction(fixed_object.noise, need), isFalse);
      expect(semanticDirectObjectFitsAction(fixed_object.no, need), isFalse);

      expect(
        semanticDirectObjectFitsAction(fixed_object.something, doVerb),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(fixed_object.homework, doVerb),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.task.toNounPhrase(Number.singular),
          doVerb,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.book.toNounPhrase(Number.singular),
          doVerb,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(fixed_object.english, doVerb),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.game.toNounPhrase(Number.singular),
          doVerb,
        ),
        isFalse,
      );

      expect(
        semanticDirectObjectFitsAction(
          object_data.cake.toNounPhrase(Number.singular),
          make,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.coffee.toNounPhrase(Number.singular),
          make,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.gift.toNounPhrase(Number.singular),
          make,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.document.toNounPhrase(Number.singular),
          make,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.apple.toNounPhrase(Number.singular),
          make,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.carrot.toNounPhrase(Number.singular),
          make,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.key.toNounPhrase(Number.singular),
          make,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.phone.toNounPhrase(Number.singular),
          make,
        ),
        isFalse,
      );

      expect(
        semanticDirectObjectFitsAction(
          object_data.book.toNounPhrase(Number.singular),
          take,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.phone.toNounPhrase(Number.singular),
          take,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.photo.toNounPhrase(Number.singular),
          take,
        ),
        isTrue,
      );
      expect(semanticDirectObjectFitsAction(fixed_object.money, take), isTrue);
      expect(
        semanticDirectObjectFitsAction(
          object_data.charger.toNounPhrase(Number.singular),
          take,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.key.toNounPhrase(Number.singular),
          take,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.road.toNounPhrase(Number.singular),
          take,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.ticket.toNounPhrase(Number.singular),
          take,
        ),
        isFalse,
      );

      expect(
        semanticDirectObjectFitsAction(
          object_data.book.toNounPhrase(Number.singular),
          bring,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.phone.toNounPhrase(Number.singular),
          bring,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.photo.toNounPhrase(Number.singular),
          bring,
        ),
        isTrue,
      );
      expect(semanticDirectObjectFitsAction(fixed_object.money, bring), isTrue);
      expect(
        semanticDirectObjectFitsAction(
          object_data.apple.toNounPhrase(Number.singular),
          bring,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.charger.toNounPhrase(Number.singular),
          bring,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.key.toNounPhrase(Number.singular),
          bring,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.ticket.toNounPhrase(Number.singular),
          bring,
        ),
        isFalse,
      );

      expect(
        semanticDirectObjectFitsAction(
          object_data.book.toNounPhrase(Number.singular),
          give,
        ),
        isTrue,
      );
      expect(semanticDirectObjectFitsAction(fixed_object.money, give), isTrue);
      expect(
        semanticDirectObjectFitsAction(
          object_data.food.toNounPhrase(Number.singular),
          give,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.gift.toNounPhrase(Number.singular),
          give,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(fixed_object.smoking, give),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          fixed_object.smoking,
          give,
          rightParticle: upParticle,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.letter.toNounPhrase(Number.singular),
          give,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.key.toNounPhrase(Number.singular),
          give,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.phone.toNounPhrase(Number.singular),
          give,
        ),
        isFalse,
      );

      expect(
        semanticDirectObjectFitsAction(
          object_data.book.toNounPhrase(Number.singular),
          read,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.newspaper.toNounPhrase(Number.singular),
          read,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(fixed_object.english, read),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.phone.toNounPhrase(Number.singular),
          read,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.key.toNounPhrase(Number.singular),
          read,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.bread.toNounPhrase(Number.singular),
          read,
        ),
        isFalse,
      );
      expect(semanticDirectObjectFitsAction(fixed_object.money, read), isFalse);

      expect(
        semanticDirectObjectFitsAction(
          object_data.story.toNounPhrase(Number.singular),
          write,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.letter.toNounPhrase(Number.singular),
          write,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.report.toNounPhrase(Number.singular),
          write,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.email.toNounPhrase(Number.singular),
          write,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.code.toNounPhrase(Number.singular),
          write,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(fixed_object.something, write),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.newspaper.toNounPhrase(Number.singular),
          write,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.magazine.toNounPhrase(Number.singular),
          write,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.website.toNounPhrase(Number.singular),
          write,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.phone.toNounPhrase(Number.singular),
          write,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.bread.toNounPhrase(Number.singular),
          write,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(fixed_object.money, write),
        isFalse,
      );

      expect(
        semanticDirectObjectFitsAction(fixed_object.something, use),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.phone.toNounPhrase(Number.singular),
          use,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.computer.toNounPhrase(Number.singular),
          use,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.key.toNounPhrase(Number.singular),
          use,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.keyboard.toNounPhrase(Number.singular),
          use,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.apple.toNounPhrase(Number.singular),
          use,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.bread.toNounPhrase(Number.singular),
          use,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.story.toNounPhrase(Number.singular),
          use,
        ),
        isFalse,
      );
      expect(semanticDirectObjectFitsAction(fixed_object.money, use), isFalse);

      expect(
        semanticDirectObjectFitsAction(fixed_object.something, watch),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.movie.toNounPhrase(Number.singular),
          watch,
        ),
        isTrue,
      );
      expect(semanticDirectObjectFitsAction(fixed_object.show, watch), isTrue);
      expect(
        semanticDirectObjectFitsAction(
          object_data.game.toNounPhrase(Number.singular),
          watch,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          people_data.john.toNounPhrase(Number.singular),
          watch,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          animal_data.cat.toNounPhrase(Number.singular),
          watch,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.key.toNounPhrase(Number.singular),
          watch,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.bread.toNounPhrase(Number.singular),
          watch,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(fixed_object.money, watch),
        isFalse,
      );

      expect(
        semanticDirectObjectFitsAction(fixed_object.something, see),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          people_data.john.toNounPhrase(Number.singular),
          see,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          animal_data.cat.toNounPhrase(Number.singular),
          see,
        ),
        isTrue,
      );
      expect(semanticDirectObjectFitsAction(fixed_object.problem, see), isTrue);
      expect(
        semanticDirectObjectFitsAction(
          object_data.apple.toNounPhrase(Number.singular),
          see,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.key.toNounPhrase(Number.singular),
          see,
        ),
        isTrue,
      );
      expect(semanticDirectObjectFitsAction(fixed_object.yes, see), isFalse);
      expect(semanticDirectObjectFitsAction(fixed_object.noise, see), isFalse);
      expect(
        semanticDirectObjectFitsAction(fixed_object.waiting, see),
        isFalse,
      );

      expect(
        semanticDirectObjectFitsAction(fixed_object.something, findVerb),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.book.toNounPhrase(Number.singular),
          findVerb,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.book.toNounPhrase(Number.plural),
          findVerb,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.key.toNounPhrase(Number.singular),
          findVerb,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.key.toNounPhrase(Number.plural),
          findVerb,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(fixed_object.money, findVerb),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(people_data.someone, findVerb),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.bread.toNounPhrase(Number.singular),
          findVerb,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(fixed_object.yes, findVerb),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(fixed_object.noise, findVerb),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(fixed_object.waiting, findVerb),
        isFalse,
      );

      expect(
        semanticDirectObjectFitsAction(fixed_object.something, open),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.eye.toNounPhrase(Number.plural),
          open,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.store.toNounPhrase(Number.singular),
          open,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.workshop.toNounPhrase(Number.singular),
          open,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.office.toNounPhrase(Number.singular),
          open,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.bread.toNounPhrase(Number.singular),
          open,
        ),
        isFalse,
      );
      expect(semanticDirectObjectFitsAction(fixed_object.money, open), isFalse);

      expect(
        semanticDirectObjectFitsAction(fixed_object.something, close),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.eye.toNounPhrase(Number.plural),
          close,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.store.toNounPhrase(Number.singular),
          close,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.workshop.toNounPhrase(Number.singular),
          close,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.office.toNounPhrase(Number.singular),
          close,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.bread.toNounPhrase(Number.singular),
          close,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(fixed_object.money, close),
        isFalse,
      );

      expect(
        semanticDirectObjectFitsAction(fixed_object.something, breakVerb),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.window.toNounPhrase(Number.singular),
          breakVerb,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.window.toNounPhrase(Number.plural),
          breakVerb,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.phone.toNounPhrase(Number.singular),
          breakVerb,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.chair.toNounPhrase(Number.singular),
          breakVerb,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.cup.toNounPhrase(Number.singular),
          breakVerb,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.eye.toNounPhrase(Number.plural),
          breakVerb,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.store.toNounPhrase(Number.singular),
          breakVerb,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.office.toNounPhrase(Number.singular),
          breakVerb,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.book.toNounPhrase(Number.singular),
          breakVerb,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.bread.toNounPhrase(Number.singular),
          breakVerb,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(fixed_object.money, breakVerb),
        isFalse,
      );

      expect(
        semanticDirectObjectFitsAction(fixed_object.something, lose),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(object_pronouns.yourself, lose),
        isTrue,
      );
      expect(semanticDirectObjectFitsAction(fixed_object.money, lose), isTrue);
      expect(
        semanticDirectObjectFitsAction(
          object_data.key.toNounPhrase(Number.singular),
          lose,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.phone.toNounPhrase(Number.singular),
          lose,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.game.toNounPhrase(Number.singular),
          lose,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.card.toNounPhrase(Number.plural),
          lose,
        ),
        isTrue,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.book.toNounPhrase(Number.singular),
          lose,
        ),
        isFalse,
      );
      expect(
        semanticDirectObjectFitsAction(
          object_data.bread.toNounPhrase(Number.singular),
          lose,
        ),
        isFalse,
      );
      expect(semanticDirectObjectFitsAction(fixed_object.yes, lose), isFalse);
      expect(semanticDirectObjectFitsAction(fixed_object.noise, lose), isFalse);
    });

    test(
      'authored word-opening queries stay separate from structural helpers',
      () {
        final learnObjects = predicateNounChoicesFor(
          learn,
          PredicatePathKind.directObject,
        ).map((noun) => noun.text).toList();

        expect(learnObjects, containsAll(['English', 'grammar', 'history']));
        expect(learnObjects, isNot(contains('book')));
        expect(
          fixedObjectChoicesFor(learn).map((noun) => noun.text),
          containsAll([
            'English',
            'Polish',
            'Spanish',
            'grammar',
            'math',
            'history',
            'science',
            'language',
            'skill',
            'lesson',
          ]),
        );
        expect(
          fixedObjectChoicesFor(learn).map((noun) => noun.text),
          isNot(contains('book')),
        );

        final learnRightActions = predicateVerbChoicesFor(
          learn,
          PredicatePathKind.toRightAction,
        ).map((verb) => verb.infinitive).toList();
        final helperRightActions = rightActionChoicesFor(
          learn,
        ).map((verb) => verb.infinitive).toList();

        expect(helperRightActions, learnRightActions);
        expect(helperRightActions, [
          'speak',
          'swim',
          'work',
          'read',
          'write',
          'sing',
          'play',
        ]);
      },
    );

    test('authored paths fit lower structural laws', () {
      for (final unlocks in guidedPredicateUnlocks) {
        for (final path in unlocks.paths) {
          final reason = '${unlocks.verb.infinitive} ${path.kind}';

          switch (path.kind) {
            case PredicatePathKind.directObject:
              expect(
                unlocks.verb.takesObject || hasFixedObjectFrame(unlocks.verb),
                isTrue,
                reason: reason,
              );
              expect(path.nouns, isNotEmpty, reason: reason);
              for (final noun in path.nouns) {
                if (hasFixedObjectFrame(unlocks.verb)) {
                  expect(
                    fixedObjectFitsAction(noun, unlocks.verb),
                    isTrue,
                    reason: '$reason -> ${noun.text}',
                  );
                }
              }
            case PredicatePathKind.toRightAction:
              expect(hasRightActionFrame(unlocks.verb), isTrue, reason: reason);
              expect(path.verbs, isNotEmpty, reason: reason);
              for (final rightAction in path.verbs) {
                expect(
                  rightActionFitsAction(rightAction, unlocks.verb),
                  isTrue,
                  reason: '$reason -> ${rightAction.infinitive}',
                );
              }
            case PredicatePathKind.toRecipient:
              expect(unlocks.verb.takesRecipient, isTrue, reason: reason);
              expect(path.nouns, isNotEmpty, reason: reason);
            case PredicatePathKind.toAddressee:
              expect(unlocks.verb.takesAddressee, isTrue, reason: reason);
              expect(path.nouns, isNotEmpty, reason: reason);
            case PredicatePathKind.withCompanion:
              expect(unlocks.verb.takesCompanion, isTrue, reason: reason);
              expect(path.nouns, isNotEmpty, reason: reason);
            case PredicatePathKind.withInstrument:
              expect(unlocks.verb.takesInstrument, isTrue, reason: reason);
              expect(path.nouns, isNotEmpty, reason: reason);
            case PredicatePathKind.toDestination:
              expect(unlocks.verb.usesDestinationPlace, isTrue, reason: reason);
              expect(path.nouns, isNotEmpty, reason: reason);
            case PredicatePathKind.aboutTopic:
            case PredicatePathKind.ofTopic:
            case PredicatePathKind.onTopic:
            case PredicatePathKind.overTopic:
            case PredicatePathKind.withTopic:
              expect(unlocks.verb.takesTopic, isTrue, reason: reason);
              expect(path.nouns, isNotEmpty, reason: reason);
            case PredicatePathKind.forBeneficiary:
              expect(unlocks.verb.takesBeneficiary, isTrue, reason: reason);
              expect(path.nouns, isNotEmpty, reason: reason);
            case PredicatePathKind.fromSource:
              expect(unlocks.verb.takesSource, isTrue, reason: reason);
              expect(path.nouns, isNotEmpty, reason: reason);
            case PredicatePathKind.forPurpose:
              expect(unlocks.verb.takesPurpose, isTrue, reason: reason);
              expect(path.nouns, isNotEmpty, reason: reason);
            case PredicatePathKind.atLocation:
              expect(path.places, isNotEmpty, reason: reason);
              for (final place in path.places) {
                expect(
                  place.render(PlaceMeaning.location).startsWith('at '),
                  isTrue,
                  reason: '$reason -> ${place.render(PlaceMeaning.location)}',
                );
              }
            case PredicatePathKind.inLocation:
              expect(path.places, isNotEmpty, reason: reason);
              for (final place in path.places) {
                expect(
                  place.render(PlaceMeaning.location).startsWith('in '),
                  isTrue,
                  reason: '$reason -> ${place.render(PlaceMeaning.location)}',
                );
              }
            case PredicatePathKind.onLocation:
              expect(path.places, isNotEmpty, reason: reason);
              for (final place in path.places) {
                expect(
                  place.render(PlaceMeaning.location).startsWith('on '),
                  isTrue,
                  reason: '$reason -> ${place.render(PlaceMeaning.location)}',
                );
              }
            case PredicatePathKind.fromLocation:
              expect(path.places, isNotEmpty, reason: reason);
              for (final place in path.places) {
                expect(
                  place.render(PlaceMeaning.source).startsWith('from '),
                  isTrue,
                  reason: '$reason -> ${place.render(PlaceMeaning.source)}',
                );
              }
            case PredicatePathKind.placePhrase:
              expect(path.places, isNotEmpty, reason: reason);
            case PredicatePathKind.timePhrase:
              expect(path.times, isNotEmpty, reason: reason);
            case PredicatePathKind.frequencyPhrase:
              expect(path.frequencies, isNotEmpty, reason: reason);
            case PredicatePathKind.mannerPhrase:
              expect(path.manners, isNotEmpty, reason: reason);
            case PredicatePathKind.rightParticle:
              expect(path.particles, isNotEmpty, reason: reason);
          }
        }
      }
    });

    test('authored paths translate into Lock moves and render', () {
      for (final unlocks in guidedPredicateUnlocks) {
        for (final path in unlocks.paths) {
          var state = ConfigurationState.initial();
          state = stateAfterPath(unlocks, path);

          expect(
            wasBlocked(state),
            isFalse,
            reason: '${unlocks.verb.infinitive} ${path.kind}',
          );
          expect(grammar.generate(state.sentenceState).text, isNotEmpty);
        }
      }
    });

    test('object-dependent paths document and compile their prerequisite', () {
      for (final verb in [take, bring]) {
        final unlocks = predicateUnlocksFor(verb)!;
        final destinationPath = unlocks.paths.singleWhere(
          (path) => path.kind == PredicatePathKind.toDestination,
        );

        expect(destinationPath.requiresObject, isTrue);
        expect(
          predicatePathRequiresObject(verb, PredicatePathKind.toDestination),
          isTrue,
        );

        final state = stateAfterPath(unlocks, destinationPath);

        expect(wasBlocked(state), isFalse);
        expect(state.sentenceState.object, isNotNull);
        expect(state.sentenceState.destination?.text, 'John');
        expect(
          grammar.generate(state.sentenceState).text,
          allOf(startsWith('You ${verb.infinitive} '), endsWith(' to John.')),
        );
      }
    });

    test('object-moving destination-place paths compile after an object', () {
      for (final verb in [take, bring]) {
        final unlocks = predicateUnlocksFor(verb)!;
        final destinationPlacePath = unlocks.paths.singleWhere(
          (path) => path.kind == PredicatePathKind.placePhrase,
        );

        expect(destinationPlacePath.requiresObject, isTrue);
        expect(
          predicatePathRequiresObject(verb, PredicatePathKind.placePhrase),
          isTrue,
        );

        final state = stateAfterPath(unlocks, destinationPlacePath);

        expect(wasBlocked(state), isFalse, reason: verb.infinitive);
        expect(state.sentenceState.object?.text, 'something');
        expect(state.sentenceState.placePhrase?.noun, 'home');
        expect(state.sentenceState.placeMeaning, PlaceMeaning.destination);
        expect(
          grammar.generate(state.sentenceState).text,
          'You ${verb.infinitive} something home.',
        );
      }
    });

    test('object-dependent prepositional paths compile their prerequisite', () {
      final unlocks = predicateUnlocksFor(need)!;
      final examples = [
        (
          kind: PredicatePathKind.fromSource,
          field: (SentenceState state) => state.source,
          ending: ' from John.',
        ),
        (
          kind: PredicatePathKind.forBeneficiary,
          field: (SentenceState state) => state.beneficiary,
          ending: ' for John.',
        ),
        (
          kind: PredicatePathKind.forPurpose,
          field: (SentenceState state) => state.purpose,
          ending: ' for work.',
        ),
      ];

      for (final (:kind, :field, :ending) in examples) {
        final path = unlocks.paths.singleWhere((path) => path.kind == kind);

        expect(path.requiresObject, isTrue, reason: kind.name);
        expect(predicatePathRequiresObject(need, kind), isTrue);

        final state = stateAfterPath(unlocks, path);

        expect(wasBlocked(state), isFalse, reason: kind.name);
        expect(state.sentenceState.object, isNotNull, reason: kind.name);
        expect(field(state.sentenceState), isNotNull, reason: kind.name);
        expect(
          grammar.generate(state.sentenceState).text,
          allOf(startsWith('You need '), endsWith(ending)),
          reason: kind.name,
        );
      }
    });

    test(
      'object verbs compile object-dependent prepositional prerequisites',
      () {
        final examples = [
          (
            verb: have,
            kind: PredicatePathKind.withCompanion,
            field: (SentenceState state) => state.companion,
            ending: ' with John.',
          ),
          (
            verb: have,
            kind: PredicatePathKind.fromSource,
            field: (SentenceState state) => state.source,
            ending: ' from John.',
          ),
          (
            verb: have,
            kind: PredicatePathKind.forBeneficiary,
            field: (SentenceState state) => state.beneficiary,
            ending: ' for John.',
          ),
          (
            verb: have,
            kind: PredicatePathKind.forPurpose,
            field: (SentenceState state) => state.purpose,
            ending: ' for work.',
          ),
          (
            verb: have,
            kind: PredicatePathKind.atLocation,
            field: (SentenceState state) => state.placePhrase,
            ending: ' at home.',
          ),
          (
            verb: doVerb,
            kind: PredicatePathKind.withCompanion,
            field: (SentenceState state) => state.companion,
            ending: ' with John.',
          ),
          (
            verb: doVerb,
            kind: PredicatePathKind.forBeneficiary,
            field: (SentenceState state) => state.beneficiary,
            ending: ' for John.',
          ),
          (
            verb: doVerb,
            kind: PredicatePathKind.forPurpose,
            field: (SentenceState state) => state.purpose,
            ending: ' for work.',
          ),
          (
            verb: doVerb,
            kind: PredicatePathKind.atLocation,
            field: (SentenceState state) => state.placePhrase,
            ending: ' at home.',
          ),
          (
            verb: get,
            kind: PredicatePathKind.fromSource,
            field: (SentenceState state) => state.source,
            ending: ' from John.',
          ),
          (
            verb: get,
            kind: PredicatePathKind.forBeneficiary,
            field: (SentenceState state) => state.beneficiary,
            ending: ' for John.',
          ),
          (
            verb: get,
            kind: PredicatePathKind.forPurpose,
            field: (SentenceState state) => state.purpose,
            ending: ' for work.',
          ),
          (
            verb: get,
            kind: PredicatePathKind.atLocation,
            field: (SentenceState state) => state.placePhrase,
            ending: ' at home.',
          ),
          (
            verb: get,
            kind: PredicatePathKind.fromLocation,
            field: (SentenceState state) => state.placePhrase,
            ending: ' from home.',
          ),
          (
            verb: make,
            kind: PredicatePathKind.forBeneficiary,
            field: (SentenceState state) => state.beneficiary,
            ending: ' for John.',
          ),
          (
            verb: make,
            kind: PredicatePathKind.forPurpose,
            field: (SentenceState state) => state.purpose,
            ending: ' for work.',
          ),
        ];

        for (final (:verb, :kind, :field, :ending) in examples) {
          final unlocks = predicateUnlocksFor(verb)!;
          final path = unlocks.paths.singleWhere((path) => path.kind == kind);

          expect(path.requiresObject, isTrue, reason: kind.name);
          expect(predicatePathRequiresObject(verb, kind), isTrue);

          final state = stateAfterPath(unlocks, path);

          expect(wasBlocked(state), isFalse, reason: kind.name);
          expect(state.sentenceState.object, isNotNull, reason: kind.name);
          expect(field(state.sentenceState), isNotNull, reason: kind.name);
          expect(
            grammar.generate(state.sentenceState).text,
            allOf(startsWith('You ${verb.infinitive} '), endsWith(ending)),
            reason: kind.name,
          );
        }
      },
    );

    test(
      'recipient-dependent paths document and compile their prerequisite',
      () {
        final unlocks = predicateUnlocksFor(education_data.teach)!;
        final rightActionPath = unlocks.paths.singleWhere(
          (path) => path.kind == PredicatePathKind.toRightAction,
        );

        expect(rightActionPath.requiresRecipient, isTrue);
        expect(
          predicatePathRequiresRecipient(
            education_data.teach,
            PredicatePathKind.toRightAction,
          ),
          isTrue,
        );

        final state = stateAfterPath(unlocks, rightActionPath);

        expect(wasBlocked(state), isFalse);
        expect(state.sentenceState.recipient, isNotNull);
        expect(state.sentenceState.rightAction, isNotNull);
        expect(
          grammar.generate(state.sentenceState).text,
          'You teach ${state.sentenceState.recipient!.text} to speak.',
        );
      },
    );

    test('seed paths document the intended first product tracks', () {
      final examples = <Verb, List<String>>{
        learn: [
          'You learn English.',
          'You learn to speak.',
          'You learn with John.',
        ],
        talk: ['You talk to John.', 'You talk with John.'],
        write: [
          'You write book.',
          'You write John book.',
          'You write to John.',
          'You write with John.',
        ],
        go: ['You go to John.', 'You go with John.'],
      };

      for (final entry in examples.entries) {
        final unlocks = predicateUnlocksFor(entry.key)!;
        final rendered = unlocks.paths.map((path) {
          final state = stateAfterPath(unlocks, path);
          return grammar.generate(state.sentenceState).text;
        }).toList();

        expect(rendered, containsAll(entry.value));
      }
    });

    test('essential reviewed phrase paths are authored', () {
      expect(
        predicateNounChoicesFor(
          learn,
          PredicatePathKind.aboutTopic,
        ).map((topic) => topic.text),
        containsAll(['grammar', 'science', 'Mary']),
      );
      expect(
        predicateNounChoicesFor(
          work,
          PredicatePathKind.onTopic,
        ).map((topic) => topic.text),
        containsAll([
          'English',
          'grammar',
          'science',
          'car',
          'cars',
          'physique',
          'skill',
          'skills',
          'swimming',
          'skating',
        ]),
      );
      expect(predicateTopicConnectorsFor(work), ['on']);
      expect(predicateTopicConnectorsFor(think), ['about', 'of', 'over']);
      expect(predicateTopicConnectorsFor(help), ['with']);
      expect(
        predicateNounChoicesFor(
          think,
          PredicatePathKind.overTopic,
        ).map((topic) => topic.text),
        containsAll(['plan', 'problem', 'grammar', 'document']),
      );
      expect(
        predicateNounChoicesFor(
          help,
          PredicatePathKind.withTopic,
        ).map((topic) => topic.text),
        containsAll(['homework', 'problem', 'question']),
      );
      expect(
        predicateNounChoicesFor(
          close,
          PredicatePathKind.onTopic,
        ).map((topic) => topic.text),
        containsAll(['something', 'deal', 'contract', 'house', 'store']),
      );
      expect(predicateTopicConnectorsFor(close), ['on']);
      expect(
        predicatePlaceChoicesFor(
          work,
          PredicatePathKind.atLocation,
        ).map((place) => place.noun),
        containsAll(['home', 'school', 'work']),
      );
      expect(
        predicatePlaceChoicesFor(
          work,
          PredicatePathKind.inLocation,
        ).map((place) => place.noun),
        containsAll(['office', 'IT']),
      );
      expect(
        predicatePlaceChoicesFor(
          findVerb,
          PredicatePathKind.inLocation,
        ).map((place) => place.noun),
        contains('room'),
      );
      expect(
        predicatePlaceChoicesFor(
          buy,
          PredicatePathKind.inLocation,
        ).map((place) => place.noun),
        contains('shop'),
      );
      expect(
        predicateNounChoicesFor(
          education_data.analyze,
          PredicatePathKind.directObject,
        ).map((object) => object.text),
        containsAll(['data', 'problem', 'question', 'document']),
      );
      expect(
        predicateNounChoicesFor(
          education_data.analyze,
          PredicatePathKind.withInstrument,
        ).map((object) => object.text),
        containsAll(['computer', 'pen']),
      );
      expect(
        predicateNounChoicesFor(
          education_data.analyze,
          PredicatePathKind.forPurpose,
        ).map((object) => object.text),
        containsAll(['work', 'school']),
      );
      expect(
        predicatePlaceChoicesFor(
          sleep,
          PredicatePathKind.onLocation,
        ).map((place) => place.noun),
        contains('bed'),
      );
      expect(
        predicatePlaceChoicesFor(
          write,
          PredicatePathKind.onLocation,
        ).map((place) => place.noun),
        contains('table'),
      );
      expect(
        predicatePlaceChoicesFor(
          come,
          PredicatePathKind.fromLocation,
        ).map((place) => place.noun),
        containsAll(['home', 'school', 'work']),
      );
      expect(
        predicatePlaceChoicesFor(
          go,
          PredicatePathKind.fromLocation,
        ).map((place) => place.noun),
        containsAll(['home', 'school', 'work', 'shop']),
      );
      expect(
        predicatePlaceChoicesFor(
          lose,
          PredicatePathKind.inLocation,
        ).map((place) => place.noun),
        contains('park'),
      );
      expect(
        predicatePlaceChoicesFor(
          go,
          PredicatePathKind.placePhrase,
        ).map((place) => place.noun),
        containsAll(['home', 'school', 'work', 'shop']),
      );
      expect(
        predicateNounChoicesFor(
          bring,
          PredicatePathKind.directObject,
        ).map((object) => object.text),
        containsAll(['something', 'book', 'money', 'phone', 'photo']),
      );
      expect(
        predicatePlaceChoicesFor(
          bring,
          PredicatePathKind.placePhrase,
        ).map((place) => place.noun),
        containsAll(['home', 'school', 'work']),
      );
      expect(
        predicatePlaceChoicesFor(
          bring,
          PredicatePathKind.fromLocation,
        ).map((place) => place.noun),
        containsAll(['home', 'school', 'work']),
      );
      expect(
        predicateNounChoicesFor(
          take,
          PredicatePathKind.directObject,
        ).map((object) => object.text),
        containsAll(['something', 'book', 'money', 'phone', 'photo']),
      );
      expect(
        predicateNounChoicesFor(
          take,
          PredicatePathKind.forBeneficiary,
        ).map((object) => object.text),
        containsAll(['John', 'Mary', 'friend']),
      );
      expect(
        predicateNounChoicesFor(
          take,
          PredicatePathKind.forPurpose,
        ).map((object) => object.text),
        containsAll(['school', 'fun']),
      );
      expect(
        predicatePlaceChoicesFor(
          take,
          PredicatePathKind.placePhrase,
        ).map((place) => place.noun),
        containsAll(['home', 'school', 'work']),
      );
      expect(
        predicatePlaceChoicesFor(
          take,
          PredicatePathKind.fromLocation,
        ).map((place) => place.noun),
        containsAll(['home', 'school', 'work']),
      );
      expect(
        predicateMannerChoicesFor(
          go,
          PredicatePathKind.mannerPhrase,
        ).map((manner) => manner.text),
        contains('quickly'),
      );
      expect(
        predicateAuthoredPlaceChoicesFor(go).map((place) => place.noun),
        contains('there'),
      );
      expect(
        predicateParticleChoicesFor(go).map((particle) => particle.text),
        containsAll(['away', 'back', 'around']),
      );
      expect(
        predicateMannerChoicesFor(
          watch,
          PredicatePathKind.mannerPhrase,
        ).map((manner) => manner.text),
        contains('closely'),
      );
      expect(
        predicateNounChoicesFor(
          work,
          PredicatePathKind.forBeneficiary,
        ).map((beneficiary) => beneficiary.text),
        containsAll(['John', 'Mary', 'friend']),
      );
      expect(
        predicateNounChoicesFor(
          learn,
          PredicatePathKind.fromSource,
        ).map((source) => source.text),
        containsAll(['John', 'Mary', 'friend']),
      );
      expect(
        predicateNounChoicesFor(
          think,
          PredicatePathKind.aboutTopic,
        ).map((topic) => topic.text),
        containsAll(['grammar', 'science', 'Mary']),
      );
      expect(
        predicateNounChoicesFor(
          think,
          PredicatePathKind.ofTopic,
        ).map((topic) => topic.text),
        containsAll(['John', 'Mary', 'friend']),
      );
      expect(
        predicateNounChoicesFor(
          think,
          PredicatePathKind.withCompanion,
        ).map((companion) => companion.text),
        containsAll(['John', 'Mary', 'friend']),
      );
      expect(
        predicateMannerChoicesFor(
          think,
          PredicatePathKind.mannerPhrase,
        ).map((manner) => manner.text),
        containsAll(['carefully', 'quickly']),
      );
      expect(
        predicateTimeChoicesFor(
          think,
          PredicatePathKind.timePhrase,
        ).map((time) => time.text),
        containsAll(['today', 'now']),
      );
      expect(
        predicateAuthoredPlaceChoicesFor(sleep).map((place) => place.noun),
        containsAll(['home', 'bed']),
      );
    });

    test('essential verb review sheet is executable route audit', () {
      expect(
        _essentialVerbReviewRoutes
            .map((route) => route.verb.infinitive)
            .toSet(),
        containsAll(essentialVerbs.map((verb) => verb.infinitive)),
        reason: 'Every essential verb should have at least one reviewed route.',
      );

      for (final route in _essentialVerbReviewRoutes) {
        expect(_reviewedRouteExists(route), isTrue, reason: route.description);
      }
    });

    test('authored phrase routes use predicate-bound classified phrases', () {
      for (final unlocks in guidedPredicateUnlocks) {
        for (final path in unlocks.paths) {
          final phrases = switch (path.kind) {
            PredicatePathKind.atLocation => <Object>[...path.places],
            PredicatePathKind.inLocation => <Object>[...path.places],
            PredicatePathKind.onLocation => <Object>[...path.places],
            PredicatePathKind.fromLocation => <Object>[...path.places],
            PredicatePathKind.placePhrase => <Object>[...path.places],
            PredicatePathKind.mannerPhrase => <Object>[...path.manners],
            _ => const <Object>[],
          };

          for (final phrase in phrases) {
            expect(
              currentPhraseClassificationFor(phrase)?.role,
              PhraseSurfaceRole.predicateBoundRoute,
              reason: '${unlocks.verb.infinitive} ${path.kind}',
            );
          }
        }
      }
    });

    test('authored Compass mode narrows phrase rails to predicate paths', () {
      final authoredCompass = ConfigurationCompass(
        predicatePathMode: PredicatePathMode.authoredTracks,
      );
      var state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetAction(go));

      final placeLabels = authoredCompass
          .suggestionsFor(state, ConfigurationCompassSlot.placePhrase, limit: 0)
          .map((suggestion) => suggestion.label)
          .toList();
      final mannerLabels = authoredCompass
          .suggestionsFor(
            state,
            ConfigurationCompassSlot.mannerPhrase,
            limit: 0,
          )
          .map((suggestion) => suggestion.label)
          .toList();
      final particleLabels = authoredCompass
          .suggestionsFor(
            state,
            ConfigurationCompassSlot.rightParticle,
            limit: 0,
          )
          .map((suggestion) => suggestion.label)
          .toList();

      final sourcePlaceLabels = authoredCompass
          .suggestionsFor(state, ConfigurationCompassSlot.sourcePlace, limit: 0)
          .map((suggestion) => suggestion.label)
          .toList();

      expect(placeLabels, containsAll(['home', 'to school', 'to the shop']));
      expect(placeLabels, isNot(contains('from work')));
      expect(sourcePlaceLabels, containsAll(['from work', 'from school']));
      expect(placeLabels, isNot(contains('bed')));
      expect(mannerLabels, contains('quickly'));
      expect(mannerLabels, isNot(contains('away')));
      expect(mannerLabels, isNot(contains('closely')));
      expect(particleLabels, containsAll(['away', 'back', 'around']));
    });

    test('reviewed phrase paths render through the lower Grammar Engine', () {
      final cases = [
        (
          action: go,
          move: const SetRightParticle(awayParticle),
          text: 'You go away.',
        ),
        (
          action: go,
          move: const SetRightParticle(aroundParticle),
          text: 'You go around.',
        ),
        (
          action: watch,
          move: const SetMannerPhrase(closelyMannerPhrase),
          text: 'You watch closely.',
        ),
        (
          action: sleep,
          move: const SetPlacePhrase(inBedPlacePhrase),
          text: 'You sleep in bed.',
        ),
        (
          action: findVerb,
          move: const SetPlacePhrase(roomPlacePhrase),
          text: 'You find in the room.',
        ),
        (
          action: work,
          move: const SetPlacePhrase(itDomainPlacePhrase),
          text: 'You work in IT.',
        ),
        (
          action: go,
          move: const SetPlacePhrase(
            workPlacePhrase,
            placeMeaning: PlaceMeaning.source,
          ),
          text: 'You go from work.',
        ),
      ];

      for (final example in cases) {
        var state = ConfigurationState.initial();
        state = lock.applyMove(state, SetAction(example.action));
        state = lock.applyMove(state, example.move);

        expect(wasBlocked(state), isFalse);
        expect(grammar.generate(state.sentenceState).text, example.text);
      }
    });

    test(
      'newly reviewed right-hand predicate routes render through the lock',
      () {
        final cases =
            <
              ({
                Verb action,
                List<ConfigurationMove> preMoves,
                ConfigurationMove move,
                String text,
              })
            >[
              (
                action: breakVerb,
                preMoves: [
                  SetObject(object_data.window.toNounPhrase(Number.singular)),
                ],
                move: SetInstrument(
                  object_data.key.toNounPhrase(Number.singular),
                ),
                text: 'You break window with key.',
              ),
              (
                action: get,
                preMoves: [
                  SetObject(object_data.book.toNounPhrase(Number.singular)),
                ],
                move: SetBeneficiary(
                  people_data.mary.toNounPhrase(Number.singular),
                ),
                text: 'You get book for Mary.',
              ),
              (
                action: give,
                preMoves: [
                  SetObject(object_data.book.toNounPhrase(Number.singular)),
                ],
                move: SetCompanion(
                  people_data.john.toNounPhrase(Number.singular),
                ),
                text: 'You give book with John.',
              ),
              (
                action: say,
                preMoves: const [],
                move: SetTopic(fixed_object.grammar),
                text: 'You say about grammar.',
              ),
              (
                action: want,
                preMoves: const [],
                move: SetCompanion(
                  people_data.john.toNounPhrase(Number.singular),
                ),
                text: 'You want with John.',
              ),
              (
                action: open,
                preMoves: [
                  SetObject(object_data.door.toNounPhrase(Number.singular)),
                ],
                move: SetBeneficiary(
                  people_data.mary.toNounPhrase(Number.singular),
                ),
                text: 'You open door for Mary.',
              ),
              (
                action: introduce,
                preMoves: [
                  SetObject(people_data.john.toNounPhrase(Number.singular)),
                ],
                move: SetAddressee(
                  people_data.mary.toNounPhrase(Number.singular),
                ),
                text: 'You introduce John to Mary.',
              ),
              (
                action: findVerb,
                preMoves: const [],
                move: const SetRightParticle(outParticle),
                text: 'You find out.',
              ),
              (
                action: give,
                preMoves: const [],
                move: const SetMannerPhrase(carefullyMannerPhrase),
                text: 'You give carefully.',
              ),
              (
                action: give,
                preMoves: const [],
                move: const SetRightParticle(upParticle),
                text: 'You give up.',
              ),
              (
                action: give,
                preMoves: const [SetObject(fixed_object.grammar)],
                move: const SetRightParticle(upParticle),
                text: 'You give up grammar.',
              ),
              (
                action: give,
                preMoves: const [SetRightParticle(upParticle)],
                move: const SetObject(fixed_object.smoking),
                text: 'You give up smoking.',
              ),
              (
                action: give,
                preMoves: const [SetObject(fixed_object.money)],
                move: const SetRightParticle(awayParticle),
                text: 'You give money away.',
              ),
              (
                action: give,
                preMoves: [
                  SetObject(object_data.book.toNounPhrase(Number.singular)),
                ],
                move: const SetRightParticle(backParticle),
                text: 'You give book back.',
              ),
              (
                action: take,
                preMoves: const [],
                move: const SetRightParticle(offParticle),
                text: 'You take off.',
              ),
              (
                action: take,
                preMoves: [
                  SetObject(object_data.phone.toNounPhrase(Number.singular)),
                ],
                move: const SetRightParticle(awayParticle),
                text: 'You take phone away.',
              ),
              (
                action: bring,
                preMoves: [
                  SetObject(object_data.key.toNounPhrase(Number.singular)),
                ],
                move: const SetRightParticle(backParticle),
                text: 'You bring key back.',
              ),
              (
                action: think,
                preMoves: const [],
                move: const SetRightParticle(throughParticle),
                text: 'You think through.',
              ),
              (
                action: write,
                preMoves: [
                  SetObject(object_data.note.toNounPhrase(Number.singular)),
                ],
                move: const SetRightParticle(downParticle),
                text: 'You write down note.',
              ),
              (
                action: write,
                preMoves: [
                  SetObject(object_data.note.toNounPhrase(Number.singular)),
                ],
                move: const SetMannerPhrase(carefullyMannerPhrase),
                text: 'You write note carefully.',
              ),
              (
                action: particle_data.turn,
                preMoves: [
                  SetObject(object_data.key.toNounPhrase(Number.singular)),
                ],
                move: const SetMannerPhrase(carefullyMannerPhrase),
                text: 'You turn key carefully.',
              ),
              (
                action: particle_data.pick,
                preMoves: [
                  SetObject(object_data.phone.toNounPhrase(Number.singular)),
                ],
                move: const SetMannerPhrase(carefullyMannerPhrase),
                text: 'You pick phone carefully.',
              ),
              (
                action: particle_data.put,
                preMoves: [
                  SetObject(object_data.book.toNounPhrase(Number.singular)),
                ],
                move: const SetMannerPhrase(carefullyMannerPhrase),
                text: 'You put book carefully.',
              ),
              (
                action: particle_data.look,
                preMoves: const [],
                move: const SetMannerPhrase(carefullyMannerPhrase),
                text: 'You look carefully.',
              ),
              (
                action: stand,
                preMoves: const [],
                move: const SetRightParticle(upParticle),
                text: 'You stand up.',
              ),
              (
                action: sit,
                preMoves: const [],
                move: const SetRightParticle(downParticle),
                text: 'You sit down.',
              ),
              (
                action: go,
                preMoves: const [],
                move: const SetRightParticle(awayParticle),
                text: 'You go away.',
              ),
              (
                action: go,
                preMoves: const [],
                move: const SetRightParticle(outParticle),
                text: 'You go out.',
              ),
              (
                action: go,
                preMoves: const [],
                move: const SetRightParticle(backParticle),
                text: 'You go back.',
              ),
              (
                action: come,
                preMoves: const [],
                move: const SetRightParticle(backParticle),
                text: 'You come back.',
              ),
              (
                action: come,
                preMoves: const [],
                move: const SetRightParticle(inParticle),
                text: 'You come in.',
              ),
              (
                action: come,
                preMoves: const [],
                move: const SetRightParticle(outParticle),
                text: 'You come out.',
              ),
              (
                action: work,
                preMoves: const [],
                move: const SetRightParticle(outParticle),
                text: 'You work out.',
              ),
              (
                action: call,
                preMoves: [
                  SetObject(people_data.mary.toNounPhrase(Number.singular)),
                ],
                move: const SetRightParticle(backParticle),
                text: 'You call Mary back.',
              ),
              (
                action: write,
                preMoves: [
                  SetObject(object_data.letter.toNounPhrase(Number.singular)),
                ],
                move: const SetRightParticle(backParticle),
                text: 'You write letter back.',
              ),
              (
                action: sport_data.throwVerb,
                preMoves: const [SetObject(fixed_object.stone)],
                move: const SetRightParticle(awayParticle),
                text: 'You throw stone away.',
              ),
              (
                action: open,
                preMoves: const [],
                move: const SetRightParticle(upParticle),
                text: 'You open up.',
              ),
              (
                action: close,
                preMoves: const [],
                move: const SetRightParticle(downParticle),
                text: 'You close down.',
              ),
              (
                action: breakVerb,
                preMoves: const [],
                move: const SetRightParticle(upParticle),
                text: 'You break up.',
              ),
              (
                action: breakVerb,
                preMoves: const [],
                move: const SetRightParticle(outParticle),
                text: 'You break out.',
              ),
              (
                action: breakVerb,
                preMoves: const [],
                move: const SetRightParticle(downParticle),
                text: 'You break down.',
              ),
              (
                action: particle_data.turn,
                preMoves: const [],
                move: const SetRightParticle(onParticle),
                text: 'You turn on.',
              ),
              (
                action: particle_data.turn,
                preMoves: const [],
                move: const SetRightParticle(aroundParticle),
                text: 'You turn around.',
              ),
              (
                action: particle_data.turn,
                preMoves: [
                  SetObject(object_data.lamp.toNounPhrase(Number.singular)),
                ],
                move: const SetRightParticle(offParticle),
                text: 'You turn off lamp.',
              ),
              (
                action: particle_data.pick,
                preMoves: [
                  SetObject(object_data.phone.toNounPhrase(Number.singular)),
                ],
                move: const SetRightParticle(upParticle),
                text: 'You pick up phone.',
              ),
              (
                action: particle_data.put,
                preMoves: [
                  SetObject(object_data.book.toNounPhrase(Number.singular)),
                ],
                move: const SetRightParticle(downParticle),
                text: 'You put down book.',
              ),
              (
                action: particle_data.put,
                preMoves: [
                  SetObject(object_data.book.toNounPhrase(Number.singular)),
                ],
                move: const SetRightParticle(awayParticle),
                text: 'You put away book.',
              ),
              (
                action: particle_data.put,
                preMoves: [
                  SetObject(object_data.book.toNounPhrase(Number.singular)),
                ],
                move: const SetRightParticle(backParticle),
                text: 'You put back book.',
              ),
              (
                action: particle_data.look,
                preMoves: const [],
                move: const SetRightParticle(aroundParticle),
                text: 'You look around.',
              ),
              (
                action: particle_data.look,
                preMoves: const [],
                move: const SetRightParticle(outParticle),
                text: 'You look out.',
              ),
              (
                action: particle_data.look,
                preMoves: const [],
                move: const SetRightParticle(backParticle),
                text: 'You look back.',
              ),
              (
                action: particle_data.look,
                preMoves: const [SetObject(fixed_object.word)],
                move: const SetRightParticle(upParticle),
                text: 'You look up word.',
              ),
              (
                action: particle_data.wake,
                preMoves: const [],
                move: const SetRightParticle(upParticle),
                text: 'You wake up.',
              ),
              (
                action: particle_data.calmVerb,
                preMoves: const [],
                move: const SetRightParticle(downParticle),
                text: 'You calm down.',
              ),
              (
                action: particle_data.slowVerb,
                preMoves: const [],
                move: const SetRightParticle(downParticle),
                text: 'You slow down.',
              ),
              (
                action: fall,
                preMoves: const [],
                move: const SetRightParticle(downParticle),
                text: 'You fall down.',
              ),
              (
                action: take,
                preMoves: [
                  SetObject(object_data.key.toNounPhrase(Number.singular)),
                ],
                move: const SetRightParticle(outParticle),
                text: 'You take out key.',
              ),
              (
                action: bring,
                preMoves: [
                  SetObject(object_data.book.toNounPhrase(Number.singular)),
                ],
                move: const SetRightParticle(inParticle),
                text: 'You bring in book.',
              ),
              (
                action: bring,
                preMoves: [
                  SetObject(object_data.book.toNounPhrase(Number.singular)),
                ],
                move: const SetRightParticle(outParticle),
                text: 'You bring out book.',
              ),
              (
                action: work_data.clean,
                preMoves: const [SetObject(fixed_object.room)],
                move: const SetRightParticle(upParticle),
                text: 'You clean up room.',
              ),
            ];

        for (final example in cases) {
          var state = ConfigurationState.initial();
          state = lock.applyMove(state, SetAction(example.action));
          for (final move in example.preMoves) {
            state = lock.applyMove(state, move);
          }
          state = lock.applyMove(state, example.move);

          expect(wasBlocked(state), isFalse, reason: example.text);
          expect(grammar.generate(state.sentenceState).text, example.text);
        }
      },
    );

    test('particle object order rules are reviewable authored route data', () {
      expect(particleObjectOrderRules, isNotEmpty);

      final seen = <String>{};
      for (final rule in particleObjectOrderRules) {
        final key = '${rule.verb.infinitive}:${rule.particle.text}';
        expect(seen.add(key), isTrue, reason: 'duplicate $key');
        expect(rule.example, isNotEmpty, reason: key);
        expect(
          predicateParticleChoicesFor(rule.verb),
          contains(rule.particle),
          reason: key,
        );
        expect(
          rightParticlePlacesObjectAfter(
            verb: rule.verb,
            particle: rule.particle,
          ),
          isTrue,
          reason: key,
        );
      }
    });
  });
}

enum _ReviewedRouteKind {
  directObject,
  rightAction,
  recipient,
  addressee,
  companion,
  destination,
  aboutTopic,
  ofTopic,
  withTopic,
  overTopic,
  beneficiary,
  source,
  place,
  sourcePlace,
  time,
  manner,
  rightParticle,
  particleObject,
  lexicalBeNounComplement,
  lexicalBeAdjectiveComplement,
  objectAdjectiveComplement,
  instrument,
  purpose,
  onTopic,
}

class _ReviewedRoute {
  final Verb verb;
  final _ReviewedRouteKind kind;
  final String? text;
  final String? rightParticle;

  const _ReviewedRoute(this.verb, this.kind, {this.text, this.rightParticle});

  String get description {
    final value = text == null ? '' : ' "$text"';
    return '${verb.infinitive} ${kind.name}$value';
  }
}

const _essentialVerbReviewRoutes = [
  _ReviewedRoute(be, _ReviewedRouteKind.lexicalBeAdjectiveComplement),
  _ReviewedRoute(be, _ReviewedRouteKind.lexicalBeNounComplement),
  _ReviewedRoute(be, _ReviewedRouteKind.place, text: 'home'),
  _ReviewedRoute(be, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(be, _ReviewedRouteKind.sourcePlace),
  _ReviewedRoute(be, _ReviewedRouteKind.companion),
  _ReviewedRoute(
    be,
    _ReviewedRouteKind.lexicalBeAdjectiveComplement,
    text: 'happy',
  ),
  _ReviewedRoute(
    be,
    _ReviewedRouteKind.lexicalBeAdjectiveComplement,
    text: 'tired',
  ),
  _ReviewedRoute(
    be,
    _ReviewedRouteKind.lexicalBeAdjectiveComplement,
    text: 'hungry',
  ),
  _ReviewedRoute(
    be,
    _ReviewedRouteKind.lexicalBeAdjectiveComplement,
    text: 'ready',
  ),
  _ReviewedRoute(
    be,
    _ReviewedRouteKind.lexicalBeAdjectiveComplement,
    text: 'late',
  ),

  _ReviewedRoute(have, _ReviewedRouteKind.directObject),
  _ReviewedRoute(have, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(have, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(have, _ReviewedRouteKind.companion),
  _ReviewedRoute(have, _ReviewedRouteKind.place, text: 'home'),
  _ReviewedRoute(have, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(have, _ReviewedRouteKind.directObject, text: 'money'),
  _ReviewedRoute(have, _ReviewedRouteKind.directObject, text: 'time'),
  _ReviewedRoute(have, _ReviewedRouteKind.directObject, text: 'problem'),
  _ReviewedRoute(have, _ReviewedRouteKind.directObject, text: 'question'),
  _ReviewedRoute(have, _ReviewedRouteKind.directObject, text: 'breakfast'),
  _ReviewedRoute(have, _ReviewedRouteKind.directObject, text: 'anything'),
  _ReviewedRoute(have, _ReviewedRouteKind.directObject, text: 'it'),
  _ReviewedRoute(have, _ReviewedRouteKind.source),
  _ReviewedRoute(have, _ReviewedRouteKind.beneficiary),
  _ReviewedRoute(have, _ReviewedRouteKind.purpose, text: 'school'),
  _ReviewedRoute(have, _ReviewedRouteKind.purpose, text: 'fun'),
  _ReviewedRoute(have, _ReviewedRouteKind.rightAction, text: 'go'),
  _ReviewedRoute(have, _ReviewedRouteKind.rightAction, text: 'work'),

  _ReviewedRoute(doVerb, _ReviewedRouteKind.directObject),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.companion),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.manner, text: 'carefully'),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.manner, text: 'again'),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.directObject, text: 'anything'),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.directObject, text: 'nothing'),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.directObject, text: 'everything'),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.directObject, text: 'it'),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.directObject, text: 'this'),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.directObject, text: 'that'),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.directObject, text: 'work'),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.directObject, text: 'homework'),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.directObject, text: 'job'),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.directObject, text: 'exercise'),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.beneficiary),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.purpose, text: 'school'),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.place, text: 'home'),

  _ReviewedRoute(findVerb, _ReviewedRouteKind.directObject),
  _ReviewedRoute(findVerb, _ReviewedRouteKind.directObject, text: 'something'),
  _ReviewedRoute(findVerb, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(findVerb, _ReviewedRouteKind.directObject, text: 'key'),
  _ReviewedRoute(findVerb, _ReviewedRouteKind.place, text: 'home'),
  _ReviewedRoute(findVerb, _ReviewedRouteKind.place, text: 'room'),
  _ReviewedRoute(findVerb, _ReviewedRouteKind.companion),
  _ReviewedRoute(findVerb, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(findVerb, _ReviewedRouteKind.rightParticle, text: 'out'),
  _ReviewedRoute(findVerb, _ReviewedRouteKind.manner, text: 'by accident'),
  _ReviewedRoute(findVerb, _ReviewedRouteKind.directObject, text: 'money'),
  _ReviewedRoute(findVerb, _ReviewedRouteKind.directObject, text: 'someone'),

  _ReviewedRoute(sing, _ReviewedRouteKind.directObject, text: 'song'),
  _ReviewedRoute(sing, _ReviewedRouteKind.companion),
  _ReviewedRoute(sing, _ReviewedRouteKind.addressee),
  _ReviewedRoute(sing, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(sing, _ReviewedRouteKind.manner, text: 'loudly'),
  _ReviewedRoute(sing, _ReviewedRouteKind.manner, text: 'quietly'),
  _ReviewedRoute(sing, _ReviewedRouteKind.manner, text: 'well'),
  _ReviewedRoute(sing, _ReviewedRouteKind.manner, text: 'badly'),
  _ReviewedRoute(sing, _ReviewedRouteKind.directObject, text: 'music'),

  _ReviewedRoute(breakVerb, _ReviewedRouteKind.directObject),
  _ReviewedRoute(breakVerb, _ReviewedRouteKind.directObject, text: 'phone'),
  _ReviewedRoute(breakVerb, _ReviewedRouteKind.directObject, text: 'window'),
  _ReviewedRoute(breakVerb, _ReviewedRouteKind.directObject, text: 'chair'),
  _ReviewedRoute(breakVerb, _ReviewedRouteKind.manner, text: 'by accident'),
  _ReviewedRoute(breakVerb, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(breakVerb, _ReviewedRouteKind.rightParticle, text: 'down'),
  _ReviewedRoute(breakVerb, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(breakVerb, _ReviewedRouteKind.directObject, text: 'cup'),
  _ReviewedRoute(breakVerb, _ReviewedRouteKind.instrument),

  _ReviewedRoute(read, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(read, _ReviewedRouteKind.directObject, text: 'books'),
  _ReviewedRoute(read, _ReviewedRouteKind.directObject, text: 'letter'),
  _ReviewedRoute(read, _ReviewedRouteKind.directObject, text: 'newspaper'),
  _ReviewedRoute(read, _ReviewedRouteKind.directObject, text: 'story'),
  _ReviewedRoute(read, _ReviewedRouteKind.addressee),
  _ReviewedRoute(read, _ReviewedRouteKind.companion),
  _ReviewedRoute(read, _ReviewedRouteKind.manner, text: 'carefully'),
  _ReviewedRoute(read, _ReviewedRouteKind.rightParticle, text: 'through'),
  _ReviewedRoute(read, _ReviewedRouteKind.time, text: 'at night'),
  _ReviewedRoute(read, _ReviewedRouteKind.aboutTopic),
  _ReviewedRoute(read, _ReviewedRouteKind.overTopic, text: 'story'),
  _ReviewedRoute(read, _ReviewedRouteKind.purpose, text: 'school'),
  _ReviewedRoute(read, _ReviewedRouteKind.purpose, text: 'work'),
  _ReviewedRoute(read, _ReviewedRouteKind.directObject, text: 'English'),

  _ReviewedRoute(begin, _ReviewedRouteKind.directObject),
  _ReviewedRoute(begin, _ReviewedRouteKind.rightAction, text: 'go'),
  _ReviewedRoute(begin, _ReviewedRouteKind.rightAction, text: 'work'),
  _ReviewedRoute(begin, _ReviewedRouteKind.rightAction, text: 'learn'),
  _ReviewedRoute(begin, _ReviewedRouteKind.rightAction, text: 'speak'),
  _ReviewedRoute(begin, _ReviewedRouteKind.rightAction, text: 'swim'),
  _ReviewedRoute(begin, _ReviewedRouteKind.rightAction, text: 'read'),
  _ReviewedRoute(begin, _ReviewedRouteKind.rightAction, text: 'write'),
  _ReviewedRoute(begin, _ReviewedRouteKind.rightAction, text: 'play'),
  _ReviewedRoute(begin, _ReviewedRouteKind.companion),
  _ReviewedRoute(begin, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(begin, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(begin, _ReviewedRouteKind.time, text: 'now'),
  _ReviewedRoute(begin, _ReviewedRouteKind.directObject, text: 'lesson'),
  _ReviewedRoute(begin, _ReviewedRouteKind.directObject, text: 'work'),

  _ReviewedRoute(go, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(go, _ReviewedRouteKind.manner, text: 'slowly'),
  _ReviewedRoute(go, _ReviewedRouteKind.companion),
  _ReviewedRoute(go, _ReviewedRouteKind.destination),
  _ReviewedRoute(go, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(go, _ReviewedRouteKind.place, text: 'work'),
  _ReviewedRoute(go, _ReviewedRouteKind.place, text: 'shop'),
  _ReviewedRoute(go, _ReviewedRouteKind.place, text: 'home'),
  _ReviewedRoute(go, _ReviewedRouteKind.rightParticle, text: 'away'),
  _ReviewedRoute(go, _ReviewedRouteKind.rightParticle, text: 'back'),
  _ReviewedRoute(go, _ReviewedRouteKind.rightParticle, text: 'around'),
  _ReviewedRoute(go, _ReviewedRouteKind.place, text: 'there'),
  _ReviewedRoute(go, _ReviewedRouteKind.time, text: 'now'),
  _ReviewedRoute(go, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(go, _ReviewedRouteKind.overTopic, text: 'grammar'),

  _ReviewedRoute(come, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(come, _ReviewedRouteKind.manner, text: 'slowly'),
  _ReviewedRoute(come, _ReviewedRouteKind.companion),
  _ReviewedRoute(come, _ReviewedRouteKind.destination),
  _ReviewedRoute(come, _ReviewedRouteKind.place, text: 'home'),
  _ReviewedRoute(come, _ReviewedRouteKind.place, text: 'here'),
  _ReviewedRoute(come, _ReviewedRouteKind.rightParticle, text: 'back'),
  _ReviewedRoute(come, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(come, _ReviewedRouteKind.time, text: 'now'),
  _ReviewedRoute(come, _ReviewedRouteKind.sourcePlace),

  _ReviewedRoute(get, _ReviewedRouteKind.directObject),
  _ReviewedRoute(get, _ReviewedRouteKind.directObject, text: 'something'),
  _ReviewedRoute(get, _ReviewedRouteKind.directObject, text: 'it'),
  _ReviewedRoute(get, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(get, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(get, _ReviewedRouteKind.directObject, text: 'gift'),
  _ReviewedRoute(get, _ReviewedRouteKind.source),
  _ReviewedRoute(get, _ReviewedRouteKind.sourcePlace, text: 'school'),
  _ReviewedRoute(get, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(get, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(get, _ReviewedRouteKind.directObject, text: 'money'),
  _ReviewedRoute(get, _ReviewedRouteKind.directObject, text: 'job'),
  _ReviewedRoute(get, _ReviewedRouteKind.beneficiary),
  _ReviewedRoute(get, _ReviewedRouteKind.purpose, text: 'school'),
  _ReviewedRoute(get, _ReviewedRouteKind.purpose, text: 'fun'),

  _ReviewedRoute(make, _ReviewedRouteKind.directObject),
  _ReviewedRoute(make, _ReviewedRouteKind.directObject, text: 'something'),
  _ReviewedRoute(make, _ReviewedRouteKind.directObject, text: 'it'),
  _ReviewedRoute(make, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(make, _ReviewedRouteKind.directObject, text: 'cake'),
  _ReviewedRoute(make, _ReviewedRouteKind.directObject, text: 'coffee'),
  _ReviewedRoute(make, _ReviewedRouteKind.directObject, text: 'gift'),
  _ReviewedRoute(make, _ReviewedRouteKind.directObject, text: 'game'),
  _ReviewedRoute(make, _ReviewedRouteKind.directObject, text: 'toy'),
  _ReviewedRoute(make, _ReviewedRouteKind.directObject, text: 'song'),
  _ReviewedRoute(make, _ReviewedRouteKind.directObject, text: 'movie'),
  _ReviewedRoute(make, _ReviewedRouteKind.directObject, text: 'photo'),
  _ReviewedRoute(make, _ReviewedRouteKind.directObject, text: 'painting'),
  _ReviewedRoute(make, _ReviewedRouteKind.directObject, text: 'document'),
  _ReviewedRoute(make, _ReviewedRouteKind.directObject, text: 'message'),
  _ReviewedRoute(make, _ReviewedRouteKind.recipient),
  _ReviewedRoute(
    make,
    _ReviewedRouteKind.objectAdjectiveComplement,
    text: 'happy',
  ),
  _ReviewedRoute(
    make,
    _ReviewedRouteKind.objectAdjectiveComplement,
    text: 'calm',
  ),
  _ReviewedRoute(make, _ReviewedRouteKind.companion),
  _ReviewedRoute(make, _ReviewedRouteKind.manner, text: 'carefully'),
  _ReviewedRoute(make, _ReviewedRouteKind.directObject, text: 'plan'),
  _ReviewedRoute(make, _ReviewedRouteKind.directObject, text: 'mistake'),
  _ReviewedRoute(make, _ReviewedRouteKind.beneficiary),
  _ReviewedRoute(make, _ReviewedRouteKind.purpose, text: 'work'),
  _ReviewedRoute(make, _ReviewedRouteKind.purpose, text: 'school'),
  _ReviewedRoute(make, _ReviewedRouteKind.purpose, text: 'dinner'),
  _ReviewedRoute(make, _ReviewedRouteKind.purpose, text: 'fun'),

  _ReviewedRoute(take, _ReviewedRouteKind.directObject),
  _ReviewedRoute(take, _ReviewedRouteKind.directObject, text: 'something'),
  _ReviewedRoute(take, _ReviewedRouteKind.directObject, text: 'it'),
  _ReviewedRoute(take, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(take, _ReviewedRouteKind.directObject, text: 'phone'),
  _ReviewedRoute(take, _ReviewedRouteKind.directObject, text: 'photo'),
  _ReviewedRoute(take, _ReviewedRouteKind.companion),
  _ReviewedRoute(take, _ReviewedRouteKind.source),
  _ReviewedRoute(take, _ReviewedRouteKind.sourcePlace, text: 'school'),
  _ReviewedRoute(take, _ReviewedRouteKind.beneficiary),
  _ReviewedRoute(take, _ReviewedRouteKind.purpose, text: 'school'),
  _ReviewedRoute(take, _ReviewedRouteKind.purpose, text: 'fun'),
  _ReviewedRoute(take, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(take, _ReviewedRouteKind.rightParticle, text: 'off'),
  _ReviewedRoute(take, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(take, _ReviewedRouteKind.directObject, text: 'money'),
  _ReviewedRoute(take, _ReviewedRouteKind.destination),
  _ReviewedRoute(take, _ReviewedRouteKind.place, text: 'school'),

  _ReviewedRoute(bring, _ReviewedRouteKind.directObject),
  _ReviewedRoute(bring, _ReviewedRouteKind.directObject, text: 'something'),
  _ReviewedRoute(bring, _ReviewedRouteKind.directObject, text: 'it'),
  _ReviewedRoute(bring, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(bring, _ReviewedRouteKind.directObject, text: 'phone'),
  _ReviewedRoute(bring, _ReviewedRouteKind.directObject, text: 'photo'),
  _ReviewedRoute(bring, _ReviewedRouteKind.directObject, text: 'money'),
  _ReviewedRoute(bring, _ReviewedRouteKind.destination),
  _ReviewedRoute(bring, _ReviewedRouteKind.source),
  _ReviewedRoute(bring, _ReviewedRouteKind.sourcePlace, text: 'school'),
  _ReviewedRoute(bring, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(bring, _ReviewedRouteKind.companion),
  _ReviewedRoute(bring, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(bring, _ReviewedRouteKind.time, text: 'today'),

  _ReviewedRoute(give, _ReviewedRouteKind.directObject),
  _ReviewedRoute(give, _ReviewedRouteKind.directObject, text: 'something'),
  _ReviewedRoute(give, _ReviewedRouteKind.directObject, text: 'it'),
  _ReviewedRoute(give, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(give, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(give, _ReviewedRouteKind.directObject, text: 'gift'),
  _ReviewedRoute(
    give,
    _ReviewedRouteKind.particleObject,
    text: 'smoking',
    rightParticle: 'up',
  ),
  _ReviewedRoute(
    give,
    _ReviewedRouteKind.particleObject,
    text: 'gambling',
    rightParticle: 'up',
  ),
  _ReviewedRoute(give, _ReviewedRouteKind.recipient),
  _ReviewedRoute(give, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(give, _ReviewedRouteKind.beneficiary),
  _ReviewedRoute(give, _ReviewedRouteKind.companion),
  _ReviewedRoute(give, _ReviewedRouteKind.manner, text: 'carefully'),
  _ReviewedRoute(give, _ReviewedRouteKind.rightParticle, text: 'up'),

  _ReviewedRoute(write, _ReviewedRouteKind.manner, text: 'carefully'),
  _ReviewedRoute(
    particle_data.turn,
    _ReviewedRouteKind.manner,
    text: 'carefully',
  ),
  _ReviewedRoute(
    particle_data.pick,
    _ReviewedRouteKind.manner,
    text: 'carefully',
  ),
  _ReviewedRoute(
    particle_data.put,
    _ReviewedRouteKind.manner,
    text: 'carefully',
  ),
  _ReviewedRoute(
    particle_data.look,
    _ReviewedRouteKind.manner,
    text: 'carefully',
  ),

  _ReviewedRoute(know, _ReviewedRouteKind.directObject),
  _ReviewedRoute(know, _ReviewedRouteKind.directObject, text: 'Mary'),
  _ReviewedRoute(know, _ReviewedRouteKind.directObject, text: 'English'),
  _ReviewedRoute(know, _ReviewedRouteKind.directObject, text: 'grammar'),
  _ReviewedRoute(know, _ReviewedRouteKind.aboutTopic),
  _ReviewedRoute(know, _ReviewedRouteKind.manner, text: 'well'),
  _ReviewedRoute(know, _ReviewedRouteKind.manner, text: 'already'),
  _ReviewedRoute(know, _ReviewedRouteKind.time, text: 'now'),
  _ReviewedRoute(know, _ReviewedRouteKind.directObject, text: 'answer'),

  _ReviewedRoute(think, _ReviewedRouteKind.aboutTopic),
  _ReviewedRoute(think, _ReviewedRouteKind.ofTopic),
  _ReviewedRoute(think, _ReviewedRouteKind.overTopic, text: 'plan'),
  _ReviewedRoute(think, _ReviewedRouteKind.companion),
  _ReviewedRoute(think, _ReviewedRouteKind.manner, text: 'carefully'),
  _ReviewedRoute(think, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(think, _ReviewedRouteKind.rightParticle, text: 'through'),
  _ReviewedRoute(think, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(think, _ReviewedRouteKind.time, text: 'now'),

  _ReviewedRoute(say, _ReviewedRouteKind.directObject),
  _ReviewedRoute(say, _ReviewedRouteKind.directObject, text: 'something'),
  _ReviewedRoute(say, _ReviewedRouteKind.directObject, text: 'it'),
  _ReviewedRoute(say, _ReviewedRouteKind.addressee),
  _ReviewedRoute(say, _ReviewedRouteKind.manner, text: 'loudly'),
  _ReviewedRoute(say, _ReviewedRouteKind.manner, text: 'quietly'),
  _ReviewedRoute(say, _ReviewedRouteKind.aboutTopic),
  _ReviewedRoute(say, _ReviewedRouteKind.directObject, text: 'word'),
  _ReviewedRoute(say, _ReviewedRouteKind.directObject, text: 'yes'),
  _ReviewedRoute(say, _ReviewedRouteKind.directObject, text: 'no'),
  _ReviewedRoute(say, _ReviewedRouteKind.directObject, text: 'hello'),

  _ReviewedRoute(see, _ReviewedRouteKind.directObject),
  _ReviewedRoute(see, _ReviewedRouteKind.directObject, text: 'cat'),
  _ReviewedRoute(see, _ReviewedRouteKind.directObject, text: 'friend'),
  _ReviewedRoute(see, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(see, _ReviewedRouteKind.companion),
  _ReviewedRoute(see, _ReviewedRouteKind.manner, text: 'clearly'),
  _ReviewedRoute(see, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(see, _ReviewedRouteKind.directObject, text: 'problem'),

  _ReviewedRoute(want, _ReviewedRouteKind.directObject),
  _ReviewedRoute(want, _ReviewedRouteKind.directObject, text: 'something'),
  _ReviewedRoute(want, _ReviewedRouteKind.directObject, text: 'it'),
  _ReviewedRoute(want, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(want, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(want, _ReviewedRouteKind.rightAction, text: 'go'),
  _ReviewedRoute(want, _ReviewedRouteKind.rightAction, text: 'learn'),
  _ReviewedRoute(want, _ReviewedRouteKind.rightAction, text: 'speak'),
  _ReviewedRoute(want, _ReviewedRouteKind.rightAction, text: 'sleep'),
  _ReviewedRoute(want, _ReviewedRouteKind.rightAction, text: 'read'),
  _ReviewedRoute(want, _ReviewedRouteKind.rightAction, text: 'write'),
  _ReviewedRoute(want, _ReviewedRouteKind.rightAction, text: 'play'),
  _ReviewedRoute(want, _ReviewedRouteKind.rightAction, text: 'sing'),
  _ReviewedRoute(want, _ReviewedRouteKind.rightAction, text: 'help'),
  _ReviewedRoute(want, _ReviewedRouteKind.time, text: 'now'),
  _ReviewedRoute(want, _ReviewedRouteKind.companion),

  _ReviewedRoute(need, _ReviewedRouteKind.directObject),
  _ReviewedRoute(need, _ReviewedRouteKind.directObject, text: 'something'),
  _ReviewedRoute(need, _ReviewedRouteKind.directObject, text: 'it'),
  _ReviewedRoute(need, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(need, _ReviewedRouteKind.directObject, text: 'key'),
  _ReviewedRoute(need, _ReviewedRouteKind.rightAction, text: 'go'),
  _ReviewedRoute(need, _ReviewedRouteKind.rightAction, text: 'learn'),
  _ReviewedRoute(need, _ReviewedRouteKind.rightAction, text: 'speak'),
  _ReviewedRoute(need, _ReviewedRouteKind.rightAction, text: 'sleep'),
  _ReviewedRoute(need, _ReviewedRouteKind.rightAction, text: 'read'),
  _ReviewedRoute(need, _ReviewedRouteKind.rightAction, text: 'write'),
  _ReviewedRoute(need, _ReviewedRouteKind.rightAction, text: 'help'),
  _ReviewedRoute(need, _ReviewedRouteKind.time, text: 'now'),
  _ReviewedRoute(need, _ReviewedRouteKind.directObject, text: 'help'),
  _ReviewedRoute(need, _ReviewedRouteKind.directObject, text: 'money'),
  _ReviewedRoute(need, _ReviewedRouteKind.source),
  _ReviewedRoute(need, _ReviewedRouteKind.beneficiary),
  _ReviewedRoute(need, _ReviewedRouteKind.purpose),
  _ReviewedRoute(need, _ReviewedRouteKind.purpose, text: 'work'),
  _ReviewedRoute(need, _ReviewedRouteKind.purpose, text: 'school'),

  _ReviewedRoute(meet, _ReviewedRouteKind.directObject),
  _ReviewedRoute(meet, _ReviewedRouteKind.directObject, text: 'friend'),
  _ReviewedRoute(meet, _ReviewedRouteKind.directObject, text: 'teacher'),
  _ReviewedRoute(meet, _ReviewedRouteKind.directObject, text: 'cat'),
  _ReviewedRoute(meet, _ReviewedRouteKind.companion),
  _ReviewedRoute(meet, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(meet, _ReviewedRouteKind.place, text: 'home'),
  _ReviewedRoute(meet, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(meet, _ReviewedRouteKind.time, text: 'tomorrow'),

  _ReviewedRoute(like, _ReviewedRouteKind.directObject),
  _ReviewedRoute(like, _ReviewedRouteKind.directObject, text: 'something'),
  _ReviewedRoute(like, _ReviewedRouteKind.directObject, text: 'music'),
  _ReviewedRoute(like, _ReviewedRouteKind.directObject, text: 'game'),
  _ReviewedRoute(like, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(like, _ReviewedRouteKind.rightAction, text: 'learn'),
  _ReviewedRoute(like, _ReviewedRouteKind.rightAction, text: 'swim'),
  _ReviewedRoute(like, _ReviewedRouteKind.rightAction, text: 'watch'),
  _ReviewedRoute(like, _ReviewedRouteKind.rightAction, text: 'go'),
  _ReviewedRoute(like, _ReviewedRouteKind.rightAction, text: 'work'),
  _ReviewedRoute(like, _ReviewedRouteKind.rightAction, text: 'speak'),
  _ReviewedRoute(like, _ReviewedRouteKind.rightAction, text: 'sleep'),
  _ReviewedRoute(like, _ReviewedRouteKind.rightAction, text: 'read'),
  _ReviewedRoute(like, _ReviewedRouteKind.rightAction, text: 'write'),
  _ReviewedRoute(like, _ReviewedRouteKind.rightAction, text: 'play'),
  _ReviewedRoute(like, _ReviewedRouteKind.rightAction, text: 'sing'),
  _ReviewedRoute(like, _ReviewedRouteKind.companion),

  _ReviewedRoute(love, _ReviewedRouteKind.directObject),
  _ReviewedRoute(love, _ReviewedRouteKind.directObject, text: 'something'),
  _ReviewedRoute(love, _ReviewedRouteKind.directObject, text: 'music'),
  _ReviewedRoute(love, _ReviewedRouteKind.directObject, text: 'game'),
  _ReviewedRoute(love, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(love, _ReviewedRouteKind.rightAction, text: 'learn'),
  _ReviewedRoute(love, _ReviewedRouteKind.rightAction, text: 'swim'),
  _ReviewedRoute(love, _ReviewedRouteKind.rightAction, text: 'watch'),
  _ReviewedRoute(love, _ReviewedRouteKind.rightAction, text: 'go'),
  _ReviewedRoute(love, _ReviewedRouteKind.rightAction, text: 'work'),
  _ReviewedRoute(love, _ReviewedRouteKind.rightAction, text: 'speak'),
  _ReviewedRoute(love, _ReviewedRouteKind.rightAction, text: 'sleep'),
  _ReviewedRoute(love, _ReviewedRouteKind.rightAction, text: 'read'),
  _ReviewedRoute(love, _ReviewedRouteKind.rightAction, text: 'write'),
  _ReviewedRoute(love, _ReviewedRouteKind.rightAction, text: 'play'),
  _ReviewedRoute(love, _ReviewedRouteKind.rightAction, text: 'sing'),
  _ReviewedRoute(love, _ReviewedRouteKind.companion),

  _ReviewedRoute(work, _ReviewedRouteKind.companion),
  _ReviewedRoute(work, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(work, _ReviewedRouteKind.place, text: 'home'),
  _ReviewedRoute(work, _ReviewedRouteKind.place, text: 'work'),
  _ReviewedRoute(work, _ReviewedRouteKind.place, text: 'IT'),
  _ReviewedRoute(work, _ReviewedRouteKind.beneficiary),
  _ReviewedRoute(work, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(work, _ReviewedRouteKind.manner, text: 'carefully'),
  _ReviewedRoute(work, _ReviewedRouteKind.manner, text: 'manually'),
  _ReviewedRoute(work, _ReviewedRouteKind.rightParticle, text: 'out'),
  _ReviewedRoute(work, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(work, _ReviewedRouteKind.onTopic),
  _ReviewedRoute(work, _ReviewedRouteKind.onTopic, text: 'car'),
  _ReviewedRoute(work, _ReviewedRouteKind.onTopic, text: 'cars'),
  _ReviewedRoute(work, _ReviewedRouteKind.onTopic, text: 'physique'),
  _ReviewedRoute(work, _ReviewedRouteKind.onTopic, text: 'skills'),
  _ReviewedRoute(work, _ReviewedRouteKind.onTopic, text: 'swimming'),
  _ReviewedRoute(work, _ReviewedRouteKind.onTopic, text: 'skating'),

  _ReviewedRoute(buy, _ReviewedRouteKind.directObject),
  _ReviewedRoute(buy, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(buy, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(buy, _ReviewedRouteKind.directObject, text: 'gift'),
  _ReviewedRoute(buy, _ReviewedRouteKind.directObject, text: 'ticket'),
  _ReviewedRoute(buy, _ReviewedRouteKind.recipient),
  _ReviewedRoute(buy, _ReviewedRouteKind.beneficiary),
  _ReviewedRoute(buy, _ReviewedRouteKind.companion),
  _ReviewedRoute(buy, _ReviewedRouteKind.place, text: 'shop'),
  _ReviewedRoute(buy, _ReviewedRouteKind.time, text: 'today'),

  _ReviewedRoute(sell, _ReviewedRouteKind.directObject),
  _ReviewedRoute(sell, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(sell, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(sell, _ReviewedRouteKind.directObject, text: 'car'),
  _ReviewedRoute(sell, _ReviewedRouteKind.directObject, text: 'house'),
  _ReviewedRoute(sell, _ReviewedRouteKind.addressee),
  _ReviewedRoute(sell, _ReviewedRouteKind.companion),
  _ReviewedRoute(sell, _ReviewedRouteKind.place, text: 'shop'),
  _ReviewedRoute(sell, _ReviewedRouteKind.time, text: 'today'),

  _ReviewedRoute(listen, _ReviewedRouteKind.addressee, text: 'Mary'),
  _ReviewedRoute(listen, _ReviewedRouteKind.addressee, text: 'music'),
  _ReviewedRoute(listen, _ReviewedRouteKind.onTopic, text: 'speakers'),
  _ReviewedRoute(listen, _ReviewedRouteKind.onTopic, text: 'headphones'),
  _ReviewedRoute(listen, _ReviewedRouteKind.companion),
  _ReviewedRoute(describe, _ReviewedRouteKind.directObject),
  _ReviewedRoute(describe, _ReviewedRouteKind.addressee, text: 'Mary'),
  _ReviewedRoute(describe, _ReviewedRouteKind.companion),
  _ReviewedRoute(describe, _ReviewedRouteKind.manner, text: 'carefully'),
  _ReviewedRoute(describe, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(introduce, _ReviewedRouteKind.directObject, text: 'John'),
  _ReviewedRoute(introduce, _ReviewedRouteKind.addressee, text: 'Mary'),
  _ReviewedRoute(introduce, _ReviewedRouteKind.companion),
  _ReviewedRoute(introduce, _ReviewedRouteKind.manner, text: 'politely'),
  _ReviewedRoute(introduce, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(laugh, _ReviewedRouteKind.aboutTopic, text: 'story'),
  _ReviewedRoute(laugh, _ReviewedRouteKind.companion),
  _ReviewedRoute(laugh, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(laugh, _ReviewedRouteKind.manner, text: 'happily'),
  _ReviewedRoute(smile, _ReviewedRouteKind.companion),
  _ReviewedRoute(smile, _ReviewedRouteKind.place, text: 'home'),
  _ReviewedRoute(smile, _ReviewedRouteKind.manner, text: 'politely'),
  _ReviewedRoute(smile, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(shout, _ReviewedRouteKind.addressee, text: 'Mary'),
  _ReviewedRoute(shout, _ReviewedRouteKind.aboutTopic, text: 'story'),
  _ReviewedRoute(shout, _ReviewedRouteKind.companion),
  _ReviewedRoute(shout, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(whisper, _ReviewedRouteKind.addressee, text: 'Mary'),
  _ReviewedRoute(whisper, _ReviewedRouteKind.aboutTopic, text: 'story'),
  _ReviewedRoute(whisper, _ReviewedRouteKind.companion),
  _ReviewedRoute(whisper, _ReviewedRouteKind.manner, text: 'quietly'),

  _ReviewedRoute(use, _ReviewedRouteKind.directObject),
  _ReviewedRoute(use, _ReviewedRouteKind.directObject, text: 'key'),
  _ReviewedRoute(use, _ReviewedRouteKind.directObject, text: 'phone'),
  _ReviewedRoute(use, _ReviewedRouteKind.directObject, text: 'computer'),
  _ReviewedRoute(use, _ReviewedRouteKind.companion),
  _ReviewedRoute(use, _ReviewedRouteKind.manner, text: 'carefully'),
  _ReviewedRoute(use, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(use, _ReviewedRouteKind.purpose),
  _ReviewedRoute(use, _ReviewedRouteKind.purpose, text: 'work'),
  _ReviewedRoute(use, _ReviewedRouteKind.purpose, text: 'exercise'),
  _ReviewedRoute(use, _ReviewedRouteKind.purpose, text: 'school'),
  _ReviewedRoute(use, _ReviewedRouteKind.purpose, text: 'health'),
  _ReviewedRoute(use, _ReviewedRouteKind.purpose, text: 'fun'),

  _ReviewedRoute(watch, _ReviewedRouteKind.directObject),
  _ReviewedRoute(watch, _ReviewedRouteKind.directObject, text: 'movie'),
  _ReviewedRoute(watch, _ReviewedRouteKind.companion),
  _ReviewedRoute(watch, _ReviewedRouteKind.rightAction, text: 'research'),
  _ReviewedRoute(watch, _ReviewedRouteKind.rightAction, text: 'learn'),
  _ReviewedRoute(watch, _ReviewedRouteKind.manner, text: 'closely'),
  _ReviewedRoute(watch, _ReviewedRouteKind.manner, text: 'quietly'),
  _ReviewedRoute(watch, _ReviewedRouteKind.place, text: 'home'),
  _ReviewedRoute(watch, _ReviewedRouteKind.directObject, text: 'show'),
  _ReviewedRoute(watch, _ReviewedRouteKind.directObject, text: 'game'),
  _ReviewedRoute(watch, _ReviewedRouteKind.rightAction, text: 'analyze'),

  _ReviewedRoute(lose, _ReviewedRouteKind.directObject),
  _ReviewedRoute(lose, _ReviewedRouteKind.directObject, text: 'key'),
  _ReviewedRoute(lose, _ReviewedRouteKind.directObject, text: 'phone'),
  _ReviewedRoute(lose, _ReviewedRouteKind.directObject, text: 'game'),
  _ReviewedRoute(lose, _ReviewedRouteKind.place, text: 'home'),
  _ReviewedRoute(lose, _ReviewedRouteKind.place, text: 'park'),
  _ReviewedRoute(lose, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(lose, _ReviewedRouteKind.manner, text: 'by accident'),
  _ReviewedRoute(lose, _ReviewedRouteKind.directObject, text: 'money'),

  _ReviewedRoute(play, _ReviewedRouteKind.directObject, text: 'football'),
  _ReviewedRoute(play, _ReviewedRouteKind.directObject, text: 'basketball'),
  _ReviewedRoute(play, _ReviewedRouteKind.directObject, text: 'volleyball'),
  _ReviewedRoute(play, _ReviewedRouteKind.directObject, text: 'tennis'),
  _ReviewedRoute(play, _ReviewedRouteKind.companion),
  _ReviewedRoute(play, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(play, _ReviewedRouteKind.manner, text: 'well'),
  _ReviewedRoute(play, _ReviewedRouteKind.directObject, text: 'music'),
  _ReviewedRoute(play, _ReviewedRouteKind.directObject, text: 'game'),
  _ReviewedRoute(play, _ReviewedRouteKind.place, text: 'outside'),

  _ReviewedRoute(learn, _ReviewedRouteKind.directObject, text: 'English'),
  _ReviewedRoute(learn, _ReviewedRouteKind.directObject, text: 'grammar'),
  _ReviewedRoute(learn, _ReviewedRouteKind.directObject, text: 'history'),
  _ReviewedRoute(learn, _ReviewedRouteKind.directObject, text: 'science'),
  _ReviewedRoute(learn, _ReviewedRouteKind.rightAction, text: 'speak'),
  _ReviewedRoute(learn, _ReviewedRouteKind.rightAction, text: 'swim'),
  _ReviewedRoute(learn, _ReviewedRouteKind.rightAction, text: 'work'),
  _ReviewedRoute(learn, _ReviewedRouteKind.rightAction, text: 'read'),
  _ReviewedRoute(learn, _ReviewedRouteKind.rightAction, text: 'write'),
  _ReviewedRoute(learn, _ReviewedRouteKind.rightAction, text: 'sing'),
  _ReviewedRoute(learn, _ReviewedRouteKind.rightAction, text: 'play'),
  _ReviewedRoute(learn, _ReviewedRouteKind.companion),
  _ReviewedRoute(learn, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(learn, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(learn, _ReviewedRouteKind.directObject, text: 'Polish'),
  _ReviewedRoute(learn, _ReviewedRouteKind.purpose, text: 'school'),
  _ReviewedRoute(learn, _ReviewedRouteKind.purpose, text: 'work'),
  _ReviewedRoute(learn, _ReviewedRouteKind.purpose, text: 'grammar'),

  _ReviewedRoute(education_data.teach, _ReviewedRouteKind.directObject),
  _ReviewedRoute(
    education_data.teach,
    _ReviewedRouteKind.directObject,
    text: 'English',
  ),
  _ReviewedRoute(
    education_data.teach,
    _ReviewedRouteKind.directObject,
    text: 'grammar',
  ),
  _ReviewedRoute(education_data.teach, _ReviewedRouteKind.recipient),
  _ReviewedRoute(
    education_data.teach,
    _ReviewedRouteKind.rightAction,
    text: 'speak',
  ),
  _ReviewedRoute(
    education_data.teach,
    _ReviewedRouteKind.rightAction,
    text: 'swim',
  ),
  _ReviewedRoute(
    education_data.teach,
    _ReviewedRouteKind.rightAction,
    text: 'read',
  ),
  _ReviewedRoute(
    education_data.teach,
    _ReviewedRouteKind.rightAction,
    text: 'write',
  ),
  _ReviewedRoute(
    education_data.teach,
    _ReviewedRouteKind.rightAction,
    text: 'work',
  ),
  _ReviewedRoute(
    education_data.teach,
    _ReviewedRouteKind.rightAction,
    text: 'learn',
  ),
  _ReviewedRoute(education_data.teach, _ReviewedRouteKind.companion),

  _ReviewedRoute(hate, _ReviewedRouteKind.directObject),
  _ReviewedRoute(hate, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(hate, _ReviewedRouteKind.rightAction, text: 'work'),
  _ReviewedRoute(hate, _ReviewedRouteKind.manner, text: 'quietly'),
  _ReviewedRoute(hate, _ReviewedRouteKind.directObject, text: 'noise'),
  _ReviewedRoute(hate, _ReviewedRouteKind.directObject, text: 'waiting'),
  _ReviewedRoute(hate, _ReviewedRouteKind.rightAction, text: 'lose'),
  _ReviewedRoute(hate, _ReviewedRouteKind.rightAction, text: 'read'),
  _ReviewedRoute(hate, _ReviewedRouteKind.rightAction, text: 'write'),
  _ReviewedRoute(hate, _ReviewedRouteKind.rightAction, text: 'play'),
  _ReviewedRoute(hate, _ReviewedRouteKind.rightAction, text: 'sing'),
  _ReviewedRoute(hate, _ReviewedRouteKind.rightAction, text: 'help'),
  _ReviewedRoute(hate, _ReviewedRouteKind.companion),

  _ReviewedRoute(remember, _ReviewedRouteKind.directObject),
  _ReviewedRoute(remember, _ReviewedRouteKind.directObject, text: 'something'),
  _ReviewedRoute(remember, _ReviewedRouteKind.directObject, text: 'story'),
  _ReviewedRoute(remember, _ReviewedRouteKind.directObject, text: 'English'),
  _ReviewedRoute(remember, _ReviewedRouteKind.directObject, text: 'grammar'),
  _ReviewedRoute(remember, _ReviewedRouteKind.rightAction, text: 'go'),
  _ReviewedRoute(remember, _ReviewedRouteKind.rightAction, text: 'call'),
  _ReviewedRoute(remember, _ReviewedRouteKind.rightAction, text: 'work'),
  _ReviewedRoute(remember, _ReviewedRouteKind.rightAction, text: 'learn'),
  _ReviewedRoute(remember, _ReviewedRouteKind.rightAction, text: 'read'),
  _ReviewedRoute(remember, _ReviewedRouteKind.rightAction, text: 'write'),
  _ReviewedRoute(remember, _ReviewedRouteKind.rightAction, text: 'speak'),
  _ReviewedRoute(remember, _ReviewedRouteKind.manner, text: 'clearly'),
  _ReviewedRoute(remember, _ReviewedRouteKind.time, text: 'today'),

  _ReviewedRoute(education_data.understand, _ReviewedRouteKind.directObject),
  _ReviewedRoute(
    education_data.understand,
    _ReviewedRouteKind.directObject,
    text: 'English',
  ),
  _ReviewedRoute(
    education_data.understand,
    _ReviewedRouteKind.aboutTopic,
    text: 'grammar',
  ),
  _ReviewedRoute(
    education_data.understand,
    _ReviewedRouteKind.place,
    text: 'school',
  ),
  _ReviewedRoute(
    education_data.understand,
    _ReviewedRouteKind.manner,
    text: 'clearly',
  ),
  _ReviewedRoute(
    education_data.understand,
    _ReviewedRouteKind.time,
    text: 'today',
  ),

  _ReviewedRoute(education_data.forget, _ReviewedRouteKind.directObject),
  _ReviewedRoute(
    education_data.forget,
    _ReviewedRouteKind.directObject,
    text: 'something',
  ),
  _ReviewedRoute(
    education_data.forget,
    _ReviewedRouteKind.directObject,
    text: 'English',
  ),
  _ReviewedRoute(
    education_data.forget,
    _ReviewedRouteKind.directObject,
    text: 'grammar',
  ),
  _ReviewedRoute(
    education_data.forget,
    _ReviewedRouteKind.rightAction,
    text: 'go',
  ),
  _ReviewedRoute(
    education_data.forget,
    _ReviewedRouteKind.rightAction,
    text: 'call',
  ),
  _ReviewedRoute(
    education_data.forget,
    _ReviewedRouteKind.rightAction,
    text: 'work',
  ),
  _ReviewedRoute(
    education_data.forget,
    _ReviewedRouteKind.rightAction,
    text: 'learn',
  ),
  _ReviewedRoute(
    education_data.forget,
    _ReviewedRouteKind.rightAction,
    text: 'read',
  ),
  _ReviewedRoute(
    education_data.forget,
    _ReviewedRouteKind.rightAction,
    text: 'write',
  ),
  _ReviewedRoute(
    education_data.forget,
    _ReviewedRouteKind.rightAction,
    text: 'speak',
  ),

  _ReviewedRoute(sleep, _ReviewedRouteKind.place, text: 'home'),
  _ReviewedRoute(sleep, _ReviewedRouteKind.place, text: 'bed'),
  _ReviewedRoute(sleep, _ReviewedRouteKind.companion),
  _ReviewedRoute(sleep, _ReviewedRouteKind.manner, text: 'well'),
  _ReviewedRoute(sleep, _ReviewedRouteKind.manner, text: 'badly'),
  _ReviewedRoute(sleep, _ReviewedRouteKind.manner, text: 'quietly'),
  _ReviewedRoute(sleep, _ReviewedRouteKind.time, text: 'at night'),
  _ReviewedRoute(sleep, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(sleep, _ReviewedRouteKind.time, text: 'now'),

  _ReviewedRoute(open, _ReviewedRouteKind.directObject),
  _ReviewedRoute(open, _ReviewedRouteKind.directObject, text: 'door'),
  _ReviewedRoute(open, _ReviewedRouteKind.directObject, text: 'window'),
  _ReviewedRoute(open, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(open, _ReviewedRouteKind.directObject, text: 'box'),
  _ReviewedRoute(open, _ReviewedRouteKind.directObject, text: 'eyes'),
  _ReviewedRoute(open, _ReviewedRouteKind.directObject, text: 'store'),
  _ReviewedRoute(open, _ReviewedRouteKind.directObject, text: 'workshop'),
  _ReviewedRoute(open, _ReviewedRouteKind.directObject, text: 'office'),
  _ReviewedRoute(open, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(open, _ReviewedRouteKind.manner, text: 'carefully'),
  _ReviewedRoute(open, _ReviewedRouteKind.instrument),
  _ReviewedRoute(open, _ReviewedRouteKind.beneficiary),

  _ReviewedRoute(close, _ReviewedRouteKind.directObject),
  _ReviewedRoute(close, _ReviewedRouteKind.directObject, text: 'door'),
  _ReviewedRoute(close, _ReviewedRouteKind.directObject, text: 'window'),
  _ReviewedRoute(close, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(close, _ReviewedRouteKind.directObject, text: 'box'),
  _ReviewedRoute(close, _ReviewedRouteKind.directObject, text: 'eyes'),
  _ReviewedRoute(close, _ReviewedRouteKind.directObject, text: 'store'),
  _ReviewedRoute(close, _ReviewedRouteKind.directObject, text: 'workshop'),
  _ReviewedRoute(close, _ReviewedRouteKind.directObject, text: 'office'),
  _ReviewedRoute(close, _ReviewedRouteKind.onTopic, text: 'deal'),
  _ReviewedRoute(close, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(close, _ReviewedRouteKind.manner, text: 'carefully'),
  _ReviewedRoute(close, _ReviewedRouteKind.instrument),
  _ReviewedRoute(close, _ReviewedRouteKind.beneficiary),

  _ReviewedRoute(help, _ReviewedRouteKind.directObject),
  _ReviewedRoute(help, _ReviewedRouteKind.directObject, text: 'friend'),
  _ReviewedRoute(help, _ReviewedRouteKind.directObject, text: 'teacher'),
  _ReviewedRoute(help, _ReviewedRouteKind.directObject, text: 'child'),
  _ReviewedRoute(help, _ReviewedRouteKind.rightAction, text: 'learn'),
  _ReviewedRoute(help, _ReviewedRouteKind.rightAction, text: 'work'),
  _ReviewedRoute(help, _ReviewedRouteKind.rightAction, text: 'speak'),
  _ReviewedRoute(help, _ReviewedRouteKind.rightAction, text: 'read'),
  _ReviewedRoute(help, _ReviewedRouteKind.rightAction, text: 'write'),
  _ReviewedRoute(help, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(help, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(help, _ReviewedRouteKind.withTopic),
  _ReviewedRoute(help, _ReviewedRouteKind.withTopic, text: 'homework'),
  _ReviewedRoute(help, _ReviewedRouteKind.withTopic, text: 'problem'),

  _ReviewedRoute(education_data.analyze, _ReviewedRouteKind.directObject),
  _ReviewedRoute(
    education_data.analyze,
    _ReviewedRouteKind.directObject,
    text: 'something',
  ),
  _ReviewedRoute(
    education_data.analyze,
    _ReviewedRouteKind.directObject,
    text: 'data',
  ),
  _ReviewedRoute(
    education_data.analyze,
    _ReviewedRouteKind.directObject,
    text: 'problem',
  ),
  _ReviewedRoute(
    education_data.analyze,
    _ReviewedRouteKind.directObject,
    text: 'document',
  ),
  _ReviewedRoute(education_data.analyze, _ReviewedRouteKind.aboutTopic),
  _ReviewedRoute(education_data.analyze, _ReviewedRouteKind.instrument),
  _ReviewedRoute(
    education_data.analyze,
    _ReviewedRouteKind.instrument,
    text: 'computer',
  ),
  _ReviewedRoute(education_data.analyze, _ReviewedRouteKind.purpose),
  _ReviewedRoute(
    education_data.analyze,
    _ReviewedRouteKind.purpose,
    text: 'work',
  ),
  _ReviewedRoute(
    education_data.analyze,
    _ReviewedRouteKind.place,
    text: 'school',
  ),
  _ReviewedRoute(
    education_data.analyze,
    _ReviewedRouteKind.manner,
    text: 'carefully',
  ),
  _ReviewedRoute(
    education_data.analyze,
    _ReviewedRouteKind.manner,
    text: 'clearly',
  ),
  _ReviewedRoute(
    education_data.analyze,
    _ReviewedRouteKind.time,
    text: 'today',
  ),

  _ReviewedRoute(education_data.study, _ReviewedRouteKind.purpose),
  _ReviewedRoute(
    education_data.study,
    _ReviewedRouteKind.purpose,
    text: 'school',
  ),
  _ReviewedRoute(
    education_data.study,
    _ReviewedRouteKind.purpose,
    text: 'work',
  ),
  _ReviewedRoute(education_data.practice, _ReviewedRouteKind.purpose),
  _ReviewedRoute(
    education_data.practice,
    _ReviewedRouteKind.directObject,
    text: 'piano',
  ),
  _ReviewedRoute(
    education_data.practice,
    _ReviewedRouteKind.directObject,
    text: 'karate',
  ),
  _ReviewedRoute(
    education_data.practice,
    _ReviewedRouteKind.directObject,
    text: 'violin',
  ),
  _ReviewedRoute(
    education_data.practice,
    _ReviewedRouteKind.purpose,
    text: 'football',
  ),
  _ReviewedRoute(education_data.practice, _ReviewedRouteKind.companion),
  _ReviewedRoute(
    education_data.practice,
    _ReviewedRouteKind.place,
    text: 'school',
  ),
  _ReviewedRoute(
    education_data.practice,
    _ReviewedRouteKind.manner,
    text: 'quickly',
  ),
  _ReviewedRoute(
    education_data.practice,
    _ReviewedRouteKind.time,
    text: 'today',
  ),
  _ReviewedRoute(education_data.graduate, _ReviewedRouteKind.companion),
  _ReviewedRoute(
    education_data.graduate,
    _ReviewedRouteKind.place,
    text: 'school',
  ),
  _ReviewedRoute(
    education_data.graduate,
    _ReviewedRouteKind.sourcePlace,
    text: 'school',
  ),
  _ReviewedRoute(
    education_data.graduate,
    _ReviewedRouteKind.manner,
    text: 'happily',
  ),
  _ReviewedRoute(education_data.research, _ReviewedRouteKind.instrument),
  _ReviewedRoute(
    education_data.research,
    _ReviewedRouteKind.purpose,
    text: 'work',
  ),
  _ReviewedRoute(
    education_data.research,
    _ReviewedRouteKind.place,
    text: 'school',
  ),
  _ReviewedRoute(
    education_data.research,
    _ReviewedRouteKind.manner,
    text: 'carefully',
  ),
  _ReviewedRoute(
    education_data.research,
    _ReviewedRouteKind.time,
    text: 'today',
  ),
  _ReviewedRoute(walk, _ReviewedRouteKind.purpose),
  _ReviewedRoute(walk, _ReviewedRouteKind.purpose, text: 'exercise'),
  _ReviewedRoute(walk, _ReviewedRouteKind.rightAction, text: 'exercise'),
  _ReviewedRoute(walk, _ReviewedRouteKind.rightAction, text: 'train'),
  _ReviewedRoute(walk, _ReviewedRouteKind.rightAction, text: 'forget'),
  _ReviewedRoute(run, _ReviewedRouteKind.purpose),
  _ReviewedRoute(run, _ReviewedRouteKind.purpose, text: 'health'),
  _ReviewedRoute(run, _ReviewedRouteKind.rightAction, text: 'exercise'),
  _ReviewedRoute(run, _ReviewedRouteKind.rightAction, text: 'train'),
  _ReviewedRoute(run, _ReviewedRouteKind.rightAction, text: 'forget'),
  _ReviewedRoute(jump, _ReviewedRouteKind.purpose, text: 'exercise'),
  _ReviewedRoute(climb, _ReviewedRouteKind.companion),
  _ReviewedRoute(climb, _ReviewedRouteKind.purpose, text: 'exercise'),
  _ReviewedRoute(climb, _ReviewedRouteKind.sourcePlace, text: 'table'),
  _ReviewedRoute(crawl, _ReviewedRouteKind.companion),
  _ReviewedRoute(crawl, _ReviewedRouteKind.purpose, text: 'exercise'),
  _ReviewedRoute(dance, _ReviewedRouteKind.companion),
  _ReviewedRoute(dance, _ReviewedRouteKind.purpose, text: 'fun'),
  _ReviewedRoute(dance, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(dance, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(swim, _ReviewedRouteKind.purpose, text: 'fun'),
  _ReviewedRoute(swim, _ReviewedRouteKind.rightAction, text: 'exercise'),
  _ReviewedRoute(swim, _ReviewedRouteKind.rightAction, text: 'train'),
  _ReviewedRoute(swim, _ReviewedRouteKind.rightAction, text: 'forget'),
  _ReviewedRoute(dive, _ReviewedRouteKind.purpose, text: 'fun'),
  _ReviewedRoute(fall, _ReviewedRouteKind.sourcePlace, text: 'bridge'),
  _ReviewedRoute(sit, _ReviewedRouteKind.place, text: 'bed'),
  _ReviewedRoute(sit, _ReviewedRouteKind.manner, text: 'quietly'),
  _ReviewedRoute(stand, _ReviewedRouteKind.place, text: 'bridge'),
  _ReviewedRoute(stand, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(lie, _ReviewedRouteKind.place, text: 'bed'),
  _ReviewedRoute(lie, _ReviewedRouteKind.manner, text: 'quietly'),
  _ReviewedRoute(travel_data.depart, _ReviewedRouteKind.companion),
  _ReviewedRoute(
    travel_data.depart,
    _ReviewedRouteKind.sourcePlace,
    text: 'school',
  ),
  _ReviewedRoute(travel_data.depart, _ReviewedRouteKind.manner, text: 'slowly'),
  _ReviewedRoute(travel_data.navigate, _ReviewedRouteKind.destination),
  _ReviewedRoute(
    travel_data.navigate,
    _ReviewedRouteKind.instrument,
    text: 'map',
  ),
  _ReviewedRoute(
    travel_data.navigate,
    _ReviewedRouteKind.place,
    text: 'school',
  ),
  _ReviewedRoute(
    travel_data.navigate,
    _ReviewedRouteKind.manner,
    text: 'carefully',
  ),
  _ReviewedRoute(
    sport_data.score,
    _ReviewedRouteKind.purpose,
    text: 'football',
  ),
  _ReviewedRoute(sport_data.compete, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(sport_data.compete, _ReviewedRouteKind.manner, text: 'well'),
  _ReviewedRoute(sport_data.compete, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(sport_data.surf, _ReviewedRouteKind.companion),
  _ReviewedRoute(sport_data.surf, _ReviewedRouteKind.purpose, text: 'fun'),
  _ReviewedRoute(sport_data.surf, _ReviewedRouteKind.manner, text: 'slowly'),
  _ReviewedRoute(sport_data.cycle, _ReviewedRouteKind.companion),
  _ReviewedRoute(sport_data.cycle, _ReviewedRouteKind.purpose, text: 'health'),
  _ReviewedRoute(
    sport_data.cycle,
    _ReviewedRouteKind.sourcePlace,
    text: 'school',
  ),
  _ReviewedRoute(
    cooking_data.cut,
    _ReviewedRouteKind.directObject,
    text: 'something',
  ),
  _ReviewedRoute(
    cooking_data.chop,
    _ReviewedRouteKind.directObject,
    text: 'something',
  ),
  _ReviewedRoute(
    cooking_data.slice,
    _ReviewedRouteKind.directObject,
    text: 'something',
  ),
  _ReviewedRoute(
    cooking_data.mix,
    _ReviewedRouteKind.directObject,
    text: 'something',
  ),
  _ReviewedRoute(cooking_data.cook, _ReviewedRouteKind.purpose),
  _ReviewedRoute(cooking_data.cook, _ReviewedRouteKind.purpose, text: 'dinner'),
  _ReviewedRoute(sport_data.train, _ReviewedRouteKind.purpose),
  _ReviewedRoute(
    sport_data.train,
    _ReviewedRouteKind.purpose,
    text: 'football',
  ),
  _ReviewedRoute(sport_data.exercise, _ReviewedRouteKind.purpose),
  _ReviewedRoute(
    sport_data.exercise,
    _ReviewedRouteKind.purpose,
    text: 'health',
  ),
];

bool _reviewedRouteExists(_ReviewedRoute route) {
  final text = route.text;
  switch (route.kind) {
    case _ReviewedRouteKind.directObject:
      return _nounPathHas(route.verb, PredicatePathKind.directObject, text);
    case _ReviewedRouteKind.rightAction:
      return _verbPathHas(route.verb, PredicatePathKind.toRightAction, text);
    case _ReviewedRouteKind.recipient:
      return _nounPathHas(route.verb, PredicatePathKind.toRecipient, text);
    case _ReviewedRouteKind.addressee:
      return _nounPathHas(route.verb, PredicatePathKind.toAddressee, text);
    case _ReviewedRouteKind.companion:
      return route.verb == be ||
          _nounPathHas(route.verb, PredicatePathKind.withCompanion, text);
    case _ReviewedRouteKind.destination:
      return _nounPathHas(route.verb, PredicatePathKind.toDestination, text);
    case _ReviewedRouteKind.aboutTopic:
      return _nounPathHas(route.verb, PredicatePathKind.aboutTopic, text);
    case _ReviewedRouteKind.ofTopic:
      return _nounPathHas(route.verb, PredicatePathKind.ofTopic, text);
    case _ReviewedRouteKind.withTopic:
      return _nounPathHas(route.verb, PredicatePathKind.withTopic, text);
    case _ReviewedRouteKind.overTopic:
      return _nounPathHas(route.verb, PredicatePathKind.overTopic, text);
    case _ReviewedRouteKind.onTopic:
      return _nounPathHas(route.verb, PredicatePathKind.onTopic, text);
    case _ReviewedRouteKind.beneficiary:
      return _nounPathHas(route.verb, PredicatePathKind.forBeneficiary, text);
    case _ReviewedRouteKind.source:
      return _nounPathHas(route.verb, PredicatePathKind.fromSource, text);
    case _ReviewedRouteKind.purpose:
      return _nounPathHas(route.verb, PredicatePathKind.forPurpose, text);
    case _ReviewedRouteKind.place:
      return _placePathHas(route.verb, text);
    case _ReviewedRouteKind.sourcePlace:
      return _placePathHas(
        route.verb,
        text,
        kind: PredicatePathKind.fromLocation,
      );
    case _ReviewedRouteKind.time:
      return _timePathHas(route.verb, text);
    case _ReviewedRouteKind.manner:
      return _mannerPathHas(route.verb, text);
    case _ReviewedRouteKind.rightParticle:
      return _rightParticlePathHas(route.verb, text);
    case _ReviewedRouteKind.particleObject:
      return route.rightParticle != null &&
          _particleObjectPathHas(route.verb, route.rightParticle!, text);
    case _ReviewedRouteKind.lexicalBeNounComplement:
      return route.verb == be &&
          (text == null || _beNounComplements.contains(text));
    case _ReviewedRouteKind.lexicalBeAdjectiveComplement:
      return route.verb == be &&
          (text == null || _beAdjectiveComplements.contains(text));
    case _ReviewedRouteKind.objectAdjectiveComplement:
      return route.verb.takesObjectComplement &&
          (text == null || _objectAdjectiveComplements.contains(text));
    case _ReviewedRouteKind.instrument:
      return _nounPathHas(route.verb, PredicatePathKind.withInstrument, text);
  }
}

bool _nounPathHas(Verb verb, PredicatePathKind kind, String? text) {
  final choices = predicateNounChoicesFor(verb, kind);
  if (text == null) {
    return choices.isNotEmpty;
  }

  return choices.any(
    (choice) => choice.text.toLowerCase() == text.toLowerCase(),
  );
}

bool _verbPathHas(Verb verb, PredicatePathKind kind, String? text) {
  final choices = predicateVerbChoicesFor(verb, kind);
  if (text == null) {
    return choices.isNotEmpty;
  }

  return choices.any(
    (choice) => choice.infinitive.toLowerCase() == text.toLowerCase(),
  );
}

bool _placePathHas(Verb verb, String? text, {PredicatePathKind? kind}) {
  final choices = kind == null
      ? predicateAuthoredPlaceChoicesFor(verb)
      : predicatePlaceChoicesFor(verb, kind);
  if (text == null || text == 'somewhere') {
    return choices.isNotEmpty;
  }

  return choices.any(
    (choice) => choice.noun.toLowerCase() == text.toLowerCase(),
  );
}

bool _timePathHas(Verb verb, String? text) {
  final choices = predicateTimeChoicesFor(verb, PredicatePathKind.timePhrase);
  if (text == null) {
    return choices.isNotEmpty;
  }

  return choices.any(
    (choice) => choice.text.toLowerCase() == text.toLowerCase(),
  );
}

bool _mannerPathHas(Verb verb, String? text) {
  final choices = predicateMannerChoicesFor(
    verb,
    PredicatePathKind.mannerPhrase,
  ).map((choice) => choice.text);
  if (text == null) {
    return choices.isNotEmpty;
  }

  return choices.any((choice) => choice.toLowerCase() == text.toLowerCase());
}

bool _rightParticlePathHas(Verb verb, String? text) {
  final choices = predicateParticleChoicesFor(verb);
  if (text == null) {
    return choices.isNotEmpty;
  }

  return choices.any(
    (choice) => choice.text.toLowerCase() == text.toLowerCase(),
  );
}

bool _particleObjectPathHas(
  Verb verb,
  String rightParticle,
  String? objectText,
) {
  final particle = predicateParticleChoicesFor(
    verb,
  ).where((choice) => choice.text.toLowerCase() == rightParticle.toLowerCase());
  if (particle.isEmpty) {
    return false;
  }

  final choices = predicateParticleObjectChoicesFor(verb, particle.first);
  if (objectText == null) {
    return choices.isNotEmpty;
  }

  return choices.any(
    (choice) => choice.text.toLowerCase() == objectText.toLowerCase(),
  );
}

const _beNounComplements = {
  'person',
  'doctor',
  'teacher',
  'student',
  'engineer',
  'friend',
};

const _beAdjectiveComplements = {
  'happy',
  'tired',
  'hungry',
  'calm',
  'sad',
  'angry',
  'ready',
  'late',
};

const _objectAdjectiveComplements = {'happy', 'calm', 'sad', 'angry', 'tired'};
