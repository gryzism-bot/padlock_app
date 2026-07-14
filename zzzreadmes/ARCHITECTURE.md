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

In a strict Guided or Assisted product mode, authored tracks can be the visible
source of next moves. The learner sees only handcrafted paths such as
`learn -> English`, `talk -> to Mary`, or `write -> with Mary`.

In Manual, Explorer, or developer cockpit modes, broader structural behavior can
remain available. Turning authored tracks off may allow rough states such as
`You develop dogs.` That is acceptable there because those modes expose the
machine rather than the curated lesson.

So predicate paths are not Grammar Engine laws. They are handcrafted Guided Mode
surface. The Lock still protects grammatical validity, while the active mode
decides how much semantic/path curation the user sees.

Short formula:

Grammar is the lock. Predicate paths are the tracks.

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
