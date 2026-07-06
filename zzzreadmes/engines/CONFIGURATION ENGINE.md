# Configuration Engine

Configuration Engine governs movement through the space of valid SentenceState configurations.

Unlike Grammar Engine or Recognition Engine, it never processes English text.

Instead, it accepts physical interactions originating from the user interface and transforms them into valid grammatical state transitions.

Grammar Engine later expresses those states as English.

Recognition Engine later reconstructs those states from English.

Configuration Engine exists entirely before language appears.

## applyMove()

applyMove() is the public entry point of Configuration Engine.

It receives the current SentenceState together with a single physical interaction represented by ConfigurationMove.

Examples include

rotating the verb wheel
rotating the aspect wheel
toggling voice
selecting a place
completing a minigame interaction

The function never modifies the existing configuration directly.

Instead it creates a candidate configuration and gradually transforms it into the nearest valid grammatical configuration.

Implementation-wise applyMove() contains almost no grammar.

Its responsibility is orchestration.

Like the other engines, grammatical behaviour belongs to dedicated pipeline stages.

## _applyMove()

The first stage applies only the user's requested interaction.

Produces the first candidate configuration.

No grammar corrections happen yet.

If the learner rotates the verb wheel

work

↓

travel

only the verb changes.

Every dependent grammatical inconsistency is intentionally preserved for the moment.

The resulting configuration is usually incomplete or even impossible.

Implementation-wise this stage performs exactly one user action.

Nothing more.

## _resolveConstraints()

This is the heart of Configuration Engine.

Its responsibility is not generating English.

Its responsibility is restoring grammatical consistency.

Resolves every grammatical dependency created by the requested move.

Every grammar rule acts as an independent constraint.

Continues until the configuration becomes stable.

Examples include

intransitive verbs remove objects
passive voice requires an object
destination verbs require destination places
unsupported aspects fall back to valid ones
modal verbs constrain verb forms

Rather than executing one large algorithm, this stage repeatedly applies small grammatical corrections until the configuration becomes stable.

Conceptually this behaves like an industrial interlock system.

Changing one component may automatically affect many others.

## _resolveVerbConstraints()

Resolves constraints originating from the selected lexical verb.

Examples include

object requirements
passive availability
supported aspects
supported voices
place usage
phrase availability

Implementation-wise this stage centralises every rule that depends primarily upon verb properties.

As the grammar grows, most newly introduced verb features should naturally appear here.

## _resolveAspectConstraints()

Ensures the selected grammatical aspect remains compatible with the current configuration.

Examples include

unsupported aspects
auxiliary requirements
interaction with modality
interaction with voice

Implementation-wise this stage never generates auxiliaries.

It only validates abstract grammar.

Grammar Engine later renders those decisions.

## _resolveVoiceConstraints()

Maintains consistency between active and passive voice.

Examples include

participant swapping
passive availability
object requirements
passive agent handling

Implementation-wise participant movement belongs here rather than inside Grammar Engine.

Grammar Engine simply renders whichever participants Configuration Engine provides.

## _resolveModalConstraints()

Maintains consistency between modal verbs and the remaining grammatical state.

Examples include

supported aspects
future tense interaction
infinitive verb forms
auxiliary availability

Grammar Engine later converts these abstract decisions into English.

## _resolveParticipantConstraints()

Maintains valid relationships between grammatical participants.

Examples include

missing subjects
missing objects
duplicated participants
impossible passive constructions

Implementation-wise this stage never renders noun phrases.

It only guarantees a valid grammatical configuration.

## _resolvePhraseConstraints()

Maintains phrase consistency.

Examples include

place requirements
destination versus location
unsupported phrase meanings
phrase compatibility with selected verbs

Implementation-wise this stage operates entirely upon abstract phrase models.

Grammar Engine later converts them into English.

``` not in MPV
## _explainCorrections()

Generates explanations for every automatic correction performed during constraint resolution.

Examples include

Passive Voice disabled.

Travel does not accept an object.

Destination selected automatically.

Perfect Continuous simplified.

This stage powers Guided Mode.

Grammar rules become educational explanations.

```

## _collectChanges()

Records every automatic modification performed during constraint resolution.

Examples include

Object removed

↓

Passive disabled

↓

Destination selected

These changes become available to the user interface.

Different interaction modes may choose to display or ignore them.

