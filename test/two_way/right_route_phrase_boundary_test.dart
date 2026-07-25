import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/phrases/manner_phrases.dart';
import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/engine/recognition_engine.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

void main() {
  final grammar = GrammarEngine();
  final recognition = RecognitionEngine();

  String render(SentenceState state) => grammar.generate(state).text;

  SentenceState recognizeRoundTrip(String sentence) {
    final state = recognition.recognize(sentence);

    expect(render(state), sentence, reason: sentence);

    return state;
  }

  void expectNoun(NounPhrase? phrase, String text) {
    expect(phrase, isNotNull);
    expect(phrase!.text.toLowerCase(), text.toLowerCase());
  }

  group('Right route phrase boundary', () {
    test(
      'right action tails can still render through place and time fields',
      () {
        final sentence = render(
          SentenceState(
            agent: you,
            action: learn,
            rightAction: work,
            placePhrase: homePlacePhrase,
            timePhrase: todayTimePhrase,
            tense: Tense.present,
            aspect: Aspect.simple,
          ),
        );

        expect(sentence, 'You learn to work at home today.');
      },
    );

    test(
      'right action tails can still be read through place and time fields',
      () {
        final state = recognizeRoundTrip('You learn to work at home today.');

        expect(state.action, learn);
        expect(state.rightAction, work);
        expect(state.placePhrase, homePlacePhrase);
        expect(state.timePhrase, todayTimePhrase);
        expect(state.destination, isNull);
        expect(state.source, isNull);
      },
    );

    test('right action object and companion stay out of phrase fields', () {
      final sentence = render(
        SentenceState(
          agent: you,
          action: learn,
          rightAction: speak,
          object: science,
          companion: anyone,
          timePhrase: todayTimePhrase,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence, 'You learn to speak science with anyone today.');

      final state = recognizeRoundTrip(sentence);
      expect(state.action, learn);
      expect(state.rightAction, speak);
      expectNoun(state.object, 'science');
      expectNoun(state.companion, 'anyone');
      expect(state.timePhrase, todayTimePhrase);
      expect(state.placePhrase, isNull);
      expect(state.destination, isNull);
      expect(state.source, isNull);
    });

    test(
      'indefinite people are route participants, not swallowed tail text',
      () {
        final cases = [
          (
            sentence: 'John learns from someone today.',
            action: learn,
            field: (SentenceState state) => state.source,
            value: 'someone',
          ),
          (
            sentence: 'John thinks about everyone today.',
            action: think,
            field: (SentenceState state) => state.topic,
            value: 'everyone',
          ),
          (
            sentence: 'Mary went to nobody today.',
            action: go,
            field: (SentenceState state) => state.destination,
            value: 'nobody',
          ),
          (
            sentence: 'John wrote to anyone today.',
            action: write,
            field: (SentenceState state) => state.addressee,
            value: 'anyone',
          ),
        ];

        for (final entry in cases) {
          final state = recognizeRoundTrip(entry.sentence);

          expect(state.action, entry.action, reason: entry.sentence);
          expectNoun(entry.field(state), entry.value);
          expect(state.timePhrase, todayTimePhrase, reason: entry.sentence);
          expect(state.placePhrase, isNull, reason: entry.sentence);
        }
      },
    );

    test('main verb routes cover every prepositional participant boundary', () {
      final cases = [
        (
          sentence: 'John read to anyone today.',
          action: read,
          field: (SentenceState state) => state.addressee,
          value: 'anyone',
        ),
        (
          sentence: 'John worked with someone today.',
          action: work,
          field: (SentenceState state) => state.companion,
          value: 'someone',
        ),
        (
          sentence: 'Mary went to nobody today.',
          action: go,
          field: (SentenceState state) => state.destination,
          value: 'nobody',
        ),
        (
          sentence: 'John thought about everyone today.',
          action: think,
          field: (SentenceState state) => state.topic,
          value: 'everyone',
        ),
        (
          sentence: 'John worked for Mary today.',
          action: work,
          field: (SentenceState state) => state.beneficiary,
          value: 'Mary',
        ),
        (
          sentence: 'John learned from Mary today.',
          action: learn,
          field: (SentenceState state) => state.source,
          value: 'Mary',
        ),
      ];

      for (final entry in cases) {
        final state = recognizeRoundTrip(entry.sentence);

        expect(state.action, entry.action, reason: entry.sentence);
        expect(state.rightAction, isNull, reason: entry.sentence);
        expectNoun(entry.field(state), entry.value);
        expect(state.timePhrase, todayTimePhrase, reason: entry.sentence);
        expect(state.placePhrase, isNull, reason: entry.sentence);
      }
    });

    test(
      'right action owner routes cover every prepositional participant boundary',
      () {
        final cases = [
          (
            sentence: 'You want to speak to Mary today.',
            action: want,
            rightAction: speak,
            field: (SentenceState state) => state.addressee,
            value: 'Mary',
          ),
          (
            sentence: 'You want to speak with anyone today.',
            action: want,
            rightAction: speak,
            field: (SentenceState state) => state.companion,
            value: 'anyone',
          ),
          (
            sentence: 'You want to go to him today.',
            action: want,
            rightAction: go,
            field: (SentenceState state) => state.destination,
            value: 'him',
          ),
          (
            sentence: 'You want to speak about grammar today.',
            action: want,
            rightAction: speak,
            field: (SentenceState state) => state.topic,
            value: 'grammar',
          ),
          (
            sentence: 'You learn to work for Mary today.',
            action: learn,
            rightAction: work,
            field: (SentenceState state) => state.beneficiary,
            value: 'Mary',
          ),
          (
            sentence: 'You want to learn from someone today.',
            action: want,
            rightAction: learn,
            field: (SentenceState state) => state.source,
            value: 'someone',
          ),
        ];

        for (final entry in cases) {
          final state = recognizeRoundTrip(entry.sentence);

          expect(state.action, entry.action, reason: entry.sentence);
          expect(state.rightAction, entry.rightAction, reason: entry.sentence);
          expectNoun(entry.field(state), entry.value);
          expect(state.timePhrase, todayTimePhrase, reason: entry.sentence);
          expect(state.placePhrase, isNull, reason: entry.sentence);
        }
      },
    );

    test('right action direct objects trim before route and phrase tails', () {
      final cases = [
        (
          sentence: 'You want to speak science to Mary today.',
          route: (SentenceState state) => state.addressee,
          value: 'Mary',
        ),
        (
          sentence: 'You want to speak English with anyone today.',
          route: (SentenceState state) => state.companion,
          value: 'anyone',
        ),
        (
          sentence: 'You want to speak science about grammar today.',
          route: (SentenceState state) => state.topic,
          value: 'grammar',
        ),
        (
          sentence: 'You want to learn science from someone today.',
          route: (SentenceState state) => state.source,
          value: 'someone',
        ),
      ];

      for (final entry in cases) {
        final state = recognizeRoundTrip(entry.sentence);

        expect(state.action, want, reason: entry.sentence);
        expect(state.object, isNotNull, reason: entry.sentence);
        expect(
          ['science', 'English'],
          contains(state.object!.text),
          reason: entry.sentence,
        );
        expectNoun(entry.route(state), entry.value);
        expect(state.timePhrase, todayTimePhrase, reason: entry.sentence);
        expect(state.placePhrase, isNull, reason: entry.sentence);
      }
    });

    test('direct route prepositions do not masquerade as place phrases', () {
      final cases = [
        (
          sentence: 'John learns from Mary today.',
          action: learn,
          field: (SentenceState state) => state.source,
          value: 'Mary',
        ),
        (
          sentence: 'John thinks about Mary today.',
          action: think,
          field: (SentenceState state) => state.topic,
          value: 'Mary',
        ),
        (
          sentence: 'Mary went to him today.',
          action: go,
          field: (SentenceState state) => state.destination,
          value: 'him',
        ),
        (
          sentence: 'John wrote to Mary today.',
          action: write,
          field: (SentenceState state) => state.addressee,
          value: 'Mary',
        ),
      ];

      for (final entry in cases) {
        final state = recognizeRoundTrip(entry.sentence);

        expect(state.action, entry.action, reason: entry.sentence);
        expectNoun(entry.field(state), entry.value);
        expect(state.timePhrase, todayTimePhrase, reason: entry.sentence);
        expect(state.placePhrase, isNull, reason: entry.sentence);
      }
    });

    test('place phrases remain explicit when the sentence really uses one', () {
      final state = recognizeRoundTrip('John works at home today.');

      expect(state.action, work);
      expect(state.placePhrase, homePlacePhrase);
      expect(state.timePhrase, todayTimePhrase);
      expect(state.destination, isNull);
      expect(state.source, isNull);
    });

    test(
      'old phrase fields remain alive as Grammar and Recognition bridge',
      () {
        final state = recognizeRoundTrip(
          'John learned from Mary at home yesterday.',
        );

        expect(state.action, learn);
        expectNoun(state.source, 'Mary');
        expect(state.placePhrase, homePlacePhrase);
        expect(state.timePhrase, yesterdayTimePhrase);

        final mannerState = recognizeRoundTrip(
          'John explained grammar carefully to Mary.',
        );

        expect(mannerState.action, explain);
        expectNoun(mannerState.object, 'grammar');
        expectNoun(mannerState.addressee, 'Mary');
        expect(mannerState.mannerPhrase, carefullyMannerPhrase);
      },
    );
  });
}
