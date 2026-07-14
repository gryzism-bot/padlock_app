# padlock_app

A new Flutter project.

# Getting Started

It's a padlock to learn English

install VS Code, git

clone this repository with git installed: git clone https github com yada yada, a green CODE button on the top right of files preview

or download zip and

open directory with cloned or unzipped repository with VS Code

install Flutter plugin in VS Code

check if Flutter is installed with flutter -v, it shouldn't return red text with flutter not recognized, I think flutter plugin installs it, it also provides autocomplete

start app in Chrome from main repo directory with flutter run -d chrome

it runs home_screen.dart because that's what main.dart's main function points to as "home"

https://www.youtube.com/watch?v=SFlcKbPftog


quick run flutter test

## Night generative contract runner

The loose overnight runner stress-tests the current Grammar Engine,
Recognition Engine, and data layer by generating `SentenceState` combinations,
rendering them, recognizing them, and rendering them again.

Quick smoke run:

```powershell
dart run tool\night_contract.dart --limit=500 --exit-zero
```

One fixed minute:

```powershell
dart run tool\night_contract.dart --minutes=1 --exit-zero
```

Longer run:

```powershell
dart run tool\night_contract.dart --minutes=480 --exit-zero
```

Useful options:

```powershell
--checkpoint-every=1000
--report=build\night_contract_report.md
--jsonl=build\night_contract_findings.jsonl
--fail-fast
--state-drift-fails
```

Safe interrupt:

- Press `Ctrl+C`.
- The runner requests a stop, writes the current markdown report, and keeps
  findings already streamed to JSONL.
- JSONL findings are appended as they occur, so an interrupted run still leaves
  useful evidence.

Default output:

- `build/night_contract_report.md`
- `build/night_contract_findings.jsonl`

## Night Configuration contract runner

The Configuration overnight runner stress-tests the interaction layer. It does
not click the Flutter UI. Instead, it walks `ConfigurationState` through
Compass-visible suggestions, checks every accepted move through the Lock, and
probes nearby direct moves to collect candidate laws.

Use this when the question is closer to:

- did Compass expose a move the Lock rejects?
- which Lock laws appear near real guided states?
- which rails wake most often?
- which laws should be promoted into the Configuration Law Map?

One fixed minute:

```powershell
dart run tool\night_configuration.dart --minutes=1 --exit-zero
```

Overnight run:

```powershell
dart run tool\night_configuration.dart --minutes=480 --exit-zero --report=build\night_configuration_overnight.md --jsonl=build\night_configuration_overnight.jsonl
```

Useful options:

```powershell
--seed=20260712
--max-steps=24
--checkpoint-every=1000
--probe-every=3
--sample-every=250
--fail-on-compass-leak
```

Safe interrupt:

- Press `Ctrl+C`.
- The runner requests a stop, writes the current markdown report, and keeps
  JSONL events already streamed to disk.
- If the process is killed hard, JSONL still contains run start, first-seen law
  probes, Compass leaks, render failures, and periodic guided move samples.

Default output:

- `build/night_configuration_report.md`
- `build/night_configuration_findings.jsonl`

# ARKITEKCZURALLY
check poster grammar engine as water treatment system png

See also: `zzzreadmes/ARCHITECTURE.md` for the Predicate Paths / good
hardcoding keepsake.

## Grammar Engine renders a frame. Recognition Engine reconstructs a frame from sentence. Configuration Engine governs the movie.

## Engine question map

Each engine owns a different question. When a new law appears, put it in the
lowest engine that can answer it without stealing another engine's job.

### Grammar Engine

Question:

Given a complete `SentenceState`, what English sentence does it render?

Grammar Engine owns form laws:

- active double-object frame: `John gave Mary a book.`
- active prepositional recipient: `John gave a book to Mary.`
- active beneficiary recipient: `John bought a book for Mary.`
- passive object focus: `A book was given to Mary by John.`
- passive beneficiary phrase: `A book was bought for Mary by John.`
- passive recipient focus: `Mary was given a book by John.`
- object-case pronouns in participant phrases: `to him`, `for her`, `by me`
- hidden passive agent: `A book was given to Mary.`
- questions, negatives, modals, tense, aspect, and voice around those forms

If changing a rule changes the sentence text, it probably belongs here.

### Recognition Engine

Question:

Given an English sentence from the app's language space, what `SentenceState`
does it reconstruct?

Recognition Engine owns the mirror of Grammar Engine's form laws:

- `John gave Mary a book.` reconstructs recipient before object
- `John gave a book to Mary.` reconstructs object before `to` recipient
- `John bought a book for Mary.` reconstructs object before `for` recipient
- `A book was given to Mary by John.` reconstructs passive object focus
- `Mary was given a book by John.` reconstructs passive recipient focus
- phrase boundaries do not swallow time/place/frequency/manner phrases

If changing a rule changes how sentence text is parsed, it probably belongs
here.

### Configuration Engine / Lock

Question:

Is this `SentenceState` allowed as a guided state?

Configuration Engine owns validity laws:

- active voice requires an agent
- passive object focus requires an object
- recipient frames require an object
- recipient-capable verbs must also be object-capable
- lexical `be` excludes object, recipient, and passive voice
- modal/tense/frame combinations are allowed or blocked
- noun phrase determiners must fit number and article sound

If changing a rule changes whether a state is permitted, it probably belongs
here.

### Configuration Compass

Question:

From this valid state, what should the user see next?

Compass owns navigation and suggestion laws:

- which verb chips appear first
- which rails are awake, hidden, collapsed, or selected
- which option is ranked first for a verb
- which selected option stays visible
- which nearby move previews best from the current state

