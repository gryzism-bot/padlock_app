import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/predicate/fixed_object_frames.dart';
import 'package:padlock_app/data/predicate/predicate_paths.dart';
import 'package:padlock_app/data/predicate/right_action_frames.dart';
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
import 'package:padlock_app/data/subjects/third_person/people_categories.dart'
    as people_categories;
import 'package:padlock_app/data/subjects/third_person/people.dart'
    as people_data;
import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/cooking.dart' as cooking_data;
import 'package:padlock_app/data/verbs/education.dart' as education_data;
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/data/verbs/sport.dart' as sport_data;
import 'package:padlock_app/engine/configuration_compass.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/engine/predicate_path_compiler.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';

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
            action: use,
            kind: PredicatePathKind.forPurpose,
            text: 'You use for work.',
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
        ];

        for (final example in examples) {
          final unlocks = predicateUnlocksFor(example.action)!;
          final path = unlocks.paths.singleWhere(
            (path) => path.kind == example.kind,
          );
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
        containsAll(['John', 'Mary', 'friend', 'someone', 'boss', 'mother']),
      );
      expect(
        animal_data.singularAnimals.map((noun) => noun.text),
        containsAll(['cat', 'dog', 'puppy', 'dolphin']),
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
        ]),
      );

      final talkAddressees = predicatePathsFor(talk)
          .where((path) => path.kind == PredicatePathKind.toAddressee)
          .single
          .nouns
          .map((noun) => noun.text);

      expect(
        talkAddressees,
        containsAll(['John', 'Mary', 'boss', 'cat', 'dog', 'dolphin']),
      );
    });

    test('predicate path shelves expose semantic noun categories', () {
      expect(
        people_categories.singularWorkPeople.map((noun) => noun.text),
        containsAll(['boss', 'colleague', 'programmer', 'police officer']),
      );
      expect(
        people_categories.singularFamilyPeople.map((noun) => noun.text),
        containsAll(['mother', 'father', 'sister', 'brother']),
      );
      expect(
        animal_categories.singularPetAnimals.map((noun) => noun.text),
        containsAll(['cat', 'dog', 'puppy', 'kitten', 'parrot']),
      );
      expect(
        animal_categories.singularWaterAnimals.map((noun) => noun.text),
        containsAll(['fish', 'dolphin', 'whale', 'shark']),
      );
      expect(
        object_categories.singularFoodObjects.map((noun) => noun.text),
        containsAll(['apple', 'bread', 'rice', 'egg', 'coffee', 'juice']),
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
        ]),
      );
      expect(
        object_categories.singularOpenableObjects.map((noun) => noun.text),
        containsAll(['door', 'window', 'box', 'wallet']),
      );
      expect(
        object_categories.singularMediaObjects.map((noun) => noun.text),
        containsAll(['movie', 'song', 'photo', 'painting']),
      );
      expect(
        object_categories.singularVehicleObjects.map((noun) => noun.text),
        containsAll(['car', 'bus', 'train', 'bicycle']),
      );
      expect(
        object_categories.singularDrivableObjects.map((noun) => noun.text),
        containsAll(['car', 'bus', 'train']),
      );
      expect(
        object_categories.singularDrivableObjects.map((noun) => noun.text),
        isNot(contains('bicycle')),
      );
      expect(
        object_categories.singularRideableObjects.map((noun) => noun.text),
        containsAll(['bicycle', 'bus', 'train']),
      );
    });

    test('fixed object frames consume semantic category shelves', () {
      final examples = [
        (action: write, object: object_data.email),
        (action: write, object: object_data.message),
        (action: read, object: object_data.document),
        (action: use, object: object_data.camera),
        (action: open, object: object_data.box),
        (action: close, object: object_data.wallet),
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

      expect(labels, [
        'English',
        'Polish',
        'Spanish',
        'grammar',
        'history',
        'math',
        'science',
      ]);
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

        expect(labels, containsAll(['John', 'Mary', 'boss', 'cat', 'dolphin']));
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

    test(
      'authored word-opening queries stay separate from structural helpers',
      () {
        final learnObjects = predicateNounChoicesFor(
          learn,
          PredicatePathKind.directObject,
        ).map((noun) => noun.text).toList();

        expect(learnObjects, containsAll(['English', 'grammar', 'history']));
        expect(learnObjects, isNot(contains('book')));
        expect(fixedObjectChoicesFor(learn).map((noun) => noun.text), [
          'English',
          'Polish',
          'Spanish',
          'grammar',
          'math',
          'history',
          'science',
        ]);

        final learnRightActions = predicateVerbChoicesFor(
          learn,
          PredicatePathKind.toRightAction,
        ).map((verb) => verb.infinitive).toList();
        final helperRightActions = rightActionChoicesFor(
          learn,
        ).map((verb) => verb.infinitive).toList();

        expect(helperRightActions, learnRightActions);
        expect(helperRightActions, ['speak', 'swim', 'work']);
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
      expect(predicateTopicConnectorsFor(think), ['about', 'of']);
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
        predicateMannerChoicesFor(
          go,
          PredicatePathKind.mannerPhrase,
        ).map((manner) => manner.text),
        containsAll(['quickly', 'away', 'back', 'there']),
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
      final implemented = _essentialVerbReviewRoutes.where(
        (route) => route.status == _RouteStatus.implemented,
      );
      final pending = _essentialVerbReviewRoutes.where(
        (route) => route.status == _RouteStatus.pending,
      );

      expect(
        _essentialVerbReviewRoutes
            .map((route) => route.verb.infinitive)
            .toSet(),
        containsAll(essentialVerbs.map((verb) => verb.infinitive)),
        reason: 'Every essential verb should have at least one reviewed route.',
      );

      for (final route in implemented) {
        expect(_reviewedRouteExists(route), isTrue, reason: route.description);
      }

      for (final route in pending) {
        expect(
          _reviewedRouteExists(route),
          isFalse,
          reason:
              '${route.description} is intentionally pending; when this turns true, move it to implemented.',
        );
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

      final sourcePlaceLabels = authoredCompass
          .suggestionsFor(state, ConfigurationCompassSlot.sourcePlace, limit: 0)
          .map((suggestion) => suggestion.label)
          .toList();

      expect(placeLabels, containsAll(['home', 'to school', 'to the shop']));
      expect(placeLabels, isNot(contains('from work')));
      expect(sourcePlaceLabels, containsAll(['from work', 'from school']));
      expect(placeLabels, isNot(contains('bed')));
      expect(mannerLabels, containsAll(['quickly', 'away', 'back']));
      expect(mannerLabels, isNot(contains('closely')));
    });

    test('reviewed phrase paths render through the lower Grammar Engine', () {
      final cases = [
        (
          action: go,
          move: const SetMannerPhrase(awayMannerPhrase),
          text: 'You go away.',
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
  });
}

enum _RouteStatus { implemented, pending }

enum _ReviewedRouteKind {
  directObject,
  rightAction,
  recipient,
  addressee,
  companion,
  destination,
  aboutTopic,
  ofTopic,
  beneficiary,
  source,
  place,
  sourcePlace,
  time,
  manner,
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
  final _RouteStatus status;

  const _ReviewedRoute(
    this.verb,
    this.kind, {
    this.text,
    this.status = _RouteStatus.implemented,
  });

  String get description {
    final value = text == null ? '' : ' "$text"';
    return '${verb.infinitive} ${kind.name}$value';
  }
}

const _pending = _RouteStatus.pending;

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
    status: _pending,
  ),
  _ReviewedRoute(
    be,
    _ReviewedRouteKind.lexicalBeAdjectiveComplement,
    text: 'late',
    status: _pending,
  ),

  _ReviewedRoute(have, _ReviewedRouteKind.directObject),
  _ReviewedRoute(have, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(have, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(have, _ReviewedRouteKind.companion),
  _ReviewedRoute(have, _ReviewedRouteKind.place, text: 'home'),
  _ReviewedRoute(have, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(
    have,
    _ReviewedRouteKind.directObject,
    text: 'money',
    status: _pending,
  ),
  _ReviewedRoute(
    have,
    _ReviewedRouteKind.directObject,
    text: 'time',
    status: _pending,
  ),
  _ReviewedRoute(
    have,
    _ReviewedRouteKind.directObject,
    text: 'problem',
    status: _pending,
  ),
  _ReviewedRoute(
    have,
    _ReviewedRouteKind.directObject,
    text: 'question',
    status: _pending,
  ),
  _ReviewedRoute(
    have,
    _ReviewedRouteKind.directObject,
    text: 'breakfast',
    status: _pending,
  ),

  _ReviewedRoute(doVerb, _ReviewedRouteKind.directObject),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.companion),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.manner, text: 'carefully'),
  _ReviewedRoute(doVerb, _ReviewedRouteKind.manner, text: 'again'),
  _ReviewedRoute(
    doVerb,
    _ReviewedRouteKind.directObject,
    text: 'work',
    status: _pending,
  ),
  _ReviewedRoute(
    doVerb,
    _ReviewedRouteKind.directObject,
    text: 'homework',
    status: _pending,
  ),
  _ReviewedRoute(
    doVerb,
    _ReviewedRouteKind.directObject,
    text: 'job',
    status: _pending,
  ),
  _ReviewedRoute(
    doVerb,
    _ReviewedRouteKind.directObject,
    text: 'exercise',
    status: _pending,
  ),

  _ReviewedRoute(findVerb, _ReviewedRouteKind.directObject),
  _ReviewedRoute(findVerb, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(findVerb, _ReviewedRouteKind.directObject, text: 'key'),
  _ReviewedRoute(findVerb, _ReviewedRouteKind.place, text: 'home'),
  _ReviewedRoute(findVerb, _ReviewedRouteKind.place, text: 'room'),
  _ReviewedRoute(findVerb, _ReviewedRouteKind.companion),
  _ReviewedRoute(findVerb, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(findVerb, _ReviewedRouteKind.manner, text: 'by accident'),
  _ReviewedRoute(
    findVerb,
    _ReviewedRouteKind.directObject,
    text: 'money',
    status: _pending,
  ),
  _ReviewedRoute(
    findVerb,
    _ReviewedRouteKind.directObject,
    text: 'someone',
    status: _pending,
  ),

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
  _ReviewedRoute(breakVerb, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(
    breakVerb,
    _ReviewedRouteKind.directObject,
    text: 'cup',
    status: _pending,
  ),
  _ReviewedRoute(breakVerb, _ReviewedRouteKind.instrument),

  _ReviewedRoute(read, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(read, _ReviewedRouteKind.directObject, text: 'books'),
  _ReviewedRoute(read, _ReviewedRouteKind.directObject, text: 'letter'),
  _ReviewedRoute(read, _ReviewedRouteKind.directObject, text: 'newspaper'),
  _ReviewedRoute(read, _ReviewedRouteKind.directObject, text: 'story'),
  _ReviewedRoute(read, _ReviewedRouteKind.addressee),
  _ReviewedRoute(read, _ReviewedRouteKind.companion),
  _ReviewedRoute(read, _ReviewedRouteKind.manner, text: 'carefully'),
  _ReviewedRoute(read, _ReviewedRouteKind.time, text: 'at night'),
  _ReviewedRoute(read, _ReviewedRouteKind.aboutTopic),
  _ReviewedRoute(read, _ReviewedRouteKind.purpose, text: 'school'),
  _ReviewedRoute(read, _ReviewedRouteKind.purpose, text: 'work'),
  _ReviewedRoute(
    read,
    _ReviewedRouteKind.directObject,
    text: 'English',
    status: _pending,
  ),

  _ReviewedRoute(begin, _ReviewedRouteKind.directObject),
  _ReviewedRoute(begin, _ReviewedRouteKind.rightAction, text: 'work'),
  _ReviewedRoute(begin, _ReviewedRouteKind.rightAction, text: 'learn'),
  _ReviewedRoute(begin, _ReviewedRouteKind.companion),
  _ReviewedRoute(begin, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(begin, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(begin, _ReviewedRouteKind.time, text: 'now'),
  _ReviewedRoute(
    begin,
    _ReviewedRouteKind.directObject,
    text: 'lesson',
    status: _pending,
  ),
  _ReviewedRoute(
    begin,
    _ReviewedRouteKind.directObject,
    text: 'work',
    status: _pending,
  ),

  _ReviewedRoute(go, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(go, _ReviewedRouteKind.manner, text: 'slowly'),
  _ReviewedRoute(go, _ReviewedRouteKind.companion),
  _ReviewedRoute(go, _ReviewedRouteKind.destination),
  _ReviewedRoute(go, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(go, _ReviewedRouteKind.place, text: 'work'),
  _ReviewedRoute(go, _ReviewedRouteKind.place, text: 'shop'),
  _ReviewedRoute(go, _ReviewedRouteKind.place, text: 'home'),
  _ReviewedRoute(go, _ReviewedRouteKind.manner, text: 'away'),
  _ReviewedRoute(go, _ReviewedRouteKind.manner, text: 'back'),
  _ReviewedRoute(go, _ReviewedRouteKind.manner, text: 'there'),
  _ReviewedRoute(go, _ReviewedRouteKind.time, text: 'now'),
  _ReviewedRoute(go, _ReviewedRouteKind.time, text: 'today'),

  _ReviewedRoute(come, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(come, _ReviewedRouteKind.manner, text: 'slowly'),
  _ReviewedRoute(come, _ReviewedRouteKind.companion),
  _ReviewedRoute(come, _ReviewedRouteKind.destination),
  _ReviewedRoute(come, _ReviewedRouteKind.place, text: 'home'),
  _ReviewedRoute(come, _ReviewedRouteKind.manner, text: 'here'),
  _ReviewedRoute(come, _ReviewedRouteKind.manner, text: 'back'),
  _ReviewedRoute(come, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(come, _ReviewedRouteKind.time, text: 'now'),
  _ReviewedRoute(come, _ReviewedRouteKind.sourcePlace),

  _ReviewedRoute(get, _ReviewedRouteKind.directObject),
  _ReviewedRoute(get, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(get, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(get, _ReviewedRouteKind.directObject, text: 'gift'),
  _ReviewedRoute(get, _ReviewedRouteKind.source),
  _ReviewedRoute(get, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(get, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(
    get,
    _ReviewedRouteKind.directObject,
    text: 'money',
    status: _pending,
  ),
  _ReviewedRoute(
    get,
    _ReviewedRouteKind.directObject,
    text: 'job',
    status: _pending,
  ),
  _ReviewedRoute(get, _ReviewedRouteKind.beneficiary),

  _ReviewedRoute(make, _ReviewedRouteKind.directObject),
  _ReviewedRoute(make, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(make, _ReviewedRouteKind.directObject, text: 'cake'),
  _ReviewedRoute(make, _ReviewedRouteKind.directObject, text: 'coffee'),
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
  _ReviewedRoute(
    make,
    _ReviewedRouteKind.directObject,
    text: 'plan',
    status: _pending,
  ),
  _ReviewedRoute(
    make,
    _ReviewedRouteKind.directObject,
    text: 'mistake',
    status: _pending,
  ),

  _ReviewedRoute(take, _ReviewedRouteKind.directObject),
  _ReviewedRoute(take, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(take, _ReviewedRouteKind.directObject, text: 'phone'),
  _ReviewedRoute(take, _ReviewedRouteKind.directObject, text: 'photo'),
  _ReviewedRoute(take, _ReviewedRouteKind.companion),
  _ReviewedRoute(take, _ReviewedRouteKind.source),
  _ReviewedRoute(take, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(take, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(
    take,
    _ReviewedRouteKind.directObject,
    text: 'money',
    status: _pending,
  ),
  _ReviewedRoute(take, _ReviewedRouteKind.destination, status: _pending),

  _ReviewedRoute(give, _ReviewedRouteKind.directObject),
  _ReviewedRoute(give, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(give, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(give, _ReviewedRouteKind.directObject, text: 'gift'),
  _ReviewedRoute(give, _ReviewedRouteKind.recipient),
  _ReviewedRoute(give, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(give, _ReviewedRouteKind.beneficiary),
  _ReviewedRoute(give, _ReviewedRouteKind.companion),

  _ReviewedRoute(know, _ReviewedRouteKind.directObject),
  _ReviewedRoute(know, _ReviewedRouteKind.directObject, text: 'Mary'),
  _ReviewedRoute(know, _ReviewedRouteKind.directObject, text: 'English'),
  _ReviewedRoute(know, _ReviewedRouteKind.directObject, text: 'grammar'),
  _ReviewedRoute(know, _ReviewedRouteKind.aboutTopic),
  _ReviewedRoute(know, _ReviewedRouteKind.manner, text: 'well'),
  _ReviewedRoute(know, _ReviewedRouteKind.manner, text: 'already'),
  _ReviewedRoute(know, _ReviewedRouteKind.time, text: 'now'),
  _ReviewedRoute(
    know,
    _ReviewedRouteKind.directObject,
    text: 'answer',
    status: _pending,
  ),

  _ReviewedRoute(think, _ReviewedRouteKind.aboutTopic),
  _ReviewedRoute(think, _ReviewedRouteKind.ofTopic),
  _ReviewedRoute(think, _ReviewedRouteKind.companion),
  _ReviewedRoute(think, _ReviewedRouteKind.manner, text: 'carefully'),
  _ReviewedRoute(think, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(think, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(think, _ReviewedRouteKind.time, text: 'now'),

  _ReviewedRoute(say, _ReviewedRouteKind.directObject),
  _ReviewedRoute(say, _ReviewedRouteKind.addressee),
  _ReviewedRoute(say, _ReviewedRouteKind.manner, text: 'loudly'),
  _ReviewedRoute(say, _ReviewedRouteKind.manner, text: 'quietly'),
  _ReviewedRoute(say, _ReviewedRouteKind.aboutTopic),
  _ReviewedRoute(
    say,
    _ReviewedRouteKind.directObject,
    text: 'word',
    status: _pending,
  ),
  _ReviewedRoute(
    say,
    _ReviewedRouteKind.directObject,
    text: 'yes',
    status: _pending,
  ),
  _ReviewedRoute(
    say,
    _ReviewedRouteKind.directObject,
    text: 'no',
    status: _pending,
  ),
  _ReviewedRoute(
    say,
    _ReviewedRouteKind.directObject,
    text: 'hello',
    status: _pending,
  ),

  _ReviewedRoute(see, _ReviewedRouteKind.directObject),
  _ReviewedRoute(see, _ReviewedRouteKind.directObject, text: 'cat'),
  _ReviewedRoute(see, _ReviewedRouteKind.directObject, text: 'friend'),
  _ReviewedRoute(see, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(see, _ReviewedRouteKind.companion),
  _ReviewedRoute(see, _ReviewedRouteKind.manner, text: 'clearly'),
  _ReviewedRoute(see, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(
    see,
    _ReviewedRouteKind.directObject,
    text: 'problem',
    status: _pending,
  ),

  _ReviewedRoute(want, _ReviewedRouteKind.directObject),
  _ReviewedRoute(want, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(want, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(want, _ReviewedRouteKind.rightAction, text: 'go'),
  _ReviewedRoute(want, _ReviewedRouteKind.rightAction, text: 'learn'),
  _ReviewedRoute(want, _ReviewedRouteKind.rightAction, text: 'speak'),
  _ReviewedRoute(want, _ReviewedRouteKind.rightAction, text: 'sleep'),
  _ReviewedRoute(want, _ReviewedRouteKind.time, text: 'now'),
  _ReviewedRoute(want, _ReviewedRouteKind.companion),

  _ReviewedRoute(need, _ReviewedRouteKind.directObject),
  _ReviewedRoute(need, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(need, _ReviewedRouteKind.directObject, text: 'key'),
  _ReviewedRoute(need, _ReviewedRouteKind.rightAction, text: 'go'),
  _ReviewedRoute(need, _ReviewedRouteKind.rightAction, text: 'learn'),
  _ReviewedRoute(need, _ReviewedRouteKind.rightAction, text: 'speak'),
  _ReviewedRoute(need, _ReviewedRouteKind.time, text: 'now'),
  _ReviewedRoute(
    need,
    _ReviewedRouteKind.directObject,
    text: 'help',
    status: _pending,
  ),
  _ReviewedRoute(
    need,
    _ReviewedRouteKind.directObject,
    text: 'money',
    status: _pending,
  ),

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
  _ReviewedRoute(like, _ReviewedRouteKind.directObject, text: 'music'),
  _ReviewedRoute(like, _ReviewedRouteKind.directObject, text: 'game'),
  _ReviewedRoute(like, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(like, _ReviewedRouteKind.rightAction, text: 'learn'),
  _ReviewedRoute(like, _ReviewedRouteKind.rightAction, text: 'swim'),
  _ReviewedRoute(like, _ReviewedRouteKind.rightAction, text: 'watch'),
  _ReviewedRoute(like, _ReviewedRouteKind.companion),

  _ReviewedRoute(love, _ReviewedRouteKind.directObject),
  _ReviewedRoute(love, _ReviewedRouteKind.directObject, text: 'music'),
  _ReviewedRoute(love, _ReviewedRouteKind.directObject, text: 'game'),
  _ReviewedRoute(love, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(love, _ReviewedRouteKind.rightAction, text: 'learn'),
  _ReviewedRoute(love, _ReviewedRouteKind.rightAction, text: 'swim'),
  _ReviewedRoute(love, _ReviewedRouteKind.rightAction, text: 'watch'),
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
  _ReviewedRoute(watch, _ReviewedRouteKind.manner, text: 'closely'),
  _ReviewedRoute(watch, _ReviewedRouteKind.manner, text: 'quietly'),
  _ReviewedRoute(watch, _ReviewedRouteKind.place, text: 'home'),
  _ReviewedRoute(
    watch,
    _ReviewedRouteKind.directObject,
    text: 'show',
    status: _pending,
  ),
  _ReviewedRoute(
    watch,
    _ReviewedRouteKind.directObject,
    text: 'game',
    status: _pending,
  ),
  _ReviewedRoute(watch, _ReviewedRouteKind.rightAction, text: 'analyze'),

  _ReviewedRoute(lose, _ReviewedRouteKind.directObject),
  _ReviewedRoute(lose, _ReviewedRouteKind.directObject, text: 'key'),
  _ReviewedRoute(lose, _ReviewedRouteKind.directObject, text: 'phone'),
  _ReviewedRoute(lose, _ReviewedRouteKind.directObject, text: 'game'),
  _ReviewedRoute(lose, _ReviewedRouteKind.place, text: 'home'),
  _ReviewedRoute(lose, _ReviewedRouteKind.place, text: 'park'),
  _ReviewedRoute(lose, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(lose, _ReviewedRouteKind.manner, text: 'by accident'),
  _ReviewedRoute(
    lose,
    _ReviewedRouteKind.directObject,
    text: 'money',
    status: _pending,
  ),

  _ReviewedRoute(play, _ReviewedRouteKind.directObject, text: 'football'),
  _ReviewedRoute(play, _ReviewedRouteKind.directObject, text: 'basketball'),
  _ReviewedRoute(play, _ReviewedRouteKind.directObject, text: 'volleyball'),
  _ReviewedRoute(play, _ReviewedRouteKind.directObject, text: 'tennis'),
  _ReviewedRoute(play, _ReviewedRouteKind.companion),
  _ReviewedRoute(play, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(play, _ReviewedRouteKind.manner, text: 'well'),
  _ReviewedRoute(play, _ReviewedRouteKind.directObject, text: 'music'),
  _ReviewedRoute(play, _ReviewedRouteKind.directObject, text: 'game'),
  _ReviewedRoute(
    play,
    _ReviewedRouteKind.manner,
    text: 'outside',
    status: _pending,
  ),

  _ReviewedRoute(learn, _ReviewedRouteKind.directObject, text: 'English'),
  _ReviewedRoute(learn, _ReviewedRouteKind.directObject, text: 'grammar'),
  _ReviewedRoute(learn, _ReviewedRouteKind.directObject, text: 'history'),
  _ReviewedRoute(learn, _ReviewedRouteKind.directObject, text: 'science'),
  _ReviewedRoute(learn, _ReviewedRouteKind.rightAction, text: 'speak'),
  _ReviewedRoute(learn, _ReviewedRouteKind.rightAction, text: 'swim'),
  _ReviewedRoute(learn, _ReviewedRouteKind.rightAction, text: 'work'),
  _ReviewedRoute(learn, _ReviewedRouteKind.companion),
  _ReviewedRoute(learn, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(learn, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(learn, _ReviewedRouteKind.directObject, text: 'Polish'),
  _ReviewedRoute(learn, _ReviewedRouteKind.purpose, text: 'school'),
  _ReviewedRoute(learn, _ReviewedRouteKind.purpose, text: 'work'),
  _ReviewedRoute(learn, _ReviewedRouteKind.purpose, text: 'grammar'),

  _ReviewedRoute(hate, _ReviewedRouteKind.directObject),
  _ReviewedRoute(hate, _ReviewedRouteKind.directObject, text: 'food'),
  _ReviewedRoute(hate, _ReviewedRouteKind.rightAction, text: 'work'),
  _ReviewedRoute(hate, _ReviewedRouteKind.manner, text: 'quietly'),
  _ReviewedRoute(
    hate,
    _ReviewedRouteKind.directObject,
    text: 'noise',
    status: _pending,
  ),
  _ReviewedRoute(
    hate,
    _ReviewedRouteKind.directObject,
    text: 'waiting',
    status: _pending,
  ),
  _ReviewedRoute(hate, _ReviewedRouteKind.rightAction, text: 'lose'),
  _ReviewedRoute(hate, _ReviewedRouteKind.companion, status: _pending),

  _ReviewedRoute(remember, _ReviewedRouteKind.directObject),
  _ReviewedRoute(remember, _ReviewedRouteKind.directObject, text: 'story'),
  _ReviewedRoute(remember, _ReviewedRouteKind.directObject, text: 'English'),
  _ReviewedRoute(remember, _ReviewedRouteKind.directObject, text: 'grammar'),
  _ReviewedRoute(remember, _ReviewedRouteKind.rightAction, text: 'go'),
  _ReviewedRoute(remember, _ReviewedRouteKind.rightAction, text: 'call'),
  _ReviewedRoute(remember, _ReviewedRouteKind.manner, text: 'clearly'),
  _ReviewedRoute(remember, _ReviewedRouteKind.time, text: 'today'),

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
  _ReviewedRoute(open, _ReviewedRouteKind.manner, text: 'quickly'),
  _ReviewedRoute(open, _ReviewedRouteKind.manner, text: 'carefully'),
  _ReviewedRoute(open, _ReviewedRouteKind.instrument),
  _ReviewedRoute(open, _ReviewedRouteKind.beneficiary),

  _ReviewedRoute(close, _ReviewedRouteKind.directObject),
  _ReviewedRoute(close, _ReviewedRouteKind.directObject, text: 'door'),
  _ReviewedRoute(close, _ReviewedRouteKind.directObject, text: 'window'),
  _ReviewedRoute(close, _ReviewedRouteKind.directObject, text: 'book'),
  _ReviewedRoute(close, _ReviewedRouteKind.directObject, text: 'box'),
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
  _ReviewedRoute(help, _ReviewedRouteKind.place, text: 'school'),
  _ReviewedRoute(help, _ReviewedRouteKind.time, text: 'today'),
  _ReviewedRoute(help, _ReviewedRouteKind.aboutTopic, status: _pending),

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
    _ReviewedRouteKind.purpose,
    text: 'football',
  ),
  _ReviewedRoute(walk, _ReviewedRouteKind.purpose),
  _ReviewedRoute(walk, _ReviewedRouteKind.purpose, text: 'exercise'),
  _ReviewedRoute(run, _ReviewedRouteKind.purpose),
  _ReviewedRoute(run, _ReviewedRouteKind.purpose, text: 'health'),
  _ReviewedRoute(swim, _ReviewedRouteKind.purpose, text: 'fun'),
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
  if (text == null || text == 'something') {
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
  );
  if (text == null) {
    return choices.isNotEmpty;
  }

  return choices.any(
    (choice) => choice.text.toLowerCase() == text.toLowerCase(),
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
};

const _objectAdjectiveComplements = {'happy', 'calm', 'sad', 'angry', 'tired'};
