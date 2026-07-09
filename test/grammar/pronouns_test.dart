import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/verbs/work.dart';

import 'package:padlock_app/engine/grammar_engine.dart';

import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

import 'package:padlock_app/data/subjects/pronouns.dart';

import 'package:padlock_app/data/verbs/essential.dart';

void main() {
  final engine = GrammarEngine();

  group('Grammar pronouns test', () {
    test('I work', () {
      final sentence = engine.generate(
        SentenceState(
          agent: i,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'I work.');
    });

    test('You work', () {
      final sentence = engine.generate(
        SentenceState(
          agent: you,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'You work.');
    });

    test('He works', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'He works.');
    });

    test('She works', () {
      final sentence = engine.generate(
        SentenceState(
          agent: she,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'She works.');
    });

    test('It works', () {
      final sentence = engine.generate(
        SentenceState(
          agent: it,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'It works.');
    });

    test('We work', () {
      final sentence = engine.generate(
        SentenceState(
          agent: we,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'We work.');
    });

    test('They work', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'They work.');
    });

    test('He built it', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: build,
          object: it,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'He built it.');
    });

    test('They built it', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: build,
          object: it,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'They built it.');
    });

    test('I am working', () {
      final sentence = engine.generate(
        SentenceState(
          agent: i,
          action: work,
          aspect: Aspect.continuous,
          tense: Tense.present,
        ),
      );

      expect(sentence.text, 'I am working.');
    });

    test('You are working', () {
      final sentence = engine.generate(
        SentenceState(
          agent: you,
          action: work,
          aspect: Aspect.continuous,
          tense: Tense.present,
        ),
      );

      expect(sentence.text, 'You are working.');
    });

    test('He is working', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          aspect: Aspect.continuous,
          tense: Tense.present,
        ),
      );

      expect(sentence.text, 'He is working.');
    });

    test('We are working', () {
      final sentence = engine.generate(
        SentenceState(
          agent: we,
          action: work,
          aspect: Aspect.continuous,
          tense: Tense.present,
        ),
      );

      expect(sentence.text, 'We are working.');
    });

    test('They have worked', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: work,
          aspect: Aspect.perfect,
          tense: Tense.present,
        ),
      );

      expect(sentence.text, 'They have worked.');
    });

    test('They had worked', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: work,
          aspect: Aspect.perfect,
          tense: Tense.past,
        ),
      );

      expect(sentence.text, 'They had worked.');
    });

    test('He has worked', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          aspect: Aspect.perfect,
          tense: Tense.present,
        ),
      );

      expect(sentence.text, 'He has worked.');
    });

    test('He had worked', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          aspect: Aspect.perfect,
          tense: Tense.past,
        ),
      );

      expect(sentence.text, 'He had worked.');
    });

    test('She had worked', () {
      final sentence = engine.generate(
        SentenceState(
          agent: she,
          action: work,
          tense: Tense.past,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, 'She had worked.');
    });

    test('I will work', () {
      final sentence = engine.generate(
        SentenceState(
          agent: i,
          action: work,
          tense: Tense.future,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'I will work.');
    });

    test('He can work', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          modal: can,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'He can work.');
    });

    test('They should build it', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: build,
          object: it,
          modal: should,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'They should build it.');
    });

    test('It was built', () {
      final sentence = engine.generate(
        SentenceState(
          object: it,
          action: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, 'It was built.');
    });

    test('It was built by them', () {
      final sentence = engine.generate(
        SentenceState(
          object: it,
          action: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
          agent: they,
        ),
      );

      expect(sentence.text, 'It was built by them.');
    });

    test('Does he work?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Does he work?');
    });

    test('Do they work?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Do they work?');
    });

    test('Is she working?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: she,
          action: work,
          tense: Tense.present,
          aspect: Aspect.continuous,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Is she working?');
    });

    test('Have they worked?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: work,
          tense: Tense.present,
          aspect: Aspect.perfect,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Have they worked?');
    });

    test('Will we work?', () {
      final sentence = engine.generate(
        SentenceState(
          agent: we,
          action: work,
          tense: Tense.future,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, 'Will we work?');
    });

    test('Object pronouns render in object case', () {
      final cases = {
        i: 'He saw me.',
        you: 'He saw you.',
        he: 'She saw him.',
        she: 'He saw her.',
        it: 'He saw it.',
        we: 'He saw us.',
        they: 'He saw them.',
      };

      for (final entry in cases.entries) {
        final agent = entry.key == he ? she : he;
        final sentence = engine.generate(
          SentenceState(
            agent: agent,
            action: see,
            object: entry.key,
            tense: Tense.past,
            aspect: Aspect.simple,
          ),
        );

        expect(sentence.text, entry.value);
      }
    });

    test('Passive agents render pronouns in object case', () {
      final cases = {
        i: 'It was built by me.',
        you: 'It was built by you.',
        he: 'It was built by him.',
        she: 'It was built by her.',
        it: 'It was built by it.',
        we: 'It was built by us.',
        they: 'It was built by them.',
      };

      for (final entry in cases.entries) {
        final sentence = engine.generate(
          SentenceState(
            object: it,
            agent: entry.key,
            action: build,
            voice: Voice.passive,
            tense: Tense.past,
            aspect: Aspect.simple,
          ),
        );

        expect(sentence.text, entry.value);
      }
    });

    test('Recipient pronouns render in object case', () {
      final cases = {
        i: 'He gave me a book.',
        you: 'He gave you a book.',
        he: 'She gave him a book.',
        she: 'He gave her a book.',
        it: 'He gave it a book.',
        we: 'He gave us a book.',
        they: 'He gave them a book.',
      };

      for (final entry in cases.entries) {
        final agent = entry.key == he ? she : he;
        final sentence = engine.generate(
          SentenceState(
            agent: agent,
            action: give,
            recipient: entry.key,
            object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
            tense: Tense.past,
            aspect: Aspect.simple,
          ),
        );

        expect(sentence.text, entry.value);
      }
    });

    test('Passive ditransitive pronouns keep case by focus', () {
      final objectFocus = engine.generate(
        SentenceState(
          agent: he,
          action: give,
          recipient: i,
          object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
          voice: Voice.passive,
          passiveFocus: PassiveFocus.object,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      final recipientFocus = engine.generate(
        SentenceState(
          agent: he,
          action: give,
          recipient: i,
          object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
          voice: Voice.passive,
          passiveFocus: PassiveFocus.recipient,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(objectFocus.text, 'A book was given to me by him.');
      expect(recipientFocus.text, 'I was given a book by him.');
    });
  });
}
