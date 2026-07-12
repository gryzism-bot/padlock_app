import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/adjectives/colors.dart';
import 'package:padlock_app/data/subjects/adjectives/emotions.dart';
import 'package:padlock_app/data/subjects/adjectives/size.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart'
    as fixed_object;
import 'package:padlock_app/data/subjects/object_pronouns.dart' as object_case;
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/movement.dart';
import 'package:padlock_app/data/verbs/work.dart' as work_data;
import 'package:padlock_app/engine/configuration_compass.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/voice.dart';

void main() {
  final lock = ConfigurationEngine();
  final compass = ConfigurationCompass(
    actions: [learn, work, work_data.build, give, speak, be, go],
    objects: [
      book.toNounPhrase(Number.singular),
      bridge.toNounPhrase(Number.singular),
    ],
    recipients: [
      mary.toNounPhrase(Number.singular),
      john.toNounPhrase(Number.singular),
    ],
    adjectiveComplements: [happy, tired],
    nounAdjectives: [big, red],
    determiners: [aDeterminer, anDeterminer, theDeterminer, manyDeterminer],
    modals: [noModal, can, should, will],
    places: [
      homePlacePhrase,
      schoolPlacePhrase,
      workPlacePhrase,
      parkPlacePhrase,
    ],
  );
  final grammar = GrammarEngine();

  String render(ConfigurationState state) {
    return grammar.generate(state.sentenceState).text;
  }

  bool wasBlocked(ConfigurationState state) {
    return state.messages.any(
      (message) => message.kind == ConfigurationMessageKind.blocked,
    );
  }

  group('Configuration Compass', () {
    test('filters object suggestions through the lock', () {
      final initialSuggestions = compass.suggestionsFor(
        ConfigurationState.initial(),
        ConfigurationCompassSlot.object,
        limit: 0,
      );

      expect(initialSuggestions.map((suggestion) => suggestion.label), [
        'English',
        'grammar',
        'history',
        'math',
        'science',
      ]);

      final englishSuggestion = initialSuggestions.singleWhere(
        (suggestion) => suggestion.label == 'English',
      );
      expect(render(englishSuggestion.preview), 'You learn English.');

      final workState = lock.applyMove(
        ConfigurationState.initial(),
        const SetAction(work),
      );
      expect(
        compass.suggestionsFor(workState, ConfigurationCompassSlot.object),
        isEmpty,
      );

      var state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetAction(work_data.build));

      final suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.object,
        limit: 0,
      );

      expect(suggestions.map((suggestion) => suggestion.label), [
        'book',
        'bridge',
      ]);
      expect(render(suggestions.first.preview), 'You build book.');
      expect(wasBlocked(suggestions.first.preview), isFalse);
    });

    test('fixed object frames wake a narrow bare object rail', () {
      var state = lock.applyMove(
        ConfigurationState.initial(),
        const SetAction(play),
      );

      final objectSuggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.object,
        limit: 0,
      );

      expect(
        objectSuggestions.map((suggestion) => suggestion.label),
        containsAll(['football', 'tennis', 'volleyball']),
      );

      final volleyballSuggestion = objectSuggestions.singleWhere(
        (suggestion) => suggestion.label == 'volleyball',
      );
      expect(render(volleyballSuggestion.preview), 'You play volleyball.');

      state = volleyballSuggestion.preview;
      expect(
        compass.suggestionsFor(
          state,
          ConfigurationCompassSlot.objectDeterminer,
          limit: 0,
        ),
        isEmpty,
      );
      expect(
        compass.suggestionsFor(
          state,
          ConfigurationCompassSlot.objectAdjective,
          limit: 0,
        ),
        isEmpty,
      );

      final blocked = lock.applyMove(
        state,
        const SetNounPhraseDeterminer(NounPhraseTarget.object, aDeterminer),
      );

      expect(blocked.sentenceState, same(state.sentenceState));
      expect(wasBlocked(blocked), isTrue);
      expect(
        blocked.messages.single.text,
        'play fixed activity objects stay bare.',
      );
    });

    test('guided actions hide flattened fixed object verbs', () {
      final suggestions = ConfigurationCompass().suggestionsFor(
        ConfigurationState.initial(),
        ConfigurationCompassSlot.action,
        limit: 0,
      );

      expect(
        suggestions.map((suggestion) => suggestion.label),
        contains('play'),
      );
      expect(
        suggestions.map((suggestion) => suggestion.label),
        isNot(contains('play volleyball')),
      );
    });

    test('fixed object frames reject unrelated nouns', () {
      final state = lock.applyMove(
        ConfigurationState.initial(),
        const SetAction(learn),
      );
      final blocked = lock.applyMove(
        state,
        const SetObject(fixed_object.volleyball),
      );

      expect(blocked.sentenceState, same(state.sentenceState));
      expect(wasBlocked(blocked), isTrue);
      expect(
        blocked.messages.single.text,
        'learn only takes fixed subject objects.',
      );
    });

    test('object noun phrase modifiers wake after object exists', () {
      expect(
        compass.suggestionsFor(
          ConfigurationState.initial(),
          ConfigurationCompassSlot.objectDeterminer,
          limit: 0,
        ),
        isEmpty,
      );
      expect(
        compass.suggestionsFor(
          ConfigurationState.initial(),
          ConfigurationCompassSlot.objectAdjective,
          limit: 0,
        ),
        isEmpty,
      );

      var state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetAction(work_data.build));
      state = lock.applyMove(
        state,
        SetObject(book.toNounPhrase(Number.singular)),
      );

      final determinerSuggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.objectDeterminer,
        limit: 0,
      );

      expect(determinerSuggestions.map((suggestion) => suggestion.label), [
        'no determiner',
        'a',
        'the',
      ]);
      expect(determinerSuggestions.first.isSelected, isTrue);

      final aSuggestion = determinerSuggestions.singleWhere(
        (suggestion) => suggestion.label == 'a',
      );
      expect(render(aSuggestion.preview), 'You build a book.');

      var adjectiveSuggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.objectAdjective,
        limit: 0,
      );

      expect(adjectiveSuggestions.map((suggestion) => suggestion.label), [
        'no adjective',
        'big',
        'red',
      ]);
      expect(adjectiveSuggestions.first.isSelected, isTrue);

      final bigSuggestion = adjectiveSuggestions.singleWhere(
        (suggestion) => suggestion.label == 'big',
      );

      state = bigSuggestion.preview;
      expect(render(state), 'You build big book.');

      adjectiveSuggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.objectAdjective,
        limit: 0,
      );
      final redSuggestion = adjectiveSuggestions.singleWhere(
        (suggestion) => suggestion.label == 'red',
      );

      expect(render(redSuggestion.preview), 'You build big red book.');
    });

    test('suggests passive voice only after an object frame exists', () {
      final initialSuggestions = compass.suggestionsFor(
        ConfigurationState.initial(),
        ConfigurationCompassSlot.voice,
      );

      expect(initialSuggestions.map((suggestion) => suggestion.label), [
        'active',
      ]);
      expect(initialSuggestions.single.isSelected, isTrue);

      var state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetAction(work_data.build));
      state = lock.applyMove(
        state,
        SetObject(bridge.toNounPhrase(Number.singular)),
      );

      final suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.voice,
      );

      expect(suggestions.map((suggestion) => suggestion.label), [
        'passive',
        'active',
      ]);
      expect(
        suggestions
            .singleWhere((suggestion) => suggestion.label == 'active')
            .isSelected,
        isTrue,
      );

      final passiveSuggestion = suggestions.singleWhere(
        (suggestion) => suggestion.label == 'passive',
      );

      expect(passiveSuggestion.preview.sentenceState.voice, Voice.passive);
      expect(render(passiveSuggestion.preview), 'Bridge is built by you.');
    });

    test('hides passive focus until passive voice is selected', () {
      var state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetAction(give));
      state = lock.applyMove(
        state,
        SetObject(book.toNounPhrase(Number.singular)),
      );
      state = lock.applyMove(
        state,
        SetRecipient(mary.toNounPhrase(Number.singular)),
      );

      expect(
        compass.suggestionsFor(
          state,
          ConfigurationCompassSlot.passiveFocus,
          limit: 0,
        ),
        isEmpty,
      );

      state = lock.applyMove(state, const SetVoice(Voice.passive));

      final suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.passiveFocus,
        limit: 0,
      );

      expect(suggestions.map((suggestion) => suggestion.label), [
        'no passive focus',
        'object',
        'recipient',
      ]);
      expect(suggestions.first.isSelected, isTrue);
    });

    test('offers lexical be as the doorway to complement suggestions', () {
      var suggestions = compass.suggestionsFor(
        ConfigurationState.initial(),
        ConfigurationCompassSlot.action,
        limit: 0,
      );

      expect(
        suggestions
            .singleWhere((suggestion) => suggestion.label == 'learn')
            .isSelected,
        isTrue,
      );

      final beSuggestion = suggestions.singleWhere(
        (suggestion) => suggestion.label == 'be',
      );
      expect(render(beSuggestion.preview), 'You are.');

      expect(
        compass.suggestionsFor(
          ConfigurationState.initial(),
          ConfigurationCompassSlot.complement,
          limit: 0,
        ),
        isEmpty,
      );
      expect(
        compass.suggestionsFor(
          ConfigurationState.initial(),
          ConfigurationCompassSlot.adjectiveComplement,
          limit: 0,
        ),
        isEmpty,
      );

      final beState = beSuggestion.preview;
      suggestions = compass.suggestionsFor(
        beState,
        ConfigurationCompassSlot.adjectiveComplement,
        limit: 0,
      );

      expect(suggestions.map((suggestion) => suggestion.label), [
        'happy',
        'tired',
      ]);
      expect(render(suggestions.first.preview), 'You are happy.');
    });

    test('default verb dial keeps go visible as a movement doorway', () {
      final suggestions = ConfigurationCompass().suggestionsFor(
        ConfigurationState.initial(),
        ConfigurationCompassSlot.action,
        limit: 6,
      );

      expect(suggestions.map((suggestion) => suggestion.label), contains('go'));
    });

    test('ranks predicate doorways by sentence influence', () {
      final labels = ConfigurationCompass()
          .suggestionsFor(
            ConfigurationState.initial(),
            ConfigurationCompassSlot.action,
            limit: 0,
          )
          .map((suggestion) => suggestion.label)
          .toList();

      expect(
        labels,
        containsAll(['be', 'give', 'play', 'learn', 'go', 'get', 'work']),
      );
      expect(labels.indexOf('be'), lessThan(labels.indexOf('get')));
      expect(labels.indexOf('give'), lessThan(labels.indexOf('get')));
      expect(labels.indexOf('play'), lessThan(labels.indexOf('get')));
      expect(labels.indexOf('learn'), lessThan(labels.indexOf('get')));
      expect(labels.indexOf('go'), lessThan(labels.indexOf('work')));
    });

    test('noun complement suggestions follow agent number', () {
      var state = lock.applyMove(
        ConfigurationState.initial(),
        const SetAction(be),
      );

      var suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.complement,
        limit: 0,
      );

      expect(suggestions.map((suggestion) => suggestion.label), [
        'a doctor',
        'a student',
        'a teacher',
        'an engineer',
      ]);

      state = lock.applyMove(state, const SetAgent(they));
      suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.complement,
        limit: 0,
      );

      expect(suggestions.map((suggestion) => suggestion.label), [
        'doctors',
        'engineers',
        'students',
        'teachers',
      ]);
      expect(render(suggestions.last.preview), 'They are teachers.');
    });

    test('offers normal verbs as exits from lexical be', () {
      final state = lock.applyMove(
        ConfigurationState.initial(),
        const SetLexicalBeAdjectiveComplement(happy),
      );

      final suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.action,
        limit: 0,
      );

      expect(
        suggestions.map((suggestion) => suggestion.label),
        contains('work'),
      );

      final workSuggestion = suggestions.singleWhere(
        (suggestion) => suggestion.label == 'work',
      );

      expect(workSuggestion.preview.sentenceState.action, work);
      expect(workSuggestion.preview.sentenceState.adjectiveComplement, isNull);
      expect(wasBlocked(workSuggestion.preview), isFalse);
      expect(render(workSuggestion.preview), 'You work.');
    });

    test(
      'hides incompatible object recipient and passive focus for lexical be',
      () {
        final state = lock.applyMove(
          ConfigurationState.initial(),
          const SetLexicalBeAdjectiveComplement(happy),
        );

        expect(
          compass.suggestionsFor(state, ConfigurationCompassSlot.object),
          isEmpty,
        );
        expect(
          compass.suggestionsFor(state, ConfigurationCompassSlot.recipient),
          isEmpty,
        );
        expect(
          compass.suggestionsFor(state, ConfigurationCompassSlot.passiveFocus),
          isEmpty,
        );
      },
    );

    test('addressee suggestions require addressee-capable frame', () {
      var state = ConfigurationState.initial();

      expect(
        compass.suggestionsFor(state, ConfigurationCompassSlot.addressee),
        isEmpty,
      );

      state = lock.applyMove(state, const SetAction(speak));
      final suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.addressee,
        limit: 0,
      );

      expect(suggestions.map((suggestion) => suggestion.label), [
        'John',
        'Mary',
      ]);
      expect(render(suggestions.last.preview), 'You speak to Mary.');
    });

    test('companion suggestions require companion-capable frame', () {
      var state = lock.applyMove(
        ConfigurationState.initial(),
        const SetAction(work_data.build),
      );

      expect(
        compass.suggestionsFor(state, ConfigurationCompassSlot.companion),
        isEmpty,
      );

      state = lock.applyMove(state, const SetAction(speak));
      final suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.companion,
        limit: 0,
      );

      expect(suggestions.map((suggestion) => suggestion.label), [
        'John',
        'Mary',
      ]);
      expect(render(suggestions.last.preview), 'You speak with Mary.');
    });

    test('destination suggestions require movement destination frame', () {
      var state = lock.applyMove(
        ConfigurationState.initial(),
        const SetAction(speak),
      );

      expect(
        compass.suggestionsFor(state, ConfigurationCompassSlot.destination),
        isEmpty,
      );

      state = lock.applyMove(state, const SetAction(go));
      final suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.destination,
        limit: 0,
      );

      expect(suggestions.map((suggestion) => suggestion.label), [
        'John',
        'Mary',
      ]);
      expect(render(suggestions.last.preview), 'You go to Mary.');
    });

    test('keeps recipient focus behind the ditransitive frame', () {
      var state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetAction(give));
      state = lock.applyMove(
        state,
        SetObject(book.toNounPhrase(Number.singular)),
      );
      state = lock.applyMove(state, const SetVoice(Voice.passive));

      var suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.passiveFocus,
        limit: 0,
      );

      expect(suggestions.map((suggestion) => suggestion.label), [
        'no passive focus',
        'object',
      ]);

      state = lock.applyMove(
        state,
        SetRecipient(mary.toNounPhrase(Number.singular)),
      );
      suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.passiveFocus,
        limit: 0,
      );

      expect(suggestions.map((suggestion) => suggestion.label), [
        'no passive focus',
        'object',
        'recipient',
      ]);
      expect(
        suggestions.last.preview.sentenceState.passiveFocus,
        PassiveFocus.recipient,
      );
      expect(render(suggestions.last.preview), 'Mary is given book by you.');

      final exitSuggestion = suggestions.singleWhere(
        (suggestion) => suggestion.label == 'no passive focus',
      );
      expect(exitSuggestion.preview.sentenceState.passiveFocus, isNull);
      expect(render(exitSuggestion.preview), 'Book is given to Mary by you.');
    });

    test('recipient object pronouns support passive to phrases', () {
      var state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetAction(give));
      state = lock.applyMove(
        state,
        SetObject(book.toNounPhrase(Number.singular)),
      );

      final suggestions = ConfigurationCompass().suggestionsFor(
        state,
        ConfigurationCompassSlot.recipient,
        limit: 0,
      );
      final himSuggestion = suggestions.singleWhere(
        (suggestion) => suggestion.label == 'him',
      );

      expect(himSuggestion.preview.sentenceState.recipient, object_case.him);
      expect(render(himSuggestion.preview), 'You give him book.');

      state = lock.applyMove(state, const SetRecipient(object_case.him));
      state = lock.applyMove(state, const SetVoice(Voice.passive));
      state = lock.applyMove(state, const SetTense(Tense.past));

      expect(render(state), 'Book was given to him by you.');

      final recipientSuggestions = ConfigurationCompass().suggestionsFor(
        state,
        ConfigurationCompassSlot.recipient,
        limit: 0,
      );
      final noRecipientSuggestion = recipientSuggestions.singleWhere(
        (suggestion) => suggestion.label == 'no recipient',
      );

      expect(noRecipientSuggestion.preview.sentenceState.recipient, isNull);
      expect(render(noRecipientSuggestion.preview), 'Book was given by you.');

      final agentSuggestions = ConfigurationCompass().suggestionsFor(
        state,
        ConfigurationCompassSlot.passiveAgent,
        limit: 0,
      );

      expect(agentSuggestions.map((suggestion) => suggestion.label), [
        'show by-agent',
        'hide by-agent',
      ]);
      expect(agentSuggestions.first.isSelected, isTrue);

      final hideAgentSuggestion = agentSuggestions.singleWhere(
        (suggestion) => suggestion.label == 'hide by-agent',
      );

      expect(hideAgentSuggestion.preview.sentenceState.showPassiveAgent, false);
      expect(render(hideAgentSuggestion.preview), 'Book was given to him.');
    });

    test('offers active voice as an exit from passive recipient focus', () {
      var state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetAction(give));
      state = lock.applyMove(
        state,
        SetObject(book.toNounPhrase(Number.singular)),
      );
      state = lock.applyMove(
        state,
        SetRecipient(mary.toNounPhrase(Number.singular)),
      );
      state = lock.applyMove(state, const SetVoice(Voice.passive));
      state = lock.applyMove(
        state,
        const SetPassiveFocus(PassiveFocus.recipient),
      );

      final suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.voice,
        limit: 0,
      );
      final activeSuggestion = suggestions.singleWhere(
        (suggestion) => suggestion.label == 'active',
      );

      expect(activeSuggestion.preview.sentenceState.voice, Voice.active);
      expect(activeSuggestion.preview.sentenceState.passiveFocus, isNull);
      expect(wasBlocked(activeSuggestion.preview), isFalse);
      expect(render(activeSuggestion.preview), 'You give Mary book.');
    });

    test('modal suggestions honor tense frames', () {
      final presentSuggestions = compass.suggestionsFor(
        ConfigurationState.initial(),
        ConfigurationCompassSlot.modal,
        limit: 0,
      );

      expect(presentSuggestions.map((suggestion) => suggestion.label), [
        'can',
        'should',
        'no modal',
      ]);
      expect(presentSuggestions.last.isSelected, isTrue);

      var state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetTense(Tense.future));

      final futureSuggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.modal,
        limit: 0,
      );

      expect(futureSuggestions.map((suggestion) => suggestion.label), [
        'will',
        'no modal',
      ]);
      expect(futureSuggestions.last.isSelected, isTrue);
      expect(render(futureSuggestions.first.preview), 'You will learn.');
    });

    test('modal suggestions expose no modal as the exit', () {
      final state = lock.applyMove(
        ConfigurationState.initial(),
        const SetModal(can),
      );

      final suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.modal,
      );

      final noModalSuggestion = suggestions.singleWhere(
        (suggestion) => suggestion.label == 'no modal',
      );

      expect(noModalSuggestion.preview.sentenceState.modal, noModal);
      expect(wasBlocked(noModalSuggestion.preview), isFalse);
      expect(render(noModalSuggestion.preview), 'You learn.');
    });

    test('keeps current choices visible as selected suggestions', () {
      var state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetAction(work_data.build));
      state = lock.applyMove(
        state,
        SetObject(book.toNounPhrase(Number.singular)),
      );
      state = lock.applyMove(
        state,
        const SetNounPhraseDeterminer(NounPhraseTarget.object, aDeterminer),
      );

      final actionSuggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.action,
        limit: 0,
      );
      final buildSuggestion = actionSuggestions.singleWhere(
        (suggestion) => suggestion.label == 'build',
      );
      expect(buildSuggestion.isSelected, isTrue);

      final objectSuggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.object,
        limit: 0,
      );
      expect(objectSuggestions.first.label, 'a book');
      expect(objectSuggestions.first.isSelected, isTrue);
      expect(render(objectSuggestions.first.preview), 'You build a book.');

      final determinerSuggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.objectDeterminer,
        limit: 0,
      );
      final selectedDeterminer = determinerSuggestions.singleWhere(
        (suggestion) => suggestion.isSelected,
      );
      expect(selectedDeterminer.label, 'a');

      final adjectiveSuggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.objectAdjective,
      );
      expect(adjectiveSuggestions.first.label, 'no adjective');
      expect(adjectiveSuggestions.first.isSelected, isTrue);
    });

    test(
      'noun suggestions carry compatible modifiers from the current slot',
      () {
        final modifierCompass = ConfigurationCompass(
          actions: [work_data.build],
          objects: [
            book.toNounPhrase(Number.singular),
            bridge.toNounPhrase(Number.singular),
            engineer.toNounPhrase(Number.singular),
            book.toNounPhrase(Number.plural),
          ],
          nounAdjectives: [big],
          determiners: [aDeterminer, anDeterminer, manyDeterminer],
        );

        var state = ConfigurationState.initial();
        state = lock.applyMove(state, const SetAction(work_data.build));
        state = lock.applyMove(
          state,
          SetObject(book.toNounPhrase(Number.singular)),
        );
        state = lock.applyMove(
          state,
          const SetNounPhraseDeterminer(NounPhraseTarget.object, aDeterminer),
        );
        state = lock.applyMove(
          state,
          const SetNounPhraseAdjectives(NounPhraseTarget.object, [big]),
        );

        var suggestions = modifierCompass.suggestionsFor(
          state,
          ConfigurationCompassSlot.object,
          limit: 0,
        );

        final bridgeSuggestion = suggestions.singleWhere(
          (suggestion) => suggestion.label == 'a big bridge',
        );
        expect(render(bridgeSuggestion.preview), 'You build a big bridge.');

        final engineerSuggestion = suggestions.singleWhere(
          (suggestion) => suggestion.label == 'a big engineer',
        );
        expect(render(engineerSuggestion.preview), 'You build a big engineer.');

        state = lock.applyMove(
          state,
          const SetNounPhraseAdjectives(NounPhraseTarget.object, []),
        );
        suggestions = modifierCompass.suggestionsFor(
          state,
          ConfigurationCompassSlot.object,
          limit: 0,
        );

        final plainEngineerSuggestion = suggestions.singleWhere(
          (suggestion) => suggestion.label == 'an engineer',
        );
        expect(
          render(plainEngineerSuggestion.preview),
          'You build an engineer.',
        );

        state = lock.applyMove(
          state,
          SetObject(book.toNounPhrase(Number.plural)),
        );
        state = lock.applyMove(
          state,
          const SetNounPhraseDeterminer(
            NounPhraseTarget.object,
            manyDeterminer,
          ),
        );
        state = lock.applyMove(
          state,
          const SetNounPhraseAdjectives(NounPhraseTarget.object, [big]),
        );
        suggestions = modifierCompass.suggestionsFor(
          state,
          ConfigurationCompassSlot.object,
          limit: 0,
        );

        final pluralBookSuggestion = suggestions.singleWhere(
          (suggestion) => suggestion.label == 'many big books',
        );
        expect(
          render(pluralBookSuggestion.preview),
          'You build many big books.',
        );
      },
    );

    test('does not carry narrow object choices into incompatible verbs', () {
      final semanticCompass = ConfigurationCompass(
        actions: [give, drive, use],
        objects: [
          house.toNounPhrase(Number.singular),
          car.toNounPhrase(Number.singular),
        ],
      );

      var state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetAction(give));
      state = lock.applyMove(
        state,
        SetObject(house.toNounPhrase(Number.singular)),
      );

      var suggestions = semanticCompass.suggestionsFor(
        state,
        ConfigurationCompassSlot.action,
        limit: 0,
      );

      expect(suggestions.map((suggestion) => suggestion.label), [
        'give',
        'use',
      ]);

      state = lock.applyMove(
        state,
        SetObject(car.toNounPhrase(Number.singular)),
      );

      suggestions = semanticCompass.suggestionsFor(
        state,
        ConfigurationCompassSlot.action,
        limit: 0,
      );

      expect(
        suggestions.map((suggestion) => suggestion.label),
        contains('drive'),
      );

      state = lock.applyMove(
        ConfigurationState.initial(),
        const SetAction(drive),
      );
      suggestions = semanticCompass.suggestionsFor(
        state,
        ConfigurationCompassSlot.object,
        limit: 0,
      );

      expect(suggestions.map((suggestion) => suggestion.label), ['car']);
    });

    test('place suggestions use location meaning for ordinary verbs', () {
      final state = lock.applyMove(
        ConfigurationState.initial(),
        const SetAction(work),
      );
      final suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.placePhrase,
        limit: 0,
      );

      expect(suggestions.first.label, 'no place');
      expect(suggestions.first.isSelected, isTrue);
      expect(
        suggestions.map((suggestion) => suggestion.label),
        isNot(contains('work')),
      );

      final schoolSuggestion = suggestions.singleWhere(
        (suggestion) => suggestion.label == 'school',
      );
      expect(render(schoolSuggestion.preview), 'You work at school.');

      final stateWithPlace = schoolSuggestion.preview;
      final exitSuggestions = compass.suggestionsFor(
        stateWithPlace,
        ConfigurationCompassSlot.placePhrase,
        limit: 0,
      );

      expect(
        exitSuggestions
            .singleWhere((suggestion) => suggestion.label == 'school')
            .isSelected,
        isTrue,
      );
      expect(
        render(
          exitSuggestions
              .singleWhere((suggestion) => suggestion.label == 'no place')
              .preview,
        ),
        'You work.',
      );
    });

    test('place suggestions use destination meaning for movement verbs', () {
      final state = lock.applyMove(
        ConfigurationState.initial(),
        const SetAction(go),
      );

      final suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.placePhrase,
        limit: 0,
      );

      expect(suggestions.first.label, 'home');
      expect(render(suggestions.first.preview), 'You go home.');

      final schoolSuggestion = suggestions.singleWhere(
        (suggestion) => suggestion.label == 'school',
      );

      expect(render(schoolSuggestion.preview), 'You go to school.');
    });

    test('time suggestions put tense-friendly phrases first', () {
      var state = ConfigurationState.initial();

      var suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.timePhrase,
      );

      expect(suggestions.first.label, 'no time');
      expect(suggestions.first.isSelected, isTrue);

      state = lock.applyMove(state, const SetAspect(Aspect.continuous));
      suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.timePhrase,
      );

      expect(
        suggestions.singleWhere((suggestion) => suggestion.label == 'now'),
        isNotNull,
      );

      state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetTense(Tense.past));
      suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.timePhrase,
      );

      expect(
        suggestions.singleWhere(
          (suggestion) => suggestion.label == 'yesterday',
        ),
        isNotNull,
      );

      state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetTense(Tense.future));
      suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.timePhrase,
      );

      expect(
        suggestions.singleWhere((suggestion) => suggestion.label == 'tomorrow'),
        isNotNull,
      );

      state = lock.applyMove(state, const SetTimePhrase(tomorrowTimePhrase));
      suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.timePhrase,
        limit: 0,
      );

      expect(
        suggestions
            .singleWhere((suggestion) => suggestion.label == 'tomorrow')
            .isSelected,
        isTrue,
      );
      expect(
        render(
          suggestions
              .singleWhere((suggestion) => suggestion.label == 'no time')
              .preview,
        ),
        'You will learn.',
      );
    });

    test('never returns a move blocked by guided mode', () {
      var state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetAction(give));
      state = lock.applyMove(
        state,
        SetObject(book.toNounPhrase(Number.singular)),
      );
      state = lock.applyMove(
        state,
        SetRecipient(mary.toNounPhrase(Number.singular)),
      );

      for (final slot in ConfigurationCompassSlot.values) {
        final suggestions = compass.suggestionsFor(state, slot, limit: 0);

        for (final suggestion in suggestions) {
          expect(
            wasBlocked(suggestion.preview),
            isFalse,
            reason: '${slot.name} suggested ${suggestion.label}',
          );
          expect(() => render(suggestion.preview), returnsNormally);
        }
      }
    });
  });
}
