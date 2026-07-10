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

### Predicate Paths

- Object suggestions are hidden until the selected verb can take objects.
- Passive voice is hidden until an object frame exists.
- Passive focus is hidden until passive voice is selected.
- Recipient focus is hidden until the full ditransitive passive frame exists.
- Active voice is a practical exit from passive recipient focus.
- Lexical `be` is the doorway to noun and adjective complement suggestions.
- Noun and adjective complement suggestions are hidden until lexical `be` is
  selected.
- Normal verbs, especially `work`, are visible exits from lexical `be`.
- Noun complement suggestions follow agent number.
- Object, recipient, and passive-focus suggestions are hidden in lexical `be`.

### Modal And Phrase Paths

- Present modal frames suggest present-compatible modals.
- Future frames suggest `will`.
- When a modal is selected, `no modal` is a high-priority exit.
- Place phrase suggestions are available as location phrases for ordinary
  verbs.
- Destination verbs such as `go`, `come`, `travel`, `arrive`, `leave`, and
  `return` prioritize place suggestions and render them as destinations.
- Time phrase ranking prefers tense/aspect-friendly phrases:
  `today` for simple present, `now` for continuous, `yesterday` for past,
  `tomorrow` for future.

## Widget And Integration Laws

These prove the live UI stays in the tested state-space.

- The app launches into a renderable initial state.
- A visible Compass suggestion changes the rendered sentence.
- A blocked manual probe shows a lock message and keeps the sentence valid.
- A user can enter lexical `be` and exit back to a normal verb.

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
