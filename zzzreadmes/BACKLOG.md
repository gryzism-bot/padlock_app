# Padlock Backlog

This backlog keeps the work discovered while testing the live machine. It is
ordered from the deepest layer upward, but trimmed to current decisions rather
than every historical side quest.

Layer map:

1. Grammar and Recognition: sentence form and parse shape.
2. Configuration Engine / Lock: hard validity of a `SentenceState`.
3. Configuration Compass / PredicatePaths: reachable next moves.
4. Semantic C-section: meaning and world-fit.
5. UI: how the machine exposes choices.
6. Product modes: how someone first plays with it.

## Current Best Next Moves

1. Translate authored route ingredients.
   - UI toggles now exist for sentence, verbs, objects, companions, location,
     topic/source/right-action/time/manner, and other major rails.
   - Remaining work is data quality and coverage, not button plumbing.
   - First targets:
     - connectors: `with`, `to`, `from`, `for`, `about`, `of`, `on`, `at`, `in`
     - reusable route shelves: people/source nouns, places, tools, foods,
       openables, text/media, study subjects, and everyday objects
     - better Polish verb fragments where person/number is currently too crude

2. Continue staged vocabulary saturation.
   - The cockpit is ready for careful growth:
     - large rails are virtualized
     - rail-local search can summon late vocabulary
     - preview rendering is cached and bounded near visible choices
     - ordinary verb switching is usually in the 400-700 ms band
   - Saturate in small batches:
     - add one data layer
     - run focused tests
     - sample 10-20 developer-console moves
     - record whether timing stays acceptable
   - Prefer verb-owned shelves first, broad noun flooding second.

3. Keep route audit tooling current.
   - The route-kind architecture is broad enough for now.
   - Missing rows should usually mean missing authored data, not missing Grammar
     Engine logic.
   - Keep the review sheet executable and rare in pending rows.

4. Improve educational diagnostics.
   - Keep developer precision: `Lock law alert`, `Compass path alert`,
     `UI rail alert`.
   - Add friendlier educational wording from the same source later.
   - Do not lose the current testing value of exact law names.

5. Plan, but do not start yet: Guess The Sentence.
   - This is the biggest product leap, but it should wait until the console has
     enough vocabulary and translation depth to speak for itself.

## Recently Completed Foundation

These are no longer active backlog items unless a regression appears.

- Grammar and Recognition have a strong one-predicate surface with tests down
  to axioms, invariants, two-way round trips, and nightly contracts.
- Configuration Engine owns hard validity and has a law runner instead of raw
  ad-hoc validation sprawl.
- Compass and PredicatePaths now expose authored Guided Mode routes.
- Guided Mode is effectively `PredicatePaths` on.
- Explorer/Manual/Assisted modes remain policy-ready variants of the same core.
- Verb switching can shave incompatible right-side material while keeping
  compatible object/companion/destination/right-action tails.
- Rail policy keeps hidden but reachable rails visible after predicate changes.
- Large rails are lazy and virtualized without `show more`.
- Word mode avoids full preview rendering.
- Preview sentences are cached for a build pass.
- Dark mode is default.
- The developer console has collapsible diagnostics, move trace timing, cache
  controls, and copyable sentence/state text.
- Rail-local translation toggles exist for the major rails.
- Fourth vocabulary batch widened everyday object shelves:
  - text/work items: recipe, menu, bill, receipt, contract, file, page,
    website, code
  - tools/devices/openables: screwdriver, saw, glue, tape, pot, pan, bowl,
    microphone, app, server, envelope, package, suitcase, fridge
  - food, media, clothing, furniture, vehicle, and abstract route nouns

## PredicatePath Status

Current route families exist:

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
- fixed objects: language/text/tool/openable/activity-style shelves
- object-moving destination/source:
  - `You take a book to Mary.`
  - `Mary brought a book from John.`

Current audit signal:

- no authored paths: 0
- one-route verbs: 0
- thin verbs: 0
- thin essential verbs: 0
- expected special case: `teach` has recipient-gated right action because
  `teach Mary to swim` needs a learner before the `to + verb` rail wakes

Interpretation:

- New PredicatePath work should usually add vocabulary to an existing route
  kind.
- Add a new route kind only when the sentence cannot be expressed through the
  current one-predicate surface.

## Vocabulary Saturation

Saturation should follow noun atomization:

- expose base nouns first: `friend`, `enemy`, `cat`, `dog`
- use determiner/adjective rails for `a friend`, `my friend`, `that enemy`,
  `young dog`
- keep true pronoun-like words as complete noun phrases:
  `someone`, `anyone`, `nobody`, `everyone`

Useful next shelves:

- people/person-like:
  - family, workplace, public roles, social roles, learners, customers,
    performers, drivers, passengers
- animals:
  - pet/farm/wild/bird/water/small animals
- everyday objects:
  - containers, household items, bags, room objects, office objects
- foods and drinks:
  - common eat/drink/cook/chop/boil objects, then split cooking ingredients
    from prepared meals if semantic filtering needs it
- tools:
  - write/open/cut/fix/build/use instruments, then add tool-specific route
    tests when a tool should be narrower than the broad `use` shelf
- openables:
  - doors, windows, bottles, boxes, bags, laptops, apps, files, packages
- text/media:
  - books, articles, messages, scripts, scenes, episodes, songs, videos
- places:
  - home/school/work anchors, shops, transport places, public buildings,
    rooms, outdoor places
- adjectives/adverbs:
  - common size/color/quality/emotion/weather
  - simple manner words: quickly, slowly, carefully, again, well, badly

Timing target while saturating:

- ordinary verb switches: about 400-700 ms
- dense first-open rail spikes: acceptable under 1000 ms if search/scroll stays
  responsive
