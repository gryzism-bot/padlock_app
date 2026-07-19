# Verb Review

Purpose: one place to review every verb currently present in `lib/data/verbs`.

Use this as the hand-authored PredicatePaths audit sheet. The goal is not to let
software guess every verb connection. The goal is to decide, verb by verb, what
Guided Mode should expose as the next meaningful word path.

Legend:

- `visible`: should this verb appear in the learner-facing verb list?
- `pl`: Polish infinitive or short learner gloss to show on verb chips.
- `paths`: what this verb should wake in Guided Mode.
- `review`: open decision, semantic filter, or UI note.

## Essential

| verb | const | visible | pl | paths | review |
| --- | --- | --- | --- | --- | --- |
| be | `be` | yes |  | noun complement, adjective complement, place, companion | lexical be surface |
| have | `have` | yes |  | object | possession objects need review |
| do | `doVerb` | yes? |  | task/activity object | keep separate from auxiliary do-support |
| find | `findVerb` | yes |  | findable object |  |
| sing | `sing` | yes |  | song/performance, companion? |  |
| break | `breakVerb` | yes |  | breakable object |  |
| read | `read` | yes |  | text object |  |
| begin | `begin` | yes |  | right action? |  |
| go | `go` | yes |  | destination, companion |  |
| come | `come` | yes |  | destination, companion |  |
| get | `get` | yes |  | obtainable object |  |
| make | `make` | yes |  | object, recipient, object complement | distinguish from do |
| take | `take` | yes |  | takeable object |  |
| give | `give` | yes |  | object, recipient |  |
| know | `know` | yes |  | person, animal, subject/topic |  |
| think | `think` | yes |  | topic, right action? |  |
| say | `say` | yes |  | speech object, addressee? |  |
| see | `see` | yes |  | visible object/person/animal |  |
| want | `want` | yes |  | object, right action |  |
| need | `need` | yes |  | object, right action |  |
| meet | `meet` | yes |  | person/animal object |  |
| like | `like` | yes |  | object, right action |  |
| love | `love` | yes |  | person/animal/music/game, right action |  |
| work | `work` | yes |  | companion, place, time, manner |  |
| buy | `buy` | yes |  | object, recipient |  |
| sell | `sell` | yes |  | object, recipient/addressee? |  |
| use | `use` | yes |  | tool object |  |
| watch | `watch` | yes |  | media object |  |
| lose | `lose` | yes |  | losable object |  |
| play | `play` | yes |  | activity, game/music?, companion | fixed activity aliases exist |
| learn | `learn` | yes |  | subject, right action, companion | starter predicate |
| hate | `hate` | yes |  | object, right action? |  |
| remember | `remember` | yes |  | object, right action? |  |
| sleep | `sleep` | yes |  | place, time, manner |  |
| open | `open` | yes |  | openable object |  |
| close | `close` | yes |  | openable object |  |
| help | `help` | yes |  | person/animal object, right action? |  |

## Communication

| verb | const | visible | pl | paths | review |
| --- | --- | --- | --- | --- | --- |
| speak | `speak` | yes |  | language, to addressee, with companion |  |
| talk | `talk` | yes |  | to addressee, with companion |  |
| tell | `tell` | yes |  | text object, recipient |  |
| ask | `ask` | yes |  | person, question/topic? |  |
| answer | `answer` | yes |  | person/question? |  |
| call | `call` | yes |  | person/animal object, object complement? |  |
| listen | `listen` | yes |  | to addressee/topic? | current addressee path |
| hear | `hear` | yes |  | sound/person/topic |  |
| write | `write` | yes |  | text object, recipient, addressee, companion |  |
| explain | `explain` | yes |  | subject/topic object, addressee |  |
| describe | `describe` | yes |  | object/topic/person |  |
| discuss | `discuss` | yes |  | topic/person, companion |  |
| agree | `agree` | yes |  | with companion, topic? |  |
| disagree | `disagree` | yes |  | with companion, topic? |  |
| laugh | `laugh` | maybe |  | manner, companion? | product tone decision |
| smile | `smile` | maybe |  | manner, companion? | product tone decision |
| shout | `shout` | yes |  | to addressee, manner |  |
| whisper | `whisper` | yes |  | to addressee, manner |  |
| introduce | `introduce` | yes |  | object, addressee |  |

