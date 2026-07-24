import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/predicate/fixed_object_frames.dart';
import 'package:padlock_app/data/predicate/predicate_paths.dart';
import 'package:padlock_app/data/predicate/right_action_frames.dart';
import 'package:padlock_app/data/phrases/manner_phrases.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/subjects/third_person/animal_categories.dart'
    as animal_categories;
import 'package:padlock_app/data/subjects/third_person/animals.dart'
    as animal_data;
import 'package:padlock_app/data/subjects/third_person/object_categories.dart'
    as object_categories;
import 'package:padlock_app/data/subjects/third_person/objects.dart'
    as object_data;
import 'package:padlock_app/data/subjects/third_person/people_categories.dart'
    as people_categories;
import 'package:padlock_app/data/subjects/third_person/people.dart'
    as people_data;
import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/engine/configuration_compass.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
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

  ConfigurationMove firstMoveFor(PredicatePath path) {
    return switch (path.kind) {
      PredicatePathKind.directObject => SetObject(path.nouns.first),
      PredicatePathKind.toRightAction => SetRightAction(path.verbs.first),
      PredicatePathKind.toRecipient => SetRecipient(path.nouns.first),
      PredicatePathKind.toAddressee => SetAddressee(path.nouns.first),
      PredicatePathKind.withCompanion => SetCompanion(path.nouns.first),
      PredicatePathKind.toDestination => SetDestination(path.nouns.first),
      PredicatePathKind.aboutTopic => SetTopic(path.nouns.first),
      PredicatePathKind.forBeneficiary => SetBeneficiary(path.nouns.first),
      PredicatePathKind.fromSource => SetSource(path.nouns.first),
      PredicatePathKind.placePhrase => SetPlacePhrase(path.places.first),
      PredicatePathKind.timePhrase => SetTimePhrase(path.times.first),
      PredicatePathKind.frequencyPhrase => SetFrequencyPhrase(
        path.frequencies.first,
      ),
      PredicatePathKind.mannerPhrase => SetMannerPhrase(path.manners.first),
    };
  }

  ConfigurationState stateAfterPath(
    PredicateUnlocks unlocks,
    PredicatePath path,
  ) {
    var state = ConfigurationState.initial();
    state = lock.applyMove(state, SetAction(unlocks.verb));

    if (path.kind == PredicatePathKind.toRecipient) {
      PredicatePath? directObjectPath;
      for (final candidate in unlocks.paths) {
        if (candidate.kind == PredicatePathKind.directObject) {
          directObjectPath = candidate;
          break;
        }
      }
      if (directObjectPath != null) {
        state = lock.applyMove(state, firstMoveFor(directObjectPath));
      }
    }

    return lock.applyMove(state, firstMoveFor(path));
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

    test('guided predicate unlocks are authored per visible verb', () {
      final verbs = guidedPredicateUnlocks
          .map((unlocks) => unlocks.verb.infinitive)
          .toList();

      expect(verbs, containsAll(['learn', 'talk', 'write', 'go']));
      expect(verbs.toSet(), hasLength(verbs.length));
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

      expect(labels, ['English', 'grammar', 'history', 'math', 'science']);
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
          containsAll(['English', 'grammar', 'math', 'history', 'science']),
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
            case PredicatePathKind.toDestination:
              expect(unlocks.verb.usesDestinationPlace, isTrue, reason: reason);
              expect(path.nouns, isNotEmpty, reason: reason);
            case PredicatePathKind.aboutTopic:
              expect(unlocks.verb.takesTopic, isTrue, reason: reason);
              expect(path.nouns, isNotEmpty, reason: reason);
            case PredicatePathKind.forBeneficiary:
              expect(unlocks.verb.takesBeneficiary, isTrue, reason: reason);
              expect(path.nouns, isNotEmpty, reason: reason);
            case PredicatePathKind.fromSource:
              expect(unlocks.verb.takesSource, isTrue, reason: reason);
              expect(path.nouns, isNotEmpty, reason: reason);
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
        predicatePlaceChoicesFor(
          sleep,
          PredicatePathKind.placePhrase,
        ).map((place) => place.noun),
        containsAll(['home', 'bed']),
      );
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

      expect(placeLabels, containsAll(['home', 'school', 'shop']));
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
          move: const SetPlacePhrase(bedPlacePhrase),
          text: 'You sleep on the bed.',
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
  });
}
