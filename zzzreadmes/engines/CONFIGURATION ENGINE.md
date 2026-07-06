# Configuration Engine

Configuration Engine governs movement through the space of valid sentence configurations.

Unlike Grammar Engine and Recognition Engine, it never processes English text.

Instead, it accepts a physical interaction performed by the learner, transforms the current grammatical configuration into another valid grammatical configuration, and finally prepares everything required by the user interface to render that new state.

Grammar Engine later converts the resulting `SentenceState` into English.

Recognition Engine later reconstructs the same `SentenceState` from English.

Configuration Engine exists entirely between the learner and grammar.

It is therefore an **interaction engine**, not a language engine.

---

# Pipeline

```text
ConfigurationMove

        │

        ▼

_applyMove()

        │

        ▼

_resolveConstraints()

        │

        ▼

_buildSentenceState()

        │

        ▼

_buildViewports()

        │

        ▼

_buildToggleStates()

        │

        ▼

_collectMessages()

        │

        ▼

_collectHighlights()

        │

        ▼

_buildConfigurationState()

        │

        ▼

ConfigurationState
```

Grammar Engine transforms

```text
SentenceState

↓

English
```

Recognition Engine transforms

```text
English

↓

SentenceState
```

Configuration Engine transforms

```text
ConfigurationMove

↓

ConfigurationState
```

---

# ConfigurationMove

ConfigurationMove represents one physical interaction performed by the learner.

Examples include

- rotating the verb wheel
- rotating the subject wheel
- rotating the tense wheel
- rotating the aspect wheel
- toggling passive voice
- toggling polarity
- selecting a phrase
- completing a minigame interaction

A ConfigurationMove is **not grammar**.

It represents only what the learner physically attempted to do.

---

# applyMove()

`applyMove()` is the public entry point of Configuration Engine.

It receives

- current ConfigurationState
- one ConfigurationMove

and returns a completely new ConfigurationState.

Implementation-wise `applyMove()` should contain almost no grammar.

Like the public entry points of Grammar Engine and Recognition Engine, its responsibility is orchestration.

Every grammatical concern belongs to dedicated pipeline stages.

---

# _applyMove()

This stage applies only the learner's requested interaction.

Nothing else.

Example

```text
Rotate Verb Wheel

↓

work

↓

travel
```

At this point

- objects are not removed
- passive voice is not disabled
- places are not corrected

The configuration is intentionally allowed to become temporarily inconsistent.

Implementation-wise this function performs exactly one physical interaction.

Nothing more.

---

# _resolveConstraints()

This is the heart of Configuration Engine.

Its responsibility is restoring grammatical consistency.

Every grammar rule behaves as an independent interlock.

Examples include

- verbs removing impossible objects
- passive voice requiring transitive verbs
- destination verbs selecting destination places
- unsupported aspects simplifying automatically
- modal verbs constraining predicate construction

Conceptually this behaves like an industrial valve system.

One visible interaction may automatically produce many hidden corrections before the configuration becomes stable.

Implementation-wise grammar rules should remain small and grouped by grammatical concept rather than by wheel or UI component.

---

# _buildSentenceState()

Once every constraint has been resolved, Configuration Engine produces the canonical SentenceState.

SentenceState remains the common language shared by

- Grammar Engine
- Recognition Engine
- Configuration Engine

Implementation-wise this stage performs almost no reasoning.

Its responsibility is constructing the abstract grammatical representation understood by the remaining engines.

---

# _buildViewports()

This stage prepares every wheel visible to the learner.

Configuration Engine knows the complete grammar space.

The learner never sees it.

Instead, every wheel receives only a small visible neighbourhood.

Example

```text
learn

travel

WORK

build

eat
```

Although hundreds of verbs may exist internally, the UI receives only the five currently visible labels.

Implementation-wise this stage prevents grammar logic from leaking into Flutter widgets.

The UI never computes neighbouring values.

Configuration Engine already knows them.

---

# _buildToggleStates()

Constructs every visible toggle.

Examples include

- Voice
- Polarity
- Sentence Form

Every toggle reports

- current value
- enabled state
- optional explanation

The user interface therefore never asks

> Can this toggle be pressed?

It simply renders the answer already prepared by Configuration Engine.

---

# _collectMessages()

Collects explanations produced during constraint resolution.

Examples include

```text
Travel cannot be passive.

Object removed automatically.

Destination selected automatically.
```

Different application modes decide whether these explanations are displayed.

The engine always produces them.

---

# _collectHighlights()

Determines which grammatical concepts changed during the interaction.

Examples include

```text
Verb

↓

Object

↓

Place
```