## Education

| verb | const | visible | pl | paths | review |
| --- | --- | --- | --- | --- | --- |
| study | `study` | yes |  | subject object, companion |  |
| teach | `teach` | yes |  | subject object, recipient, companion, right action? |  |
| spell | `spell` | yes |  | text object |  |
| count | `count` | yes |  | subject/game/object |  |
| calculate | `calculate` | yes |  | subject/math object |  |
| solve | `solve` | yes |  | subject/problem object |  |
| understand | `understand` | yes |  | subject/person/topic |  |
| forget | `forget` | yes |  | subject/person, right action? |  |
| practice | `practice` | yes |  | subject/activity |  |
| repeat | `repeat` | yes |  | subject/text/action? |  |
| improve | `improve` | yes |  | subject/text/skill |  |
| graduate | `graduate` | maybe |  | from place/school? | needs source-place support if kept |
| research | `research` | yes |  | subject/topic |  |

## Movement

| verb | const | visible | pl | paths | review |
| --- | --- | --- | --- | --- | --- |
| walk | `walk` | yes |  | destination, companion, manner |  |
| run | `run` | yes |  | destination, companion, manner, right action? |  |
| jump | `jump` | maybe |  | place/direction/manner |  |
| swim | `swim` | yes |  | destination, companion, manner |  |
| fly | `fly` | yes |  | destination, companion |  |
| drive | `drive` | yes |  | vehicle object, destination |  |
| ride | `ride` | yes |  | vehicle object, destination |  |
| climb | `climb` | maybe |  | object/place |  |
| crawl | `crawl` | maybe |  | destination, manner |  |
| dance | `dance` | yes |  | companion, place, manner |  |
| sail | `sail` | yes |  | destination, companion |  |
| skate | `skate` | yes |  | destination, companion |  |
| ski | `ski` | yes |  | destination, companion |  |
| dive | `dive` | maybe |  | place/destination |  |
| fall | `fall` | maybe |  | place/direction |  |
| stand | `stand` | maybe |  | place |  |
| sit | `sit` | maybe |  | place |  |
| lie | `lie` | maybe |  | place | also homograph risk |

## Cooking

| verb | const | visible | pl | paths | review |
| --- | --- | --- | --- | --- | --- |
| cook | `cook` | yes |  | food object |  |
| bake | `bake` | yes |  | food object |  |
| fry | `fry` | yes |  | food object |  |
| boil | `boil` | yes |  | food object |  |
| grill | `grill` | yes |  | food object |  |
| eat | `eat` | yes |  | food object |  |
| drink | `drink` | yes |  | drink object |  |
| roast | `roast` | yes |  | food object |  |
| steam | `steam` | yes |  | food object |  |
| cut | `cut` | yes |  | food object | homograph tense ambiguity |
| chop | `chop` | yes |  | food object |  |
| slice | `slice` | yes |  | food object |  |
| peel | `peel` | yes |  | food object |  |
| mix | `mix` | yes |  | food object |  |
| stir | `stir` | yes |  | food object |  |
| pour | `pour` | yes |  | drink/liquid object? | current food path may need narrowing |
| add | `add` | yes |  | food object, recipient/container? |  |
| serve | `serve` | yes |  | food object, recipient? |  |
| taste | `taste` | yes |  | food object |  |
| freeze | `freeze` | yes |  | food object |  |
| melt | `melt` | yes |  | food object |  |
| wash | `wash` | yes |  | food/openable object | maybe dishes/clothes later |

## Travel

