import 'package:padlock_app/data/predicate/fixed_object_frames.dart';
import 'package:padlock_app/data/predicate/predicate_paths.dart';
import 'package:padlock_app/data/predicate/right_action_frames.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/phrase/place_phrase.dart';

void main() {
  final problems = <String>[];

  for (final unlocks in guidedPredicateUnlocks) {
    for (final path in unlocks.paths) {
      final reason = '${unlocks.verb.infinitive} ${path.kind}';
      switch (path.kind) {
        case PredicatePathKind.directObject:
          if (!unlocks.verb.takesObject) problems.add(reason);
          if (hasFixedObjectFrame(unlocks.verb)) {
            for (final noun in path.nouns) {
              if (!fixedObjectFitsAction(noun, unlocks.verb)) {
                problems.add('$reason -> ${noun.text}');
              }
            }
          }
        case PredicatePathKind.toRightAction:
          if (!hasRightActionFrame(unlocks.verb)) problems.add(reason);
          for (final rightAction in path.verbs) {
            if (!rightActionFitsAction(rightAction, unlocks.verb)) {
              problems.add('$reason -> ${rightAction.infinitive}');
            }
          }
        case PredicatePathKind.toRecipient:
          if (!unlocks.verb.takesRecipient) problems.add(reason);
        case PredicatePathKind.toAddressee:
          if (!unlocks.verb.takesAddressee) problems.add(reason);
        case PredicatePathKind.withCompanion:
          if (!unlocks.verb.takesCompanion) problems.add(reason);
        case PredicatePathKind.withInstrument:
          if (!unlocks.verb.takesInstrument) problems.add(reason);
        case PredicatePathKind.toDestination:
          if (!unlocks.verb.usesDestinationPlace) problems.add(reason);
        case PredicatePathKind.aboutTopic:
        case PredicatePathKind.ofTopic:
        case PredicatePathKind.onTopic:
        case PredicatePathKind.overTopic:
        case PredicatePathKind.withTopic:
          if (!unlocks.verb.takesTopic) problems.add(reason);
        case PredicatePathKind.forBeneficiary:
          if (!unlocks.verb.takesBeneficiary) problems.add(reason);
        case PredicatePathKind.fromSource:
          if (!unlocks.verb.takesSource) problems.add(reason);
        case PredicatePathKind.forPurpose:
          if (!unlocks.verb.takesPurpose) problems.add(reason);
        case PredicatePathKind.atLocation:
          _expectPlacePrefix(problems, reason, path.places, 'at ');
        case PredicatePathKind.inLocation:
          _expectPlacePrefix(problems, reason, path.places, 'in ');
        case PredicatePathKind.onLocation:
          _expectPlacePrefix(problems, reason, path.places, 'on ');
        case PredicatePathKind.fromLocation:
          _expectSourcePrefix(problems, reason, path.places, 'from ');
        case PredicatePathKind.placePhrase:
        case PredicatePathKind.timePhrase:
        case PredicatePathKind.frequencyPhrase:
        case PredicatePathKind.mannerPhrase:
        case PredicatePathKind.rightParticle:
          break;
      }
    }
  }

  print('predicate structural law audit');
  print('problems: ${problems.length}');
  for (final problem in problems) {
    print('- $problem');
  }
}

void _expectPlacePrefix(
  List<String> problems,
  String reason,
  List<PlacePhrase> places,
  String prefix,
) {
  for (final place in places) {
    final surface = place.render(PlaceMeaning.location);
    if (!surface.startsWith(prefix)) {
      problems.add('$reason -> $surface');
    }
  }
}

void _expectSourcePrefix(
  List<String> problems,
  String reason,
  List<PlacePhrase> places,
  String prefix,
) {
  for (final place in places) {
    final surface = place.render(PlaceMeaning.source);
    if (!surface.startsWith(prefix)) {
      problems.add('$reason -> $surface');
    }
  }
}
