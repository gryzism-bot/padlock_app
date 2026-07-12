import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/manner_phrases.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/subjects/adjectives/colors.dart';
import 'package:padlock_app/data/subjects/adjectives/emotions.dart';
import 'package:padlock_app/data/subjects/adjectives/quality.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart';
import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/data/verbs/travel.dart' as travel_data;
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/recipient_placement.dart';
import 'package:padlock_app/models/grammar/recipient_preposition.dart';
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
      expect(state.recipientPreposition, RecipientPreposition.to);
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
        expect(state.recipientPreposition, RecipientPreposition.to);
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
      expect(state.recipientPreposition, RecipientPreposition.to);
    });

    test('active for-recipient frame keeps object before recipient', () {
      final state = engine.recognize('John bought a book for Mary.');

      expectAgent(state, text: 'john');
      expectObject(state, text: 'book', determiner: aDeterminer);
      expectRecipient(state, text: 'mary');
      expect(state.action, buy);
      expect(state.voice, Voice.active);
      expect(state.recipientPlacement, RecipientPlacement.toPhrase);
      expect(state.recipientPreposition, RecipientPreposition.forBenefit);
    });

    test('active for-recipient survives verb chains and pronoun case', () {
      final state = engine.recognize(
        'She could have made the red book for him.',
      );

      expectAgent(state, text: 'she');
      expectObject(
        state,
        text: 'book',
        determiner: theDeterminer,
        adjective: red,
      );
      expectRecipient(state, text: 'him');
      expect(state.action, make);
      expect(state.aspect, Aspect.perfect);
      expect(state.recipientPlacement, RecipientPlacement.toPhrase);
      expect(state.recipientPreposition, RecipientPreposition.forBenefit);
    });

    test('active objects recognize reflexive participants', () {
      final cases = [
        (sentence: 'I saw myself.', agent: 'i', object: 'myself'),
        (sentence: 'You saw yourself.', agent: 'you', object: 'yourself'),
        (sentence: 'He saw himself.', agent: 'he', object: 'himself'),
        (sentence: 'She saw herself.', agent: 'she', object: 'herself'),
        (sentence: 'It saw itself.', agent: 'it', object: 'itself'),
        (sentence: 'We saw ourselves.', agent: 'we', object: 'ourselves'),
        (sentence: 'They saw themselves.', agent: 'they', object: 'themselves'),
      ];

      for (final entry in cases) {
        final state = engine.recognize(entry.sentence);

        expectAgent(state, text: entry.agent);
        expectObject(state, text: entry.object);
        expect(state.action, see);
      }
    });

    test('flattened fixed activity verbs canonicalize to play plus object', () {
      final cases = {
        'John played football.': football,
        'John played basketball.': basketball,
        'John played volleyball.': volleyball,
        'John played tennis.': tennis,
        'John played golf.': golf,
      };

      for (final entry in cases.entries) {
        final state = engine.recognize(entry.key);

        expectAgent(state, text: 'john');
        expect(state.action, play);
        expect(state.object, entry.value);
        expect(state.tense, Tense.past);
        expect(state.aspect, Aspect.simple);
      }
    });

    test(
      'fixed activity aliases canonicalize through questions and modals',
      () {
        final cases = {
          'Does John play volleyball?': volleyball,
          'John cannot play football.': football,
          'They should play basketball.': basketball,
          'Did Mary play tennis?': tennis,
        };

        for (final entry in cases.entries) {
          final state = engine.recognize(entry.key);

          expect(state.action, play, reason: entry.key);
          expect(state.object, entry.value, reason: entry.key);
        }
      },
    );

    test('active object adjective complement follows the object', () {
      final state = engine.recognize('They made him calm.');

      expectAgent(state, text: 'they');
      expectObject(state, text: 'him');
      expect(state.objectAdjectiveComplement, calm);
      expect(state.objectComplement, isNull);
      expect(state.action, make);
    });

    test('active object noun complement follows the object', () {
      final state = engine.recognize('They called him a teacher.');

      expectAgent(state, text: 'they');
      expectObject(state, text: 'him');
      expect(state.objectComplement, isNotNull);
      expect(state.objectComplement!.text, 'teacher');
      expect(state.objectComplement!.determiner, aDeterminer);
      expect(state.action, call);
    });

    test(
      'recipient frame still wins when make receives a second noun phrase',
      () {
        final state = engine.recognize('John made Mary a gift.');

        expectAgent(state, text: 'john');
        expectRecipient(state, text: 'mary');
        expectObject(state, text: 'gift', determiner: aDeterminer);
        expect(state.objectComplement, isNull);
        expect(state.objectAdjectiveComplement, isNull);
        expect(state.action, make);
        expect(state.recipientPlacement, RecipientPlacement.beforeObject);
      },
    );

    test('passive object complement follows the passive verb chain', () {
      final state = engine.recognize('He was made calm by them.');

      expectAgent(state, text: 'them');
      expectObject(state, text: 'he');
      expect(state.objectAdjectiveComplement, calm);
      expect(state.objectComplement, isNull);
      expect(state.action, make);
      expect(state.voice, Voice.passive);
      expect(state.passiveFocus, PassiveFocus.object);
    });

    test(
      'lexical be recognizes place phrase as predicate complement surface',
      () {
        final state = engine.recognize('John is at school.');

        expectAgent(state, text: 'john');
        expect(state.action, be);
        expect(state.placePhrase, schoolPlacePhrase);
        expect(state.complement, isNull);
        expect(state.adjectiveComplement, isNull);
        expect(state.tense, Tense.present);
        expect(state.aspect, Aspect.simple);
      },
    );

    test('lexical be place complement survives verb chains', () {
      final state = engine.recognize('Mary has been at home.');

      expectAgent(state, text: 'mary');
      expect(state.action, be);
      expect(state.placePhrase, homePlacePhrase);
      expect(state.complement, isNull);
      expect(state.adjectiveComplement, isNull);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.perfect);
    });

    test('lexical be place complement survives modals', () {
      final state = engine.recognize('Mary should be at home.');

      expectAgent(state, text: 'mary');
      expect(state.action, be);
      expect(state.placePhrase, homePlacePhrase);
      expect(state.modal, should);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.simple);
    });

    test('lexical be recognizes source place complement', () {
      final state = engine.recognize('She is from Poland.');

      expectAgent(state, text: 'she');
      expect(state.action, be);
      expect(state.placePhrase, polandPlacePhrase);
      expect(state.placeMeaning, PlaceMeaning.source);
      expect(state.complement, isNull);
      expect(state.adjectiveComplement, isNull);
    });

    test('lexical be recognizes place subject with place complement', () {
      final state = engine.recognize('Czechia is in Europe.');

      expectAgent(state, text: 'czechia');
      expect(state.action, be);
      expect(state.placePhrase, europePlacePhrase);
      expect(state.placeMeaning, PlaceMeaning.location);
      expect(state.complement, isNull);
      expect(state.adjectiveComplement, isNull);
    });

    test('lexical be recognizes companion surface', () {
      final state = engine.recognize('They are with Mary.');

      expectAgent(state, text: 'they');
      expectCompanion(state, text: 'mary');
      expect(state.action, be);
      expect(state.complement, isNull);
      expect(state.adjectiveComplement, isNull);
    });

    test('lexical be companion survives modals', () {
      final state = engine.recognize('Mary should be with him.');

      expectAgent(state, text: 'mary');
      expectCompanion(state, text: 'him');
      expect(state.action, be);
      expect(state.modal, should);
      expect(state.complement, isNull);
      expect(state.adjectiveComplement, isNull);
    });

    test('companion can recognize an indefinite name determiner', () {
      final state = engine.recognize('They are with a Mary.');

      expectAgent(state, text: 'they');
      expectCompanion(state, text: 'mary', determiner: aDeterminer);
      expect(state.action, be);
      expect(state.complement, isNull);
      expect(state.adjectiveComplement, isNull);
    });

    test('ordinary verbs recognize companion surface', () {
      final state = engine.recognize('John ran with Mary.');

      expectAgent(state, text: 'john');
      expectCompanion(state, text: 'mary');
      expect(state.action, run);
      expect(state.mannerPhrase, isNull);
    });

    test('communication verbs recognize addressee surface', () {
      final state = engine.recognize('John spoke to Mary.');

      expectAgent(state, text: 'john');
      expectAddressee(state, text: 'mary');
      expect(state.action, speak);
      expect(state.object, isNull);
      expect(state.recipient, isNull);
    });

    test('addressee pronouns recognize object case', () {
      final state = engine.recognize('Mary should talk to him.');

      expectAgent(state, text: 'mary');
      expectAddressee(state, text: 'him');
      expect(state.action, talk);
      expect(state.modal, should);
      expect(state.object, isNull);
      expect(state.recipient, isNull);
    });

    test('write can recognize an addressee without an object', () {
      final state = engine.recognize('John wrote to her.');

      expectAgent(state, text: 'john');
      expectAddressee(state, text: 'her');
      expect(state.action, write);
      expect(state.object, isNull);
      expect(state.recipient, isNull);
    });

    test('listen recognizes a bound addressee phrase', () {
      final state = engine.recognize('John listened to Mary.');

      expectAgent(state, text: 'john');
      expectAddressee(state, text: 'mary');
      expect(state.action, listen);
      expect(state.object, isNull);
      expect(state.recipient, isNull);
    });

    test('explain recognizes object plus bound addressee phrase', () {
      final state = engine.recognize('John explained grammar to Mary.');

      expectAgent(state, text: 'john');
      expectObject(state, text: 'grammar');
      expectAddressee(state, text: 'mary');
      expect(state.action, explain);
      expect(state.recipient, isNull);
    });

    test('manner can stay before object plus bound addressee phrase', () {
      final state = engine.recognize(
        'John explained grammar carefully to Mary.',
      );

      expectAgent(state, text: 'john');
      expectObject(state, text: 'grammar');
      expectAddressee(state, text: 'mary');
      expect(state.action, explain);
      expect(state.mannerPhrase, carefullyMannerPhrase);
      expect(state.recipient, isNull);
    });

    test('manner can sit between verb and bound addressee phrase', () {
      final state = engine.recognize('John spoke quietly to Mary.');

      expectAgent(state, text: 'john');
      expectAddressee(state, text: 'mary');
      expect(state.action, speak);
      expect(state.mannerPhrase, quietlyMannerPhrase);
      expect(state.object, isNull);
      expect(state.recipient, isNull);
    });

    test('introduce recognizes object plus bound addressee phrase', () {
      final state = engine.recognize('John introduced Tom to Mary.');

      expectAgent(state, text: 'john');
      expectObject(state, text: 'tom');
      expectAddressee(state, text: 'mary');
      expect(state.action, introduce);
      expect(state.recipient, isNull);
    });

    test('agreement verbs recognize bound with participant surface', () {
      final state = engine.recognize('John agreed with Mary.');

      expectAgent(state, text: 'john');
      expectCompanion(state, text: 'mary');
      expect(state.action, agree);
      expect(state.object, isNull);
      expect(state.recipient, isNull);
      expect(state.mannerPhrase, isNull);
    });

    test('manner can stay before bound companion phrase', () {
      final state = engine.recognize('John agreed politely with Mary.');

      expectAgent(state, text: 'john');
      expectCompanion(state, text: 'mary');
      expect(state.action, agree);
      expect(state.mannerPhrase, politelyMannerPhrase);
      expect(state.object, isNull);
      expect(state.recipient, isNull);
    });

    test('companion verbs recognize manner before with participant', () {
      final state = engine.recognize('John spoke well with Mary.');

      expectAgent(state, text: 'john');
      expectCompanion(state, text: 'mary');
      expect(state.action, speak);
      expect(state.mannerPhrase, wellMannerPhrase);
      expect(state.object, isNull);
      expect(state.recipient, isNull);
    });

    test('motion verbs recognize manner before destination place', () {
      final state = engine.recognize('Mary went quietly to school.');

      expectAgent(state, text: 'mary');
      expect(state.action, go);
      expect(state.placePhrase, schoolPlacePhrase);
      expect(state.placeMeaning, PlaceMeaning.destination);
      expect(state.mannerPhrase, quietlyMannerPhrase);
      expect(state.object, isNull);
      expect(state.recipient, isNull);
    });

    test('motion verbs recognize manner before person destination', () {
      final state = engine.recognize('Mary went silently to John.');

      expectAgent(state, text: 'mary');
      expectDestination(state, text: 'john');
      expect(state.action, go);
      expect(state.mannerPhrase, silentlyMannerPhrase);
      expect(state.placePhrase, isNull);
      expect(state.object, isNull);
      expect(state.recipient, isNull);
    });

    test('regular destination verbs recognize person destination surface', () {
      final state = engine.recognize('Mary travelled silently to John.');

      expectAgent(state, text: 'mary');
      expectDestination(state, text: 'john');
      expect(state.action, travel_data.travel);
      expect(state.mannerPhrase, silentlyMannerPhrase);
      expect(state.placePhrase, isNull);
      expect(state.object, isNull);
      expect(state.recipient, isNull);
    });

    test('regular destination verbs recognize perfect destination chains', () {
      final state = engine.recognize('Mary has travelled to school.');

      expectAgent(state, text: 'mary');
      expect(state.action, travel_data.travel);
      expect(state.placePhrase, schoolPlacePhrase);
      expect(state.placeMeaning, PlaceMeaning.destination);
      expect(state.tense, Tense.present);
      expect(state.aspect, Aspect.perfect);
      expect(state.object, isNull);
      expect(state.recipient, isNull);
    });

    test('person destination pronouns recognize object case', () {
      final state = engine.recognize('Mary went to him.');

      expectAgent(state, text: 'mary');
      expectDestination(state, text: 'him');
      expect(state.action, go);
      expect(state.object, isNull);
      expect(state.recipient, isNull);
    });

    test('recipient still wins when object precedes to phrase', () {
      final state = engine.recognize('John wrote a letter to Mary.');

      expectAgent(state, text: 'john');
      expectObject(state, text: 'letter', determiner: aDeterminer);
      expectRecipient(state, text: 'mary');
      expect(state.addressee, isNull);
      expect(state.action, write);
      expect(state.recipientPlacement, RecipientPlacement.toPhrase);
    });

    test('with manner phrase does not become companion surface', () {
      final state = engine.recognize('John worked with care.');

      expectAgent(state, text: 'john');
      expect(state.action, work);
      expect(state.companion, isNull);
      expect(state.mannerPhrase, withCareMannerPhrase);
    });

    test('active recipients recognize reflexive participants', () {
      final state = engine.recognize('You gave yourself a book.');

      expectAgent(state, text: 'you');
      expectRecipient(state, text: 'yourself');
      expectObject(state, text: 'book', determiner: aDeterminer);
      expect(state.action, give);
      expect(state.recipientPlacement, RecipientPlacement.beforeObject);
    });

    test('active to-recipient recognizes reflexive participants', () {
      final state = engine.recognize('They bought a gift for themselves.');

      expectAgent(state, text: 'they');
      expectObject(state, text: 'gift', determiner: aDeterminer);
      expectRecipient(state, text: 'themselves');
      expect(state.action, buy);
      expect(state.recipientPlacement, RecipientPlacement.toPhrase);
      expect(state.recipientPreposition, RecipientPreposition.forBenefit);
    });

    test('passive object focus keeps recipient as a to phrase', () {
      final state = engine.recognize('A book was given to Mary by John.');

      expectObject(state, text: 'book', determiner: aDeterminer);
      expectRecipient(state, text: 'mary');
      expectAgent(state, text: 'john');
      expect(state.voice, Voice.passive);
      expect(state.passiveFocus, PassiveFocus.object);
      expect(state.recipientPreposition, RecipientPreposition.to);
    });

    test('passive object focus recognizes for-benefit recipient phrase', () {
      final state = engine.recognize('A book was bought for Mary by John.');

      expectObject(state, text: 'book', determiner: aDeterminer);
      expectRecipient(state, text: 'mary');
      expectAgent(state, text: 'john');
      expect(state.action, buy);
      expect(state.voice, Voice.passive);
      expect(state.passiveFocus, PassiveFocus.object);
      expect(state.recipientPreposition, RecipientPreposition.forBenefit);
    });

    test('passive for-recipient does not swallow trailing time phrases', () {
      final state = engine.recognize('A book was bought for Mary yesterday.');

      expectObject(state, text: 'book', determiner: aDeterminer);
      expectRecipient(state, text: 'mary');
      expect(state.agent, isNull);
      expect(state.timePhrase!.text, 'yesterday');
      expect(state.voice, Voice.passive);
      expect(state.passiveFocus, PassiveFocus.object);
      expect(state.recipientPreposition, RecipientPreposition.forBenefit);
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
