import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart'
    as fixed_object;
import 'package:padlock_app/data/subjects/third_person/animal_categories.dart'
    as animal_categories;
import 'package:padlock_app/data/subjects/third_person/object_categories.dart'
    as object_categories;
import 'package:padlock_app/data/subjects/third_person/people_categories.dart'
    as people_categories;
import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';

enum PredicatePathMode { authoredTracks, legacyCompassFallback }

enum PredicatePathReadiness { seeded, pendingHandAuthored }

enum PredicatePathKind {
  directObject,
  toRightAction,
  toAddressee,
  withCompanion,
  toDestination,
}

class PredicatePath {
  final PredicatePathKind kind;
  final List<NounPhrase> nouns;
  final List<Verb> verbs;

  const PredicatePath._({
    required this.kind,
    this.nouns = const [],
    this.verbs = const [],
  });

  const PredicatePath.directObject(List<NounPhrase> nouns)
    : this._(kind: PredicatePathKind.directObject, nouns: nouns);

  const PredicatePath.toRightAction(List<Verb> verbs)
    : this._(kind: PredicatePathKind.toRightAction, verbs: verbs);

  const PredicatePath.toAddressee(List<NounPhrase> nouns)
    : this._(kind: PredicatePathKind.toAddressee, nouns: nouns);

  const PredicatePath.withCompanion(List<NounPhrase> nouns)
    : this._(kind: PredicatePathKind.withCompanion, nouns: nouns);

  const PredicatePath.toDestination(List<NounPhrase> nouns)
    : this._(kind: PredicatePathKind.toDestination, nouns: nouns);
}

class PredicateUnlocks {
  final Verb verb;
  final List<PredicatePath> paths;

  const PredicateUnlocks({required this.verb, required this.paths});
}

class PredicatePathMigrationDecision {
  final Verb verb;
  final PredicatePathReadiness readiness;
  final String note;

  const PredicatePathMigrationDecision({
    required this.verb,
    required this.readiness,
    required this.note,
  });
}

List<NounPhrase> _uniqueByText(List<NounPhrase> nouns) {
  final seen = <String>{};

  return [
    for (final noun in nouns)
      if (seen.add(noun.text.toLowerCase())) noun,
  ];
}

final _people = people_categories.singularEverydayPeople;
final _peopleAndAnimals = _uniqueByText([
  ...people_categories.singularEverydayPeople,
  ...animal_categories.singularEverydayAnimals,
]);
final _textObjects = object_categories.singularTextObjects;

final guidedPredicateUnlocks = [
  PredicateUnlocks(
    verb: learn,
    paths: [
      PredicatePath.directObject([
        fixed_object.english,
        fixed_object.grammar,
        fixed_object.history,
      ]),
      PredicatePath.toRightAction([speak, swim, work]),
      PredicatePath.withCompanion(_people),
    ],
  ),
  PredicateUnlocks(
    verb: talk,
    paths: [
      PredicatePath.toAddressee(_peopleAndAnimals),
      PredicatePath.withCompanion(_people),
    ],
  ),
  PredicateUnlocks(
    verb: write,
    paths: [
      PredicatePath.directObject(_textObjects),
      PredicatePath.toAddressee(_people),
      PredicatePath.withCompanion(_people),
    ],
  ),
  PredicateUnlocks(
    verb: go,
    paths: [
      PredicatePath.toDestination(_people),
      PredicatePath.withCompanion(_people),
    ],
  ),
];

