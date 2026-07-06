# Grammar Engine

## Grammar Engine is responsible for transforming an abstract SentenceState into a natural English sentence.

It operates as a pipeline. Each stage enriches the sentence with one grammatical layer while assuming all previous stages have already completed successfully.

The engine never decides what the sentence means. That decision has already been made by SentenceState.

Its responsibility is to determine how that meaning is expressed in English.

Every private function represents one stage of this transformation.

The output of one stage becomes the input of the next.

## build()

build() is the public entry point of Grammar Engine.

It receives a fully populated SentenceState, creates a temporary builder object and executes every grammar stage in a predefined order.

The builder acts as a workspace where partially constructed sentence components are stored until the sentence is complete.

Implementation-wise, build() intentionally contains almost no grammatical logic.

Its responsibility is orchestration.

When adding new grammatical features, they should almost never be implemented directly inside build(). Instead, they belong to one of the dedicated pipeline stages or to a newly extracted stage if the grammar concept introduces a new responsibility.

Conceptually, build() is the conductor of the orchestra rather than one of the musicians.

## _buildVerbChain()

The predicate is the grammatical centre of every sentence.

For this reason the verb chain is constructed before any other sentence component.

This stage examines the grammatical properties stored inside SentenceState and determines every verb required to express them.

These include:

tense
aspect
voice
modality
polarity

Depending on their combination, the function decides which auxiliaries appear, in which order they appear, and which lexical verb form should be produced.

For example, the following abstract configuration

Future
Perfect Continuous
Passive

gradually becomes

will

↓

will have

↓

will have been

↓

will have been being

↓

will have been being built

The resulting predicate is stored inside the builder rather than immediately converted into text.

Implementation-wise this function contains a large number of conditional branches.

Although they appear independent, they are all solving one problem:

Construct the complete English predicate.

Future refactors should prefer extracting smaller helper methods grouped around one grammatical concept rather than separating conditions arbitrarily.

Examples include:

modal handling
aspect handling
passive handling
auxiliary insertion
lexical verb inflection
_buildParticipants()

Once the predicate exists, Grammar Engine determines the sentence participants.

Participants are abstract grammatical entities represented by NounPhrase objects.

This stage transforms those objects into their English representation.

Unlike the predicate stage, participant generation is largely independent from tense or modality.

Instead it focuses on grammatical roles.

It decides:

who becomes the grammatical subject
whether an object exists
whether a passive agent should be rendered
in which order participants should later appear

Implementation-wise this stage delegates most work to _buildNounPhrase().

Its own responsibility is not rendering nouns.

Its responsibility is determining which participants belong in the sentence.

## _buildNounPhrase()

This function converts one abstract noun phrase into English.

It is intentionally reusable.

The same implementation is used whether the noun phrase represents

subject
object
passive agent

The function resolves every property required to render a noun naturally.

These include:

article selection
adjective ordering
plurality
possessives
pronouns
noun form

The implementation is intentionally isolated because noun generation is one of the most reusable grammar operations in the project.

Future grammatical extensions such as demonstratives, quantifiers or ordinal numbers should naturally belong here rather than inside participant generation.

_buildPlacePhrase()

Place phrases describe spatial relationships.

Grammar Engine receives an already selected PlacePhrase.

Its task is to determine how that location should appear in English.

The function resolves

preposition
article
noun rendering

using information already stored inside the place phrase model.

For example

destination

bridge

becomes

to the bridge

while

location

park

becomes

in the park

Implementation-wise this function deliberately contains almost no decision-making regarding sentence structure.

Its only responsibility is rendering one place phrase.

Choosing which place phrase exists belongs to Configuration Engine.

_buildTimePhrase()

Time phrases describe when an action occurs.

Grammar Engine simply converts the selected phrase into text.

Examples include

yesterday
tomorrow
last week
next year

The implementation is intentionally small because all grammatical meaning has already been resolved before reaching this stage.

## _buildFrequencyPhrase()

Frequency phrases describe how often an action occurs.

Examples include

always
usually
often
every day

The implementation mirrors the structure of _buildTimePhrase().

Keeping these functions separate allows future grammatical rules affecting frequency expressions to evolve independently from time expressions.

## _buildMannerPhrase()

Manner phrases describe how an action is performed.

Examples include

carefully
quickly
with enthusiasm

Although currently simple, separating manner generation into its own pipeline stage prevents phrase-specific logic from spreading into sentence assembly.

## _buildSentence()

At this point every sentence component already exists.

Nothing new is generated here.

Instead this function assembles previously constructed components into their final order.

Typical ordering includes

subject
auxiliary verbs
lexical verb
object
place phrase
time phrase
frequency phrase
manner phrase

Implementation-wise this function should contain almost no grammatical decisions.

It should only express English word order.

This separation makes debugging significantly easier because incorrect word generation and incorrect word ordering become independent problems.

## _cleanupSentence() (a stub, it's just capitalization in build sentence for now)

Cleanup is the final pipeline stage.

The sentence is already grammatically complete.

Only presentation remains.

Typical operations include

removing duplicate spaces
trimming whitespace
capitalization
punctuation
final formatting

This function intentionally performs no grammatical reasoning.

Its responsibility ends at typography.

## Pipeline Philosophy

Every pipeline stage has exactly one grammatical responsibility.

Each stage receives a richer sentence than the previous stage and passes an even richer sentence to the next.

The engine therefore behaves more like an assembly line than a collection of independent helper functions.

SentenceState
        │
        ▼
build()

        │
        ▼
_buildVerbChain()

        │
        ▼
_buildParticipants()

        │
        ▼
_buildPlacePhrase()

        │
        ▼
_buildTimePhrase()

        │
        ▼
_buildFrequencyPhrase()

        │
        ▼
_buildMannerPhrase()

        │
        ▼
_buildSentence()

        │
        ▼
_cleanupSentence()

        │
        ▼
English sentence