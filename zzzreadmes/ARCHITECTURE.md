# Padlock Architecture

## Growth Shape

The architecture is easiest to remember as a growing tree.

- Grammar Engine is the seed.
  It is small, dense, and generative. Given a valid `SentenceState`, it knows how
  to render English.
- Recognition Engine is the mirrored seed.
  It takes app-English and reconstructs the `SentenceState` that could have
  produced it.
- Configuration Engine / Lock is the trunk.
  It holds the structure upright by deciding which states and transitions are
  legal.
- Compass is the branches.
  It does not invent grammar, but it decides where the current state can grow
  next.
- Predicate Paths are the veins through branches and leaves.
  They carry handcrafted meaning from a predicate to the words it can open.
- Data is the leaves.
  It is numerous, visible, touchable, replaceable, and where the learner feels
  the system most directly.
- UI is the light around the tree.
  It reveals the shape, hides or shows branches, and makes the growth playable.

This is why the system can keep expanding without twisting itself apart. The
lower layers stay small and structural; the upper layers get richer, more
curated, and more product-facing.

## Predicate Paths: Good Hardcoding

The grammar core is now intentionally small and trustworthy. Grammar Engine
renders a complete `SentenceState`; Recognition Engine reconstructs app-English
back into a `SentenceState`; Configuration Engine / Lock decides whether a
state transition is legal.

Guided Mode needs one more layer above those laws: authored predicate paths.

Predicate paths answer a different question:

Given the current predicate, what meaningful words can the learner choose next?

This is not UI logic. UI logic is chip layout, scrolling, hover previews,
icons, and animation. Predicate paths are sentence navigation logic: curated
word tracks for the toy.

Examples:

- `learn` opens `English`, `grammar`, `to speak`, `to swim`, `with Mary`
- `talk` opens `to Mary`, `to a cat`, `with Mary`
- `write` opens `book`, `letter`, `story`, `to Mary`, `with Mary`
- `go` opens `to Mary`, `with Mary`

Those authored tracks then map to ordinary `SentenceState` fields:

- `English` -> object
- `to speak` -> right action
- `to Mary` -> addressee or destination, depending on the path
- `with Mary` -> companion

The important split:

- `Verb` morphology and structural flags are permission.
- Predicate paths are product navigation.
- Lock verifies that every authored path remains legal.
- Grammar renders the resulting state.
- UI displays the authored path.

The current `takesObject`, `takesRecipient`, `takesAddressee`,
`takesCompanion`, `usesDestinationPlace`, fixed-object frames, and right-action
frames should not automatically create product UI rails. They are lower laws.
The product should show authored paths first and use those lower laws as
guardrails.

## Mode Boundary

Predicate paths are intentionally modular. They should be possible to turn on
or off per interaction mode.

In Guided Mode, authored tracks are the visible source of next moves. This is
the mode that clarified what Predicate Paths are: handwritten semantic routes
turned on. The learner sees handcrafted paths such as `learn -> English`,
`talk -> to Mary`, or `write -> with Mary`.

Assisted and Manual modes can still keep Predicate Paths on, but change the
friction around them:

- Assisted can explain more, preview blocked edges, and use more educational
  tooltips.
- Manual can be plainer and stricter, with fewer teaching gestures and more
  direct lock feedback.

In Manual, Explorer, or developer cockpit modes, broader structural behavior can
remain available. Turning authored tracks off may allow rough states such as
`You develop dogs.` That is acceptable there because those modes expose the
machine rather than the curated lesson.

So predicate paths are not Grammar Engine laws. They are handcrafted Guided Mode
surface. The Lock still protects grammatical validity, while the active mode
decides how much semantic/path curation the user sees.

Short formula:

Grammar is the lock. Predicate paths are the tracks.

## Lid Off: Grammar Decision Trees

Lid Off is not the software pipeline view.

It should not mainly show:

`data -> PredicatePaths -> Compass -> Lock -> SentenceState -> GrammarEngine`

