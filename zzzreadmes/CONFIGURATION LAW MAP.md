# Configuration Law Map

This map distills Grammar and Recognition tests into UI-state responsibilities.
It is not a copy of those suites. It separates rendered/parser facts from
state-space laws that Guided Mode must preserve.

## Test Sources

- Grammar axioms and invariants prove rendered English shape.
- Recognition axioms and invariants prove app sentences recover a stable
  `SentenceState`.
- Two-way tests prove Grammar and Recognition agree on canonical app states.
- Configuration tests prove the UI cannot create invalid states.
- Compass tests prove the UI sees useful reachable paths.

## Keep In Grammar And Recognition

These are not Configuration laws. They are renderer/parser facts.

- exact auxiliary order: `has been`, `been being`, modal plus infinitive
- agreement strings: `am`, `is`, `are`, `was`, `were`, `has`, `have`, `do`,
  `does`, `did`
- do-support and question inversion
- punctuation and capitalization
- objective case rendering and recognition: `by them`, `built him`
- irregular verb forms
- homograph parsing and token-boundary behavior
- phrase token parsing boundaries
- exact sentence text for tense/aspect/form combinations

## Configuration Engine Laws

These are hard validity rules. A blocked move must leave the previous state
unchanged.

### Predicate Frame

- Active voice requires an agent.
- Active object requires an object-capable verb.
- Active recipient requires a recipient-capable verb.
- Active recipient requires an object.
- Recipient-capable verbs must also be object-capable in data.
- Non-`be` verbs cannot carry noun or adjective complements in active or
  passive voice.
- Noun phrase determiners must match noun number:
  `a`, `an`, `this`, `that`, `each`, and `every` require singular nouns;
  `these`, `those`, and `many` require plural nouns.
- `a` and `an` must match the noun's starting sound for current app data.
- Place phrases cannot repeat the selected verb word, such as `work at work`.
- Lexical `be` requires an agent.
- Lexical `be` can be selected as a bare verb frame before a complement is
  chosen.
- Lexical `be` is active-only.
- Lexical `be` cannot carry object, recipient, or passive focus.
- Lexical `be` noun complements must match agent number.
- Changing away from lexical `be` clears complement slots.

### Passive Frame

- Passive voice requires an object-capable verb.
- Passive object focus requires an object.
- Passive recipient focus requires a recipient-capable verb.
- Passive recipient focus requires a recipient.
- Passive recipient focus still requires an object.
- Passive focus belongs only to passive voice.
- Changing from passive voice back to active clears passive focus.

### Modal And Form Frame

- `will` belongs to future tense.
- non-`will` modals belong to the present modal frame.
- Imperatives cannot take a modal.
- Imperatives use present simple.
- Imperatives use active voice.

## Compass Laws

These are path and ranking rules. Compass does not decide validity by itself;
it filters candidates through Configuration Engine.

### Global

- Every Compass suggestion must survive Guided Mode.
- Every Compass suggestion must render without throwing.
- Compass must hide slots whose moves the lock blocks.
- Compass should expose at least one practical exit from special frames.
- Compass keeps current choices visible and highlighted, but selection alone
  does not move a choice to the front of the list.
- Compass suggestion buttons render as sentence previews. The changed words are
  highlighted inside the sentence instead of shown as `option -> sentence`.
- The debug UI can switch Compass suggestion display between sentence preview,
  embedded change highlight, and compact word-only labels.

### Predicate Paths

- Object suggestions are hidden until the selected verb can take objects.
- Passive voice is hidden until an object frame exists.
- Passive focus is hidden until passive voice is selected.
- Recipient focus is hidden until the full ditransitive passive frame exists.
- Active voice is a practical exit from passive recipient focus.
- Lexical `be` is the doorway to noun and adjective complement suggestions.
- Noun and adjective complement suggestions are hidden until lexical `be` is
  selected.
- `go` stays visible as a high-priority movement doorway in the default verb
  dial.
- Noun-bearing slots expose determiner and adjective suggestions after the noun
  exists.
- Normal verbs, especially `work`, are visible exits from lexical `be`.
- Noun complement suggestions follow agent number.
- Object, recipient, and passive-focus suggestions are hidden in lexical `be`.

### Modal And Phrase Paths

- Present modal frames suggest present-compatible modals.
- Future frames suggest `will`.
- When a modal is selected, `no modal` is a high-priority exit.
- Place phrase suggestions are available as location phrases for ordinary
  verbs.
- Place phrase suggestions include `no place` as an exit when a place phrase is
  active.
- Destination verbs such as `go`, `come`, `travel`, `arrive`, `leave`, and
  `return` prioritize place suggestions and render them as destinations.
- Time phrase ranking prefers tense/aspect-friendly phrases:
  `today` for simple present, `now` for continuous, `yesterday` for past,
  `tomorrow` for future.
- Time phrase suggestions include `no time` as an exit when a time phrase is
  active.

## Widget And Integration Laws

These prove the live UI stays in the tested state-space.

- The app launches into a renderable initial state.
- A visible Compass suggestion changes the rendered sentence.
- A blocked manual probe shows a lock message and keeps the sentence valid.
- A user can enter lexical `be` and exit back to a normal verb.
- The random sentence control builds from Compass suggestions so shuffled
  states remain renderable Guided Mode states.

## Open Law Candidates

