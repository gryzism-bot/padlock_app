import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/frequency_phrases.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/adjectives/appearance.dart';
import 'package:padlock_app/data/subjects/adjectives/quality.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/verbs/education.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/work.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/engine/recognition_engine.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

void main() {
  final grammar = GrammarEngine();
  final recognition = RecognitionEngine();

  String render(SentenceState state) => grammar.generate(state).text;

  void expectStateRoundTrip(SentenceState state) {
    final firstSentence = render(state);
    final recognized = recognition.recognize(firstSentence);
    final secondSentence = render(recognized);

    expect(secondSentence, firstSentence);
  }

  void expectSentenceRoundTrip(String sentence) {
    final recognized = recognition.recognize(sentence);
    final rendered = render(recognized);

    expect(rendered, sentence);
  }

  group('Two-way one-predicate contract', () {
    test('state -> sentence -> state -> sentence keeps core active shapes', () {
      final states = [
        SentenceState(
          agent: he,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
        SentenceState(
          agent: mary.toNounPhrase(Number.singular),
          action: study,
          tense: Tense.past,
          aspect: Aspect.simple,
          timePhrase: yesterdayTimePhrase,
        ),
        SentenceState(
          agent: they,
          action: build,
          object: it,
          modal: should,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
        SentenceState(
          agent: teacher.toNounPhrase(
            Number.singular,
            determiner: theDeterminer,
            adjective: beautiful,
          ),
          action: learn,
          tense: Tense.present,
          aspect: Aspect.perfect,
          placePhrase: schoolPlacePhrase,
          frequencyPhrase: everyDayFrequencyPhrase,
        ),
      ];

      for (final state in states) {
        expectStateRoundTrip(state);
      }
    });

    test(
      'state -> sentence -> state -> sentence keeps passive and questions',
      () {
        final states = [
          SentenceState(
            object: bridge.toNounPhrase(
              Number.singular,
              determiner: theDeterminer,
              adjective: newAdjective,
            ),
            agent: worker.toNounPhrase(
              Number.plural,
              determiner: theDeterminer,
              adjective: old,
            ),
            action: build,
            voice: Voice.passive,
            tense: Tense.past,
            aspect: Aspect.perfectContinuous,
            sentenceForm: SentenceForm.question,
          ),
          SentenceState(
            agent: teacher.toNounPhrase(
              Number.singular,
              determiner: theDeterminer,
              adjective: beautiful,
            ),
            action: work,
            modal: will,
            tense: Tense.future,
            aspect: Aspect.perfectContinuous,
            polarity: Polarity.negative,
            placePhrase: homePlacePhrase,
          ),
          SentenceState(
            object: bridge.toNounPhrase(Number.singular),
            action: build,
            voice: Voice.passive,
            modal: should,
            tense: Tense.present,
            aspect: Aspect.simple,
            polarity: Polarity.negative,
            sentenceForm: SentenceForm.question,
          ),
        ];

        for (final state in states) {
          expectStateRoundTrip(state);
        }
      },
    );

    test('sentence -> state -> sentence preserves canonical app sentences', () {
      final sentences = [
        'Does he work?',
        'They should build it.',
        'The beautiful teacher has learned at school every day.',
        'Had the new bridge been being built by the old workers?',
        'The beautiful chef will not have been working at home.',
        'Should bridge not be built?',
      ];

      for (final sentence in sentences) {
        expectSentenceRoundTrip(sentence);
      }
    });

    test(
      'multiple adjectives are outside the two-way contract for now',
      () {
        expectSentenceRoundTrip(
          'The beautiful young woman built a new house yesterday.',
        );
      },
      skip: 'Multiple adjectives not implemented yet',
    );
  });
}
