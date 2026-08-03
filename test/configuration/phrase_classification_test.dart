import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/phrases/frequency_phrases.dart';
import 'package:padlock_app/data/phrases/manner_phrases.dart';
import 'package:padlock_app/data/phrases/phrase_classification.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/predicate/predicate_paths.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/engine/configuration_compass.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

void main() {
  group('Current phrase classification', () {
    test('classifies every current phrase exactly once', () {
      final phraseCount =
          placePhrases.length +
          timePhrases.length +
          frequencyPhrases.length +
          mannerPhrases.length;

      expect(currentPhraseClassifications, hasLength(phraseCount));
      expect(
        currentPhraseClassifications.map((classification) {
          return identityHashCode(classification.phrase);
        }).toSet(),
        hasLength(phraseCount),
      );

      for (final phrase in [
        ...placePhrases,
        ...timePhrases,
        ...frequencyPhrases,
        ...mannerPhrases,
      ]) {
        expect(currentPhraseClassificationFor(phrase), isNotNull);
      }
    });

    test('places are predicate-bound right route candidates', () {
      final places = currentPhraseClassificationsForFamily(
        PhraseSurfaceFamily.place,
      );

      expect(
        places.map((classification) => classification.label),
        placePhrases.map((phrase) => phrase.noun),
      );
      expect(
        places.map((classification) => classification.label),
        containsAll(['city', 'road', 'station', 'airport', 'forest']),
      );
      expect(
        places,
        everyElement(
          predicate<CurrentPhraseClassification>(
            (classification) =>
                classification.role == PhraseSurfaceRole.predicateBoundRoute,
            'is predicate-bound',
          ),
        ),
      );
      expect(
        currentPhraseClassificationFor(homePlacePhrase)!.routeHints,
        containsAll([
          PredicateRouteHint.location,
          PredicateRouteHint.destination,
          PredicateRouteHint.source,
        ]),
      );
      expect(currentPhraseClassificationFor(inBedPlacePhrase)!.routeHints, {
        PredicateRouteHint.location,
      });
      expect(currentPhraseClassificationFor(itDomainPlacePhrase)!.routeHints, {
        PredicateRouteHint.location,
      });
    });

    test('time and frequency stay clause-level modifiers for now', () {
      final clauseModifiers = currentPhraseClassificationsForRole(
        PhraseSurfaceRole.clauseLevelModifier,
      ).map((classification) => classification.label);

      expect(clauseModifiers, containsAll(['today', 'yesterday', 'now']));
      expect(clauseModifiers, containsAll(['always', 'usually', 'every day']));
      expect(clauseLevelTimePhrases, timePhrases);
      expect(clauseLevelFrequencyPhrases, frequencyPhrases);
      expect(
        currentPhraseClassificationFor(todayTimePhrase)!.family,
        PhraseSurfaceFamily.time,
      );
      expect(
        currentPhraseClassificationFor(alwaysFrequencyPhrase)!.family,
        PhraseSurfaceFamily.frequency,
      );
    });

    test('dead wood policy removes broad guided fallback only', () {
      expect(
        broadPhraseFallbackIsDeadInAuthoredMode(PhraseSurfaceFamily.place),
        isTrue,
      );
      expect(
        broadPhraseFallbackIsDeadInAuthoredMode(PhraseSurfaceFamily.manner),
        isTrue,
      );
      expect(
        usesBroadPhraseFallbackInAuthoredMode(PhraseSurfaceFamily.time),
        isTrue,
      );
      expect(
        usesBroadPhraseFallbackInAuthoredMode(PhraseSurfaceFamily.frequency),
        isTrue,
      );
    });

    test('authored mode keeps time choices broad as clause modifiers', () {
      final compass = ConfigurationCompass(
        predicatePathMode: PredicatePathMode.authoredTracks,
      );
      var state = ConfigurationState.initial();
      state = const ConfigurationEngine().applyMove(state, const SetAction(go));

      final labels = compass
          .suggestionsFor(state, ConfigurationCompassSlot.timePhrase, limit: 0)
          .map((suggestion) => suggestion.label)
          .toList();

      expect(labels, containsAll(['today', 'yesterday', 'on Monday']));
      expect(labels, contains('soon'));
    });

    test('authored mode keeps frequency choices broad as clause modifiers', () {
      final compass = ConfigurationCompass(
        predicatePathMode: PredicatePathMode.authoredTracks,
      );
      var state = ConfigurationState.initial();
      state = const ConfigurationEngine().applyMove(state, const SetAction(go));

      final labels = compass
          .suggestionsFor(
            state,
            ConfigurationCompassSlot.frequencyPhrase,
            limit: 0,
          )
          .map((suggestion) => suggestion.label)
          .toList();

      expect(labels, containsAll(['always', 'usually', 'never']));
      expect(labels, contains('every year'));
    });

    test('clause modifiers survive guided verb shaving', () {
      final lock = const ConfigurationEngine();
      var state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetAction(go));
      state = lock.applyMove(state, const SetTimePhrase(yesterdayTimePhrase));
      state = lock.applyMove(
        state,
        const SetFrequencyPhrase(neverFrequencyPhrase),
      );
      state = lock.applyMove(state, const SetAction(read));

      expect(state.sentenceState.action, read);
      expect(state.sentenceState.timePhrase, yesterdayTimePhrase);
      expect(state.sentenceState.frequencyPhrase, neverFrequencyPhrase);
    });

    test('authored mode hides broad place routes without an authored path', () {
      final compass = ConfigurationCompass(
        predicatePathMode: PredicatePathMode.authoredTracks,
      );
      var state = ConfigurationState.initial();
      state = const ConfigurationEngine().applyMove(
        state,
        const SetAction(say),
      );

      final labels = compass
          .suggestionsFor(state, ConfigurationCompassSlot.placePhrase, limit: 0)
          .map((suggestion) => suggestion.label)
          .toList();

      expect(labels, isEmpty);
    });

    test(
      'authored mode hides broad manner routes without an authored path',
      () {
        final compass = ConfigurationCompass(
          predicatePathMode: PredicatePathMode.authoredTracks,
        );
        var state = ConfigurationState.initial();
        state = const ConfigurationEngine().applyMove(
          state,
          const SetAction(want),
        );

        final labels = compass
            .suggestionsFor(
              state,
              ConfigurationCompassSlot.mannerPhrase,
              limit: 0,
            )
            .map((suggestion) => suggestion.label)
            .toList();

        expect(labels, isEmpty);
      },
    );

    test('authored mode keeps selected place exit without broad fallback', () {
      final compass = ConfigurationCompass(
        predicatePathMode: PredicatePathMode.authoredTracks,
      );
      final state = ConfigurationState(
        sentenceState: SentenceState(
          agent: you,
          action: say,
          placePhrase: schoolPlacePhrase,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      final suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.placePhrase,
        limit: 0,
      );

      final labels = suggestions.map((suggestion) => suggestion.label);

      expect(labels, ['no place', 'at school']);
      expect(labels, isNot(contains('at home')));
      expect(
        suggestions
            .singleWhere((suggestion) => suggestion.label == 'no place')
            .preview
            .sentenceState
            .placePhrase,
        isNull,
      );
    });

    test('authored mode keeps selected manner exit without broad fallback', () {
      final compass = ConfigurationCompass(
        predicatePathMode: PredicatePathMode.authoredTracks,
      );
      final state = ConfigurationState(
        sentenceState: SentenceState(
          agent: you,
          action: want,
          mannerPhrase: closelyMannerPhrase,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      final suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.mannerPhrase,
        limit: 0,
      );

      final labels = suggestions.map((suggestion) => suggestion.label);

      expect(labels, ['no manner', 'closely']);
      expect(labels, isNot(contains('quickly')));
      expect(
        suggestions
            .singleWhere((suggestion) => suggestion.label == 'no manner')
            .preview
            .sentenceState
            .mannerPhrase,
        isNull,
      );
    });

    test('legacy mode keeps broad phrase fallback for explorer-style use', () {
      final compass = ConfigurationCompass(
        predicatePathMode: PredicatePathMode.legacyCompassFallback,
      );
      var state = ConfigurationState.initial();
      state = const ConfigurationEngine().applyMove(
        state,
        const SetAction(say),
      );

      final placeLabels = compass
          .suggestionsFor(state, ConfigurationCompassSlot.placePhrase, limit: 0)
          .map((suggestion) => suggestion.label)
          .toList();
      final mannerLabels = compass
          .suggestionsFor(
            state,
            ConfigurationCompassSlot.mannerPhrase,
            limit: 0,
          )
          .map((suggestion) => suggestion.label)
          .toList();

      expect(placeLabels, containsAll(['no place', 'at home', 'at school']));
      expect(mannerLabels, containsAll(['no manner', 'quickly', 'carefully']));
    });

    test('predicate-bound phrase routes are shaved by incompatible verbs', () {
      final lock = const ConfigurationEngine();
      var state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetAction(go));
      state = lock.applyMove(state, const SetPlacePhrase(schoolPlacePhrase));
      state = lock.applyMove(state, const SetMannerPhrase(awayMannerPhrase));
      state = lock.applyMove(state, const SetAction(say));

      expect(state.sentenceState.action, say);
      expect(state.sentenceState.placePhrase, isNull);
      expect(state.sentenceState.mannerPhrase, isNull);
    });

    test('manner words are currently predicate-bound route material', () {
      final manners = currentPhraseClassificationsForFamily(
        PhraseSurfaceFamily.manner,
      );

      expect(
        manners.map((classification) => classification.label),
        containsAll(['quickly', 'carefully', 'with care', 'by accident']),
      );
      expect(
        manners,
        everyElement(
          predicate<CurrentPhraseClassification>(
            (classification) =>
                classification.role == PhraseSurfaceRole.predicateBoundRoute,
            'is predicate-bound',
          ),
        ),
      );
    });

    test('bare direction words are classified as route words', () {
      final bareDirections = currentPhraseClassifications
          .where(
            (classification) => classification.routeHints.contains(
              PredicateRouteHint.bareDirection,
            ),
          )
          .map((classification) => classification.label)
          .toList();

      expect(bareDirections, ['away', 'back', 'here', 'there', 'outside']);
      expect(
        currentPhraseClassificationFor(outsideMannerPhrase)!.note,
        contains('authored per predicate'),
      );
    });

    test('particle words are classified as route words', () {
      final particles = currentPhraseClassifications
          .where(
            (classification) =>
                classification.routeHints.contains(PredicateRouteHint.particle),
          )
          .map((classification) => classification.label)
          .toList();

      expect(particles, [
        'up',
        'down',
        'out',
        'off',
        'on',
        'through',
        'around',
      ]);
      expect(
        currentPhraseClassificationFor(outMannerPhrase)!.note,
        contains('authored per predicate'),
      );
    });
  });
}
