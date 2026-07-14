import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/subjects/adjectives/emotions.dart';
import 'package:padlock_app/data/subjects/adjectives/size.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart'
    as fixed_object;
import 'package:padlock_app/data/subjects/object_pronouns.dart' as object_data;
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/animals.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/cooking.dart';
import 'package:padlock_app/data/verbs/education.dart';
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

      expect(render(state), 'You learn.');
      expect(state.messages, isEmpty);
    });

    test('accepts a valid wheel move', () {
      final state = engine.applyMove(
        ConfigurationState.initial(),
        const SetTense(Tense.past),
      );

      expect(state.sentenceState.tense, Tense.past);
      expect(render(state), 'You learned.');
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
      final previous = engine.applyMove(
        ConfigurationState.initial(),
        const SetAction(work),
      );
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
      expect(render(state), 'You build bridge.');
      expect(wasBlocked(state), isFalse);
    });

    test('fixed subject verbs clear incompatible current objects', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(teach));
      state = engine.applyMove(state, const SetObject(fixed_object.english));
      state = engine.applyMove(state, const SetAction(chop));
      state = engine.applyMove(
        state,
        SetObject(bridge.toNounPhrase(Number.singular)),
      );
      state = engine.applyMove(state, const SetAction(teach));

      expect(state.sentenceState.action, teach);
      expect(state.sentenceState.object, isNull);
      expect(render(state), 'You teach.');
      expect(wasBlocked(state), isFalse);
    });

    test('accepts right action complement for verbs that wake it', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(want));
      state = engine.applyMove(state, const SetRightAction(go));

      expect(state.sentenceState.action, want);
      expect(state.sentenceState.rightAction, go);
      expect(render(state), 'You want to go.');
      expect(wasBlocked(state), isFalse);
    });

    test('blocks right action complement on verbs without that frame', () {
      final previous = engine.applyMove(
        ConfigurationState.initial(),
        const SetAction(work),
      );
      final state = engine.applyMove(previous, const SetRightAction(go));

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(
        state.messages.single.text,
        'work does not take a right action complement.',
      );
    });

    test('clears right action when changing to an incompatible verb', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(want));
      state = engine.applyMove(state, const SetRightAction(go));
      state = engine.applyMove(state, const SetAction(work_data.build));

      expect(state.sentenceState.action, work_data.build);
      expect(state.sentenceState.rightAction, isNull);
      expect(render(state), 'You build.');
      expect(wasBlocked(state), isFalse);
    });

    test('blocks object and right action in the same frame', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(want));
      state = engine.applyMove(state, const SetRightAction(go));
      final previous = state;
      state = engine.applyMove(
        state,
        SetObject(book.toNounPhrase(Number.singular)),
      );

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(
        state.messages.single.text,
        'Right action complement does not combine with an object in this frame.',
      );
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
      expect(render(state), 'You build many books.');

      state = engine.applyMove(
        previous,
        const SetNounPhraseDeterminer(NounPhraseTarget.object, allDeterminer),
      );

      expect(wasBlocked(state), isFalse);
      expect(render(state), 'You build all books.');

      state = engine.applyMove(
        previous,
        SetObject(book.toNounPhrase(Number.singular)),
      );
      final singularPrevious = state;
      state = engine.applyMove(
        state,
        const SetNounPhraseDeterminer(NounPhraseTarget.object, allDeterminer),
      );

      expect(state.sentenceState, same(singularPrevious.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(
        state.messages.single.text,
        'Object determiner "all" requires a plural noun.',
      );
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
      expect(render(state), 'You build an engineer.');
    });

    test('checks noun phrase article sound against the first spoken word', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(work_data.build));
      state = engine.applyMove(
        state,
        SetObject(engineer.toNounPhrase(Number.singular)),
      );
      state = engine.applyMove(
        state,
        const SetNounPhraseAdjectives(NounPhraseTarget.object, [big]),
      );
      state = engine.applyMove(
        state,
        const SetNounPhraseDeterminer(NounPhraseTarget.object, aDeterminer),
      );

      expect(wasBlocked(state), isFalse);
      expect(render(state), 'You build a big engineer.');
    });

    test('blocks place phrase that repeats the verb word', () {
      final previous = engine.applyMove(
        ConfigurationState.initial(),
        const SetAction(work),
      );
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

    test('accepts addressee on verbs with addressee frame', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(speak));
      state = engine.applyMove(
        state,
        SetAddressee(mary.toNounPhrase(Number.singular)),
      );

      expect(wasBlocked(state), isFalse);
      expect(state.sentenceState.addressee?.text, 'Mary');
      expect(render(state), 'You speak to Mary.');
    });

    test('accepts object plus addressee on bound preposition verbs', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(explain));
      state = engine.applyMove(state, const SetObject(fixed_object.grammar));
      state = engine.applyMove(
        state,
        SetAddressee(mary.toNounPhrase(Number.singular)),
      );

      expect(wasBlocked(state), isFalse);
      expect(state.sentenceState.object?.text, 'grammar');
      expect(state.sentenceState.addressee?.text, 'Mary');
      expect(state.sentenceState.recipient, isNull);
      expect(render(state), 'You explain grammar to Mary.');
    });

    test('blocks addressee on verbs without addressee frame', () {
      final previous = engine.applyMove(
        ConfigurationState.initial(),
        const SetAction(work),
      );
      final state = engine.applyMove(
        previous,
        SetAddressee(mary.toNounPhrase(Number.singular)),
      );

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(state.messages.single.text, 'work does not take an addressee.');
    });

    test('changing action clears incompatible addressee frame', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(speak));
      state = engine.applyMove(
        state,
        SetAddressee(mary.toNounPhrase(Number.singular)),
      );
      state = engine.applyMove(state, const SetAction(work));

      expect(wasBlocked(state), isFalse);
      expect(state.sentenceState.action, work);
      expect(state.sentenceState.addressee, isNull);
      expect(render(state), 'You work.');
    });

    test('accepts companion on verbs with companion frame', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(speak));
      state = engine.applyMove(
        state,
        SetCompanion(mary.toNounPhrase(Number.singular)),
      );

      expect(wasBlocked(state), isFalse);
      expect(state.sentenceState.companion?.text, 'Mary');
      expect(render(state), 'You speak with Mary.');
    });

    test('accepts companion on writing frame', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(write));
      state = engine.applyMove(
        state,
        SetCompanion(mary.toNounPhrase(Number.singular)),
      );

      expect(wasBlocked(state), isFalse);
      expect(state.sentenceState.companion?.text, 'Mary');
      expect(render(state), 'You write with Mary.');
    });

    test('blocks companion on verbs without companion frame', () {
      final previous = engine.applyMove(
        ConfigurationState.initial(),
        const SetAction(work_data.build),
      );
      final state = engine.applyMove(
        previous,
        SetCompanion(mary.toNounPhrase(Number.singular)),
      );

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(state.messages.single.text, 'build does not take a companion.');
    });

    test('changing action clears incompatible companion frame', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(speak));
      state = engine.applyMove(
        state,
        SetCompanion(mary.toNounPhrase(Number.singular)),
      );
      state = engine.applyMove(state, const SetAction(work_data.build));

      expect(wasBlocked(state), isFalse);
      expect(state.sentenceState.action, work_data.build);
      expect(state.sentenceState.companion, isNull);
      expect(render(state), 'You build.');
    });

    test('accepts destination on movement verbs', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(go));
      state = engine.applyMove(
        state,
        SetDestination(john.toNounPhrase(Number.singular)),
      );

      expect(wasBlocked(state), isFalse);
      expect(state.sentenceState.destination?.text, 'John');
      expect(render(state), 'You go to John.');
    });

    test('blocks destination on verbs without destination frame', () {
      final previous = engine.applyMove(
        ConfigurationState.initial(),
        const SetAction(speak),
      );
      final state = engine.applyMove(
        previous,
        SetDestination(john.toNounPhrase(Number.singular)),
      );

      expect(state.sentenceState, same(previous.sentenceState));
      expect(wasBlocked(state), isTrue);
      expect(state.messages.single.text, 'speak does not take a destination.');
    });

    test('changing action clears incompatible destination frame', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetAction(go));
      state = engine.applyMove(
        state,
        SetDestination(john.toNounPhrase(Number.singular)),
      );
      state = engine.applyMove(state, const SetAction(speak));

      expect(wasBlocked(state), isFalse);
      expect(state.sentenceState.action, speak);
      expect(state.sentenceState.destination, isNull);
      expect(render(state), 'You speak.');
    });

    test('blocks passive voice without a passive-capable frame', () {
      final previous = engine.applyMove(
        ConfigurationState.initial(),
        const SetAction(work),
      );
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
      expect(render(state), 'Bridge is built by you.');
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
      expect(render(state), 'Mary is given book by you.');
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
      expect(render(state), 'You give Mary book.');
    });

    test(
      'active voice restores subject-form agents after passive object pronoun by-agents',
      () {
        final cases = [
          (
            byAgent: object_data.me,
            activeAgent: 'i',
            sentence: 'I am cleaning cat.',
          ),
          (
            byAgent: object_data.him,
            activeAgent: 'he',
            sentence: 'He is cleaning cat.',
          ),
          (
            byAgent: object_data.her,
            activeAgent: 'she',
            sentence: 'She is cleaning cat.',
          ),
          (
            byAgent: object_data.us,
            activeAgent: 'we',
            sentence: 'We are cleaning cat.',
          ),
          (
            byAgent: object_data.them,
            activeAgent: 'they',
            sentence: 'They are cleaning cat.',
          ),
        ];

        for (final currentCase in cases) {
          var state = ConfigurationState.initial();

          state = engine.applyMove(state, const SetAction(work_data.clean));
          state = engine.applyMove(
            state,
            SetObject(cat.toNounPhrase(Number.singular)),
          );
          state = engine.applyMove(state, const SetAspect(Aspect.continuous));
          state = engine.applyMove(state, const SetVoice(Voice.passive));
          state = engine.applyMove(state, SetAgent(currentCase.byAgent));
          state = engine.applyMove(
            state,
            const SetPassiveAgentVisibility(false),
          );
          state = engine.applyMove(state, const SetVoice(Voice.active));

          expect(state.sentenceState.voice, Voice.active);
          expect(state.sentenceState.agent?.text, currentCase.activeAgent);
          expect(wasBlocked(state), isFalse);
          expect(render(state), currentCase.sentence);
        }
      },
    );

    test('selects lexical be as a bare verb frame', () {
      final state = engine.applyMove(
        ConfigurationState.initial(),
        const SetAction(be),
      );

      expect(state.sentenceState.action, be);
      expect(state.sentenceState.complement, isNull);
      expect(state.sentenceState.adjectiveComplement, isNull);
      expect(wasBlocked(state), isFalse);
      expect(render(state), 'You are.');
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
      expect(render(state), 'You are happy.');
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
      expect(render(state), 'You are a doctor.');
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
      expect(render(state), 'You are a doctor.');
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
      expect(render(state), 'You are happy.');
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
      expect(render(state), 'You can be happy.');
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
      expect(render(state), 'You work.');
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
      expect(render(state), 'You are.');
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
      expect(state.messages.single.text, 'learn does not take a complement.');
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

    test('future tense clears present modals because future supplies will', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetModal(can));
      state = engine.applyMove(state, const SetTense(Tense.future));

      expect(state.sentenceState.tense, Tense.future);
      expect(state.sentenceState.modal, noModal);
      expect(render(state), 'You will learn.');
      expect(wasBlocked(state), isFalse);
    });

    test('will modal chip is a shortcut to future tense', () {
      final state = engine.applyMove(
        ConfigurationState.initial(),
        const SetModal(will),
      );

      expect(state.sentenceState.tense, Tense.future);
      expect(state.sentenceState.modal, noModal);
      expect(render(state), 'You will learn.');
      expect(wasBlocked(state), isFalse);
    });

    test('present modal chips exit future tense', () {
      var state = ConfigurationState.initial();

      state = engine.applyMove(state, const SetTense(Tense.future));
      state = engine.applyMove(state, const SetModal(should));

      expect(state.sentenceState.tense, Tense.present);
      expect(state.sentenceState.modal, should);
      expect(render(state), 'You should learn.');
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
      expect(render(state), 'Bridge should be built by you.');
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