That chain is useful to developers, but it is app plumbing. Lid Off is the
educational view of the grammar machinery itself.

For Grammar Engine, Lid Off starts after Configuration has already produced a
trusted `SentenceState`. It is almost `grammar_engine.dart` rewritten from Dart
syntax into educational English:

`SentenceState -> verb chain -> participant placement -> phrase placement -> punctuation -> sentence`

Example:

- `SentenceState`: agent `John`, action `give`, recipient `Mary`, object
  `book`, passive recipient focus, modal `should`
- verb chain decision: modal + passive + past participle -> `should be given`
- participant placement: recipient focus becomes subject -> `Mary`
- object placement: object stays after the verb chain -> `a book`
- passive agent surface: agent becomes `by John`
- sentence form: statement adds `.`
- result: `Mary should be given a book by John.`

For Recognition Engine, Lid Off is the mirrored route. It is almost
`recognition_engine.dart` rewritten into educational English:

`sentence -> sentence form -> verb chain recognition -> participant recognition -> phrase recognition -> SentenceState`

Example:

- input: `Mary should be given a book by John.`
- sentence form: statement
- verb chain recognition: `should be given` -> modal passive `give`
- subject role: `Mary` -> passive recipient focus
- object role: `a book` -> object
- by-phrase: `by John` -> agent
- result: `SentenceState(...)`

Visually, Lid Off can feel like white-character source code, but not plain Dart.
The inactive grammar tree stays pale. The exact grammatical path used for the
current sentence turns dark, grouped, and electrified. It is a decision tree of
English, not a stack trace of implementation calls.

Translations can sit on top of the same tree later. They should stay bracketed
and ingredient-like when they are crude:

`You learn.`

`(Ty) (uczyć się).`

So Lid Off answers:

How did this `SentenceState` become this sentence?

And for recognition:

How did this sentence become this `SentenceState`?

## Migration Plan

1. Add a data-only `predicate_paths.dart` layer.
2. Seed it with a few verbs that are already important in the cockpit:
   `learn`, `talk`, `write`, and `go`.
3. Add tests proving:
   - every authored path is attached to one visible verb
   - authored paths are not inferred from broad `takesX` flags
   - every path fits lower structural laws
   - every path can become a Lock move and render
4. Keep current Compass behavior as fallback.
5. Teach Compass/UI to prefer predicate paths when present.
6. Gradually cover guided-mode verbs.
7. Once coverage is good, product Guided Mode should stop discovering rails
   from raw structural flags.

This is deliberately not a big bang. Predicate paths can start as a small
parallel map, prove themselves in tests, and then slowly absorb the current
word-wiring maps such as fixed object frames and right-action frames.

## Why This Matters

Without predicate paths, the developer has to remember engine slots while
authoring vocabulary:

- is `to Mary` an addressee, destination, or recipient?
- is `English` a normal object or a fixed subject object?
- does `with Mary` come from companion capacity or a semantic rail?

With predicate paths, authoring becomes teacher-facing:

- after `talk`, expose `to Mary`, `to the cat`, `with Mary`
- after `learn`, expose `English`, `to swim`, `with a teacher`
- after `write`, expose `story`, `to Mary`, `with a friend`

The bridge layer can translate those tracks into the correct fields. This keeps
the toy finite, inspectable, and handcrafted instead of trying to become a
general deterministic language model.

Predicate paths also prepare better translations. A path can carry meaning:

- `to Mary` after `write` can translate differently than `to school` after `go`
- `to swim` after `learn` can translate as a learned action, not a literal
  preposition
- `with Mary` can stay a companion path instead of an accidental phrase

That makes the same authored track useful for UI, translation, testing, and
eventual educational explanations.

## Keepsake Pt 2: Careful Comb-Downs

The system is now being refined by small comb-down passes. Each pass gathers a
scattered responsibility into the lowest layer that can own it without turning
the app into a larger, fuzzier engine.

### Comb-Down 1: Configuration Laws

Question:

Is this `SentenceState` legal?

The Lock already knew many laws, but some of them lived as inline conditions.
They were extracted into named predicates in `configuration_laws.dart`.

Examples:

- lexical `be` is active and needs an agent
- active voice needs an agent
- passive object focus needs an object
- passive recipient focus needs recipient plus object
- future tense owns `will`
- imperative uses active present simple

This pass did not change Predicate Paths or word choice. It only made language
shape laws explicit and reusable.

### Comb-Down 2: Predicate Path Queries

Question:

What authored words can this predicate open?

Predicate Paths became the explicit source for handcrafted word openings. The
data layer now exposes reusable queries:

- `predicateNounChoicesFor(verb, pathKind)`
- `predicateVerbChoicesFor(verb, pathKind)`

Compass uses those queries in authored mode instead of scanning path objects
itself. Right-action helpers can safely prefer authored path data because they
answer the same narrow question: which bare verb can follow `to`.

Fixed object frames were deliberately kept separate as structural compatibility
helpers. A focused test caught that globally replacing them with authored paths
would leak Guided Mode narrowing into Explorer/legacy behavior.

This pass drew the boundary:

- Predicate Paths are authored product tracks.
- Fixed object frames are structural/legacy support.
- Compass adapts the active mode into suggestions.

### Comb-Down 3: Predicate Influence

Question:

What should verb chips claim they can wake?

`verb_influence.dart` used to independently infer badges and output counts from
verb flags, fixed frames, and right-action frames. It now collects authored
Predicate Paths first, then fills missing influence from structural fallback
rules.

That makes the UI badges describe the same tracks that Guided Mode uses.

Examples:

- `give` wakes `recipient` and `object`
- `learn` wakes `subject`, `right action`, and `companion`
- `go` wakes `destination` and `companion`
- `read` wakes `text`

Influences are sorted by rank before the UI sees them, so stronger signals such
as recipient still lead the tooltip and icon color even when path data is
authored in another order.

The split after this pass:

- Verb structural flags say what the grammar permits.
- Predicate Paths say what authored tracks exist.
- Predicate Influence says how those openings should be signaled on verb chips.

### Comb-Down 4: Rail Policy

Question:

What should the cockpit show as asleep, awake, open, or filled?

Rails already had that state machine, but the logic was spread across Compass,
UI checks, and tests. The important bug that forced the comb-down was an
object-gated path:

`You do.` showed Purpose as awake, but opening the rail produced no choices
because `do` purpose paths require an object first.

Rail Policy now asks Predicate Paths whether the matching route prerequisites
are satisfied before showing a rail as awake. Verb chips may still advertise
future exits, but participant doors distinguish:

- this predicate can eventually open Purpose
- Purpose is open right now
- Purpose is filled

This keeps rail visibility aligned with the same authored tracks Compass uses
for suggestions.

Examples:

- `You do.` keeps Purpose asleep.
- `You do something.` wakes Purpose.
- `You take book.` wakes destination/source routes that require an object.
- `You learn.` wakes non-gated routes immediately.

The split after this pass:

- Predicate Paths own route existence and prerequisites.
- Compass owns concrete suggestions for an open rail.
- Rail Policy owns whether a rail should be visible, collapsed, awake, or
  filled.
- UI owns layout, scrolling, search, and click handling.

### Next Comb-Down Candidates

Diagnostics labels are the next clean candidate.

Current diagnostic UI classifies Lock messages by reading message text. That is
useful, but it is still text-sniffing. A future pass should let
`ConfigurationMessage` carry a stable law category directly:

- noun phrase shape violation
- predicate frame violation
- passive shape violation
- modal tense frame violation
- imperative frame violation
- phrase compatibility violation

## Keepsake Pt 3: Right-Side Word Route Surface

The next architectural pressure point is the old phrase surface.

`placePhrase`, `timePhrase`, `frequencyPhrase`, and `mannerPhrase` were useful
early because they gave Grammar Engine a compact way to render extra sentence
material. But Guided Mode is no longer asking only:

Can this complete phrase be appended?

It is asking:

What word can the learner choose next after this predicate?

That makes some phrase data feel too prebaked. `You go home`, `You go to
school`, `You go from work`, `You go into the shop`, and `You work at home` are
not just generic place decorations in the product view. They are predicate-owned
routes. The verb opens the next word, and that next word may open another noun.

Guiding law:

If a choice is licensed by the predicate, it belongs to Predicate Paths. If it
modifies the whole clause, it stays a clause modifier.

The split:

- Predicate-bound right routes:
  - `go home`
  - `go to school`
  - `go from work`
  - `go into the shop`
  - `work at home`
  - `speak with Mary`
  - `talk about grammar`
  - `learn from John`
  - `write on paper`
- Clause-level modifiers:
  - `yesterday`
  - `today`
  - `usually`
  - `every day`
  - possibly broad sentence-level manner

This is not a new Phrase Engine. It is the opposite direction: split old
prebaked phrase choices into smaller right-side routes where the predicate owns
the opening.

The educational reason matters. A sentence configurator should show the learner
that `to`, `from`, `with`, `about`, `for`, `at`, `in`, and bare direction words
are live pieces of the sentence, not hidden ingredients inside a phrase label.
`outside`, `inside`, `abroad`, `nearby`, `home`, and `there` are one-word route
choices in the same broad UI sense as object nouns: the learner chooses a word,
then the sentence changes.

The implementation plan should be incremental:

1. Classify existing phrase data into clause-level modifiers and predicate-bound
   routes.
2. Keep true clause modifiers in the old sentence-level fields.
3. Move predicate-bound place/source/topic/beneficiary/location behavior into
   authored Predicate Paths.
4. Compile those routes back into existing `SentenceState` fields so Grammar and
   Recognition stay stable.
5. Hide broad generic phrase rails from Guided Mode where a predicate-owned route
   now exists.
6. Add tests that protect the split:
   - `You go home.`
   - `You go to school.`
   - `You go from work.`
   - `You work at home.`
   - `You learn about grammar.`
   - `You worked yesterday.`
   - no duplicate guided route appears through both a phrase rail and a
     predicate route

Act 1 exists as executable data in `phrase_classification.dart`. It classifies
all current place, time, frequency, and manner phrase constants before any
fields are removed or any rails are rewired.

Act 2 keeps clause modifiers explicit. Current time and frequency phrases stay
sentence-level controls in Guided Mode: they remain broad Compass choices, they
do not count as verb-woken outputs, and guided verb switching does not shave
them away just because the next predicate has different authored tracks.

Act 3 moves predicate-bound phrase exposure into Predicate Paths. In authored
mode, place and manner rails no longer fall back to every old phrase constant
when a predicate has not authored that route. A predicate-bound place or manner
can stay visible only as a selected exit, or as a route the current predicate
explicitly owns. Switching verbs shaves those route-bound phrases when the next
predicate does not author them.

Act 4 adds the bridge compiler. Predicate Paths stay authored data, but
`predicate_path_compiler.dart` knows how to turn a chosen route into the correct
Configuration move and therefore into the same `SentenceState` fields that
Grammar and Recognition already understand. This keeps the new right-side word
routes from forcing a rewrite of the old engines.

Act 5 hides broad generic phrase rails from Guided Mode. In authored mode,
predicate-bound place and manner surfaces appear only when the current predicate
owns that route, or when an already selected value needs an exit. Clause-level
time and frequency controls remain broad for now because they modify the whole
sentence rather than belonging to one predicate route.

Act 6 protects the bridge boundary with two-way tests. Right-side routes can
still compile down into old `SentenceState` phrase fields while the migration is
in progress, but Recognition must read them back into the intended fields:
`rightAction`, route participants, `placePhrase`, and `timePhrase` must not
silently swallow each other.

