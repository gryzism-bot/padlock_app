# Padlock Backlog

This file keeps the work discovered while testing the live machine. It is
ordered from the deepest crease upward:

1. Grammar and Recognition: sentence form and parse shape.
2. Configuration Engine / Lock: hard validity of a `SentenceState`.
3. Configuration Compass: reachable next moves and ranking.
4. Semantic C-section: meaning and world-fit.
5. UI: how the machine exposes those choices.

## Feature Surface Map

UI is not equal to features. UI is the surface where implemented features become
reachable, understandable, and testable.

## Sorted Next Moves

Use this when the side quests start competing for attention.

Best low-effort / high-value moves for the developer cockpit:

1. Done: avoid full preview rendering in `word` mode.
   - word chips now render labels directly
   - full sentence previews stay available for sentence/change modes
   - this sharpens the current testing UI without changing grammar laws
2. Done: cache rendered preview sentences for one build pass.
   - key: `SentenceState` or a stable state signature
   - target: repeated `GrammarEngine.generate` calls while rendering nearby
     suggestions
   - value: likely visible in verb/object/phrase rails
3. Done: make large rails unrestricted but lazy.
   - no `show more` gate in the product feeling
   - keep choices scrollable like faces on a physical object
   - large rails now hydrate chips progressively instead of blocking the whole
     frame
   - value: vocabulary can grow while still feeling like a physical word table
4. Done: virtualize large rail bodies.
   - large rails now use builder-backed viewport rendering instead of keeping
     every chip alive as a widget
   - small rails still render as simple wraps
   - rail-local search stays the way to summon late vocabulary immediately
   - value: another visible cut in verb-click render time and better alignment
     with the final combination-padlock UI
5. Done: add a configuration nightly runner.
   - no Flutter or Chrome
   - walk Compass-visible moves and Lock responses
   - output markdown/jsonl evidence for missing laws and stale paths
6. Done: make the developer console presentation-safe enough for data growth.
   - dark mode is the default
   - the top title moved into the footer to save vertical space
   - sentence preview, control deck, core participant surface, and verb rail can
     stay fixed while vocabulary rails scroll
   - large rails are virtualized with natural chip sizing
   - diagnostics remain available without repainting the whole cockpit
   - current manual timing target is roughly sub-1000 ms for dense states and
     around 400-700 ms for ordinary verb switching
7. Current: finish essential PredicatePath authoring.
   - the route-kind architecture is broad enough now; the best value is
     handwriting the remaining verb-owned shelves
   - done: generic direct-object shelf now feeds multiple object-taking verbs:
     `something`, `anything`, `nothing`, `everything`, `it`, `this`, `that`
     are shared by broad object routes instead of living only under `do`
   - done: `have` now has deeper authored routes:
     `have anything`, `have it`, `have something from someone`,
     `have something for someone`, `have money for school/fun`, and
     semi-modal `have to + verb`
   - done: `get` now has object-gated source, beneficiary, and purpose routes:
     `get something from someone`, `get something for someone`,
     `get money for school`, and `get something for fun`
   - done: `make` now has a make-specific object shelf and object-gated
     `for` routes:
     `make something for John`, `make a cake for Mary`,
     `make a gift for her`, `make a plan for work`,
     `make food for dinner`, and `make something for fun`
   - use the executable review sheet to find thin verbs instead of guessing
   - prioritize verbs that are common, visible, and memorable:
     `be`, `have`, `do`, `find`, `sing`, `break`, `come`, `get`, `make`,
     `think`, `say`, `see`, `play`, `work`, `sleep`
   - this is the biggest current slice of "fly territory": it makes the app
     feel intentional instead of random without touching Grammar Engine
8. Next: staged vocabulary saturation.
   - recent performance work makes this much less risky:
     - large rails are virtualized
     - rail-local search can summon late vocabulary
     - preview rendering is cached and bounded near visible choices
     - closed rails no longer compute full suggestion bodies
   - saturation should follow noun atomization:
     - show base nouns first: `friend`, `enemy`, `cat`, `dog`
     - use determiner/adjective rails for `a friend`, `my friend`,
       `that enemy`, `young dog`
     - keep true pronoun-like words as complete noun phrases:
       `someone`, `anyone`, `nobody`, `everyone`
   - saturate in layers, checking move-trace timing after each:
     - people, animals, pronoun-like nouns
     - everyday objects and food/tool/openable/text shelves
     - adjectives and simple adverbs
     - verb-owned PredicatePath vocabulary
     - Polish translation fragments
   - target cockpit feel while saturating:
     - ordinary verb switches stay around 400-600 ms
     - occasional heavy first-open rails are acceptable if search and scrolling
       stay responsive
9. Continue: route-audit tooling.
   - route kinds now exist for the important right-side families:
     - direct object
     - recipient / addressee
     - companion
     - instrument
     - destination
     - source
     - topic: `about`, `of`, `on`, `with`
     - purpose: `for`
     - location: `at`, `in`, `on`, `from`
     - right action: `to + verb`
   - remaining work is mostly verb-by-verb authorship and vocabulary shelves,
     not new route-kind architecture
   - explicit pending review rows are currently closed
