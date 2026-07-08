```

applyVerbChain(builder)

│
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
│
├── state.modal != noModal ?
│   │
│   ├── yes
│   │
│   │   <isomorphic="RenderModal">
│   │   append modal.text
│   │   </isomorphic>
│   │
│   │   ↓
│   │
│   │   <isomorphic="Negative">
│   │   polarity == negative ?
│   │       ├── yes → append "not"
│   │       └── no
│   │   </isomorphic>
│   │
│   │   ↓
│   │
│   │   tense == Future ?
│   │   │
│   │   ├── yes
│   │   │
│   │   │      aspect == Simple ?
│   │   │      │
│   │   │      ├── yes
│   │   │      │
│   │   │      │      voice == Active ?
│   │   │      │          ├── yes → append infinitive
│   │   │      │          └── no
│   │   │      │                 append "be"
│   │   │      │                 append pastParticiple
│   │   │      │
│   │   │      ├── Continuous
│   │   │      │
│   │   │      │      append "be"
│   │   │      │      append presentParticiple
│   │   │      │
│   │   │      ├── Perfect
│   │   │      │
│   │   │      │      append "have"
│   │   │      │
│   │   │      │      voice == Active ?
│   │   │      │          ├── yes → append pastParticiple
│   │   │      │          └── no
│   │   │      │                 append "been"
│   │   │      │                 append pastParticiple
│   │   │      │
│   │   │      └── PerfectContinuous
│   │   │
│   │   │             append "have"
│   │   │             append "been"
│   │   │
│   │   │             voice == Active ?
│   │   │                 ├── yes → append presentParticiple
│   │   │                 └── no
│   │   │                        append "being"
│   │   │                        append pastParticiple
│   │   │
│   │   └── no
│   │
│   │          aspect == Simple ?
│   │          │
│   │          ├── yes
│   │          │
│   │          │      voice == Active ?
│   │          │          ├── yes → append infinitive
│   │          │          └── no
│   │          │                 append "be"
│   │          │                 append pastParticiple
│   │          │
│   │          ├── Continuous
│   │          │
│   │          │      append "be"
│   │          │      append presentParticiple
│   │          │
│   │          ├── Perfect
│   │          │
│   │          │      append "have"
│   │          │
│   │          │      voice == Active ?
│   │          │          ├── yes → append pastParticiple
│   │          │          └── no
│   │          │                 append "been"
│   │          │                 append pastParticiple
│   │          │
│   │          └── PerfectContinuous
│   │
│   │                 append "have"
│   │                 append "been"
│   │
│   │                 voice == Active ?
│   │                     ├── yes → append presentParticiple
│   │                     └── no
│   │                            append "being"
│   │                            append pastParticiple
│   │
│   └────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
│
├── modal == noModal
│
│   ↓
│
│   tense
│   │
│   ├────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
│   │
│   ├── Present
│   │
│   │     aspect
│   │     │
│   │     ├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────
│   │     │
│   │     ├── Simple
│   │     │
│   │     │      polarity == Positive ?
│   │     │      │
│   │     │      ├── yes
│   │     │      │
│   │     │      │      voice == Active ?
│   │     │      │      │
│   │     │      │      ├── yes
│   │     │      │      │
│   │     │      │      │     <isomorphic="thirdPersonVerb">
│   │     │      │      │     third singular ?
│   │     │      │      │         ├── yes → presentThirdPerson
│   │     │      │      │         └── no  → infinitive
│   │     │      │      │     </isomorphic>
│   │     │      │      │
│   │     │      │      └── no
│   │     │      │
│   │     │      │             <isomorphic="presentBe">
│   │     │      │             am
│   │     │      │             is
│   │     │      │             are
│   │     │      │             </isomorphic>
│   │     │      │
│   │     │      │             append pastParticiple
│   │     │      │
│   │     │      └── no
│   │     │
│   │     │             <isomorphic="doAuxiliary">
│   │     │             do / does
│   │     │             </isomorphic>
│   │     │
│   │     │             append "not"
│   │     │
│   │     │             append infinitive
│   │     │
│   │     ├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────
│   │     │
│   │     ├── Continuous
│   │     │
│   │     │      <isomorphic="presentBe">
│   │     │      am
│   │     │      is
│   │     │      are
│   │     │      </isomorphic>
│   │     │
│   │     │      <isomorphic="Negative">
│   │     │      optional "not"
│   │     │      </isomorphic>
│   │     │
│   │     │      voice == Active ?
│   │     │          ├── yes → presentParticiple
│   │     │          └── no
│   │     │                 append "being"
│   │     │                 append pastParticiple
│   │     │
│   │     ├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────
│   │     │
│   │     ├── Perfect
│   │     │
│   │     │      <isomorphic="presentHave">
│   │     │      has / have
│   │     │      </isomorphic>
│   │     │
│   │     │      <isomorphic="Negative">
│   │     │      optional "not"
│   │     │      </isomorphic>
│   │     │
│   │     │      voice == Active ?
│   │     │          ├── yes → pastParticiple
│   │     │          └── no
│   │     │                 append "been"
│   │     │                 append pastParticiple
│   │     │
│   │     └─────────────────────────────────────────────────────────────────────────────────────────────────────────────────
│   │
│   │       PerfectContinuous
│   │
│   │            <isomorphic="presentHave">
│   │            has / have
│   │            </isomorphic>
│   │
│   │            append "been"
│   │
│   │            <isomorphic="Negative">
│   │            optional "not"
│   │            </isomorphic>
│   │
│   │            voice == Active ?
│   │                ├── yes → presentParticiple
│   │                └── no
│   │                       append "being"
│   │                       append pastParticiple
│   │
│   ├────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
│   │
│   ├── Past
│   │
│   │     Simple
│   │         ├── Active  → pastSimple
│   │         └── Passive
│   │
│   │                <isomorphic="pastBe">
│   │                was / were
│   │                </isomorphic>
│   │
│   │                append pastParticiple
│   │
│   │     Continuous
│   │
│   │         <isomorphic="pastBe">
│   │         was / were
│   │         </isomorphic>
│   │
│   │         <isomorphic="Negative">
│   │         optional "not"
│   │         </isomorphic>
│   │
│   │         voice == Active ?
│   │             ├── yes → presentParticiple
│   │             └── no
│   │                    append "being"
│   │                    append pastParticiple
│   │
│   │     Perfect
│   │
│   │         append "had"
│   │
│   │         <isomorphic="Negative">
│   │         optional "not"
│   │         </isomorphic>
│   │
│   │         voice == Active ?
│   │             ├── yes → pastParticiple
│   │             └── no
│   │                    append "been"
│   │                    append pastParticiple
│   │
│   │     PerfectContinuous
│   │
│   │         append "had"
│   │         append "been"
│   │
│   │         <isomorphic="Negative">
│   │         optional "not"
│   │         </isomorphic>
│   │
│   │         voice == Active ?
│   │             ├── yes → presentParticiple
│   │             └── no
│   │                    append "being"
│   │                    append pastParticiple
│   │
│   └────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
│
└── Future
    │
    ├── Simple
    │
    │      append "will"
    │
    │      <isomorphic="Negative">
    │      optional "not"
    │      </isomorphic>
    │
    │      voice == Active ?
    │          ├── yes → infinitive
    │          └── no
    │                 append "be"
    │                 append pastParticiple
    │
    ├── Continuous
    │
    │      append "will"
    │      append "be"
    │
    │      <isomorphic="Negative">
    │      optional "not"
    │      </isomorphic>
    │
    │      voice == Active ?
    │          ├── yes → presentParticiple
    │          └── no
    │                 append "being"
    │                 append pastParticiple
    │
    ├── Perfect
    │
    │      append "will"
    │      append "have"
    │
    │      <isomorphic="Negative">
    │      optional "not"
    │      </isomorphic>
    │
    │      voice == Active ?
    │          ├── yes → pastParticiple
    │          └── no
    │                 append "been"
    │                 append pastParticiple
    │
    └── PerfectContinuous
           append "will"
           append "have"
           append "been"

           <isomorphic="Negative">
           optional "not"
           </isomorphic>

           voice == Active ?
               ├── yes → presentParticiple
               └── no
                      append "being"
                      append pastParticiple

                      ```