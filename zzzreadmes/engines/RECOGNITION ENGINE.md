# Recognition Engine

## Recognition Engine performs the opposite transformation of Grammar Engine.

It accepts an English sentence and gradually reconstructs the abstract SentenceState that could later be rendered again by Grammar Engine.

The engine does not translate.

It identifies grammatical structure.

Like Grammar Engine, Recognition Engine is organised as a pipeline.

Each stage discovers one layer of grammatical information and stores it inside a temporary recognition builder.

Later stages build upon information discovered by earlier stages.

The engine intentionally postpones object creation until every important grammatical property has been recognised.

## recognize()

recognize() is the public entry point of Recognition Engine.

It receives an English sentence, tokenises it into words and creates a temporary _RecognitionBuilder.

Every recognition stage contributes information to this builder.

Only after the entire pipeline completes is the final SentenceState constructed.

Implementation-wise recognize() should contain almost no grammatical logic.

Its responsibility is orchestration.

Whenever Recognition Engine grows, new grammatical concepts should appear as new pipeline stages rather than additional logic inside recognize() itself.

## _tokenizeSentence()

Recognition begins by converting text into tokens.

This stage removes punctuation, normalises spacing and splits the sentence into individual words.

Example

The beautiful woman has been working.

becomes

[
The,
beautiful,
woman,
has,
been,
working
]

Every later recognition stage operates on tokens rather than raw text.

Implementation-wise this function intentionally performs no grammatical reasoning.

Its responsibility is preparing the sentence for analysis.

## _recognizeSentenceForm()

Determines the overall sentence form.

Examples include

statement
question
imperative

Recognition Engine first establishes the global sentence structure before analysing individual grammatical components.

This information later influences participant recognition and auxiliary placement.

Implementation-wise this function usually examines only a small number of sentence positions.

## _recognizeVerbChain()

The predicate is recognised before participants.

This stage searches for the complete English verb chain.

It identifies

modal verbs
auxiliaries
lexical verb
tense
aspect
polarity
voice

Examples

works
has worked
will have been working
was built

During this stage Recognition Engine also records the beginning and end of the verb chain.

These boundaries become the foundation for nearly every later recognition stage.

Implementation-wise this function contains the largest collection of conditional grammar rules.

Although the code may appear fragmented, every branch contributes toward solving one problem:

Reconstruct the complete grammatical predicate.

Future refactors should continue grouping logic around grammar concepts rather than token positions.

## _recognizeParticipantBoundaries()

Once the predicate is known, Recognition Engine determines where sentence participants begin and end.

It identifies token ranges representing

subject
object
passive agent

without yet constructing noun phrases.

Examples

The beautiful young woman

or

the new bridge

remain simple token boundaries during this stage.

Implementation-wise this separation allows phrase recognition and participant recognition to remain independent.

## _recognizePhrases()

Recognises sentence phrases that are not participants.

Examples include

place phrases
time phrases
frequency phrases
manner phrases

Each recognised phrase records

phrase model
starting token
ending token

These boundaries are later used to separate phrases from noun phrase recognition.

Implementation-wise this stage intentionally discovers phrase positions rather than constructing final objects.

## _trimParticipantBoundaries()

After phrase recognition completes, participant boundaries are adjusted.

This stage removes recognised phrases from participant ranges.

Without trimming, participant recognition could incorrectly include

every day

inside an object or

yesterday

inside a passive agent.

Implementation-wise this stage exists purely to maintain clean separation between grammatical participants and grammatical phrases.

It performs no phrase recognition itself.

## _buildParticipants()

Once every boundary is known, Recognition Engine finally constructs participant objects.

Each participant boundary is passed into _recognizeNounPhrase().

Examples include

agent
object
passive agent

Unlike previous stages, this function creates grammar objects rather than merely recording indices.

## _recognizeNounPhrase()

Converts a sequence of participant tokens into one abstract NounPhrase.

Responsible for recognising

articles
adjectives
noun
plurality
pronouns
possessives

This function performs the inverse operation of Grammar Engine's _buildNounPhrase().

Implementation-wise it is intentionally reusable for every grammatical participant.

## _buildSentenceState()

The final stage of Recognition Engine.

Every grammatical property has already been discovered.

This function simply transfers information accumulated inside _RecognitionBuilder into an immutable SentenceState.

Implementation-wise this function should contain almost no grammatical reasoning.

Its responsibility is object construction.

# Recognition Philosophy

Recognition Engine gradually removes grammatical decoration from English until only grammatical meaning remains.

Each stage reduces ambiguity.

Each stage discovers information required by the next stage.

Unlike Grammar Engine, which progressively enriches a sentence, Recognition Engine progressively simplifies it.

English sentence
        │
        ▼
recognize()

        │
        ▼
_tokenizeSentence()

        │
        ▼
_recognizeSentenceForm()

        │
        ▼
_recognizeVerbChain()

        │
        ▼
_recognizeParticipantBoundaries()

        │
        ▼
_recognizePhrases()

        │
        ▼
_trimParticipantBoundaries()

        │
        ▼
_buildParticipants()

        │
        ▼
_recognizeNounPhrase()

        │
        ▼
_buildSentenceState()

        │
        ▼
SentenceState
Pipeline Philosophy

Recognition Engine intentionally delays object creation until the grammatical structure of the sentence has already been established.

Earlier stages answer questions such as

Where is the predicate?
Where do participants begin?
Which phrases exist?

Only after those answers are known are grammar objects constructed.

This separation keeps recognition deterministic and makes each stage responsible for exactly one grammatical concern.

Like Grammar Engine, Recognition Engine is organised as an assembly line. Each stage has a single responsibility and passes a richer understanding of the sentence to the next stage. A developer should be able to read this document alongside recognition_engine.dart, identify the corresponding function, understand why it exists before reading how it is implemented, and navigate the code by grammatical responsibility rather than by nested conditionals or token manipulations.