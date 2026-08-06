# Idiom Review

Purpose: one place to review idioms currently present in
`lib/data/idioms/idiom_patterns.dart`.

Use this as the hand-authored idiom audit sheet. These are not broad grammar
rules; they are memorable predicate routes the product can recognize and
celebrate when the user finds them.

Current target: 58 idioms.

## Right Particle Idioms

give up - give up + habit - stop doing something - You give up smoking.
give up - give up - stop trying - You give up.
give back - give back + thing - return something - You give back the book.
give away - give away + thing - donate or reveal something - You give away a secret.
find out - find out - discover information - You find out.
work out - work out - exercise or solve something - You work out.
open up - open up - become open or speak more freely - You open up.
close down - close down - stop operating - The shop closes down.
break up - break up - separate or end a relationship - They break up.
break out - break out - escape or suddenly begin - You break out.
turn on - turn on + device - activate something - You turn on the light.
turn off - turn off + device - deactivate something - You turn off the light.
pick up - pick up + thing - lift or collect something - You pick up the phone.
put down - put down + thing - place something down - You put down the book.
look up - look up + word - search for information - You look up a word.
look around - look around - inspect the area - You look around.
wake up - wake up - stop sleeping - You wake up.
calm down - calm down - become calmer - You calm down.
slow down - slow down - move or act more slowly - You slow down.
stand up - stand up - rise to a standing position - You stand up.
sit down - sit down - take a seat - You sit down.
take off - take off - leave the ground or remove something - The plane takes off.
take away - take away + thing - remove something - You take away the box.
bring back - bring back + thing - return something - You bring back the book.
call back - call back + person - return a call - You call back Mary.
write down - write down + text - record in writing - You write down the note.
write back - write back - reply in writing - You write back.
throw away - throw away + thing - discard something - You throw away the paper.
think through - think through - consider carefully from start to finish - You think through.
come back - come back - return - You come back.
go away - go away - leave - You go away.
go out - go out - leave a place or spend time outside - You go out.
go back - go back - return - You go back.
come in - come in - enter - You come in.
come out - come out - leave a place or become visible - You come out.
look out - look out - be careful - You look out.
look back - look back - think about the past - You look back.
turn around - turn around - face the other way or improve a situation - You turn around.
break down - break down - stop working or lose emotional control - You break down.
fall down - fall down - drop to the ground - You fall down.
put away - put away + thing - place something where it belongs - You put away the book.
put back - put back + thing - return something to its place - You put back the book.
take out - take out + thing - remove something - You take out the key.
bring in - bring in + thing - carry something inside or introduce something - You bring in the book.
bring out - bring out + thing - make something visible or available - You bring out the book.
clean up - clean up + thing - make something clean or tidy - You clean up the room.
sing along - sing along - sing together with music or another person - You sing along.

## Prepositional Idioms

work on - work on + topic - make progress on something - You work on grammar.
think about - think about + topic - consider something - You think about grammar.
think of - think of + someone/something - remember or imagine someone or something - You think of Mary.
think over - think over + topic - consider before deciding - You think over the plan.
help with - help with + topic - assist on a task - You help with homework.
hear from - hear from + person - receive news from someone - You hear from Mary.
ask for - ask for + thing - request something - You ask for help.
look for - look for + thing - search for something - You look for the key.
go for - go for + activity - choose or leave to do something - You go for a walk.
close on - close on + topic - come near to an agreement or capture - You close on a deal.
lose yourself - lose + reflexive object + in + place - become deeply absorbed in a place, activity, or situation - You lose yourself in the office.

## Intentional Literal Particle Routes

These are authored `rightParticle` routes that are deliberately not counted by
Idiom Finder yet. The reverse audit keeps this list honest: every particle route
must either be an idiom above or appear here with a reason.

go in - literal movement into a place
go around - literal movement around an area
read through - literal completion of a text from start to finish
take back - literal return route for objects
turn back - literal direction change or return
look down - literal gaze direction
help out - support route kept literal until idiom copy is authored

## Review Notes

- Right particle idioms use `SentenceState.rightParticle`.
- Topic idioms use `SentenceState.topic` plus `topicPreposition`.
- Source and purpose idioms use their matching core participant fields.
- Particle/object order is reviewed separately in
  `lib/data/predicate/particle_object_order.dart`.
- Reverse audit lives in `test/configuration/predicate_paths_test.dart` and
  checks that every authored particle route is either an idiom or intentional
  literal route.
