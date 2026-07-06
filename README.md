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


quick run flutter test

# ARKITEKCZURALLY
check poster grammar engine as water treatment system png

## Grammar Engine renders a frame. Recognition Engine reconstructs a frame from sentence. Configuration Engine governs the movie.

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

## Configuration Engine prevents UI's HomeScreen from importing Grammar Engine's generate(SentenceState: (subject, tense, aspect, modal, verb, polarity, voice, etc.)) and grammar logic implementation, it prevents HomeScreen from becoming GrammarEngine's generate parameter filler which can damage it's performance with hundreds of data consts with tens of translations

Grammar Engine and Recognition Engine transform language. Configuration Engine transforms interaction.

## All Side Quests First Driven Development

Features are added before abstractions

A side quest is complete when it changes your understanding of the main quest.

An engine is to be implemented when existing ones no longer answer new questions


# UI

UI is Configuration Engine shaven to 2-3 closest possible moves, because of wheel nature and perspective

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

