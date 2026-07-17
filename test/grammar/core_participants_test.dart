import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart' hide need;
import 'package:padlock_app/data/phrases/manner_phrases.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/subjects/adjectives/colors.dart';
import 'package:padlock_app/data/subjects/adjectives/emotions.dart';
import 'package:padlock_app/data/subjects/adjectives/quality.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart';
import 'package:padlock_app/data/subjects/object_pronouns.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/geography.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/data/verbs/travel.dart' as travel_data;
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/recipient_placement.dart';
import 'package:padlock_app/models/grammar/recipient_preposition.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
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

    test('active to-recipient uses to as the default preposition', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: give,
          object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
          recipient: mary.toNounPhrase(Number.singular),
          recipientPlacement: RecipientPlacement.toPhrase,
          recipientPreposition: RecipientPreposition.to,
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

    test('active recipient phrase can use for after the object', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: buy,
          object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
          recipient: mary.toNounPhrase(Number.singular),
          recipientPlacement: RecipientPlacement.toPhrase,
          recipientPreposition: RecipientPreposition.forBenefit,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'John bought a book for Mary.');
    });

    test('active for-recipient keeps modifiers and pronoun case', () {
      final sentence = render(
        SentenceState(
          agent: she,
          action: make,
          object: book.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
            adjective: red,
          ),
          recipient: he,
          recipientPlacement: RecipientPlacement.toPhrase,
          recipientPreposition: RecipientPreposition.forBenefit,
          modal: could,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence, 'She could have made the red book for him.');
    });

    test('active objects can be reflexive participants', () {
      final cases = {
        i: (object: myself, sentence: 'I saw myself.'),
        you: (object: yourself, sentence: 'You saw yourself.'),
        he: (object: himself, sentence: 'He saw himself.'),
        she: (object: herself, sentence: 'She saw herself.'),
        it: (object: itself, sentence: 'It saw itself.'),
        we: (object: ourselves, sentence: 'We saw ourselves.'),
        they: (object: themselves, sentence: 'They saw themselves.'),
      };

      for (final entry in cases.entries) {
        final sentence = render(
          SentenceState(
            agent: entry.key,
            action: see,
            object: entry.value.object,
            tense: Tense.past,
            aspect: Aspect.simple,
          ),
        );

        expect(sentence, entry.value.sentence);
      }
    });

    test('fixed activity objects render as regular object participants', () {
      final cases = {
        football: 'John played football.',
        basketball: 'John played basketball.',
        volleyball: 'John played volleyball.',
        tennis: 'John played tennis.',
        golf: 'John played golf.',
      };

      for (final entry in cases.entries) {
        final sentence = render(
          SentenceState(
            agent: john.toNounPhrase(Number.singular),
            action: play,
            object: entry.key,
            tense: Tense.past,
            aspect: Aspect.simple,
          ),
        );

        expect(sentence, entry.value);
      }
    });

    test('active object adjective complement follows the object', () {
      final sentence = render(
        SentenceState(
          agent: they,
          action: make,
          object: he,
          objectAdjectiveComplement: calm,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'They made him calm.');
    });

    test('active object noun complement follows the object', () {
      final sentence = render(
        SentenceState(
          agent: they,
          action: call,
          object: he,
          objectComplement: teacher.toNounPhrase(
            Number.singular,
            determiner: aDeterminer,
          ),
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'They called him a teacher.');
    });

    test('passive object complement follows the passive verb chain', () {
      final sentence = render(
        SentenceState(
          agent: they,
          action: make,
          object: he,
          objectAdjectiveComplement: calm,
          voice: Voice.passive,
          passiveFocus: PassiveFocus.object,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'He was made calm by them.');
    });

    test('lexical be renders place phrase as a predicate complement', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: be,
          placePhrase: schoolPlacePhrase,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'John is at school.');
    });

    test('lexical be place complement survives verb chains', () {
      final sentence = render(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: be,
          placePhrase: homePlacePhrase,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence, 'Mary has been at home.');
    });

    test('lexical be place complement survives modals', () {
      final sentence = render(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: be,
          placePhrase: homePlacePhrase,
          modal: should,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'Mary should be at home.');
    });

    test('lexical be can render source place complement', () {
      final sentence = render(
        SentenceState(
          agent: she,
          action: be,
          placePhrase: polandPlacePhrase,
          placeMeaning: PlaceMeaning.source,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'She is from Poland.');
    });

    test('lexical be can link place subject to place complement', () {
      final sentence = render(
        SentenceState(
          agent: czechia.toNounPhrase(Number.singular),
          action: be,
          placePhrase: europePlacePhrase,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'Czechia is in Europe.');
    });

    test('lexical be can render companion surface', () {
      final sentence = render(
        SentenceState(
          agent: they,
          action: be,
          companion: mary.toNounPhrase(Number.singular),
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'They are with Mary.');
    });

    test('lexical be companion survives modals', () {
      final sentence = render(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: be,
          companion: he,
          modal: should,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'Mary should be with him.');
    });

    test('companion can take an indefinite name determiner', () {
      final sentence = render(
        SentenceState(
          agent: they,
          action: be,
          companion: mary.toNounPhrase(
            Number.singular,
            determiner: aDeterminer,
          ),
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'They are with a Mary.');
    });

    test('ordinary verbs can render companion surface', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: run,
          companion: mary.toNounPhrase(Number.singular),
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'John ran with Mary.');
    });

    test('communication verbs can render addressee surface', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: speak,
          addressee: mary.toNounPhrase(Number.singular),
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'John spoke to Mary.');
    });

    test('addressee pronouns render in object case', () {
      final sentence = render(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: talk,
          addressee: he,
          modal: should,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'Mary should talk to him.');
    });

    test('write can render an addressee without an object', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: write,
          addressee: she,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'John wrote to her.');
    });

    test('listen can render a bound addressee phrase', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: listen,
          addressee: mary.toNounPhrase(Number.singular),
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'John listened to Mary.');
    });

    test('explain can render object plus bound addressee phrase', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: explain,
          object: grammar,
          addressee: mary.toNounPhrase(Number.singular),
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'John explained grammar to Mary.');
    });

    test('introduce can render object plus bound addressee phrase', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: introduce,
          object: tom.toNounPhrase(Number.singular),
          addressee: mary.toNounPhrase(Number.singular),
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'John introduced Tom to Mary.');
    });

    test('manner can stay before bound addressee phrase', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: explain,
          object: grammar,
          addressee: mary.toNounPhrase(Number.singular),
          mannerPhrase: carefullyMannerPhrase,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'John explained grammar carefully to Mary.');
    });

    test('manner can sit between verb and bound addressee phrase', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: speak,
          addressee: mary.toNounPhrase(Number.singular),
          mannerPhrase: quietlyMannerPhrase,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'John spoke quietly to Mary.');
    });

    test('agreement verbs can render bound with participant surface', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: agree,
          companion: mary.toNounPhrase(Number.singular),
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'John agreed with Mary.');
    });

    test('manner can stay before bound companion phrase', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: agree,
          companion: mary.toNounPhrase(Number.singular),
          mannerPhrase: politelyMannerPhrase,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'John agreed politely with Mary.');
    });

    test('companion verbs can render manner before with participant', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: speak,
          companion: mary.toNounPhrase(Number.singular),
          mannerPhrase: wellMannerPhrase,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'John spoke well with Mary.');
    });

    test('motion verbs can render manner before destination place', () {
      final sentence = render(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: go,
          placePhrase: schoolPlacePhrase,
          mannerPhrase: quietlyMannerPhrase,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'Mary went quietly to school.');
    });

    test('motion verbs can render manner before person destination', () {
      final sentence = render(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: go,
          destination: john.toNounPhrase(Number.singular),
          mannerPhrase: silentlyMannerPhrase,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'Mary went silently to John.');
    });

    test(
      'regular destination verbs use the same person destination surface',
      () {
        final sentence = render(
          SentenceState(
            agent: mary.toNounPhrase(Number.singular),
            action: travel_data.travel,
            destination: john.toNounPhrase(Number.singular),
            mannerPhrase: silentlyMannerPhrase,
            tense: Tense.past,
            aspect: Aspect.simple,
          ),
        );

        expect(sentence, 'Mary travelled silently to John.');
      },
    );

    test('regular destination verbs survive perfect verb chains', () {
      final sentence = render(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: travel_data.travel,
          placePhrase: schoolPlacePhrase,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence, 'Mary has travelled to school.');
    });

    test('right action complement renders as an inferior to action', () {
      final sentence = render(
        SentenceState(
          agent: i,
          action: want,
          rightAction: go,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'I want to go.');
    });

    test(
      'right action complement keeps finite agreement on the first verb',
      () {
        final sentence = render(
          SentenceState(
            agent: she,
            action: need,
            rightAction: work,
            tense: Tense.present,
            aspect: Aspect.simple,
          ),
        );

        expect(sentence, 'She needs to work.');
      },
    );

    test('right action complement survives past tense and modals', () {
      expect(
        render(
          SentenceState(
            agent: they,
            action: like,
            rightAction: swim,
            tense: Tense.past,
            aspect: Aspect.simple,
          ),
        ),
        'They liked to swim.',
      );

      expect(
        render(
          SentenceState(
            agent: you,
            action: learn,
            rightAction: speak,
            modal: should,
            tense: Tense.present,
            aspect: Aspect.simple,
          ),
        ),
        'You should learn to speak.',
      );
    });

    test('right action complement survives negatives and questions', () {
      expect(
        render(
          SentenceState(
            agent: he,
            action: want,
            rightAction: go,
            polarity: Polarity.negative,
            tense: Tense.present,
            aspect: Aspect.simple,
          ),
        ),
        'He does not want to go.',
      );

      expect(
        render(
          SentenceState(
            agent: he,
            action: want,
            rightAction: go,
            sentenceForm: SentenceForm.question,
            tense: Tense.present,
            aspect: Aspect.simple,
          ),
        ),
        'Does he want to go?',
      );
    });

    test('right action can own a direct object and companion tail', () {
      final sentence = render(
        SentenceState(
          agent: you,
          action: learn,
          rightAction: speak,
          object: science,
          companion: anyone,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'You learn to speak science with anyone.');
    });

    test('person destination pronouns render in object case', () {
      final sentence = render(
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: go,
          destination: he,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'Mary went to him.');
    });

    test('active recipients can be reflexive participants', () {
      final sentence = render(
        SentenceState(
          agent: you,
          action: give,
          recipient: yourself,
          object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'You gave yourself a book.');
    });

    test('active to-recipient can use reflexive pronouns', () {
      final sentence = render(
        SentenceState(
          agent: they,
          action: buy,
          object: gift.toNounPhrase(Number.singular, determiner: aDeterminer),
          recipient: themselves,
          recipientPlacement: RecipientPlacement.toPhrase,
          recipientPreposition: RecipientPreposition.forBenefit,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'They bought a gift for themselves.');
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

    test('passive object focus keeps for-benefit recipient preposition', () {
      final sentence = render(
        SentenceState(
          agent: john.toNounPhrase(Number.singular),
          action: buy,
          object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
          recipient: mary.toNounPhrase(Number.singular),
          recipientPlacement: RecipientPlacement.toPhrase,
          recipientPreposition: RecipientPreposition.forBenefit,
          voice: Voice.passive,
          passiveFocus: PassiveFocus.object,
          tense: Tense.past,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'A book was bought for Mary by John.');
    });

    test(
      'passive object focus can hide agent while keeping recipient phrase',
      () {
        final sentence = render(
          SentenceState(
            agent: john.toNounPhrase(Number.singular),
            action: buy,
            object: book.toNounPhrase(Number.singular, determiner: aDeterminer),
            recipient: mary.toNounPhrase(Number.singular),
            recipientPlacement: RecipientPlacement.toPhrase,
            recipientPreposition: RecipientPreposition.forBenefit,
            voice: Voice.passive,
            passiveFocus: PassiveFocus.object,
            showPassiveAgent: false,
            tense: Tense.past,
            aspect: Aspect.simple,
          ),
        );

        expect(sentence, 'A book was bought for Mary.');
      },
    );

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
