# Padlock Backlog

This file keeps the work discovered while testing the live machine. It is
ordered from the deepest crease upward:

1. Grammar and Recognition: sentence form and parse shape.
2. Configuration Engine / Lock: hard validity of a `SentenceState`.
3. Configuration Compass: reachable next moves and ranking.
4. Semantic C-section: meaning and world-fit.
5. UI: how the machine exposes those choices.

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

## Current Priority: Core Participant Surface

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

Next crease candidates:

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
- use consistent icon shapes for influence types
- keep rail-unlock count visible without swallowing the selected verb

### Diagnostic Body

- keep Language Alert and Last Moves glued above the footer
- Language Alert should show all triggered Lock laws in one panel
- each alert should name its layer:
  - Lock law alert
  - Compass path alert
  - UI rail alert
- keep developer phrasing available, then later add educational phrasing from
  the same source
- Last Moves should keep the last 10 moves, scroll if needed, and reset with
  the reset button
- random sentence should record itself as a random move

### Rail Interaction

- selecting a verb should not explode the whole page at once
- verbs should be selectable first, then their rails can be expanded
- hidden rails:
  - `be` wakes noun/adjective complement
  - object-capable verbs wake object
  - recipient-capable verbs wake object and recipient
  - destination verbs wake place/direction
  - fixed-object verbs wake fixed activity/object rail
- rail headers should explain what woke them
- rail content should start inline with the title when compact

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
- add preview budgets:
  - show a small nearest set first
  - render full sentence previews only for visible candidates
  - defer hidden candidate previews until hover/open/search
- split developer cockpit from product toy:
  - cockpit can keep broad rails for debugging
  - product UI consumes the same Configuration state through local paths
- add lazy/virtualized rail lists before loading much larger vocabulary
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

- sentence preview should be copyable plain text
- SentenceState debug text should remain copyable
- keep random/reset as development tools
- configuration nightly runner:
  - `tool/night_configuration.dart`
  - walks Compass-visible moves without opening Flutter or Chrome
  - probes nearby direct moves against the Lock
  - reports candidate law messages, Compass leaks, rail wake counts, and guided
    move distribution
  - output markdown/jsonl evidence like the engine night runner
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
