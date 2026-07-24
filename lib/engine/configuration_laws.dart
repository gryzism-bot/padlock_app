import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

bool isLexicalBeFrame(SentenceState state) {
  return state.action == be;
}

bool lexicalBeNeedsAgent(SentenceState state) {
  return isLexicalBeFrame(state) && state.agent == null;
}

bool lexicalBeNeedsActiveVoice(SentenceState state) {
  return isLexicalBeFrame(state) && state.voice != Voice.active;
}

bool lexicalBeNounComplementMatchesAgentNumber(SentenceState state) {
  if (!isLexicalBeFrame(state) ||
      state.agent == null ||
      state.complement == null) {
    return true;
  }

  return state.agent!.isPlural == state.complement!.isPlural;
}

bool lexicalBeRejectsObjectSurface(SentenceState state) {
  return isLexicalBeFrame(state) && state.object != null;
}

bool lexicalBeRejectsObjectComplementSurface(SentenceState state) {
  return isLexicalBeFrame(state) &&
      (state.objectComplement != null ||
          state.objectAdjectiveComplement != null);
}

bool lexicalBeRejectsRecipientSurface(SentenceState state) {
  return isLexicalBeFrame(state) && state.recipient != null;
}

bool lexicalBeRejectsAddresseeSurface(SentenceState state) {
  return isLexicalBeFrame(state) && state.addressee != null;
}

bool lexicalBeRejectsTopicSurface(SentenceState state) {
  return isLexicalBeFrame(state) && state.topic != null;
}

bool lexicalBeRejectsBeneficiarySurface(SentenceState state) {
  return isLexicalBeFrame(state) && state.beneficiary != null;
}

bool lexicalBeRejectsSourceSurface(SentenceState state) {
  return isLexicalBeFrame(state) && state.source != null;
}

bool lexicalBeRejectsDestinationSurface(SentenceState state) {
  return isLexicalBeFrame(state) && state.destination != null;
}

bool lexicalBeRejectsRightActionSurface(SentenceState state) {
  return isLexicalBeFrame(state) && state.rightAction != null;
}

bool lexicalBeRejectsPassiveFocus(SentenceState state) {
  return isLexicalBeFrame(state) && state.passiveFocus != null;
}

bool lexicalBeRejectsPassiveAgentVisibility(SentenceState state) {
  return isLexicalBeFrame(state) && !state.showPassiveAgent;
}

bool activeVoiceNeedsAgent(SentenceState state) {
  return state.voice == Voice.active && state.agent == null;
}

bool passiveFocusBelongsToPassiveVoice(SentenceState state) {
  return state.voice == Voice.passive || state.passiveFocus == null;
}

bool passiveAgentVisibilityBelongsToPassiveVoice(SentenceState state) {
  return state.voice == Voice.passive || state.showPassiveAgent;
}

bool passiveVoiceNeedsObjectCapablePredicate(SentenceState state) {
  return state.voice != Voice.passive || state.action.takesObject;
}

bool passiveObjectFocusNeedsObject(SentenceState state) {
  if (state.voice != Voice.passive) {
    return true;
  }

  final focus = state.passiveFocus ?? PassiveFocus.object;
  return focus != PassiveFocus.object || state.object != null;
}

bool passiveRecipientFocusNeedsRecipientCapablePredicate(SentenceState state) {
  if (state.voice != Voice.passive) {
    return true;
  }

  final focus = state.passiveFocus ?? PassiveFocus.object;
  return focus != PassiveFocus.recipient || state.action.takesRecipient;
}

bool passiveRecipientFocusNeedsRecipient(SentenceState state) {
  if (state.voice != Voice.passive) {
    return true;
  }

  final focus = state.passiveFocus ?? PassiveFocus.object;
  return focus != PassiveFocus.recipient || state.recipient != null;
}

bool passiveRecipientFocusNeedsObject(SentenceState state) {
  if (state.voice != Voice.passive) {
    return true;
  }

  final focus = state.passiveFocus ?? PassiveFocus.object;
  return focus != PassiveFocus.recipient || state.object != null;
}

bool objectComplementsNeedObjectCapablePredicate(SentenceState state) {
  final hasObjectComplement =
      state.objectComplement != null || state.objectAdjectiveComplement != null;
  return !hasObjectComplement || state.action.takesObjectComplement;
}

bool objectComplementsNeedObject(SentenceState state) {
  final hasObjectComplement =
      state.objectComplement != null || state.objectAdjectiveComplement != null;
  return !hasObjectComplement || state.object != null;
}

bool activeRecipientNeedsRecipientCapablePredicate(SentenceState state) {
  return state.voice != Voice.active ||
      state.recipient == null ||
      state.action.takesRecipient;
}

bool activeAddresseeNeedsAddresseeCapablePredicate(SentenceState state) {
  if (state.voice != Voice.active || state.addressee == null) {
    return true;
  }

  final rightAction = state.rightAction;
  return rightAction == null
      ? state.action.takesAddressee
      : rightAction.takesAddressee;
}

bool activeTopicNeedsTopicCapablePredicate(SentenceState state) {
  if (state.voice != Voice.active || state.topic == null) {
    return true;
  }

  final rightAction = state.rightAction;
  return rightAction == null ? state.action.takesTopic : rightAction.takesTopic;
}

bool activeBeneficiaryNeedsBeneficiaryCapablePredicate(SentenceState state) {
  if (state.voice != Voice.active || state.beneficiary == null) {
    return true;
  }

  final rightAction = state.rightAction;
  return rightAction == null
      ? state.action.takesBeneficiary
      : rightAction.takesBeneficiary;
}

bool activeSourceNeedsSourceCapablePredicate(SentenceState state) {
  if (state.voice != Voice.active || state.source == null) {
    return true;
  }

  final rightAction = state.rightAction;
  return rightAction == null
      ? state.action.takesSource
      : rightAction.takesSource;
}

bool activeObjectNeedsObjectCapablePredicate(SentenceState state) {
  if (state.voice != Voice.active || state.object == null) {
    return true;
  }

  final rightAction = state.rightAction;
  return rightAction == null
      ? state.action.takesObject
      : rightAction.takesObject;
}

bool recipientFrameNeedsObject(SentenceState state) {
  return state.recipient == null || state.object != null;
}

bool modalAllowedInSentenceForm(SentenceState state) {
  return state.modal.isNone || state.sentenceForm != SentenceForm.imperative;
}

bool modalMatchesTenseFrame(SentenceState state) {
  if (state.modal.isNone) {
    return true;
  }

  if (state.modal == will) {
    return state.tense == Tense.future;
  }

  return state.tense != Tense.future;
}

bool imperativeUsesPresentSimple(SentenceState state) {
  return state.sentenceForm != SentenceForm.imperative ||
      (state.tense == Tense.present && state.aspect == Aspect.simple);
}

bool imperativeUsesActiveVoice(SentenceState state) {
  return state.sentenceForm != SentenceForm.imperative ||
      state.voice == Voice.active;
}