10. Later: path-scoped Compass for the product UI.
   - one active locus at a time
   - opening a verb feature narrows the tree until collapsed
   - this is the bigger design payoff, but it is not the cheapest next step

Postpone for now:

- broad semantic blockers such as `eat street`
- semi-modal / right-side verb frames such as `have to go`
- browser/UI nightly automation
- deeper browser/runtime profiling, unless the current 400-600 ms cockpit feel
  stops holding during staged vocabulary saturation
- Match Mode / Guess The Sentence, until the authored Guided Mode web feels
  dense enough to be worth guessing through

## Presentation Mode: Guess The Sentence

Goal:

Make the first public play session memorable without explaining the whole
machine in a tutorial reel.

Core loop:

1. Pick a valid target `SentenceState` from a curated deck.
2. Render the target sentence.
3. Start the player from a simple sentence such as `You learn.`
4. Let the player use the same Guided Mode controls to transform the current
   sentence.
5. Show remaining moves by comparing normalized state fields.
6. Mark the sentence solved when current state matches the target state.

First implementation:

- use a curated target list, not random generation
- compute remaining moves with a field-distance helper:
  - subject
  - action
  - object and object modifiers
  - recipient/addressee/companion/instrument/destination/topic/source/purpose
  - right action
  - tense/aspect/modal/polarity/form/voice/passive focus
- show matched fields subtly in the current developer console
- add tests for:
  - exact match gives zero remaining moves
  - changing only tense is one remaining move
  - changing `You learn.` toward `Mary brought a book to John.` reports the
    expected missing fields
  - a solved target survives Grammar render and Recognition round trip

Why this is presentation-ready:

- it lets the app speak through play
- it turns `SentenceState` into a visible puzzle
- it demonstrates the one-predicate machine without requiring a lecture
- it can later become the first polished product mode while the developer
  console remains the workbench

## Presentation Side Quest: Idiom Hunting

Idea:

Review authored verb routes for idiom-capable combinations. When the user builds
one naturally, show a small celebratory note such as `idiom found`.

Examples to hunt later:

- `get over it`
- `make up`
- `take off`
- `look for`
- `run into`
- `give up`

Implementation notes:

- keep this as a detection layer over valid `SentenceState` / PredicatePath
  output, not as a replacement for grammar
- start with a curated idiom list, then expand from playtesting
- notification should be subtle and educational, separate from Lock alerts

## Executable Review Audit

The essential verb review sheet is now executable through
`test/configuration/predicate_paths_test.dart`.

Current audit shape:

- the review sheet is executable through route assertions
- reviewed rows are increasingly executable, but the important signal is now
  "thin verb" coverage rather than missing route kinds
- recently closed review rows:
  - `hate` + companion
  - `help` + with-topic (`help with homework/problem/question`)
  - `teach` right-action routes are recipient-gated:
    `You teach Mary to speak.`, not bare `You teach to speak.`
  - `take` / `bring` can move an object to a person:
    `You take a book to Mary.`, `Mary brought a book to John.`
  - `do` is now product-visible instead of structural-only:
    `do something`, `do it`, `do homework`, `do this for Mary`,
    `do homework for school`, `do carefully/again`, `do at home`
- recently implemented route families include:
  - atomized location routes: `at`, `in`, `on`
  - source-place routes: `from`
  - topic routes: `about`, `of`, `on`
  - with-topic routes for content-like help surfaces
  - instrument `with`, separate from companion `with`
  - purpose `for`
  - object-dependent destination:
    - `You take a book to Mary.`
    - `Mary brought a book to John.`

Interpretation:

- Most future missing rows will be missing data or missing authored
  `PredicatePath` entries,
  not missing Grammar Engine logic.
- The important route kinds now exist; new work should usually start by adding
  data to a verb-owned path rather than adding a new engine law.
- `at`, `in`, `on`, and `from` are now atomized as verb-owned location routes,
  compiled back into the existing `PlacePhrase` surface for Grammar Engine.
- Recent shelf items covered by that migration:
  - `You find in the room.`
  - `You work in IT.`
  - `You sleep in bed.`

Constraint sorting for PredicatePaths:

1. Near-universal clause modifiers:
   - time: `today`, `now`, `at night`
   - frequency: `often`, `sometimes`, `every day`
   - manner: `quickly`, `carefully`, `well`
   - broad location: `at school`, `at home`, `in the office`
   - these are mostly Compass ranking / semantic C-section work
2. Structural verb frames:
   - direct object: `read a book`
   - recipient: `give Mary a book`, `give a book to Mary`
   - addressee: `speak to Mary`
   - companion: `learn with Mary`
   - destination/source: `go to school`, `learn from Mary`
   - beneficiary: `buy a book for Mary`
   - right action: `learn to speak`
   - these belong in verb-owned PredicatePaths and shared frame metadata
3. Verb-owned semantic rails:
   - `play` wakes sports/games/music
   - `learn` wakes languages/subjects/skills
   - `read/write` wake text
   - `use` wakes tools
   - `open/close` wake openable objects
   - these are handcrafted Guided Mode data