These are not yet hard laws, but Grammar/Recognition tests suggest they may
become Configuration or Compass work as the UI gets richer.

- Phrase compatibility by verb:
  work/study verbs should prefer location/frequency phrases.
- Phrase compatibility by tense:
  some time phrases should be ranked down or hidden for conflicting tense.
- Sentence-form reachability:
  questions and exclamations are currently broadly reachable; final UI may rank
  common forms differently.
- Imperative frame depth:
  the current lock keeps imperatives present simple and modal-free, but future
  UI may need a clearer subject/agent policy for imperative display.
- Data quality:
  duplicate verb infinitives and missing object/recipient flags should remain
  covered by data/contract tests and may later feed Compass categories.

## Classification Rule

When reading a Grammar or Recognition test:

- If it asserts exact text or exact token parsing, keep it in Grammar or
  Recognition.
- If it implies a state must never be reachable, add a Configuration law.
- If it implies a useful state should be easy to reach, add a Compass law.
- If it proves a real user can follow that path, add a widget or integration
  test.

## SentenceState Force Map

This asks each field what it influences. "Rightward" means the field opens,
closes, or ranks later choices in the builder flow. "Leftward" means the field
changes how an earlier field is rendered or interpreted. "Structural" means the
field participates in validity laws without being a simple left/right nudge.

### Predicate Core

- `agent`
  - Structural: required in active voice and lexical `be`.
  - Leftward/projection: its person and number choose verb agreement strings:
    `am`, `is`, `are`, `was`, `were`, `has`, `have`, `do`, `does`.
  - Rightward: its number filters lexical `be` noun complements.

- `action`
  - Structural: the main predicate frame. It decides whether object,
    recipient, complements, passive voice, and destination place logic can
    exist.
  - Rightward: object-capable verbs open object suggestions; recipient-capable
    verbs open recipient paths; `be` opens complement paths; destination verbs
    rank place phrases as destinations.
  - Leftward/projection: irregular forms, participles, and passive rendering
    reshape the predicate text.

- `object`
  - Structural: required for active recipients and passive object focus.
  - Rightward: once present, it opens object determiner/adjective modifiers and
    passive voice.
  - Leftward/projection: in passive object focus, it becomes the displayed
    subject.

- `recipient`
  - Structural: requires a recipient-capable verb and an object.
  - Rightward: once present in passive voice, it opens passive recipient focus.
  - Leftward/projection: in passive recipient focus, it becomes the displayed
    subject.

- `complement`
  - Structural: belongs only to lexical `be`; noun complement number must match
    agent number.
  - Rightward: once present, it opens complement determiner/adjective
    modifiers.
  - Leftward/projection: completes the meaning of `be` without changing the
    verb chain.

- `adjectiveComplement`
  - Structural: belongs only to lexical `be`.
  - Rightward: no current downstream field.
  - Leftward/projection: completes the meaning of `be` without changing the
    verb chain.

### Voice And Verb Chain

- `voice`
  - Structural: active requires an agent; passive requires an object-capable
    frame and passive focus laws.
  - Rightward: passive opens passive focus; active closes passive focus.
  - Leftward/projection: passive promotes object or recipient into subject
    position and renders the agent with `by`.

- `passiveFocus`
  - Structural: belongs only to passive voice; object focus requires object;
    recipient focus requires recipient-capable verb, recipient, and object.
  - Rightward: no current downstream field.
  - Leftward/projection: chooses which participant is promoted in passive
    rendering.

- `tense`
  - Structural: participates in modal frame laws.
  - Rightward: future opens `will`; present opens non-`will` modals; tense ranks
    time phrases.
  - Leftward/projection: chooses auxiliary and verb forms.

- `aspect`
  - Structural: imperative must be simple; aspect participates in the verb
    chain shape.
  - Rightward: continuous ranks `now` highly.
  - Leftward/projection: chooses auxiliary chain such as `is working`,
    `has worked`, `has been working`.

- `modal`
  - Structural: modal frame must match tense; imperatives cannot take modals.
  - Rightward: when present, Compass exposes `no modal` as an exit.
  - Leftward/projection: forces infinitive/base verb chain after the modal.

- `polarity`
  - Structural: no current Configuration law beyond being renderable.
  - Rightward: no current downstream field.
  - Leftward/projection: inserts negation and may trigger do-support.

- `sentenceForm`
  - Structural: imperative laws constrain modal, tense, aspect, and voice.
  - Rightward: no current downstream field, though final UI may rank forms.
  - Leftward/projection: question form changes auxiliary order; imperative form
    suppresses the displayed subject.

### Phrase Layer

- `timePhrase`
  - Structural: no current hard lock beyond renderability.
  - Rightward: no current downstream field.
  - Leftward/projection: contributes phrase text; future Configuration may
    compare it with tense.

- `placePhrase`
  - Structural: no current hard lock beyond renderability.
  - Rightward: no current downstream field.
  - Leftward/projection: its rendered preposition depends on `action`
    location/destination meaning.

- `frequencyPhrase`
  - Structural: no current hard lock beyond renderability.
  - Rightward: no current downstream field.
  - Leftward/projection: contributes phrase placement/text.

- `mannerPhrase`
  - Structural: no current hard lock beyond renderability.
  - Rightward: no current downstream field.
  - Leftward/projection: contributes phrase placement/text.