| verb | const | visible | pl | paths | review |
| --- | --- | --- | --- | --- | --- |
| travel | `travel` | yes |  | destination, companion |  |
| visit | `visit` | yes |  | place/person object |  |
| arrive | `arrive` | yes |  | destination/source? | passive blocked |
| leave | `leave` | yes |  | destination/source/object? |  |
| depart | `depart` | maybe |  | source place | close to leave |
| return | `returnVerb` | yes |  | destination/source, object? |  |
| explore | `explore` | yes |  | place object |  |
| book | `book` | maybe |  | travel object | homograph with noun |
| pack | `pack` | yes |  | travel/tool/clothing object |  |
| unpack | `unpack` | maybe |  | travel/tool/clothing object |  |
| board | `board` | maybe |  | vehicle object | homograph with noun |
| land | `land` | maybe |  | place/destination | homograph with noun |
| rent | `rent` | yes |  | vehicle/place/tool object |  |
| reserve | `reserve` | yes |  | travel/place object |  |
| navigate | `navigate` | yes |  | place/route object |  |
| camp | `camp` | maybe |  | place |  |
| hike | `hike` | maybe |  | destination/place |  |
| photograph | `photograph` | yes |  | person/place/object |  |
| stay | `stay` | yes |  | place, companion? | lexical be cousin |
| cross | `cross` | yes |  | place/object |  |

## Work

| verb | const | visible | pl | paths | review |
| --- | --- | --- | --- | --- | --- |
| build | `build` | yes |  | furniture/openable object |  |
| create | `create` | yes |  | text/media object |  |
| design | `design` | yes |  | text/device object |  |
| develop | `develop` | yes |  | device/text object |  |
| program | `program` | yes |  | device object |  |
| test | `testVerb` | yes |  | device/text object | const name avoids test keyword |
| debug | `debug` | yes |  | device object |  |
| fix | `fix` | yes |  | device/openable object |  |
| repair | `repair` | yes |  | device/openable object |  |
| clean | `clean` | yes |  | device/furniture/openable object |  |
| organize | `organize` | yes |  | text/tool object |  |
| manage | `manage` | yes |  | people/text object |  |
| lead | `lead` | maybe |  | people/team object | homograph/irregular risk |
| deliver | `deliver` | yes |  | text/money object, recipient? |  |
| produce | `produce` | yes |  | text/media object |  |
| earn | `earn` | yes |  | money object |  |

## Sport

| verb | const | visible | pl | paths | review |
| --- | --- | --- | --- | --- | --- |
| train | `train` | yes |  | companion, place, time, right action? |  |
| exercise | `exercise` | yes |  | companion, place, time, manner |  |
| lift | `lift` | yes |  | game/tool object |  |
| throw | `throwVerb` | yes |  | game/food object, recipient? |  |
| catch | `catchVerb` | yes |  | game/food object |  |
| kick | `kick` | yes |  | game object |  |
| hit | `hit` | yes |  | game object |  |
| score | `score` | maybe |  | game/point object |  |
| win | `win` | yes |  | game/prize object |  |
| compete | `compete` | maybe |  | with companion, in activity |  |
| box | `box` | maybe |  | companion? | homograph with object |
| wrestle | `wrestle` | maybe |  | with companion |  |
| surf | `surf` | maybe |  | place/media? |  |
| cycle | `cycle` | maybe |  | destination/companion |  |

Sport activity note: `play football`, `play basketball`, `play volleyball`,
`play tennis`, and `play golf` are intentionally not separate verbs anymore.
They belong to `play` through the fixed `activity` object rail.

## Review Questions

- Which verbs are learner-facing in Guided Mode, and which are backend/Explorer
  only?
- Which verbs deserve exact PredicatePaths by hand before the first public
  developer console build?
- Which verbs should be hidden until their semantic rails are authored?
- Which verbs need Polish learner glosses different from dictionary
  infinitives?
- Which verbs are dangerous homographs for Recognition Engine or UI search?
- Which verbs should become canonical `verb + object` instead of flat verbs?