Act 7 decides what is dead wood. The old phrase fields are not dead: Grammar and
Recognition still use them as the bridge while Predicate Paths are being
authored. What is dead in Guided Mode is the broad generic fallback for
predicate-bound place and manner choices. `placePhrase` and `mannerPhrase` can
still appear when an authored Predicate Path owns them, or when a selected value
needs an exit. Time and frequency stay broad clause-level controls because they
modify the whole sentence rather than completing one verb route.

Long term, this prepares the final sentence-centered UI. The learner clicks the
sentence's verb, sees authored routes opened by that verb, and follows one route
at a time. The developer cockpit may still show broader rails, but the product
view should feel like word routing rather than phrase dumping.

## Idiom Finder

Idiom Finder is a product layer over already-valid sentence states.

It does not decide whether a sentence is grammatical. It does not decide which
predicate routes exist. It watches the current `SentenceState` after the Lock,
Compass, and Predicate Paths have done their work, then asks:

Did the learner just find a memorable phrase?

Examples:

- `give` + `up` -> `give up`
- `give` + `up` + `smoking` -> `give up smoking`
- `write` + `down` + object -> `write down`
- `work` + `on` + topic -> `work on`
- `hear` + source -> `hear from`
- `ask` + purpose -> `ask for`

The source of truth is `idiom_patterns.dart`. Patterns can observe:

- `action`
- `rightParticle`
- `object`
- `topic` and `topicPreposition`
- `source`
- `purpose`

Predicate Paths make idioms reachable. Idiom Finder recognizes them after they
are reached. That keeps the split clean:

- Predicate Paths answer: what route can this verb open?
- Lock answers: is this resulting state legal?
- Grammar answers: how is this state spoken?
- Idiom Finder answers: is this state memorable as an idiom?

Two audits protect the layer:

- forward audit: every idiom pattern must have a reachable Predicate Path
- reverse audit: every authored `rightParticle` route must either be an idiom
  pattern or an intentional literal particle route

Intentional literal particle routes live next to the idiom patterns. They are
reviewable by hand because a route such as `look down` or `read through` may be
literal today and become product-celebrated later. The review copy lives in
`IDIOM_REVIEW.md`.

## UI-Only Wires

A UI-only wire is allowed when it changes how an already-known language truth is
displayed, reached, debugged, or made fast. It is not allowed to be the first
place where a language rule becomes true.

Allowed UI-only wires:

- rail open/closed state
- overlays, sticky decks, dark mode, footer placement, and responsive layout
- search boxes, rail virtualization, lazy chip rendering, and preview cache
- chip keys, tooltips, hover preview, clicked preview, Word/Change display modes
- translation visibility, diagnostics panels, move trace, and copyable text
- visual signals: icons, carets, badges, rail grouping, and selected-chip styling

Not allowed as UI-only wires:

- deciding that a verb can take an object, recipient, addressee, companion,
  source, beneficiary, instrument, purpose, topic, destination, or right action
- deciding which noun shelf a verb can reach
- deciding whether a `SentenceState` is legal
- deciding how a `SentenceState` renders into English
- deciding how an English sentence is recognized back into `SentenceState`

Comb-down rule:

- If a wire answers "can this sentence exist?", move it to Configuration / Lock.
- If it answers "which word can come next after this verb?", move it to
  Predicate Paths.
- If it answers "what does this move open or close?", move it to Predicate
  Influence or Rail Policy.
- If it answers "how is this state spoken or recognized?", move it to Grammar
  Engine or Recognition Engine.
- If it answers "how do I show, search, cache, explain, or debug this choice?",
  it may stay in UI.

Current examples:

- UI-only: verb rail virtualization, noun overlay, sticky control deck,
  diagnostics bar, move trace, preview cache, theme, chip display modes.
- Not UI-only: `make -> object + beneficiary`, `learn -> right action`,
  `go -> destination`, `work -> on topic`, and `do -> generic objects`.

This keeps the developer console honest. It can be a rich instrument without
quietly becoming the source of grammar or predicate truth.
