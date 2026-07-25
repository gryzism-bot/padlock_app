import 'package:padlock_app/data/phrases/frequency_phrases.dart';
import 'package:padlock_app/data/phrases/manner_phrases.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/models/grammar/phrase/frequency_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/time_phrase.dart';

enum PhraseSurfaceFamily { place, time, frequency, manner }

enum PhraseSurfaceRole { predicateBoundRoute, clauseLevelModifier }

enum PredicateRouteHint { bareDirection, location, destination, source, manner }

class CurrentPhraseClassification {
  final Object phrase;
  final String label;
  final PhraseSurfaceFamily family;
  final PhraseSurfaceRole role;
  final Set<PredicateRouteHint> routeHints;
  final String note;

  const CurrentPhraseClassification({
    required this.phrase,
    required this.label,
    required this.family,
    required this.role,
    required this.note,
    this.routeHints = const {},
  });
}

const _bareDirectionWords = {'away', 'back', 'here', 'there', 'outside'};

final currentPhraseClassifications = <CurrentPhraseClassification>[
  for (final phrase in placePhrases)
    CurrentPhraseClassification(
      phrase: phrase,
      label: phrase.noun,
      family: PhraseSurfaceFamily.place,
      role: PhraseSurfaceRole.predicateBoundRoute,
      routeHints: const {
        PredicateRouteHint.location,
        PredicateRouteHint.destination,
        PredicateRouteHint.source,
      },
      note:
          'Place choices should be exposed as verb-owned right routes in Guided Mode.',
    ),
  for (final phrase in timePhrases)
    CurrentPhraseClassification(
      phrase: phrase,
      label: phrase.text,
      family: PhraseSurfaceFamily.time,
      role: PhraseSurfaceRole.clauseLevelModifier,
      note:
          'Current time choices modify the clause; verb-bound time routes can be added separately later.',
    ),
  for (final phrase in frequencyPhrases)
    CurrentPhraseClassification(
      phrase: phrase,
      label: phrase.text,
      family: PhraseSurfaceFamily.frequency,
      role: PhraseSurfaceRole.clauseLevelModifier,
      note:
          'Current frequency choices modify the clause rather than completing one verb route.',
    ),
  for (final phrase in mannerPhrases)
    CurrentPhraseClassification(
      phrase: phrase,
      label: phrase.text,
      family: PhraseSurfaceFamily.manner,
      role: PhraseSurfaceRole.predicateBoundRoute,
      routeHints: {
        if (_bareDirectionWords.contains(phrase.text))
          PredicateRouteHint.bareDirection
        else
          PredicateRouteHint.manner,
      },
      note:
          'Current manner choices should be authored per predicate before product Guided Mode exposes them.',
    ),
];

CurrentPhraseClassification? currentPhraseClassificationFor(Object phrase) {
  for (final classification in currentPhraseClassifications) {
    if (identical(classification.phrase, phrase)) {
      return classification;
    }
  }

  return null;
}

List<CurrentPhraseClassification> currentPhraseClassificationsForRole(
  PhraseSurfaceRole role,
) {
  return [
    for (final classification in currentPhraseClassifications)
      if (classification.role == role) classification,
  ];
}

List<CurrentPhraseClassification> currentPhraseClassificationsForFamily(
  PhraseSurfaceFamily family,
) {
  return [
    for (final classification in currentPhraseClassifications)
      if (classification.family == family) classification,
  ];
}

bool isClauseLevelModifier(Object phrase) {
  return currentPhraseClassificationFor(phrase)?.role ==
      PhraseSurfaceRole.clauseLevelModifier;
}

final clauseLevelTimePhrases = <TimePhrase>[
  for (final classification in currentPhraseClassifications)
    if (classification.family == PhraseSurfaceFamily.time &&
        classification.role == PhraseSurfaceRole.clauseLevelModifier)
      classification.phrase as TimePhrase,
];

final clauseLevelFrequencyPhrases = <FrequencyPhrase>[
  for (final classification in currentPhraseClassifications)
    if (classification.family == PhraseSurfaceFamily.frequency &&
        classification.role == PhraseSurfaceRole.clauseLevelModifier)
      classification.phrase as FrequencyPhrase,
];
