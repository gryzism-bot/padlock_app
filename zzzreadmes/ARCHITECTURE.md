# Padlock Architecture

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

Rail Policy is the next larger candidate after that.

Rails already have an implicit state machine: asleep, awake, open, filled,
hidden-but-backreachable. Some of that lives in Compass, some in UI, and some in
tests. A future pass can gather it into a small policy layer:

`SentenceState + mode + Predicate Paths + Lock -> rail visibility states`

That would make disappearing rails, remembered passive agents, and open/closed
predicate surfaces easier to test and reason about.