If changing a rule changes what option appears first, appears at all, or gets
suggested, it probably belongs here.

### Semantic C-section

Question:

Does this valid form make sense as an English meaning?

The semantic layer is future C-section work:

- `I eat street` should be blocked, greyed, or explained
- `I drink school` should be blocked, greyed, or explained
- `I run to you` should be allowed
- `play` should prefer sports, games, music, and instruments
- same-participant cases should become reflexive or suspicious:
  `You gave yourself a book`, not `You gave you a book`

If changing a rule judges meaning or world-fit without changing grammar form,
it probably belongs here.

Short rule:

- text changes -> Grammar Engine
- parsing changes -> Recognition Engine
- state validity changes -> Configuration Engine
- option visibility/ranking changes -> Configuration Compass
- meaning/world-fit changes -> semantic C-section

## UI shaves what Configuration Engine knows

Grammar Engine renders sentence from SentenceState object that has agent, object, tense, verb, polarity, aspect, phrases etc filled with data objects based on model classes

Configuration Engine treats SentenceStates as frames connected by valid interactions rather than isolated configurations.

Recognition Engine started as a test tool for Grammar Engine to make it work backwards and it does the opposite: parses SentenceState from a sentence, which on UI will be limited to autocomplete narrowing in subject/verb/modal/phrase input list

Configuration Engine knows current position on a graph and possible moves on that graph of grammar trees, based on fields in data models, 
it contains logic like "if modal can chosen, verb can't be can too", or "if passive voice chosen, subject splits to agent and object", 
"if modal will chosen, verb be stays be"(not sure, maybe it's because of tense future, but you better get the idea) etc

Every physical interaction (wheel rotation, toggle, minigame action) represents movement through the configuration space rather than direct mutation of grammar.

Configuration Engine does not generate or recognize language. It governs movement through the space of valid SentenceState configurations.

The graph of valid sentence configurations is implicit. It emerges from grammar constraints instead of being explicitly stored.

A learner never manipulates grammar directly—they perform physical interactions (wheel rotations, toggles, game actions). Configuration Engine translates those interactions into valid grammatical transitions.

The UI is not a grammar editor. It is a collection of windows into a much richer configuration space, exposing only the information required by the current interaction model.

## UI turns scattered options into paths

The current guided screen is a developer cockpit. It exposes many rails at
once, which is useful while building the machine but too broad for the final
toy. The product UI should be centered on the sentence and especially on the
predicate. A user should touch one visible word, then follow the path that word
opens.

Water-treatment model:

- user intent is pressure
- `SentenceState` is the current water shape in the system
- Configuration Engine / Lock is the set of valves that cannot open into an
  invalid state
- Configuration Compass routes pressure into the useful next pipes
- UI shows only the pipework around the valve currently being touched
- collapse/reset releases pressure from the current local branch

This is both a product rule and a performance rule. As the sentence becomes
more specific, the UI should narrow the interaction tree instead of widening it.
More committed sentence detail means more pressure in the system, so parallel
pipes should close until the current branch is collapsed.

Example:

- The starter sentence can be `You learn.`
- `You` and `learn` are visible sentence fields.
- Clicking `learn` opens verb-centered choices.
- Choosing `learn` can reveal only `learn`-specific doors:
  objects/skills, companion, place, time, manner.
- While a `learn` feature door is open, Compass does not need to compute every
  other verb and every rail those verbs could wake.
- Clicking `You` opens the subject path:
  pronouns first, then third-person noun expansion if requested.

The final UI should therefore feel closer to backend design than the current
cockpit: one predicate in the center, with the sentence unfolding outward from
the active word.

## Configuration Engine prevents UI's HomeScreen from importing Grammar Engine's generate(SentenceState: (subject, tense, aspect, modal, verb, polarity, voice, etc.)) and grammar logic implementation, it prevents HomeScreen from becoming GrammarEngine's generate parameter filler which can damage it's performance with hundreds of data consts with tens of translations

Grammar Engine and Recognition Engine transform language. Configuration Engine transforms interaction.

## All Side Quests First Driven Development

Features are added before abstractions

A side quest is complete when it changes your understanding of the main quest.

An engine is to be implemented when existing ones no longer answer new questions


# UI

UI is Configuration Engine shaven to 2-3 closest possible moves, because of wheel nature and perspective, you see these wheels just like you'd have a rollerblade in front of you facing you, you see an oval rectangle but you know it's a wheel facing you, there is no clockwise/counterclockwise, it's up down, left right

in lid on mode it shows wheels that manipulate Grammar Engine and shows SentenceState

in lid off mode it shows how Grammar Engine works, shows lid on's wheels as SentenceState's fields of subject, verb, tense, aspect, modal, polarity, voice, etc

in lid on mode it has autocomplete guided "input" that gives Recognition Engine a sentence to parse SentenceState

Different interaction models (Assisted, Guided, Lid Off, Minigames) differ only in how they expose or enforce Configuration Engine, not in the grammar they operate on.


## Configuration Engine provides time, Grammar Engine provides rules, developer can provide space for minigames, Grammar Engine so abstract it could become a boss fight

or a platform game

or an origami

or a freeskate line

or a maze


## UI has a button to show crude translations and it has to be held to function, no translation on/off, only hold

## UI has a toggle to like drone's auto or manual or off mode: 

🟢 Assisted

Configuration Engine repairs everything automatically - turns wheels when necessary

🟡 Guided

Configuration Engine blocks impossible moves and explains why.

🔴 Manual

Configuration Engine blocks impossible moves but gives no explanation.

☠ Explorer

Configuration Engine OFF.

Grammar and Recognition receive whatever monstrosity the user creates. User may set "John can can at home".
