import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/subjects/adjectives/colors.dart';
import 'package:padlock_app/data/subjects/adjectives/quality.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/recipient_placement.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

void main() {
  final engine = GrammarEngine();

  String render(SentenceState state) => engine.generate(state).text;

  group('Grammar core participants', () {
    test('active recipient defaults to the double-object frame', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: give,
          recipient: mary.toNounPhrase(Number.singular),
          object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'John gave Mary a book.');
    });

    test('active recipient can render as a to phrase after the object', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: give,
          object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
          recipient: mary.toNounPhrase(Number.singular),
          recipientPlacement: RecipientPlacement.toPhrase,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'John gave a book to Mary.');
    });

    test('active to-recipient keeps both participant noun phrases intact', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: give,
          object: book.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
            adjective: red,
          ),
          recipient: teacher.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
            adjective: old,
          ),
          recipientPlacement: RecipientPlacement.toPhrase,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'John gave the red book to the old teacher.');
    });

    test('active to-recipient pronouns render in object case', () {
      final cases = {
        i: 'He gave a book to me.',
        you: 'He gave a book to you.',
        he: 'She gave a book to him.',
        she: 'He gave a book to her.',
        it: 'He gave a book to it.',
        we: 'He gave a book to us.',
        they: 'He gave a book to them.',
      };

      for (final entry in cases.entries) {
        final agent = entry.key == he ? she : he;
        final sentence = render(
          SentenceState(
            agent: agent,
            action: give,
            object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
            recipient: entry.key,
            recipientPlacement: RecipientPlacement.toPhrase,
            tense: Tense.past,
            aspect: Aspect.simple,
          ),
        );

        expect(sentence, entry.value);
      }
    });

    test('active to-recipient survives questions and verb chains', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: give,
          object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
          recipient: mary.toNounPhrase(Number.singular),
          recipientPlacement: RecipientPlacement.toPhrase,
          modal: should,
          tense: Tense.present,
          aspect: Aspect.perfect,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence, 'Should John have given a book to Mary?');
    });

    test('passive object focus always renders recipient as a to phrase', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: give,
          object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
          recipient: mary.toNounPhrase(Number.singular),
          recipientPlacement: RecipientPlacement.beforeObject,
          voice: Voice.passive,
          passiveFocus: PassiveFocus.object,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'A book was given to Mary by John.');
    });

    test('passive recipient focus keeps object after the verb chain', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: give,
          object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
          recipient: mary.toNounPhrase(Number.singular),
          recipientPlacement: RecipientPlacement.toPhrase,
          voice: Voice.passive,
          passiveFocus: PassiveFocus.recipient,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'Mary was given a book by John.');
    });
  });
}