final essentialPredicatePathMigration = [
  PredicatePathMigrationDecision(
    verb: be,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author noun, adjective, place, and companion complement tracks',
  ),
  PredicatePathMigrationDecision(
    verb: have,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author possession object tracks',
  ),
  PredicatePathMigrationDecision(
    verb: doVerb,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'decide whether do is product-visible or structural only',
  ),
  PredicatePathMigrationDecision(
    verb: findVerb,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author findable object tracks',
  ),
  PredicatePathMigrationDecision(
    verb: sing,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author song/performance and companion tracks',
  ),
  PredicatePathMigrationDecision(
    verb: breakVerb,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author breakable object tracks',
  ),
  PredicatePathMigrationDecision(
    verb: begin,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'likely right-action track candidate',
  ),
  PredicatePathMigrationDecision(
    verb: go,
    readiness: PredicatePathReadiness.seeded,
    note: 'seeded destination and companion tracks',
  ),
  PredicatePathMigrationDecision(
    verb: come,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author destination and companion tracks',
  ),
  PredicatePathMigrationDecision(
    verb: get,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author obtainable object tracks',
  ),
  PredicatePathMigrationDecision(
    verb: make,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object, recipient, and object-complement tracks',
  ),
  PredicatePathMigrationDecision(
    verb: take,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author takeable object tracks',
  ),
  PredicatePathMigrationDecision(
    verb: give,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object and recipient tracks',
  ),
  PredicatePathMigrationDecision(
    verb: know,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author knowable object/topic tracks',
  ),
  PredicatePathMigrationDecision(
    verb: think,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'decide topic/right-action tracks',
  ),
  PredicatePathMigrationDecision(
    verb: say,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'decide speech object/addressee tracks',
  ),
  PredicatePathMigrationDecision(
    verb: see,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author visible object tracks',
  ),
  PredicatePathMigrationDecision(
    verb: want,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object and right-action tracks',
  ),
  PredicatePathMigrationDecision(
    verb: need,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object and right-action tracks',
  ),
  PredicatePathMigrationDecision(
    verb: like,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object and right-action tracks',
  ),
  PredicatePathMigrationDecision(
    verb: love,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object and right-action tracks',
  ),
  PredicatePathMigrationDecision(
    verb: work,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author companion, place, time, and manner tracks',
  ),
  PredicatePathMigrationDecision(
    verb: play,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author activity, music, game, and companion tracks',
  ),
  PredicatePathMigrationDecision(
    verb: learn,
    readiness: PredicatePathReadiness.seeded,
    note: 'seeded subject, right-action, and companion tracks',
  ),
  PredicatePathMigrationDecision(
    verb: sleep,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author place, time, and manner tracks',
  ),
  PredicatePathMigrationDecision(
    verb: remember,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object and right-action tracks',
  ),
  PredicatePathMigrationDecision(
    verb: hate,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object and right-action tracks',
  ),
  PredicatePathMigrationDecision(
    verb: meet,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author people/object tracks',
  ),
  PredicatePathMigrationDecision(
    verb: use,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author tool object tracks',
  ),
  PredicatePathMigrationDecision(
    verb: open,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author openable object tracks',
  ),
  PredicatePathMigrationDecision(
    verb: close,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author openable object tracks',
  ),
  PredicatePathMigrationDecision(
    verb: help,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author person/object and right-action tracks',
  ),
  PredicatePathMigrationDecision(
    verb: buy,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object and recipient tracks',
  ),
  PredicatePathMigrationDecision(
    verb: sell,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author object and recipient/addressee tracks if supported',
  ),
  PredicatePathMigrationDecision(
    verb: read,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author text object tracks',
  ),
  PredicatePathMigrationDecision(
    verb: watch,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author media object tracks',
  ),
  PredicatePathMigrationDecision(
    verb: lose,
    readiness: PredicatePathReadiness.pendingHandAuthored,
    note: 'author losable object tracks',
  ),
];

PredicateUnlocks? predicateUnlocksFor(Verb verb) {
  for (final unlocks in guidedPredicateUnlocks) {
    if (unlocks.verb.infinitive == verb.infinitive) {
      return unlocks;
    }
  }
  return null;
}

List<PredicatePath> predicatePathsFor(Verb verb) {
  return predicateUnlocksFor(verb)?.paths ?? const [];
}

PredicatePathMigrationDecision? predicatePathMigrationFor(Verb verb) {
  for (final decision in essentialPredicatePathMigration) {
    if (decision.verb.infinitive == verb.infinitive) {
      return decision;
    }
  }
  return null;
}
