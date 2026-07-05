import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/engine/recognition_engine.dart';
import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/grammar/subject/determiner.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

final engine = RecognitionEngine();

void expectAgent(
  SentenceState state, {
  required String text,
  Determiner? determiner,
  Adjective? adjective,
}) {
  expect(state.agent, isNotNull);
  expect(state.agent!.text, text);
  expect(state.agent!.determiner, determiner);
  expect(state.agent!.adjective, adjective);
}

void expectObject(
  SentenceState state, {
  required String text,
  Determiner? determiner,
  Adjective? adjective,
}) {
  expect(state.object, isNotNull);
  expect(state.object!.text, text);
  expect(state.object!.determiner, determiner);
  expect(state.object!.adjective, adjective);
}
