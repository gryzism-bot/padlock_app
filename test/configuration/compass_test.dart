import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/subjects/adjectives/emotions.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/verbs/essential.dart';
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
    actions: [work, work_data.build, give, be],
    objects: [
      book.toNounPhrase(Number.singular),
      bridge.toNounPhrase(Number.singular),
    ],
    recipients: [
      mary.toNounPhrase(Number.singular),
      john.toNounPhrase(Number.singular),
    ],
    adjectiveComplements: [happy, tired],
    modals: [noModal, can, should, will],
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
      );

      expect(initialSuggestions, isEmpty);

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
      expect(render(suggestions.first.preview), 'He builds book.');
      expect(wasBlocked(suggestions.first.preview), isFalse);
    });

    test('suggests passive voice only after an object frame exists', () {
      final initialSuggestions = compass.suggestionsFor(
        ConfigurationState.initial(),
        ConfigurationCompassSlot.voice,
      );

      expect(initialSuggestions.map((suggestion) => suggestion.label), isEmpty);

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

      expect(suggestions.map((suggestion) => suggestion.label), ['passive']);
      expect(suggestions.single.preview.sentenceState.voice, Voice.passive);
      expect(render(suggestions.single.preview), 'Bridge is built by him.');
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
        'object',
        'recipient',
      ]);
    });

    test('enters lexical be through complement suggestions', () {
      final suggestions = compass.suggestionsFor(
        ConfigurationState.initial(),
        ConfigurationCompassSlot.adjectiveComplement,
        limit: 0,
      );

      expect(suggestions.map((suggestion) => suggestion.label), [
        'happy',
        'tired',
      ]);
      expect(suggestions.first.preview.sentenceState.action, be);
      expect(render(suggestions.first.preview), 'He is happy.');
    });

    test('noun complement suggestions follow agent number', () {
      var state = ConfigurationState.initial();

      var suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.complement,
        limit: 0,
      );

      expect(suggestions.map((suggestion) => suggestion.label), [
        'doctor',
        'engineer',
        'student',
        'teacher',
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
      expect(render(workSuggestion.preview), 'He works.');
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

      expect(suggestions.map((suggestion) => suggestion.label), ['object']);

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
        'object',
        'recipient',
      ]);
      expect(
        suggestions.last.preview.sentenceState.passiveFocus,
        PassiveFocus.recipient,
      );
      expect(render(suggestions.last.preview), 'Mary is given book by him.');
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
      expect(render(activeSuggestion.preview), 'He gives Mary book.');
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
      ]);

      var state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetTense(Tense.future));

      final futureSuggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.modal,
        limit: 0,
      );

      expect(futureSuggestions.map((suggestion) => suggestion.label), ['will']);
      expect(render(futureSuggestions.single.preview), 'He will work.');
    });

    test('time suggestions put tense-friendly phrases first', () {
      var state = ConfigurationState.initial();

      var suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.timePhrase,
      );

      expect(suggestions.first.label, 'today');

      state = lock.applyMove(state, const SetAspect(Aspect.continuous));
      suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.timePhrase,
      );

      expect(suggestions.first.label, 'now');

      state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetTense(Tense.past));
      suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.timePhrase,
      );

      expect(suggestions.first.label, 'yesterday');

      state = ConfigurationState.initial();
      state = lock.applyMove(state, const SetTense(Tense.future));
      suggestions = compass.suggestionsFor(
        state,
        ConfigurationCompassSlot.timePhrase,
      );

      expect(suggestions.first.label, 'tomorrow');
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
