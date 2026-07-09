import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/subjects/adjectives/appearance.dart';
import 'package:padlock_app/data/subjects/adjectives/quality.dart';
import 'package:padlock_app/data/verbs/work.dart';

import 'package:padlock_app/engine/grammar_engine.dart';

import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';

import 'package:padlock_app/data/verbs/communication.dart' as communication;
import 'package:padlock_app/data/verbs/education.dart' as education;
import 'package:padlock_app/data/verbs/essential.dart';

void main() {
  final engine = GrammarEngine();
  String render(SentenceState state) => engine.generate(state).text;

  group('Grammar invariants', () {
    test('First person singular uses "am"', () {
      final sentence = engine.generate(
        SentenceState(
          agent: i,
          action: work,
          tense: Tense.present,
          aspect: Aspect.continuous,
        ),
      );

      expect(sentence.text, isNot('I are working.'));
      expect(sentence.text, 'I am working.');
    });

    test('Third person singular uses "is"', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          tense: Tense.present,
          aspect: Aspect.continuous,
        ),
      );

      expect(sentence.text, isNot('He are working.'));
      expect(sentence.text, 'He is working.');
    });

    test('Plural subject uses "are"', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: work,
          tense: Tense.present,
          aspect: Aspect.continuous,
        ),
      );

      expect(sentence.text, isNot('They is working.'));
      expect(sentence.text, 'They are working.');
    });

    test('Third person singular uses "has"', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, isNot('He have worked.'));
      expect(sentence.text, 'He has worked.');
    });

    test('Plural subject uses "have"', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: work,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, isNot('They has worked.'));
      expect(sentence.text, 'They have worked.');
    });

    test('Third person singular uses "does"', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, isNot('Do he work?'));
      expect(sentence.text, 'Does he work?');
    });

    test('Plural subject uses "do"', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, isNot('Does they work?'));
      expect(sentence.text, 'Do they work?');
    });

    test('Passive agent uses object case', () {
      final sentence = engine.generate(
        SentenceState(
          object: it,
          action: build,
          agent: they,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, isNot('It was built by they.'));
      expect(sentence.text, 'It was built by them.');
    });

    test('Passive object focus renders object as displayed subject', () {
      final implicitFocus = render(
        SentenceState(
          object: bridge.toNounPhrase(Number.singular),
          agent: he,
          action: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      final explicitFocus = render(
        SentenceState(
          object: bridge.toNounPhrase(Number.singular),
          agent: he,
          action: build,
          voice: Voice.passive,
          passiveFocus: PassiveFocus.object,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(implicitFocus, 'Bridge was built by him.');
      expect(explicitFocus, implicitFocus);
    });

    test('Recipient slot renders active and passive give frames', () {
      expect(
        render(
          SentenceState(
            agent: john.toNounPhrase(Number.singular),
            recipient: mary.toNounPhrase(Number.singular),
            object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
            action: give,
            tense: Tense.past,
            aspect: Aspect.simple,
          ),
        ),
        'John gave Mary a book.',
      );

      expect(
        render(
          SentenceState(
            agent: john.toNounPhrase(Number.singular),
            recipient: mary.toNounPhrase(Number.singular),
            object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
            action: give,
            voice: Voice.passive,
            passiveFocus: PassiveFocus.object,
            tense: Tense.past,
            aspect: Aspect.simple,
          ),
        ),
        'A book was given to Mary by John.',
      );

      expect(
        render(
          SentenceState(
            agent: john.toNounPhrase(Number.singular),
            recipient: mary.toNounPhrase(Number.singular),
            object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
            action: give,
            voice: Voice.passive,
            passiveFocus: PassiveFocus.recipient,
            tense: Tense.past,
            aspect: Aspect.simple,
          ),
        ),
        'Mary was given a book by John.',
      );
    });

    test('Core ditransitive verbs unlock the recipient slot in data', () {
      final ditransitiveVerbs = [
        give,
        buy,
        communication.tell,
        communication.write,
        education.teach,
      ];

      for (final verb in ditransitiveVerbs) {
        expect(verb.takesObject, isTrue, reason: verb.infinitive);
        expect(verb.takesRecipient, isTrue, reason: verb.infinitive);
      }
    });

    test('Engine verb list has one canonical entry per infinitive', () {
      final seen = <String>{};
      final duplicates = <String>[];

      for (final verb in verbs) {
        if (!seen.add(verb.infinitive)) {
          duplicates.add(verb.infinitive);
        }
      }

      expect(duplicates, isEmpty);
    });

    test('Expanded ditransitive data renders active recipient frame', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          recipient: mary.toNounPhrase(Number.singular),
          object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
          action: buy,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'John bought Mary a book.');
    });

    test('Noun phrases render ordered multiple adjectives', () {
      final sentence = render(
        SentenceState(
          agent: woman.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
            adjectives: [beautiful, young],
          ),
          object: house.toNounPhrase(
            Number.singular,
            determiner: aDeterminer,
            adjectives: [newAdjective, beautiful],
          ),
          action: build,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(
        sentence,
        'The beautiful young woman built a new beautiful house.',
      );
    });

    test('Passive does not conjugate lexical verb', () {
      final sentence = engine.generate(
        SentenceState(
          object: bridge.toNounPhrase(Number.singular),
          action: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, isNot('Bridge builds.'));
      expect(sentence.text.endsWith('is built.'), isTrue);
    });

    test('Modal is followed by infinitive', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          modal: can,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, isNot('He can works.'));
      expect(sentence.text, 'He can work.');
    });

    test('Modal suppresses third person singular', () {
      final sentence = engine.generate(
        SentenceState(
          agent: she,
          action: build,
          modal: should,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, isNot('She should builds.'));
      expect(sentence.text, 'She should build.');
    });

    test('Future uses infinitive', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          tense: Tense.future,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, isNot('He will works.'));
      expect(sentence.text, 'He will work.');
    });

    test('Perfect uses past participle', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: build,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text, isNot('They have build.'));
      expect(sentence.text, 'They have built.');
    });

    test('Continuous uses present participle', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: build,
          tense: Tense.present,
          aspect: Aspect.continuous,
        ),
      );

      expect(sentence.text, isNot('They are built.'));
      expect(sentence.text, 'They are building.');
    });

    test('Past Simple irregular verb is preserved', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: go,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text, isNot('He goed.'));
      expect(sentence.text, 'He went.');
    });

    test('Question does not duplicate auxiliary', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text, isNot('Does he does work?'));
      expect(sentence.text, 'Does he work?');
    });

    test('Negative inserts only one "not"', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
        ),
      );

      expect(sentence.text, isNot('They do not not work.'));
      expect(sentence.text, 'They do not work.');
    });

    test('Sentence ends with a single punctuation mark', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text.endsWith('.'), isTrue);
      expect(sentence.text.contains('..'), isFalse);
      expect(sentence.text.contains('??'), isFalse);
    });

    test('Active objects use object case for pronouns', () {
      final objectCases = {
        i: 'He built me.',
        he: 'He built him.',
        she: 'He built her.',
        we: 'He built us.',
        they: 'He built them.',
      };

      for (final entry in objectCases.entries) {
        final sentence = render(
          SentenceState(
            agent: he,
            action: build,
            object: entry.key,
            tense: Tense.past,
            aspect: Aspect.simple,
          ),
        );

        expect(sentence, entry.value);
      }
    });

    test('Passive agents use object case for every pronoun', () {
      final agentCases = {
        i: 'It was built by me.',
        he: 'It was built by him.',
        she: 'It was built by her.',
        we: 'It was built by us.',
        they: 'It was built by them.',
      };

      for (final entry in agentCases.entries) {
        final sentence = render(
          SentenceState(
            object: it,
            agent: entry.key,
            action: build,
            voice: Voice.passive,
            tense: Tense.past,
            aspect: Aspect.simple,
          ),
        );

        expect(sentence, entry.value);
      }
    });

    test('Negative question inverts only the first auxiliary', () {
      expect(
        render(
          SentenceState(
            agent: he,
            action: work,
            tense: Tense.present,
            aspect: Aspect.simple,
            polarity: Polarity.negative,
            sentenceForm: SentenceForm.question,
          ),
        ),
        'Does he not work?',
      );

      expect(
        render(
          SentenceState(
            agent: they,
            action: work,
            tense: Tense.past,
            aspect: Aspect.perfectContinuous,
            polarity: Polarity.negative,
            sentenceForm: SentenceForm.question,
          ),
        ),
        'Had they not been working?',
      );
    });

    test('Passive perfect continuous keeps passive helper stack intact', () {
      final sentence = render(
        SentenceState(
          object: bridge.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
            adjective: newAdjective,
          ),
          agent: they,
          action: build,
          voice: Voice.passive,
          tense: Tense.past,
          aspect: Aspect.perfectContinuous,
        ),
      );

      expect(sentence, 'The new bridge had been being built by them.');
      expect(sentence, isNot('The new bridge had been building by them.'));
      expect(sentence, isNot('The new bridge had being built by them.'));
    });

    test('Modal passive does not conjugate BE or lexical verb', () {
      final sentence = render(
        SentenceState(
          object: bridge.toNounPhrase(Number.singular),
          action: build,
          modal: should,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'Bridge should be built.');
      expect(sentence, isNot('Bridge should is built.'));
      expect(sentence, isNot('Bridge should be builds.'));
    });
  });
}