- if a batch causes obvious lag, index/filter that rail before reducing visible
  vocabulary

## Translation Work

Current translation surface:

- header sentence translation can be toggled
- verb rail translation can be toggled locally
- object/person/location/topic/source/right-action/time/manner and similar rail
  translations can be toggled locally
- translation is intentionally crude and bracketed:
  - `You learn.`
  - `(Ty) (uczysz się.)`

Next translation tasks:

- improve Polish verb tables beyond the current small set
- distinguish singular/plural `you` more clearly where possible
- add translations to the new vocabulary shelves as they are added
- keep connector translation visible in predicate routes:
  - `to` -> `do`
  - `with` -> `z`
  - `from` -> context-dependent `z` / `od`
  - `for` -> `dla` / purpose-like `na`
  - `about/of/on` -> context-dependent `o` / `na`
- accept that this remains a learning gloss, not a polished translator

## Semantic C-section

This is not Grammar Engine work. These are meaningfulness laws over otherwise
valid grammar.

High-value semantic blockers:

- `I eat street.`
- `I drink school.`
- `He drives house.`
- `A bridge is taught to John by you.`
- odd cooking/object pairings such as boiling bridges
- odd lexical `be` + time combinations
- adjective stacking/order restraint such as `white blue key`

Clause force / semantic polarity:

- Current `Polarity` tracks verb-chain negation:
  - `He does not buy books.`
- Some words make the clause semantically negative:
  - `Nobody buys books anymore.`
  - `Nothing works anymore.`
- Candidate abstraction:
  - `ClauseForce.affirmative`
  - `ClauseForce.negative`
- First use:
  - allow `anymore` with negative clause force
  - block or hide `Everybody buys books anymore.`

## Grammar / Recognition Future Creases

Avoid reopening `SentenceState` unless the current surface cannot express the
lesson.

Known future candidates:

- participant identity/reflexive law:
  - decide whether Guided Mode transforms `You gave you a book.` into
    `You gave yourself a book.`
  - flag suspicious same-participant passive states such as
    `A book was given to you by you.`
- phrasal/particle slot:
  - `wake up`
  - `turn on`
  - `look after`
  - `give up`
- new right-side roles if plain `rightAction` stops being enough:
  - semi-modal frame: `I have to go.`
  - ability/permission frame: `He is able to go.`
  - purpose action: `He walks to exercise.`

Current note:

- `rightAction` already covers a lot of `to + bare verb` value:
  - `I want to go.`
  - `You learn to speak English.`
  - `You forget to call John.`
  - `You teach Mary to swim.`
- Treat it as closed enough until a clearly distinct role appears.

## UI Side Quests

Developer console:

- keep chips, rails, diagnostic panels, and control cards reusable
- keep Material icons configurable from data through `SemanticIcon`
- allow asset paths later for Noun Project or hand-drawn icons
- keep rail headers with connector hints:
  `with`, `to`, `about`, `from`, `for`, `at`, `in`, `on`
- next UI refinements:
  - friendlier rail explanations: what woke this rail and why
  - visible shave explanation when verb changes remove incompatible material
  - optional disabled-but-visible verbs for Explorer-ish mode
  - keep selected/current options stable and highlighted

Control deck:

- sentence preview stays stable at the top
- tense/aspect, subject, modal, voice, polarity, and form stay constant controls
- core participant surface and verb rail can be collapsed
- diagnostics stay glued above footer
- reset/random/translation/cache/debug controls stay development-facing

Final product direction:

- starter sentence can be `You learn.`
- sentence sits in the middle
- clickable words have faint outlines
- clicking the verb opens the verb list
- choosing a verb opens only that verb's local feature doors
- opening a verb feature narrows the tree until collapsed
- product UI should be path-scoped and much narrower than the developer console

## Product Mode: Guess The Sentence

Goal:

Make the first public play session memorable without a tutorial reel.

Core loop:

1. Pick a valid target `SentenceState` from a curated deck.
2. Render the target sentence.
3. Start from `You learn.`
4. Let the player use Guided Mode controls to transform the current sentence.
5. Show remaining moves by comparing normalized state fields.
6. Mark solved when current state matches target state.

First tests later:

- exact match gives zero remaining moves
- changing only tense is one remaining move
- changing `You learn.` toward `Mary brought a book to John.` reports the
  expected missing fields
- solved target survives Grammar render and Recognition round trip

## Product Side Quest: Idiom Hunting

Idea:

Review authored verb routes for idiom-capable combinations. When the user builds
one naturally, show a small `idiom found` note.

Examples:

- `get over it`
- `make up`
- `take off`
- `look for`
- `run into`
- `give up`

Keep this as a detection layer over valid output, not as a replacement for
grammar.

## Night Runs And Audit Tools

Existing tools:

- backend night contract: raw Grammar/Recognition contract stress
- configuration night runner: Compass-visible moves and Lock responses
- predicate route audits:
  - `dart run tool/audit_predicate_influences.dart`
  - `dart run tool/audit_verb_review.dart`

Useful next audit enhancement:

- group blocked configuration probes by verb and route family:
  - missing PredicatePath data
  - missing route kind
  - stale Compass exposure
  - semantic blocker candidate

Later:

- browser/UI nightly runner:
  - press random sentence repeatedly
  - collect sentence, state, alerts, last moves, timing
  - compare against Lock and round-trip expectations

## Postponed

- broad semantic blockers such as `eat street`
- browser/UI nightly automation
- deeper browser/runtime profiling unless 400-700 ms ordinary interaction stops
  holding during vocabulary saturation
- Match Mode / Guess The Sentence, until Guided Mode has more vocabulary and
  translation depth
- final lid-on product UI
- Lid Off educational grammar/recognition decision-tree visualization