4. Special lexical frames:
   - lexical `be`: noun/adjective/place/source/companion complement
   - object complement verbs: `make him calm`, `call him a teacher`
   - these are structural and should remain explicit

Next audit actions:

- keep the executable review sheet current as new verbs/routes are added
- done: add an audit helper/tool that lists verbs by route count:
  - no-carets / no authored paths
  - one-route verbs
  - highly connected verbs
  - recipient-gated right-action verbs
  - command: `dart run tool/audit_predicate_influences.dart`
- latest route-audit signal:
  - done: `analyze` now has authored object/topic/instrument/purpose/context
    routes
  - done: `need` now has object-gated source/beneficiary/purpose routes
  - done: `do` now has authored object/companion/beneficiary/purpose/location/
    manner/time routes
  - still expected: recipient-gated right action: `teach`
  - no one-route verbs remain
  - no thin essential verbs remain
- keep pending rows rare: either implement the route, add the shelf, or
  document a deliberate semantic postponement
- start saturation with verb-owned shelves before broad noun flooding:
  - more useful objects for `bring`, `take`, `give`, `buy`, `sell`
  - richer study/learn/read/write topic and text shelves
  - people/animal/person-like noun shelves for companion, source, addressee,
    and destination
- keep shrinking broad phrase pressure as predicate-bound routes are migrated

Recently completed:

- deepened `need`:
  - it is an essential verb
  - it is common and learner-facing
  - it already has the correct right-action crease
  - it now has richer object/source/beneficiary/purpose shelves:
    `need help`, `need money`, `need a book`, `need help from Mary`,
    `need a tool for work`
- seeded `analyze`:
  - it is the only currently unauthored verb in the full audit
  - it now wakes objects/topics, instruments, and purpose/context:
    `analyze data`, `analyze a problem`, `analyze with a computer`,
    `analyze for work`, `analyze at school`

Best immediate follow-up:

- rerun the route audit and choose the next thin/empty predicate edge from
  executable data rather than guessing
- continue essential PredicatePath saturation toward verbs with few distinct
  right-side surfaces

## Noun Atomization Before Saturation

Observation:

The noun model already has the correct lower crease:

- `Noun` stores singular/plural forms and translations.
- `Noun.toNounPhrase(...)` builds a `NounPhrase`.
- `NounPhrase` can carry determiner and adjective data.

The problem is higher up: some UI-facing shelves expose pre-baked noun phrases
such as `a friend`, `my friend`, `our friend`, and `that enemy` directly beside
atomic nouns such as `cat`, `dog`, `John`, and `Mary`.

Guiding law:

If a word is a noun, expose the noun as the noun choice. If a word changes the
noun, expose it through a modifier rail.

Keep as complete noun phrases:

- pronouns: `I`, `you`, `he`, `she`, `it`, `we`, `they`
- object pronouns: `me`, `him`, `her`, `us`, `them`
- reflexives: `myself`, `herself`, `themselves`
- indefinite pronoun-like nouns: `someone`, `anyone`, `nobody`, `everyone`

Move out of direct noun shelves:

- `a friend` -> noun `friend` plus determiner `a`
- `my friend` -> noun `friend` plus determiner `my`
- `our friend` -> noun `friend` plus determiner `our`
- `that enemy` -> noun `enemy` plus determiner `that`

Why this comes before saturation:

- it prevents duplicate chips as vocabulary grows
- it makes singular/plural switching cleaner
- it keeps noun, determiner, and adjective lessons visible
- it aligns noun data with the recent phrase refactor:
  atomized choices in Guided Mode, rendered surfaces in Grammar Engine

Likely implementation:

- keep `Noun` and `NounPhrase` model shapes
- create noun shelf helpers that return bare noun phrases only
- create separate curated modifier presets only for demo/Match Mode targets,
  not for ordinary noun choice rails
- adjust subject/object/recipient/addressee/companion/source/destination rails
  to prefer bare nouns, then use their existing determiner/adjective rails
- add regression tests proving:
  - subject noun shelves show `friend`, not `a friend`
  - determiner rail can produce `a friend`, `my friend`, and `that enemy`
  - pronoun-like words remain one-click choices
  - plural switch preserves noun identity without duplicating determiner chips

## Night Configuration Run Takeaways

Latest 6-hour render run:

- guided moves accepted: 18,505,171
- direct law probe attempts: 737,315,475
- Compass leaks: 0
- render failures: 0
- Compass collection average: 0.99 ms
- Lock/render transition average: 0.03 ms

Interpretation:

- The current Compass -> Lock -> Grammar render route is stable.
- Candidate law output is not a failure list. Most rows are direct probes
  intentionally asking impossible questions such as "does this verb take an
  object?" or "can passive focus exist in active voice?"
- The useful signal is where a blocked probe looks like a sentence the product
  should eventually support.

Candidate-law sorting from the run:

1. Already-solid structural guardrails:
   - active voice requires an agent
   - passive focus belongs to passive voice
   - passive agent visibility belongs to passive voice
   - passive object focus requires an object
   - imperatives are present-simple and modal-free
   - pronouns do not take determiners/adjectives
   - noun determiners must match number and article sound
