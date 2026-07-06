```

// ============================================================
// VERB
// ============================================================

if (!verb.takesObject) {
  object = null;
}

if (verb.takesObject && object == null) {
  object = defaultObject();
}

if (!verb.supportsPassive) {
  voice = Voice.active;
}

if (!verb.supportsContinuous &&
    aspect == Aspect.continuous) {
  aspect = Aspect.simple;
}

if (!verb.supportsContinuous &&
    aspect == Aspect.perfectContinuous) {
  aspect = Aspect.perfect;
}

if (!verb.supportsPerfect &&
    aspect == Aspect.perfect) {
  aspect = Aspect.simple;
}

if (!verb.supportsPerfect &&
    aspect == Aspect.perfectContinuous) {
  aspect = Aspect.continuous;
}

if (!verb.usesPlace) {
  placePhrase = null;
}

if (verb.usesDestinationPlace) {
  placeMeaning = PlaceMeaning.destination;
}

if (verb.usesLocationPlace &&
    placeMeaning != PlaceMeaning.location) {
  placeMeaning = PlaceMeaning.location;
}

if (verb.usesSourcePlace) {
  placeMeaning = PlaceMeaning.source;
}

if (!verb.usesTimePhrase) {
  timePhrase = null;
}

if (!verb.usesFrequencyPhrase) {
  frequencyPhrase = null;
}

if (!verb.usesMannerPhrase) {
  mannerPhrase = null;
}

if (!verb.supportsImperative &&
    sentenceForm == SentenceForm.imperative) {
  sentenceForm = SentenceForm.statement;
}

if (!verb.supportsQuestion &&
    sentenceForm == SentenceForm.question) {
  sentenceForm = SentenceForm.statement;
}

// ============================================================
// VOICE
// ============================================================

if (voice == Voice.passive) {
  swap(agent, object);
}

if (voice == Voice.passive &&
    !verb.takesObject) {
  voice = Voice.active;
}

if (voice == Voice.passive &&
    object == null) {
  voice = Voice.active;
}

if (voice == Voice.passive &&
    agent == null) {
  agent = defaultAgent();
}

if (voice == Voice.active &&
    object == null &&
    verb.takesObject) {
  object = defaultObject();
}

// ============================================================
// MODALS
// ============================================================

if (modal == Modal.will) {
  tense = Tense.future;
}

if (modal == Modal.none &&
    tense == Tense.future) {
  modal = Modal.will;
}

if (modal != Modal.none) {
  finiteVerb = modal;
}

if (modal != Modal.none) {
  lexicalVerbForm = VerbForm.infinitive;
}

if (modal != Modal.none &&
    voice == Voice.passive) {
  lexicalVerbForm = VerbForm.pastParticiple;
}

if (modal != Modal.none &&
    aspect == Aspect.continuous) {
  auxiliary = Auxiliary.be;
}

if (modal != Modal.none &&
    aspect == Aspect.perfect) {
  auxiliary = Auxiliary.have;
}

if (modal != Modal.none &&
    aspect == Aspect.perfectContinuous) {
  auxiliaries = [
    Auxiliary.have,
    Auxiliary.been,
  ];
}

if (!modal.supportsPerfect &&
    aspect == Aspect.perfect) {
  aspect = Aspect.simple;
}

if (!modal.supportsPerfect &&
    aspect == Aspect.perfectContinuous) {
  aspect = Aspect.continuous;
}

if (!modal.supportsContinuous &&
    aspect == Aspect.continuous) {
  aspect = Aspect.simple;
}

// ============================================================
// ASPECT
// ============================================================

if (aspect == Aspect.simple) {
  auxiliaries.clear();
}

if (aspect == Aspect.continuous) {
  auxiliaries = [Auxiliary.be];
}

if (aspect == Aspect.perfect) {
  auxiliaries = [Auxiliary.have];
}

if (aspect == Aspect.perfectContinuous) {
  auxiliaries = [
    Auxiliary.have,
    Auxiliary.been,
  ];
}

if (aspect == Aspect.continuous) {
  lexicalVerbForm = VerbForm.ing;
}

if (aspect == Aspect.perfect) {
  lexicalVerbForm = VerbForm.pastParticiple;
}

if (aspect == Aspect.perfectContinuous) {
  lexicalVerbForm = VerbForm.ing;
}

// ============================================================
// TENSE
// ============================================================

if (tense == Tense.present &&
    aspect == Aspect.simple &&
    modal == Modal.none) {
  auxiliary = null;
}

if (tense == Tense.past &&
    aspect == Aspect.simple &&
    modal == Modal.none) {
  auxiliary = null;
}

if (tense == Tense.future &&
    modal == Modal.none) {
  modal = Modal.will;
}

// ============================================================
// POLARITY
// ============================================================

if (polarity == Polarity.negative &&
    modal == Modal.none &&
    aspect == Aspect.simple &&
    voice == Voice.active) {
  enableDoSupport();
}

if (polarity == Polarity.positive) {
  disableDoSupport();
}

// ============================================================
// SENTENCE FORM
// ============================================================

if (sentenceForm == SentenceForm.question) {
  invertSubjectAndAuxiliary();
}

if (sentenceForm == SentenceForm.statement) {
  restoreCanonicalOrder();
}

if (sentenceForm == SentenceForm.question &&
    auxiliary == null) {
  enableDoSupport();
}

// ============================================================
// PARTICIPANTS
// ============================================================

if (agent == object) {
  object = null;
}

if (agent == null) {
  agent = defaultAgent();
}

if (verb.takesObject &&
    object == null) {
  object = defaultObject();
}

if (!verb.takesObject) {
  object = null;
}

// ============================================================
// PLACE
// ============================================================

if (placePhrase != null &&
    !verb.usesPlace) {
  placePhrase = null;
}

if (placePhrase == null &&
    verb.requiresPlace) {
  placePhrase = defaultPlace();
}

if (placePhrase != null &&
    !placePhrase.supports(placeMeaning)) {
  placeMeaning = placePhrase.defaultMeaning;
}

// ============================================================
// TIME
// ============================================================

if (timePhrase != null &&
    !timePhrase.supports(tense)) {
  timePhrase = null;
}

if (frequencyPhrase != null &&
    tense == Tense.future &&
    !frequencyPhrase.supportsFuture) {
  frequencyPhrase = null;
}

// ============================================================
// ARTICLE
// ============================================================

if (placePhrase != null &&
    !placePhrase.takesArticle) {
  article = Article.none;
}

if (placePhrase != null &&
    placePhrase.takesArticle &&
    article == Article.none) {
  article = Article.the;
}

// ============================================================
// AGREEMENT
// ============================================================

if (agent.isPlural) {
  agreement = Agreement.plural;
}

if (agent.isThirdPersonSingular &&
    tense == Tense.present &&
    aspect == Aspect.simple &&
    modal == Modal.none) {
  lexicalVerbForm = VerbForm.thirdPersonSingular;
}

if (!agent.isThirdPersonSingular &&
    lexicalVerbForm ==
        VerbForm.thirdPersonSingular) {
  lexicalVerbForm = VerbForm.infinitive;
}

VerbInterlock
AspectInterlock
VoiceInterlock
ModalInterlock
ParticipantInterlock
PlaceInterlock
TimeInterlock
AgreementInterlock
QuestionInterlock
NegativeInterlock
ArticleInterlock
```