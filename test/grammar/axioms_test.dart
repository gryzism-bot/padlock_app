import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/verbs/work.dart';

import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/engine/recognition_engine.dart';

import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

import 'package:padlock_app/data/subjects/pronouns.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';

import 'package:padlock_app/data/verbs/essential.dart';

void main() {
  final engine = GrammarEngine();
  final recognizer = RecognitionEngine();

  String render(SentenceState state) => engine.generate(state).text;

  group('Grammar axioms', () {
    test('Every finite sentence contains exactly one finite verb', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text.endsWith('works.'), isTrue);
      expect(sentence.text.contains(' work work'), isFalse);
    });

    test('Every Present Continuous sentence contains BE auxiliary', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          tense: Tense.present,
          aspect: Aspect.continuous,
        ),
      );

      expect(sentence.text.contains(' is '), isTrue);
      expect(sentence.text.endsWith('working.'), isTrue);
    });

    test('Every Past Continuous sentence contains BE auxiliary', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: work,
          tense: Tense.past,
          aspect: Aspect.continuous,
        ),
      );

      expect(sentence.text.contains(' were '), isTrue);
      expect(sentence.text.endsWith('working.'), isTrue);
    });

    test('Every Perfect sentence contains HAVE auxiliary', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: build,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text.contains(' have '), isTrue);
      expect(sentence.text.endsWith('built.'), isTrue);
    });

    test('Every Perfect Continuous sentence contains HAVE + BEEN', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: work,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
        ),
      );

      expect(sentence.text.contains(' have been '), isTrue);
      expect(sentence.text.endsWith('working.'), isTrue);
    });

    test('Every Future sentence contains WILL', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          tense: Tense.future,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text.endsWith('will work.'), isTrue);
    });

    test('Every Passive sentence contains BE auxiliary', () {
      final sentence = engine.generate(
        SentenceState(
          object: bridge.toNounPhrase(Number.singular),
          action: build,
          voice: Voice.passive,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text.contains(' is '), isTrue);
      expect(sentence.text.endsWith('built.'), isTrue);
    });

    test('Every modal is followed by infinitive', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: build,
          modal: should,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text.endsWith('should build.'), isTrue);
      expect(sentence.text.contains('should builds'), isFalse);
      expect(sentence.text.contains('should built'), isFalse);
    });

    test('Every Continuous aspect ends with present participle', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: build,
          tense: Tense.present,
          aspect: Aspect.continuous,
        ),
      );

      expect(sentence.text.endsWith('building.'), isTrue);
      expect(sentence.text.contains('built'), isFalse);
    });

    test('Every Perfect aspect ends with past participle', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: build,
          tense: Tense.present,
          aspect: Aspect.perfect,
        ),
      );

      expect(sentence.text.endsWith('built.'), isTrue);
      expect(sentence.text.contains('building'), isFalse);
    });

    test('Every Question performs auxiliary inversion', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          sentenceForm: SentenceForm.question,
        ),
      );

      expect(sentence.text.startsWith('Does'), isTrue);
    });

    test('Every Negative sentence contains NOT exactly once', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
          polarity: Polarity.negative,
        ),
      );

      expect('not'.allMatches(sentence.text).length, 1);
    });

    test('Every sentence ends with punctuation', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(
        sentence.text.endsWith('.') || sentence.text.endsWith('?'),
        isTrue,
      );
    });

    test('Every sentence contains exactly one lexical verb', () {
      final sentence = engine.generate(
        SentenceState(
          agent: they,
          action: work,
          tense: Tense.present,
          aspect: Aspect.perfectContinuous,
        ),
      );

      expect(sentence.text.endsWith('working.'), isTrue);
      expect(sentence.text.contains('work work'), isFalse);
      expect(sentence.text.contains('worked working'), isFalse);
    });

    test('Passive agent always uses objective case', () {
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

      expect(sentence.text.endsWith('by them.'), isTrue);
      expect(sentence.text.contains('by they'), isFalse);
    });

    test('Present Simple third person singular conjugates lexical verb', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text.endsWith('works.'), isTrue);
      expect(sentence.text.contains('work.'), isFalse);
    });

    test('Modal suppresses third person singular conjugation', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          modal: can,
          tense: Tense.present,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text.endsWith('can work.'), isTrue);
      expect(sentence.text.contains('can works'), isFalse);
    });

    test('Future suppresses third person singular conjugation', () {
      final sentence = engine.generate(
        SentenceState(
          agent: he,
          action: work,
          tense: Tense.future,
          aspect: Aspect.simple,
        ),
      );

      expect(sentence.text.endsWith('will work.'), isTrue);
      expect(sentence.text.contains('will works'), isFalse);
    });

    test('BE agreement is driven by the displayed subject', () {
      final activeCases = {
        i: 'I am working.',
        you: 'You are working.',
        he: 'He is working.',
        she: 'She is working.',
        it: 'It is working.',
        we: 'We are working.',
        they: 'They are working.',
      };

      for (final entry in activeCases.entries) {
        expect(
          render(
            SentenceState(
              agent: entry.key,
              action: work,
              tense: Tense.present,
              aspect: Aspect.continuous,
            ),
          ),
          entry.value,
        );
      }

      expect(
        render(
          SentenceState(
            object: bridge.toNounPhrase(Number.singular),
            action: build,
            voice: Voice.passive,
            tense: Tense.present,
            aspect: Aspect.simple,
          ),
        ),
        'Bridge is built.',
      );

      expect(
        render(
          SentenceState(
            object: bridge.toNounPhrase(Number.plural),
            action: build,
            voice: Voice.passive,
            tense: Tense.present,
            aspect: Aspect.simple,
          ),
        ),
        'Bridges are built.',
      );
    });

    test('Past BE agreement is driven by the displayed subject', () {
      expect(
        render(
          SentenceState(
            agent: i,
            action: work,
            tense: Tense.past,
            aspect: Aspect.continuous,
          ),
        ),
        'I was working.',
      );

      expect(
        render(
          SentenceState(
            agent: they,
            action: work,
            tense: Tense.past,
            aspect: Aspect.continuous,
          ),
        ),
        'They were working.',
      );

      expect(
        render(
          SentenceState(
            object: bridge.toNounPhrase(Number.plural),
            action: build,
            voice: Voice.passive,
            tense: Tense.past,
            aspect: Aspect.simple,
          ),
        ),
        'Bridges were built.',
      );
    });

    test('HAVE agreement is driven by the displayed subject', () {
      expect(
        render(
          SentenceState(
            agent: he,
            action: work,
            tense: Tense.present,
            aspect: Aspect.perfect,
          ),
        ),
        'He has worked.',
      );

      expect(
        render(
          SentenceState(
            agent: they,
            action: work,
            tense: Tense.present,
            aspect: Aspect.perfect,
          ),
        ),
        'They have worked.',
      );

      expect(
        render(
          SentenceState(
            object: bridge.toNounPhrase(Number.singular),
            action: build,
            voice: Voice.passive,
            tense: Tense.present,
            aspect: Aspect.perfect,
          ),
        ),
        'Bridge has been built.',
      );
    });

    test(
      'DO support appears for simple present question and negative only',
      () {
        expect(
          render(
            SentenceState(
              agent: he,
              action: work,
              tense: Tense.present,
              aspect: Aspect.simple,
              sentenceForm: SentenceForm.question,
            ),
          ),
          'Does he work?',
        );

        expect(
          render(
            SentenceState(
              agent: he,
              action: work,
              tense: Tense.present,
              aspect: Aspect.simple,
              polarity: Polarity.negative,
            ),
          ),
          'He does not work.',
        );

        expect(
          render(
            SentenceState(
              agent: he,
              action: work,
              tense: Tense.present,
              aspect: Aspect.continuous,
              sentenceForm: SentenceForm.question,
            ),
          ),
          'Is he working?',
        );
      },
    );

    test('Passive perfect continuous uses BEEN BEING plus past participle', () {
      expect(
        render(
          SentenceState(
            object: bridge.toNounPhrase(Number.singular),
            action: build,
            voice: Voice.passive,
            tense: Tense.present,
            aspect: Aspect.perfectContinuous,
          ),
        ),
        'Bridge has been being built.',
      );

      expect(
        render(
          SentenceState(
            object: bridge.toNounPhrase(Number.singular),
            agent: they,
            action: build,
            voice: Voice.passive,
            tense: Tense.past,
            aspect: Aspect.perfectContinuous,
            sentenceForm: SentenceForm.question,
          ),
        ),
        'Had bridge been being built by them?',
      );
    });

    test(
      'Generated one-predicate sentences round-trip through Recognition',
      () {
        final samples = [
          SentenceState(
            agent: he,
            action: work,
            tense: Tense.present,
            aspect: Aspect.simple,
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
            object: bridge.toNounPhrase(Number.singular),
            agent: they,
            action: build,
            voice: Voice.passive,
            tense: Tense.past,
            aspect: Aspect.perfectContinuous,
            sentenceForm: SentenceForm.question,
          ),
        ];

        for (final sample in samples) {
          final sentence = engine.generate(sample).text;
          final recognized = recognizer.recognize(sentence);

          expect(recognized.action, sample.action);
          expect(recognized.tense, sample.tense);
          expect(recognized.aspect, sample.aspect);
          expect(recognized.voice, sample.voice);
          expect(recognized.modal, sample.modal);
          expect(recognized.polarity, sample.polarity);
          expect(recognized.sentenceForm, sample.sentenceForm);
        }
      },
    );
  });
}