2. Verb-frame facts that should stay explicit:
   - many verbs do not take objects, recipients, addressees, companions,
     destinations, sources, topics, complements, or right actions
   - fixed object shelves are working:
     - `learn` only takes fixed subject/language objects
     - `read`/`write` only take fixed text objects
     - `drive` only takes vehicles
     - `use` only takes tools
     - `open`/`close` only take openable objects
     - `play` only takes fixed activity objects
3. Product-route candidates surfaced by the probes, now mostly implemented:
   - source-place route family:
     - `go from work`
     - `come from school`
     - `leave from home`
     - `return from the office`
   - on-topic/object route family:
     - `work on grammar`
     - `think of Mary`
     - `think about something`
   - instrument route family:
     - `open with a key`
     - `write with a pen`
     - `cut with a knife`
   - verb data review:
     - `photograph` probably should take visual objects
     - some activity verbs such as `box`/`wrestle` may need opponent or
       companion routes rather than broad object routes
4. Semantic C-section candidates, not lower grammar bugs:
   - odd food/object combinations such as boiling bridges
   - odd lexical `be` plus time combinations
   - doubled path feel where broad phrases stack on top of authored routes
   - adjective stacking/order restraint

Backlog additions from this run:

- done: source-place PredicatePaths exist before adding more broad place data
- done: `onTopic` / `ofTopic` topic-object routes exist, separate from
  `onLocation`
- done: instrument `with` exists, separate from companion `with`
- next: deepen the authored data behind those route families rather than adding
  broad phrase bags back into Guided Mode
- review verbs that look too narrow after probing:
  - `photograph`
  - `box`
  - `wrestle`
  - possibly `work`, `think`, `return`, `walk`, `run`, `come`, `leave`, `travel`
- add an audit section to the render runner that groups blocked probes by verb,
  so "verb needs review" becomes visible without reading raw law rows
- keep shrinking broad `placePhrase` pressure as predicate-bound routes are
  migrated

Previous 6-hour configuration run:

- guided moves accepted: 85,148,753
- direct law probe attempts: 1,117,577,405
- Compass leaks: 0
- render failures: 0
- Compass collection average: 0.18 ms
- Lock/render transition average: 0.02 ms

Conclusion:

- C-section architecture held.
- Guided state space is mechanically coherent.
- Remaining obvious problems are mostly semantic/presentation, not Lock/Compass
  correctness failures.

Tasks surfaced by samples:

- semantic object filtering:
  - avoid `You serve math.`
  - avoid food/cooking verbs with bridges, streets, schools, etc.
  - prefer food objects for `eat`, `drink`, `cook`, `boil`, `chop`
- movement/destination refinement:
  - avoid doubled path feel such as `You ski to John to the restaurant.`
  - distinguish destination person from destination place when both can exist
  - decide whether person destinations should be addressees/companions instead
- lexical `be` phrase semantics:
  - `You should be on Saturday.` is mechanically valid but semantically odd
  - time phrases with lexical `be` need a narrower rule or lower ranking
- adjective stacking and order restraint:
  - samples like `white blue key` show that multiple adjectives need semantic
    or UI-side restraint before presentation
- right-side non-finite action remains the stronger presentation feature:
  - it expands what the machine can say
  - semantic filtering mostly removes wrongness

Use this map when deciding whether a feature is truly done:

| Feature | Grammar | Recognition | Lock | Compass | UI |
| --- | --- | --- | --- | --- | --- |
| lexical `be` noun complement | yes | yes | yes | yes | yes |
| lexical `be` adjective complement | yes | yes | yes | yes | yes |
| lexical `be` place/source complement | yes | yes | yes | partial | partial |
| companion surface | yes | yes | yes | yes | partial |
| destination/addressee surface | yes | yes | yes | yes | partial |
| recipient before object | yes | yes | yes | yes | partial |
| recipient with `to`/`for` | yes | yes | yes | partial | partial |
| fixed predicate objects | yes | yes | yes | yes | yes |
| object/recipient determiner exits | yes | yes | yes | yes | needs polish |
| semantic fit such as `eat food` over `eat street` | no | no | planned | planned | no |

If a row is green through old engines but partial in UI, it is not a grammar
gap. It is a feature-surfacing gap.

## Boundary Check: Laws That May Belong Lower

Configuration Engine is mostly holding the right kind of laws. It blocks states
from being reachable in Guided Mode. Grammar Engine should not become another
Configuration Engine.

Still, a few Lock laws are close enough to Grammar and Recognition that they
should eventually be extracted into shared predicate-frame facts, then consumed
by all three old engines:

- lexical `be` frame:
  - active-only
  - requires an agent
  - can carry noun or adjective complement
  - cannot carry object, recipient, passive focus, or passive agent visibility
- passive frame:
  - passive requires an object-capable verb
  - object focus requires object
  - recipient focus requires recipient, object, and recipient-capable verb
- recipient frame:
  - recipient-capable verbs must also be object-capable
  - active recipient requires an object
  - recipient placement and preposition belong to participant surface
- noun phrase surface:
  - determiner number and article sound rules affect whether a phrase is
    renderable as good app-English, even if they are currently Lock laws

Recommendation:

- Keep blocking in Configuration Engine.
- Add or keep debug asserts in Grammar Engine for impossible frames.
- Keep Recognition parsing app-English into the same explicit fields.
- Extract shared frame metadata only when duplication starts causing drift.

## Core Participant Surface

Goal:

Make the one-predicate participant surface expressive before expanding semantic
rails.

Done recently:

- active double-object recipient:
  `John gave Mary a book.`
- active prepositional recipient:
  `John gave a book to Mary.`
- active beneficiary recipient:
  `John bought a book for Mary.`
- passive object focus with recipient phrase:
  `A book was given to Mary by John.`
- passive beneficiary phrase:
  `A book was bought for Mary by John.`
- passive recipient focus:
  `Mary was given a book by John.`
- object-case pronouns in participant phrases:
  `to him`, `for her`, `by me`
- reflexive participant pronouns:
  `myself`, `yourself`, `himself`, `herself`, `itself`, `ourselves`,
  `yourselves`, `themselves`

Remaining crease candidates:

- participant identity law after reflexive surface:
  - decide whether Guided Mode transforms `You gave you a book.` into
    `You gave yourself a book.`
  - flag suspicious same-participant passive states such as
    `A book was given to you by you.`
- object complement:
  - `They made him angry.`
  - `I painted the door red.`
  - `They elected her president.`
- lexical `be` phrase complements:
  - done for place/location/source:
    - `He is at school.`
    - `She is from Poland.`
  - done for companion surface:
    - `They are with Mary.`
- verb-bound prepositional participants:
  - `run to school`
  - `speak to Mary`
  - `speak with Mary`
  - `learn with a teacher`
- phrasal/particle slot, postponed until the frame is clearer:
  - `wake up`
  - `turn on`
  - `look after`

## Right-Side Verb Expansion

Live UI testing is showing a need for more expressive material to the right of
the chosen predicate. These features all use another verb-like word, but they do
not all belong to the same crease.

Architectural rule:

- the sentence still has one finite predicate
- `action` remains the tense/person/aspect/modal-bearing verb
- the added verb is inferior:
  - no tense
  - no subject agreement
  - no modal stack of its own
  - rendered as a non-finite right-side action such as `to go`
- this is not a second predicate in the Padlock machine; it is another surface
  unlocked by the predicate

Implemented first model:

- `rightAction` exists on `SentenceState`
- right actions are compiled from PredicatePaths
- Grammar, Recognition, Lock, Compass, and the developer console can carry
  `to + bare verb` surfaces
- verb-data frame facts can now say:
  - `want` wakes `to` action complement
  - `try` wakes `to` action complement
  - `need` wakes `to` action complement
  - `like` / `love` can wake `to` action complement
  - `learn` wakes skill/action complement
- keep choices verb-bound and data-driven, just like fixed object frames and
  participant rails

Covered first wow target:

- `I want to go.`
- `You try to learn.`
- `She needs to work.`
- `They like to swim.`
- `You learn to speak.`
- `I want to watch Netflix.`

Remaining order from safest to most expansive:

1. semi-modal `to` frames:
   - `I have to go to school.`
   - `I need to learn English.`
   - `He has to work.`
   - `They needed to leave.`
   - likely model: the real action stays in `action`, and the wrapper is a new
     modal-like frame such as `semiModal: haveTo`
   - this is closest to the existing modal wheel, but it must conjugate like a
     normal verb and support DO questions/negatives:
     `Does he have to go?`, `He does not have to go.`
2. ability/permission/expectation frames:
   - `He is able to go.`
   - `He is allowed to go.`
   - `He is supposed to go.`
   - likely a separate subtype of the same semi-modal surface because these use
     lexical `be` plus adjective/participle plus `to`
3. purpose infinitives:
   - `He walks to exercise.`
   - `I run to forget.`
   - `I listen to visualize.`
   - `I sleep to recover.`
   - likely model: `action: walk`, `purposeAction: exercise`
   - this is still one finite sentence, but it is less strictly one-predicate
     because the purpose slot contains another action

Implementation notes:

- Do not merge these directly into normal `Modal` unless the verb-chain rules
  prove identical. They are not identical: `should go`, but `have to go`.
- Keep `rightAction` as the plain inferior verb slot until the next role truly
  needs another field.
- Add new tests first when the next role begins:
  - semi-modal: `Does he have to go?`, `He does not have to go.`
  - purpose: `He walks to exercise.`
  - ability frame: `He is able to go.`
- Semantic filtering remains important, but it mostly removes wrongness. This
  crease expands what the machine can say.

## Grammar And Recognition Test Growth

Keep adding tests before or beside each crease.

Targets:

- grammar tests for every new participant surface
- recognition tests for the same surface
- two-way tests for canonical examples
- night contract seeds for each new frame
- negative or skipped examples when the sentence is valid English but outside
  the current one-predicate machine

Useful examples:

- `He gave a book to her.`
- `He bought a book for her.`
- `A book was bought for her by him.`
- `Mary was given a book by John.`
- `You taught yourself English.`
- `They made him calm.`
- `She is at school.`

## Configuration Engine / Lock Work

These are hard state-space laws. A blocked move leaves the previous sentence
active.

Known solid laws:

- active voice requires an agent
- active object requires object-capable verb
- active recipient requires recipient-capable verb and object
- passive voice requires object-capable verb
- passive focus belongs only to passive voice
- lexical `be` is active-only and complement-only
- modal and tense frames must agree
- imperatives are present-simple, active, and modal-free
- noun phrase determiners must fit number and current article sound rules

Potential next laws:

- ConfigurationEngine law-table comb-down:
  - `_validate(...)` is healthy but still a large readable if-tree
  - extract repeated "if law is broken, add this category/message" shapes into
    stable `ConfigurationLaw` / `LawCheck` data
  - this should feed both developer diagnostics and educational alerts from the
    same source
- participant identity/reflexive law:
  same participant in agent/object or agent/recipient should be transformed,
  blocked, or explained
- participant role case law:
  object-case pronouns must stay in object/recipient/passive-agent roles
- object-complement frame law:
  only selected verbs can take object complements
- lexical `be` phrase-complement law:
  only `be` can take location/source/with complements
- phrase conflict law:
  time/place/frequency/manner phrases should not fight each other when the
  conflict is grammatical enough to be a Lock issue

## Configuration Compass Work

Compass answers: what paths are available from here, and which should be near?

Current direction:

- selected options stay visible and highlighted
- special frames keep exits visible
- visible suggestions must pass the Lock
- verb chips can indicate rails they wake
- rails can be collapsed and expanded after the verb wakes them

Next Compass side quests:

- keep current verb exits visible from every special frame
- Done: mode policy for incompatible verb-switch tails:
  - example discovered in UI:
    `You learn to speak with me.` narrowed the verb list until `to speak` was
    cleared
  - Guided Mode switches verb and removes incompatible right-action, companion,
    recipient, object, addressee, object complement, destination, and passive
    shape as needed
  - Assisted Mode uses the same shaved preview path
  - Manual Mode keeps the harder block-with-explanation behavior
  - Explorer Mode is policy-ready to allow rough states intentionally
- show disabled-but-visible verbs in an Explorer-ish mode, with explanations
- rank object choices by verb frame
- rank recipients for recipient-capable verbs
- rank phrase choices by verb:
  - `go`, `come`, `arrive`, `leave`, `run` prefer destination/source paths
  - `speak` prefers language/person/topic paths
  - `learn`, `study`, `teach` prefer subject/school/skill paths
  - `play` prefers sport/game/music/instrument paths
- expose no/clear exits for every optional rail:
  object, recipient, complement, phrase, passive agent, passive focus
- avoid carrying stale selections into narrower verb frames when the carried
  noun no longer fits the new verb

## Semantic C-section Work

This is not Grammar Engine work. These are meaningfulness laws over otherwise
valid grammar.

### Clause Force / Semantic Polarity

The existing `Polarity` field answers whether the verb chain has grammatical
negation:

- `He buys books.`
- `He does not buy books.`

Some English words need a wider clause-level meaning check. Example:

- `Nobody buys books anymore.` is grammatically positive in the verb chain, but
  negative in clause force because `nobody` carries negation.
- `Everybody buys books anymore.` should not be offered in Guided Mode.

Candidate abstraction:

- `ClauseForce.affirmative`
- `ClauseForce.negative`

Potential sources of negative clause force:

- negative polarity: `does not`
- negative subjects: `nobody`, `no one`
- negative objects/determiners: `nothing`, `no books`
- later adverbs: `never`

First use:

- `anymore` wakes only in negative clause force:
  - `Nobody buys books anymore.`
  - `He does not buy books anymore.`
  - not `Everybody buys books anymore.`

Likely related future clause modifiers:

- `yet`: negative/question/perfect-ish contexts
- `already`: positive/perfect-ish contexts
- `ever`: question/negative/conditional-ish contexts

First semantic rails:

- `play`:
  - sports: `play volleyball`
  - games: `play chess`
  - music/instruments: `play guitar`
  - people/companions: `play with Mary`
- `speak`:
  - language: `speak English`
  - person: `speak to Mary`
  - companion/dialogue: `speak with Mary`
  - manner: `speak louder`, `speak faster`
- `learn`, `study`, `teach`:
  - school subject
  - skill
  - person/recipient
  - companion: `learn with a teacher`
  - duration/time: `study until late`
- movement verbs:
  - destination/source: `go to school`, `leave home`
  - companion: `run with Mary`
  - time/manner: `leave early`, `come quickly`

Early semantic blockers or greyed states:

- `I eat street.`
- `I drink school.`
- `He drives house.`
- `A bridge is taught to John by you.`

## UI Side Quests

These can be postponed while old-engine creases are active, but they should stay
recorded.

### UI Vocabulary

- keep chips, rails, diagnostic panels, and control cards reusable
- keep Material icons configurable from data through `SemanticIcon`
- allow asset paths later for Noun Project or hand-drawn icons
- done: use consistent icon shapes for influence types
- done: keep rail-unlock count visible without swallowing the selected verb
- done: keep verb translations available behind a developer toggle
- next: review Polish verb translations and improve number/person-sensitive
  translation fragments

### Diagnostic Body

- done: keep Language Alert and Last Moves glued above the footer
- done: make the diagnostic body collapsible while keeping the move count
  visible