```

_collectAnimations()

Produces semantic animation events rather than graphical animations.

Examples include

Verb wheel rotated

Object disappeared

Voice toggle switched

Place wheel advanced

The UI decides how to animate them.

Configuration Engine merely describes what changed.

_collectHighlights()

Marks sentence components affected by the move.

Examples include

verb

↓

object

↓

place

The UI may highlight corresponding wheels or sentence fragments.

This stage enables learners to observe which grammatical concepts interact.

_collectAvailableMoves()

Discovers every valid interaction from the current configuration.

Examples include

Rotate Verb

✓

Rotate Aspect

✓

Passive

✗

Rotate Time

✓

Guided Mode can use this information to enable or disable controls dynamically.

_collectReachableStates()

Determines neighbouring configurations.

Unlike Grammar Engine or Recognition Engine, Configuration Engine naturally defines a graph.

Every valid interaction represents one edge.

This stage exposes the graph surrounding the current configuration without explicitly storing it.

_generateHints()

Produces educational hints.

Examples include

Try changing Aspect next.

Passive Voice becomes available
after selecting another verb.

Travel usually requires a destination.

Hints should emerge from the current configuration rather than being predefined lessons.

_generateChallenges()

Produces small learning objectives.

Examples include

Build a passive sentence.

Ask a question.

Use Future Perfect.

Remove the object.

Travel somewhere.

The same engine that validates grammar becomes capable of generating exercises.

_evaluateObjective()

Checks whether a learner has achieved a requested configuration.

Examples include

Passive reached.

Question reached.

Present Perfect reached.

Minigames and lessons can therefore reuse Configuration Engine instead of implementing their own validation logic.

_recordHistory()

Stores every successful interaction.

Examples include

Verb

↓

Aspect

↓

Voice

↓

Place

History enables

undo
replay
lesson reconstruction
learner analytics
_suggestUndo()

Determines how to return to the previous stable configuration.

Undo becomes another valid interaction rather than reversing arbitrary field mutations.

_generateGuidedPath()

Produces a shortest sequence of valid interactions between two configurations.

Instead of

Sentence A

↓

Sentence B

Configuration Engine may discover

Rotate Verb

↓

Toggle Voice

↓

Rotate Aspect

↓

Rotate Time

This stage naturally supports Guided Mode.

_generateAssistedPath()

When the learner requests an impossible move, Assisted Mode may automatically discover the nearest reachable configuration.

Instead of rejecting the interaction, Configuration Engine navigates toward the closest valid state.

_evaluateProgress()

Measures how much of the configuration space the learner has explored.

Examples include

Present

✓

Past

✓

Passive

✓

Perfect Continuous

✗

Progress emerges from explored configurations rather than completed lessons.

_serializeConfiguration()

Produces a portable description of the current configuration.

Future features may include

sharing
saving
bookmarks
reproducible lessons

```

## _buildResult()

Produces the final ConfigurationResult.

Rather than returning only the new SentenceState, Configuration Engine also returns information describing how the state changed.

Typical result information includes

previous configuration
resulting configuration
originating user interaction
automatic changes
explanatory messages

This allows the same engine to support multiple interaction models without duplicating grammar logic.

## Configuration Philosophy

Configuration Engine does not construct sentences.

It does not recognise sentences.

It governs movement between sentences.

Every interaction begins with one physical move.

Every pipeline stage gradually restores grammatical consistency until the configuration reaches another stable state.

Unlike Grammar Engine, which enriches grammar into language, or Recognition Engine, which removes language into grammar, Configuration Engine transforms one grammatical configuration into another.

SentenceState
        │
        ▼
applyMove()

        │
        ▼
_applyMove()

        │
        ▼
_resolveVerbConstraints()

        │
        ▼
_resolveAspectConstraints()

        │
        ▼
_resolveVoiceConstraints()

        │
        ▼
_resolveModalConstraints()

        │
        ▼
_resolveParticipantConstraints()

        │
        ▼
_resolvePhraseConstraints()

        │
        ▼
_collectChanges()

        │
        ▼
_buildResult()

        │
        ▼
SentenceState


## Pipeline Philosophy

Configuration Engine deliberately separates interaction from grammar.

The user never edits a SentenceState directly.

Instead, every wheel rotation, toggle, button press or minigame interaction proposes a change.

The engine accepts that proposal, evaluates every grammatical dependency and allows the entire configuration to settle into the nearest valid state before exposing it to the user interface.

The UI therefore never contains grammar logic.

It simply presents a collection of windows into the much richer configuration maintained by Configuration Engine. Different interfaces—Padlock, Assisted Mode, Guided Mode, Lid Off or future minigames—observe exactly the same engine, differing only in how they visualize or constrain its behaviour.