import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/work.dart' as work_data;
import 'package:padlock_app/engine/configuration_laws.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

void main() {
  group('Configuration laws', () {
    SentenceState state({
      Verb action = learn,
      NounPhrase? agent = you,
      NounPhrase? object,
      NounPhrase? recipient,
      Voice voice = Voice.active,
      PassiveFocus? passiveFocus,
      bool showPassiveAgent = true,
      Tense tense = Tense.present,
      Aspect aspect = Aspect.simple,
      Modal modal = noModal,
      SentenceForm sentenceForm = SentenceForm.statement,
    }) {
      return SentenceState(
        agent: agent,
        action: action,
        object: object,
        recipient: recipient,
        voice: voice,
        passiveFocus: passiveFocus,
        showPassiveAgent: showPassiveAgent,
        tense: tense,
        aspect: aspect,
        modal: modal,
        sentenceForm: sentenceForm,
      );
    }

    test('lexical be is an active agent frame', () {
      final bareBe = state(action: be);

      expect(isLexicalBeFrame(bareBe), isTrue);
      expect(lexicalBeNeedsAgent(bareBe), isFalse);
      expect(lexicalBeNeedsActiveVoice(bareBe), isFalse);

      final noAgent = state(action: be, agent: null);
      expect(lexicalBeNeedsAgent(noAgent), isTrue);

      final passiveBe = state(action: be, voice: Voice.passive);
      expect(lexicalBeNeedsActiveVoice(passiveBe), isTrue);
    });

    test('lexical be noun complements match agent number', () {
      final singularMatch = state(
        action: be,
        agent: he,
      ).copyWithComplement(teacher.toNounPhrase(Number.singular));

      final pluralMismatch = state(
        action: be,
        agent: they,
      ).copyWithComplement(teacher.toNounPhrase(Number.singular));

      expect(lexicalBeNounComplementMatchesAgentNumber(singularMatch), isTrue);
      expect(
        lexicalBeNounComplementMatchesAgentNumber(pluralMismatch),
        isFalse,
      );
    });

    test('active and passive voice shape laws are explicit', () {
      final activeWithoutAgent = state(agent: null);
      expect(activeVoiceNeedsAgent(activeWithoutAgent), isTrue);

      final activeWithPassiveFocus = state(
        action: work_data.build,
        object: bridge.toNounPhrase(Number.singular),
        passiveFocus: PassiveFocus.object,
      );
      expect(
        passiveFocusBelongsToPassiveVoice(activeWithPassiveFocus),
        isFalse,
      );

      final passiveIntransitive = state(action: work, voice: Voice.passive);
      expect(
        passiveVoiceNeedsObjectCapablePredicate(passiveIntransitive),
        isFalse,
      );

      final passiveObjectWithoutObject = state(
        action: work_data.build,
        voice: Voice.passive,
      );
      expect(
        passiveObjectFocusNeedsObject(passiveObjectWithoutObject),
        isFalse,
      );
    });

    test(
      'recipient focus and recipient frames keep their object dependency',
      () {
        final activeRecipientWithoutObject = state(
          action: give,
          recipient: mary.toNounPhrase(Number.singular),
        );
        expect(
          recipientFrameNeedsObject(activeRecipientWithoutObject),
          isFalse,
        );

        final passiveRecipientWithoutRecipient = state(
          action: give,
          object: book.toNounPhrase(Number.singular),
          voice: Voice.passive,
          passiveFocus: PassiveFocus.recipient,
        );
        expect(
          passiveRecipientFocusNeedsRecipient(passiveRecipientWithoutRecipient),
          isFalse,
        );
        expect(
          passiveRecipientFocusNeedsObject(passiveRecipientWithoutRecipient),
          isTrue,
        );
      },
    );

    test('modal and imperative frame laws stay separate from word paths', () {
      final presentModal = state(modal: should);
      expect(modalMatchesTenseFrame(presentModal), isTrue);

      final futurePresentModal = state(tense: Tense.future, modal: should);
      expect(modalMatchesTenseFrame(futurePresentModal), isFalse);

      final willFuture = state(tense: Tense.future, modal: will);
      expect(modalMatchesTenseFrame(willFuture), isTrue);

      final modalImperative = state(
        modal: should,
        sentenceForm: SentenceForm.imperative,
      );
      expect(modalAllowedInSentenceForm(modalImperative), isFalse);

      final continuousImperative = state(
        aspect: Aspect.continuous,
        sentenceForm: SentenceForm.imperative,
      );
      expect(imperativeUsesPresentSimple(continuousImperative), isFalse);
      expect(imperativeUsesActiveVoice(continuousImperative), isTrue);
    });
  });
}

extension on SentenceState {
  SentenceState copyWithComplement(NounPhrase complement) {
    return SentenceState(
      agent: agent,
      action: action,
      object: object,
      recipient: recipient,
      addressee: addressee,
      companion: companion,
      destination: destination,
      topic: topic,
      beneficiary: beneficiary,
      source: source,
      rightAction: rightAction,
      recipientPlacement: recipientPlacement,
      recipientPreposition: recipientPreposition,
      objectComplement: objectComplement,
      objectAdjectiveComplement: objectAdjectiveComplement,
      complement: complement,
      adjectiveComplement: adjectiveComplement,
      voice: voice,
      passiveFocus: passiveFocus,
      showPassiveAgent: showPassiveAgent,
      tense: tense,
      aspect: aspect,
      modal: modal,
      polarity: polarity,
      sentenceForm: sentenceForm,
      timePhrase: timePhrase,
      placePhrase: placePhrase,
      placeMeaning: placeMeaning,
      frequencyPhrase: frequencyPhrase,
      mannerPhrase: mannerPhrase,
    );
  }
}
