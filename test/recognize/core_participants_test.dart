import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/subjects/adjectives/colors.dart';
import 'package:padlock_app/data/subjects/adjectives/quality.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/recipient_placement.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/voice.dart';

import 'helpers.dart';

void main() {
  group('Recognition core participants', () {
    test('active double-object frame keeps recipient before object', () {
      final state = engine.recognize('John gave Mary a book.');

      expectAgent(state, text: 'john');
      expectRecipient(state, text: 'mary');
      expectObject(state, text: 'book', determiner: aDeterminer);
      expect(state.action, give);
      expect(state.voice, Voice.active);
      expect(state.recipientPlacement, RecipientPlacement.beforeObject);
    });

    test('active to-recipient frame keeps object before recipient', () {
      final state = engine.recognize('John gave a book to Mary.');

      expectAgent(state, text: 'john');
      expectObject(state, text: 'book', determiner: aDeterminer);
      expectRecipient(state, text: 'mary');
      expect(state.action, give);
      expect(state.voice, Voice.active);
      expect(state.recipientPlacement, RecipientPlacement.toPhrase);
    });

    test('active to-recipient keeps modifiers on the correct noun phrase', () {
      final state = engine.recognize(
        'John gave the red book to the old teacher.',
      );

      expectAgent(state, text: 'john');
      expectObject(
        state,
        text: 'book',
        determiner: theDeterminer,
        adjective: red,
      );
      expectRecipient(
        state,
        text: 'teacher',
        determiner: theDeterminer,
        adjective: old,
      );
      expect(state.recipientPlacement, RecipientPlacement.toPhrase);
    });

    test('active to-recipient pronouns recognize object case', () {
      final cases = [
        (sentence: 'He gave a book to me.', recipient: 'me'),
        (sentence: 'He gave a book to you.', recipient: 'you'),
        (sentence: 'She gave a book to him.', recipient: 'him'),
        (sentence: 'He gave a book to her.', recipient: 'her'),
        (sentence: 'He gave a book to it.', recipient: 'it'),
        (sentence: 'He gave a book to us.', recipient: 'us'),
        (sentence: 'He gave a book to them.', recipient: 'them'),
      ];

      for (final entry in cases) {
        final state = engine.recognize(entry.sentence);

        expectObject(state, text: 'book', determiner: aDeterminer);
        expectRecipient(state, text: entry.recipient);
        expect(state.recipientPlacement, RecipientPlacement.toPhrase);
      }
    });

    test('active to-recipient survives questions and verb chains', () {
      final state = engine.recognize('Should John have given a book to Mary?');

      expectAgent(state, text: 'john');
      expectObject(state, text: 'book', determiner: aDeterminer);
      expectRecipient(state, text: 'mary');
      expect(state.action, give);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.perfect);
      expect(state.sentenceForm, SentenceForm.question);
      expect(state.recipientPlacement, RecipientPlacement.toPhrase);
    });

    test('active to-recipient does not swallow trailing time phrases', () {
      final state = engine.recognize('John gave a book to Mary yesterday.');

      expectObject(state, text: 'book', determiner: aDeterminer);
      expectRecipient(state, text: 'mary');
      expect(state.timePhrase!.text, 'yesterday');
      expect(state.recipientPlacement, RecipientPlacement.toPhrase);
    });

    test('passive object focus keeps recipient as a to phrase', () {
      final state = engine.recognize('A book was given to Mary by John.');

      expectObject(state, text: 'book', determiner: aDeterminer);
      expectRecipient(state, text: 'mary');
      expectAgent(state, text: 'john');
      expect(state.voice, Voice.passive);
      expect(state.passiveFocus, PassiveFocus.object);
    });

    test('passive recipient focus keeps object after the verb chain', () {
      final state = engine.recognize('Mary was given a book by John.');

      expectRecipient(state, text: 'mary');
      expectObject(state, text: 'book', determiner: aDeterminer);
      expectAgent(state, text: 'john');
      expect(state.voice, Voice.passive);
      expect(state.passiveFocus, PassiveFocus.recipient);
    });
  });
}
