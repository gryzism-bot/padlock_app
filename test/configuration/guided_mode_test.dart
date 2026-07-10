import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/subjects/adjectives/emotions.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/work.dart' as work_data;
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/voice.dart';

void main() {
  final engine = ConfigurationEngine();
  final grammar = GrammarEngine();

  String render(ConfigurationState state) {
    return grammar.generate(state.sentenceState).text;
  }

  bool wasBlocked(ConfigurationState state) {
    return state.messages.any(
      (message) => message.kind == ConfigurationMessageKind.blocked,
    );
  }

  group('Guided Configuration Engine', () {
    test('initial state is a valid renderable frame', () {
      final state = ConfigurationState.initial();

      expect(render(state), 'He works.');
      expect(state.messages, isEmpty);
    });

    test('accepts a valid wheel move', () {
      final state = engine.applyMove(
        ConfigurationState.initial(),
        const SetTense(Tense.past),
      );

      expect(state.sentenceState.tense, Tense.past);
      expect(render(state), 'He worked.');
      expect(wasBlocked(state), isFalse);
    });

    test('blocks removing active agent', () {
      final previous = ConfigurationState.initial();
      final state = engine.applyMove(previous, const SetAgent(null));

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(state.messages.single.text, 'Active voice requires an agent.');
    });

    test('blocks object on intransitive verb', () {
      final previous = ConfigurationState.initial();
      final state = engine.applyMove(
        previous,
        SetObject(book.toNounPhrase(Number.singular)),
      );

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(state.messages.single.text, 'work does not take an object.');
    });

    test('accepts object once verb frame supports it', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(work_data.build));
      state = engine.applyMove(
        state,
        SetObject(bridge.toNounPhrase(Number.singular)),
      );

      expect(state.sentenceState.action, work_data.build);
      expect(state.sentenceState.object?.text, 'bridge');
      expect(render(state), 'He builds bridge.');
      expect(wasBlocked(state), isFalse);
    });

    test('blocks noun phrase determiners that do not match number', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(work_data.build));
      state = engine.applyMove(
        state,
        SetObject(book.toNounPhrase(Number.plural)),
      );

      final previous = state;
      state = engine.applyMove(
        state,
        const SetNounPhraseDeterminer(NounPhraseTarget.object, aDeterminer),
      );

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(
        state.messages.single.text,
        'Object determiner "a" requires a singular noun.',
      );

      state = engine.applyMove(
        previous,
        const SetNounPhraseDeterminer(NounPhraseTarget.object, manyDeterminer),
      );

      expect(wasBlocked(state), isFalse);
      expect(render(state), 'He builds many books.');
    });

    test('blocks noun phrase articles that do not match noun sound', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(work_data.build));
      state = engine.applyMove(
        state,
        SetObject(book.toNounPhrase(Number.singular)),
      );

      final previous = state;
      state = engine.applyMove(
        state,
        const SetNounPhraseDeterminer(NounPhraseTarget.object, anDeterminer),
      );

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(
        state.messages.single.text,
        'Object determiner "an" requires a vowel sound.',
      );

      state = engine.applyMove(
        previous,
        SetObject(engineer.toNounPhrase(Number.singular)),
      );
      state = engine.applyMove(
        state,
        const SetNounPhraseDeterminer(NounPhraseTarget.object, anDeterminer),
      );

      expect(wasBlocked(state), isFalse);
      expect(render(state), 'He builds an engineer.');
    });

    test('blocks place phrase that repeats the verb word', () {
      final previous = ConfigurationState.initial();
      final state = engine.applyMove(
        previous,
        const SetPlacePhrase(workPlacePhrase),
      );

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(
        state.messages.single.text,
        'Place phrase cannot repeat the verb word "work".',
      );
    });

    test('blocks moving to an intransitive verb while object is present', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(work_data.build));
      state = engine.applyMove(
        state,
        SetObject(bridge.toNounPhrase(Number.singular)),
      );

      final previous = state;
      state = engine.applyMove(state, const SetAction(work));

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(state.messages.single.text, 'work does not take an object.');
    });

    test('blocks active recipient without object', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(give));
      final previous = state;
      state = engine.applyMove(
        state,
        SetRecipient(mary.toNounPhrase(Number.singular)),
      );

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(state.messages.single.text, 'Recipient frames require an object.');
    });

    test('blocks recipient on verbs without recipient frame', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(work_data.build));
      state = engine.applyMove(
        state,
        SetObject(bridge.toNounPhrase(Number.singular)),
      );

      final previous = state;
      state = engine.applyMove(
        state,
        SetRecipient(mary.toNounPhrase(Number.singular)),
      );

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(state.messages.single.text, 'build does not take a recipient.');
    });

    test('blocks passive voice without a passive-capable frame', () {
      final previous = ConfigurationState.initial();
      final state = engine.applyMove(previous, const SetVoice(Voice.passive));

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(
        state.messages.map((message) => message.text),
        contains('work cannot be passive in this frame.'),
      );
    });

    test('accepts passive voice when object frame exists', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(work_data.build));
      state = engine.applyMove(
        state,
        SetObject(bridge.toNounPhrase(Number.singular)),
      );
      state = engine.applyMove(state, const SetVoice(Voice.passive));

      expect(state.sentenceState.voice, Voice.passive);
      expect(render(state), 'Bridge is built by him.');
      expect(wasBlocked(state), isFalse);
    });

    test('blocks removing object from passive object focus', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(work_data.build));
      state = engine.applyMove(
        state,
        SetObject(bridge.toNounPhrase(Number.singular)),
      );
      state = engine.applyMove(state, const SetVoice(Voice.passive));

      final previous = state;
      state = engine.applyMove(state, const SetObject(null));

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(
        state.messages.single.text,
        'Passive object focus requires an object.',
      );
    });

    test('blocks passive focus while voice is active', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(work_data.build));
      state = engine.applyMove(
        state,
        SetObject(bridge.toNounPhrase(Number.singular)),
      );

      final previous = state;
      state = engine.applyMove(
        state,
        const SetPassiveFocus(PassiveFocus.object),
      );

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(
        state.messages.single.text,
        'Passive focus belongs to passive voice.',
      );
    });

    test('blocks recipient focus on non-ditransitive passive', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(work_data.build));
      state = engine.applyMove(
        state,
        SetObject(bridge.toNounPhrase(Number.singular)),
      );
      state = engine.applyMove(state, const SetVoice(Voice.passive));

      final previous = state;
      state = engine.applyMove(
        state,
        const SetPassiveFocus(PassiveFocus.recipient),
      );

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(
        state.messages.map((message) => message.text),
        contains('build has no recipient focus.'),
      );
    });

    test('blocks recipient focus until recipient exists', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(give));
      state = engine.applyMove(
        state,
        SetObject(book.toNounPhrase(Number.singular)),
      );
      state = engine.applyMove(state, const SetVoice(Voice.passive));

      final previous = state;
      state = engine.applyMove(
        state,
        const SetPassiveFocus(PassiveFocus.recipient),
      );

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(
        state.messages.map((message) => message.text),
        contains('Passive recipient focus requires a recipient.'),
      );
    });

    test('accepts recipient focus with full ditransitive frame', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(give));
      state = engine.applyMove(
        state,
        SetObject(book.toNounPhrase(Number.singular)),
      );
      state = engine.applyMove(
        state,
        SetRecipient(mary.toNounPhrase(Number.singular)),
      );
      state = engine.applyMove(state, const SetVoice(Voice.passive));
      state = engine.applyMove(
        state,
        const SetPassiveFocus(PassiveFocus.recipient),
      );

      expect(state.sentenceState.passiveFocus, PassiveFocus.recipient);
      expect(render(state), 'Mary is given book by him.');
      expect(wasBlocked(state), isFalse);
    });

    test('exits passive voice by clearing passive focus', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(give));
      state = engine.applyMove(
        state,
        SetObject(book.toNounPhrase(Number.singular)),
      );
      state = engine.applyMove(
        state,
        SetRecipient(mary.toNounPhrase(Number.singular)),
      );
      state = engine.applyMove(state, const SetVoice(Voice.passive));
      state = engine.applyMove(
        state,
        const SetPassiveFocus(PassiveFocus.recipient),
      );
      state = engine.applyMove(state, const SetVoice(Voice.active));

      expect(state.sentenceState.voice, Voice.active);
      expect(state.sentenceState.passiveFocus, isNull);
      expect(wasBlocked(state), isFalse);
      expect(render(state), 'He gives Mary book.');
    });

    test('selects lexical be as a bare verb frame', () {
      final state = engine.applyMove(
        ConfigurationState.initial(),
        const SetAction(be),
      );

      expect(state.sentenceState.action, be);
      expect(state.sentenceState.complement, isNull);
      expect(state.sentenceState.adjectiveComplement, isNull);
      expect(wasBlocked(state), isFalse);
      expect(render(state), 'He is.');
    });

    test('enters lexical be adjective frame atomically', () {
      final state = engine.applyMove(
        ConfigurationState.initial(),
        const SetLexicalBeAdjectiveComplement(happy),
      );

      expect(state.sentenceState.action, be);
      expect(state.sentenceState.adjectiveComplement, happy);
      expect(state.sentenceState.voice, Voice.active);
      expect(state.sentenceState.object, isNull);
      expect(wasBlocked(state), isFalse);
      expect(render(state), 'He is happy.');
    });

    test('enters lexical be noun complement frame atomically', () {
      final state = engine.applyMove(
        ConfigurationState.initial(),
        SetLexicalBeComplement(
          doctor.toNounPhrase(Number.singular, determiner: aDeterminer),
        ),
      );

      expect(state.sentenceState.action, be);
      expect(state.sentenceState.complement?.text, 'doctor');
      expect(state.sentenceState.adjectiveComplement, isNull);
      expect(wasBlocked(state), isFalse);
      expect(render(state), 'He is a doctor.');
    });

    test('blocks lexical be noun complement number mismatch', () {
      var state = engine.applyMove(
        ConfigurationState.initial(),
        SetLexicalBeComplement(
          doctor.toNounPhrase(Number.singular, determiner: aDeterminer),
        ),
      );

      final previous = state;
      state = engine.applyMove(state, const SetAgent(they));

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(
        state.messages.single.text,
        'Lexical be noun complement must match agent number.',
      );
      expect(render(state), 'He is a doctor.');
    });

    test('lexical be frame move clears incompatible passive/object slots', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(work_data.build));
      state = engine.applyMove(
        state,
        SetObject(bridge.toNounPhrase(Number.singular)),
      );
      state = engine.applyMove(state, const SetVoice(Voice.passive));
      state = engine.applyMove(
        state,
        const SetLexicalBeAdjectiveComplement(happy),
      );

      expect(state.sentenceState.action, be);
      expect(state.sentenceState.voice, Voice.active);
      expect(state.sentenceState.object, isNull);
      expect(state.sentenceState.recipient, isNull);
      expect(state.sentenceState.passiveFocus, isNull);
      expect(wasBlocked(state), isFalse);
      expect(render(state), 'He is happy.');
    });

    test('lexical be frame can keep a compatible modal frame', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetModal(can));
      state = engine.applyMove(
        state,
        const SetLexicalBeAdjectiveComplement(happy),
      );

      expect(state.sentenceState.action, be);
      expect(state.sentenceState.modal, can);
      expect(wasBlocked(state), isFalse);
      expect(render(state), 'He can be happy.');
    });

    test('lexical be blocks object recipient and passive focus slots', () {
      final state = engine.applyMove(
        ConfigurationState.initial(),
        SetLexicalBeComplement(
          doctor.toNounPhrase(Number.singular, determiner: aDeterminer),
        ),
      );

      var blocked = engine.applyMove(
        state,
        SetObject(book.toNounPhrase(Number.singular)),
      );

      expect(blocked.sentenceState, same(state.sentenceState));
      expect(wasBlocked(blocked), isTrue);
      expect(
        blocked.messages.single.text,
        'Lexical be does not take an object.',
      );

      blocked = engine.applyMove(
        state,
        SetRecipient(mary.toNounPhrase(Number.singular)),
      );

      expect(blocked.sentenceState, same(state.sentenceState));
      expect(wasBlocked(blocked), isTrue);
      expect(
        blocked.messages.single.text,
        'Lexical be does not take a recipient.',
      );

      blocked = engine.applyMove(
        state,
        const SetPassiveFocus(PassiveFocus.object),
      );

      expect(blocked.sentenceState, same(state.sentenceState));
      expect(wasBlocked(blocked), isTrue);
      expect(
        blocked.messages.single.text,
        'Lexical be does not take passive focus.',
      );
    });

    test('exits lexical be by clearing complement slots on verb change', () {
      var state = engine.applyMove(
        ConfigurationState.initial(),
        SetLexicalBeComplement(
          doctor.toNounPhrase(Number.singular, determiner: aDeterminer),
        ),
      );

      state = engine.applyMove(state, const SetAction(work));

      expect(state.sentenceState.action, work);
      expect(state.sentenceState.complement, isNull);
      expect(state.sentenceState.adjectiveComplement, isNull);
      expect(wasBlocked(state), isFalse);
      expect(render(state), 'He works.');
    });

    test('entering lexical be clears incompatible passive/object slots', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(work_data.build));
      state = engine.applyMove(
        state,
        SetObject(bridge.toNounPhrase(Number.singular)),
      );
      state = engine.applyMove(state, const SetVoice(Voice.passive));

      state = engine.applyMove(state, const SetAction(be));

      expect(state.sentenceState.action, be);
      expect(state.sentenceState.voice, Voice.active);
      expect(state.sentenceState.object, isNull);
      expect(state.sentenceState.recipient, isNull);
      expect(state.sentenceState.passiveFocus, isNull);
      expect(wasBlocked(state), isFalse);
      expect(render(state), 'He is.');
    });

    test('blocks passive voice from lexical be', () {
      var state = engine.applyMove(
        ConfigurationState.initial(),
        const SetAction(be),
      );

      final previous = state;
      state = engine.applyMove(state, const SetVoice(Voice.passive));

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(state.messages.single.text, 'Lexical be is active-only.');
    });

    test('blocks complements on non-be verbs', () {
      final previous = ConfigurationState.initial();
      final state = engine.applyMove(
        previous,
        const SetAdjectiveComplement(happy),
      );

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(state.messages.single.text, 'work does not take a complement.');
    });

    test('blocks complements on passive non-be verbs', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(work_data.build));
      state = engine.applyMove(
        state,
        SetObject(bridge.toNounPhrase(Number.singular)),
      );
      state = engine.applyMove(state, const SetVoice(Voice.passive));

      final previous = state;
      state = engine.applyMove(state, const SetAdjectiveComplement(happy));

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(state.messages.single.text, 'build does not take a complement.');
    });

    test('blocks modal and tense combinations outside their frame', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetModal(can));
      final previous = state;
      state = engine.applyMove(state, const SetTense(Tense.future));

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(
        state.messages.single.text,
        'can belongs to the present modal frame.',
      );
    });

    test('blocks will outside future frame', () {
      final previous = ConfigurationState.initial();
      final state = engine.applyMove(previous, const SetModal(will));

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(
        state.messages.single.text,
        'Will belongs to the future tense frame.',
      );
    });

    test('accepts will after future frame is selected', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetTense(Tense.future));
      state = engine.applyMove(state, const SetModal(will));

      expect(state.sentenceState.tense, Tense.future);
      expect(state.sentenceState.modal, will);
      expect(render(state), 'He will work.');
      expect(wasBlocked(state), isFalse);
    });

    test('accepts modal passive when object frame exists', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(work_data.build));
      state = engine.applyMove(
        state,
        SetObject(bridge.toNounPhrase(Number.singular)),
      );
      state = engine.applyMove(state, const SetVoice(Voice.passive));
      state = engine.applyMove(state, const SetModal(should));

      expect(state.sentenceState.modal, should);
      expect(state.sentenceState.voice, Voice.passive);
      expect(wasBlocked(state), isFalse);
      expect(render(state), 'Bridge should be built by him.');
    });

    test('blocks imperative with modal', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetModal(can));
      final previous = state;
      state = engine.applyMove(
        state,
        const SetSentenceForm(SentenceForm.imperative),
      );

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(state.messages.single.text, 'Imperatives cannot take a modal.');
    });

    test('blocks passive imperative frame', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(work_data.build));
      state = engine.applyMove(
        state,
        SetObject(bridge.toNounPhrase(Number.singular)),
      );
      state = engine.applyMove(state, const SetVoice(Voice.passive));

      final previous = state;
      state = engine.applyMove(
        state,
        const SetSentenceForm(SentenceForm.imperative),
      );

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(state.messages.single.text, 'Imperatives use active voice.');
    });

    test('blocks non-simple imperative frame', () {
      final previous = ConfigurationState.initial();
      final state = engine.applyMove(
        previous,
        const SetSentenceForm(SentenceForm.imperative),
      );

      expect(state.sentenceState.sentenceForm, SentenceForm.imperative);
      expect(wasBlocked(state), isFalse);

      final blocked = engine.applyMove(state, const SetAspect(Aspect.perfect));

      expect(blocked.sentenceState, same(state.sentenceState));
      expect(wasBlocked(blocked), isTrue);
      expect(blocked.messages.single.text, 'Imperatives use present simple.');
    });
  });
}