- done: Language Alert shows triggered Lock laws in one panel
- each alert should keep naming its layer:
  - Lock law alert
  - Compass path alert
  - UI rail alert
- keep developer phrasing available, then later add educational phrasing from
  the same source
- done: Last Moves keeps the last 10 moves, scrolls if needed, and resets with
  the reset button
- done: random sentence records itself as a random move
- done: move trace records logic and UI timing
- done: cache size, bounded/unbounded mode, and wipe cache control live in the
  diagnostic strip
- next: make educational alert phrasing friendlier without losing developer
  detail

### Rail Interaction

- selecting a verb should not explode the whole page at once
- verbs should be selectable first, then their rails can be expanded
- hidden rails:
  - `be` wakes noun/adjective complement
  - object-capable verbs wake object
  - recipient-capable verbs wake object and recipient
  - destination verbs wake place/direction
  - fixed-object verbs wake fixed activity/object rail
- done: rail headers show connector hints such as `with`, `to`, `about`,
  `from`, `at`, and `in`
- rail headers should explain what woke them in friendlier educational language
- rail content should start inline with the title when compact
- next: keep shaving/switching behavior visible when verb changes remove
  incompatible right-side material

### Control Panel

- keep sentence preview stable at the top
- keep tense/aspect, subject, modal, voice, polarity, and form as constant
  controls above the scrollable rails
- keep the control panel flat on wide desktop
- subject grid:
  - singular: `I`, `you`, `he`, `she`, `it`
  - plural: `we`, `you`, `they`
  - third-person noun expansion stays near third-person pronouns
- modal grid should stay compact and unselectable by clicking the selected
  modal again if that becomes cleaner than a `no modal` chip
- passive focus and passive agent visibility should keep stable positions
- done: dark mode toggle exists in the diagnostic strip
- done: sentence translation can be toggled separately from verb translation

### General Performance Tweaks

Current insight:

- The current UI is a developer cockpit:
  - the top control panel is mostly grammar-law setting:
    tense, aspect, subject/person, modal, voice, polarity, sentence form
  - the lower rails are mostly vocabulary and predicate unfoldings:
    verbs, objects, recipients, complements, places, times, and semantic rails
- The final UI can be much narrower:
  - the sentence sits in the middle
  - clickable words have faint outlines
  - selecting a word opens only the local choices for that word
  - opening a verb feature temporarily locks out other verb choices until the
    feature rail is collapsed or reset
- This means performance should come from interaction shape first, then caches:
  the UI should not ask Compass to compute paths the user cannot currently
  choose.

Done recently:

- collapsed controlled rails no longer ask Compass to generate full suggestion
  lists just to render a closed rail
- diagnostics repaint no longer rebuilds the whole cockpit:
  - Move trace updates use a listenable dock repaint
  - preview cache counter updates use a listenable dock repaint
  - rail chips no longer get rebuilt just because UI timing text changed
- large rails now hydrate suggestion chips progressively:
  - verb rails paint a useful first batch, then fill the rest over following
    frames
  - object, recipient, companion, destination, and phrase rails use the same
    transparent batching
  - vocabulary stays unrestricted; there is no `show more` interaction
- true rail virtualization now handles large rail bodies:
  - big rails use a builder-backed grid viewport
  - only visible/near-visible chips are alive as widgets
  - small rails still use a normal wrap so compact controls stay simple
  - rail search is the intentional way to reach late options instantly
- closed participant rails are now decided from the current `SentenceState`
  shape, and full suggestions are generated only after the rail is expanded
- Backleg save: rail titles, wake hints, collapsed visibility, and empty-state
  rendering were folded into one UI rail policy table
- suggestion chip labels use simple `SelectableText` for common cases, keeping
  `SelectableText.rich` only for changed-word highlighting
- rendered preview sentences are cached inside a single `HomeScreen` build pass,
  so repeated nearby `SentenceState` previews do not call Grammar Engine again
- dark mode is the default developer-console theme, so testing starts in the
  visual mode used most often
- the verb rail keeps its overflow scrollbar visible, making dense vocabulary
  discoverable without changing chip layout

Vocabulary saturation readiness:

- The cockpit is ready for a careful vocabulary expansion pass.
- The app should no longer require artificial `show more` pages before adding
  larger word shelves.
- Saturation should be verb-owned first, broad-data second:
  - a new noun is valuable when at least one visible verb has a reason to offer
    it
  - a new adjective/adverb is valuable when it teaches a visible sentence
    difference
  - a new place/time word is valuable when it belongs to a clear route or broad
    clause modifier
- New vocabulary should be added in measured batches:
  - add one data layer
  - run focused unit/widget tests
  - sample 10-20 developer-console moves
  - record whether UI move trace stays roughly in the 400-600 ms band
- If a batch causes a spike, prefer indexing/filtering that rail over reducing
  visible vocabulary.

Merged side quests:

- introduce a single active locus for the final UI:
  subject, predicate, object, recipient, complement, phrase, or grammar control
- add a path-scoped Compass API or wrapper:
  given active locus + expanded local branch, return only reachable local moves
