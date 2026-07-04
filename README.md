# padlock_app

A new Flutter project.

# Getting Started

It's a padlock to learn English

install VS Code, git

clone this repository with git installed: git clone https github com yada yada, an icon on the top right of code preview I think

open directory with cloned repository with VS Code

install Flutter plugin in VS Code

check if Flutter is installed with flutter -v, it shouldn't return red text with flutter not recognized, I think flutter plugin installs it, it also provides autocomplete

start app in Chrome from main repo directory with flutter run -d chrome

it runs home_screen.dart because that's what main.dart's function points to as "home"


quick run flutter test

# ARKITEKCZURALLY
check poster grammar engine as water treatment system png

## Grammar Engine renders a frame. Recognition Engine reconstructs a frame from sentence. Configuration Engine governs the movie.

## UI shaves what Configuration Engine knows

Grammar Engine renders sentence from SentenceState object that has agent, object, tense, verb, polarity, aspect, phrases etc filled with data objects based on model classes

Recognition Engine started as a test tool for Grammar Engine to make it work backwards and it does the opposite: parses SentenceState from a sentence, which on UI will be limited to autocomplete narrowing in subject/verb/modal/phrase input list

Configuration Engine knows current position on a graph and possible moves on that graph of grammar trees, based on fields in data models, 
it contains logic like "if modal can chosen, verb can't be can too", or "if passive voice chosen, subject splits to agent and object", 
"if modal will chosen, verb be stays be"(not sure, maybe it's because of tense future, but you better get the idea) etc

## Configuration Engine prevents UI's HomeScreen from importing Grammar Engine's generate(SentenceState: (subject, tense, aspect, modal, verb, polarity, voice, etc.)) and grammar logic implementation
it prevents HomeScreen from becoming GrammarEngine's generate parameter filler which can damage it's performance with hundreds of data consts with tens of translations

## All Side Quests First Driven Development

Features are added before abstractions

A side quest is complete when it changes your understanding of the main quest.

An engine is to be implemented when existing ones no longer answer new questions


# UI

UI is Configuration Engine shaven to 2-3 closest possible moves, because of wheel nature and perspective

in lid on mode it shows wheels that manipulate Grammar Engine and shows SentenceState

in lid off mode it shows how Grammar Engine works, shows lid on's wheels as SentenceState's fields of subject, verb, tense, aspect, modal, polarity, voice, etc

in lid on mode it has autocomplete guided "input" that gives Recognition Engine a sentence to parse SentenceState


Configuration Engine provides time, Grammar Engine provides rules, developer can provide space for minigames, Grammar Engine so abstract it could become a boss fight

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

