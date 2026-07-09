import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/adjectives/appearance.dart';
import 'package:padlock_app/data/subjects/adjectives/quality.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/verbs/work.dart';
import 'package:padlock_app/engine/recognition_engine.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/voice.dart';

import 'helpers.dart';

void main() {
  final engine = RecognitionEngine();

  group('Future features - skipped', () {});
  test('The beautiful young woman built a new house yesterday', () {
    final state = engine.recognize(
      'The beautiful young woman built a new house yesterday.',
    );

    expectAgent(
      state,
      text: 'woman',
      determiner: theDeterminer,
      adjective: beautiful,
      adjectives: [beautiful, young],
    );

    expectObject(
      state,
      text: 'house',
      determiner: aDeterminer,
      adjective: newAdjective,
    );

    expect(state.action, build);

    expect(state.voice, Voice.active);

    expect(state.tense, Tense.past);
    expect(state.aspect, Aspect.simple);

    expect(state.modal, noModal);
    expect(state.polarity, Polarity.positive);

    expect(state.sentenceForm, SentenceForm.statement);

    expect(state.timePhrase, yesterdayTimePhrase);
    expect(state.placePhrase, isNull);
    expect(state.frequencyPhrase, isNull);
    expect(state.mannerPhrase, isNull);
  });
}