The UI may highlight

- wheels
- sentence fragments
- grammar explanations

Configuration Engine itself remains presentation independent.

---

# _buildConfigurationState()

Produces the final interaction snapshot.

Unlike SentenceState, ConfigurationState represents everything required by the interface.

Typical contents include

- SentenceState
- wheel viewports
- toggle states
- explanation messages
- highlighted grammar concepts

Every UI consumes the same ConfigurationState.

Only the amount of exposed information differs.

---

# UI Shaving

Configuration Engine always knows significantly more than the user interface.

The user interface never computes grammar.

Instead it receives a deliberately reduced view of the complete interaction state.

This relationship is described as

> UI shaves what Configuration Engine knows.

Example

```text
Configuration Engine

██████████████████████████████

██████████████████████████████

██████████████████████████████

██████████████████████████████

██████████████████████████████

               │

               ▼

        ConfigurationState

               │

               ▼

        Wheel Viewports

               │

               ▼

               UI
```

The UI therefore becomes a collection of windows into a much richer configuration space.

Different interfaces simply shave different parts of Configuration Engine.

Examples include

- Padlock Mode
- Assisted Mode
- Guided Mode
- Lid Off Mode
- Minigames

None of them contain grammar logic.

---

# ConfigurationState

ConfigurationState represents the entire interaction state visible to the learner.

Unlike SentenceState, which describes grammar, ConfigurationState describes interaction.

Typical structure

```text
ConfigurationState

├── SentenceState
│
├── Subject Wheel
├── Verb Wheel
├── Aspect Wheel
├── Tense Wheel
├── Modal Wheel
├── Place Wheel
├── Time Wheel
├── Frequency Wheel
├── Manner Wheel
│
├── Voice Toggle
├── Polarity Toggle
├── Sentence Form Toggle
│
├── Messages
│
├── Highlights
│
└── Future animation events
```

The UI should require little more than ConfigurationState to render itself.

---

# Pipeline Philosophy

Grammar Engine gradually enriches grammar until it becomes English.

Recognition Engine gradually removes English until only grammar remains.

Configuration Engine gradually transforms one grammatical configuration into another while preserving grammatical consistency.

Grammar Engine transforms language.

Recognition Engine reconstructs language.

Configuration Engine governs interaction.

---

# Future Pipeline

Future versions of Configuration Engine should extend the interaction pipeline without changing its architecture.

Every future feature should become another pipeline stage rather than introducing grammar logic into the user interface.

Possible future stages include

```text
ConfigurationMove

↓

_applyMove()

↓

_resolveConstraints()

↓

_buildSentenceState()

↓

_buildViewports()

↓

_buildToggleStates()

↓

_collectMessages()

↓

_collectHighlights()

↓

_collectAnimations()

↓

_collectAvailableMoves()

↓

_generateHints()

↓

_generateChallenges()

↓

_evaluateObjective()

↓

_recordHistory()

↓

_suggestUndo()

↓

_buildConfigurationState()

↓

ConfigurationState
```

---

# Future Pipeline Components

## _collectAnimations()

Produces semantic animation events rather than Flutter animations.

Examples

- wheel rotated
- toggle switched
- object disappeared
- phrase appeared

The UI decides how those events are rendered.

---

## _collectAvailableMoves()

Discovers interactions currently reachable from this configuration.

Useful for Assisted and Guided modes.

Examples include

- next verb
- previous aspect
- available voice
- available modal

---

## _generateHints()

Produces educational hints based upon the current configuration.

Examples

- Try Passive Voice next.
- Future Perfect is now available.
- Travel usually requires a destination.

---

## _generateChallenges()

Produces learning objectives dynamically from the current configuration.

Examples

- Build a passive sentence.
- Ask a question.
- Remove the object.
- Use Present Perfect.

---

## _evaluateObjective()

Determines whether the learner has achieved a requested grammatical configuration.

Allows lessons and minigames to reuse Configuration Engine instead of implementing independent validation.

---

## _recordHistory()

Stores the sequence of successful ConfigurationMoves.

History enables

- replay
- undo
- learner analytics
- lesson reconstruction

---

## _suggestUndo()

Computes the previous stable interaction state.

Undo therefore becomes another valid interaction rather than reversing arbitrary field mutations.

---

# Long-term Philosophy

Configuration Engine should remain the single source of truth for interaction.

Grammar Engine and Recognition Engine understand language.

Configuration Engine understands movement.

The learner never edits grammar directly.

The learner moves through grammar.

Every wheel, toggle and future minigame becomes another window into the same Configuration Engine.

Every UI is therefore only another way of shaving the same underlying interaction model.