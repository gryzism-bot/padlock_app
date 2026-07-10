# Backlog

## Current Priority

### Night Generative Test Run

Build the overnight contract runner before starting the Raw UI / Explorer work.

Goal:

- walk representative grammar data combinations
- generate sentences from `SentenceState`
- recognize them back into `SentenceState`
- render again
- report mismatches, throws, unknown tokens, and skipped unsupported frames
- keep failures easy to inspect in the morning

This is the next side quest because it stress-tests the current Grammar Engine,
Recognition Engine, and data layer before UI starts depending on them.

## Later Side Quest: Raw UI / Explorer Workbench

Purpose:

- unfolded view of the grammar machine
- Configuration Engine off
- every selectable option visible and tappable
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
- It should eventually consume the same state surface that Configuration Engine
  produces, but it does not need Configuration Engine rules first.
