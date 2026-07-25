import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/phrases/frequency_phrases.dart';
import 'package:padlock_app/data/phrases/manner_phrases.dart';
import 'package:padlock_app/data/phrases/phrase_classification.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/predicate/predicate_paths.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/engine/configuration_compass.dart';
import 'package:padlock_app/engine/configuration_engine.dart';

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

      expect(places.map((classification) => classification.label), [
        'home',
        'work',
        'school',
        'university',
        'Poland',
        'Europe',
        'office',
        'park',
        'garden',
        'kitchen',
        'bathroom',
        'bedroom',
        'living room',
        'restaurant',
        'hospital',
        'shop',
        'bridge',
        'table',
        'bed',
      ]);
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
  });
}