- avoid recomputing large suggestion lists in build methods
- cache Compass suggestions per state where practical
- cache Grammar render output around preview-heavy Compass/UI paths:
  `SentenceState -> rendered sentence`
- keep rails collapsed until opened
- when a verb feature rail is open, limit Compass work to that verb's active
  local tree instead of also expanding other verbs and their possible rails
- define collapse rules:
  - changing another major word collapses the current local branch
  - reset clears all local pressure
  - random records a new state and starts collapsed
  - switching from detailed subject/object phrase back to a pronoun may require
    collapsing modifiers first
- add preview budgets without hiding vocabulary:
  - keep the full choice set logically available
  - render full sentence previews only for visible or near-visible candidates
  - defer hidden candidate preview strings until hover/open/search/scroll
- cache rendered preview sentences during one build pass so repeated
  `GrammarEngine.generate` calls do not re-render the same nearby state
- avoid full preview rendering in `word` mode when the chip only needs a label;
  keep full sentence rendering for tooltip, hover, selected sentence mode, and
  changed-word preview
- prefer rail virtualization over `show more`; the user should scroll words,
  not unlock artificial pages
- preload data/indexes, not huge widget trees:
  - data can be ready
  - Compass candidates can be indexed by frame/category
  - rendered Flutter chip widgets should stay lazy
- increasing memory is a last resort, not the main plan:
  - browser/mobile memory is managed by the runtime and OS
  - the likely hot spot is widget/render work, not the raw word data
  - Android `largeHeap` or browser flags should not be needed for this app
- split developer cockpit from product toy:
  - cockpit can keep broad rails for debugging
  - product UI consumes the same Configuration state through local paths
- index object candidates by verb frame or semantic category
- pre-render or cache stable noun/phrase fragments only if profiling shows that
  preview rendering is hot
- avoid rendering hundreds of chips when only a rail header is visible
- keep Grammar Engine micro-optimizations low priority unless profiling proves
  they matter; Grammar renders one trusted `SentenceState`, while Compass/UI may
  render many nearby previews
- Recognition lookup indexes may become useful later for night runs and typed
  recognition, but they are less urgent for the final guided UI

Final UI direction:

- Starter sentence can be `You learn.`
- `you` and `learn` are outlined as clickable sentence fields.
- Clicking `learn` opens the verb list: `go`, `get`, `travel`, etc.
- Choosing a verb keeps the sentence centered and opens only that verb's local
  feature doors.
- If `learn` wakes an object/skill surface, `learn` can show a caret; opening
  it reveals choices such as `English`, `grammar`, or a later `how to walk`
  surface.
- If `you` is clicked, the subject picker opens locally:
  - direct pronouns: `I`, `you`, `he`, `she`, `it`, `we`, `they`
  - third person can carry a caret for noun expansion:
    `Mary`, `cat`, `dog`, `teacher`
- A small global number switch may remain near tense/aspect, but full plural
  vocabulary does not need to live permanently in the control panel.
- If a richer subject such as `young dogs` is selected, switching back to `you`
  may require collapsing that subject detail first. This is acceptable: it makes
  the interaction tree directed and prevents broad recomputation.
- This is the water-treatment interlock model applied to UI:
  a local expanded path narrows reachable valves until it is collapsed.

### Copy And QA

- done: sentence preview is copyable plain text
- done: SentenceState debug text remains copyable
- keep random/reset as development tools
- done: configuration nightly runner:
  - `tool/night_configuration.dart`
  - walks Compass-visible moves without opening Flutter or Chrome
  - probes nearby direct moves against the Lock
  - reports candidate law messages, Compass leaks, rail wake counts, and guided
    move distribution
  - output markdown/jsonl evidence like the engine night runner
- next: enhance the configuration nightly runner with route-audit buckets that
  separate:
  - missing PredicatePath data
  - missing route kind
  - stale Compass exposure
  - semantic blocker candidate
- later UI/browser nightly runner:
  - press random sentence repeatedly in the developer cockpit
  - collect sentence, state, alerts, and last moves
  - compare against Lock and round-trip expectations

## Later Side Quest: Raw UI / Explorer Workbench

Purpose:

- unfolded view of the grammar machine
- Configuration Compass restrictions loosened or explained
- every selectable option visible, greyed, or tappable
- useful for debugging, demos, investor presentation, and future widget tests

Likely pieces:

- canonical UI option lists for subjects, verbs, objects, recipients,
  adjectives, tenses, aspects, modals, polarity, voice, passive focus,
  sentence forms, and phrases
- raw mutable selection state separate from final `SentenceState`
- failure-friendly rendering with generated sentence, error panel, raw
  selections, and maybe last valid sentence
- reusable scrollable selector widget
- always-visible or collapsible object, recipient, and passive-focus selectors
- widget tests proving options are reachable and key grammar examples render
- clear mode name such as `RawGrammarWorkbench`, `ExplorerGrammarScreen`, or
  `LidOffScreen`

Architectural note:

- Raw UI is the unfolded version of the same machine the final wheel UI will
  fold down to two or three nearest moves.
- It should consume the same state surface that Configuration Engine produces,
  but decide separately how much invalid or greyed state it wants to expose.
