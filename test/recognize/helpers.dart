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
  List<Adjective>? adjectives,
}) {
  expect(state.agent, isNotNull);
  expect(state.agent!.text.toLowerCase(), text.toLowerCase());
  expect(state.agent!.determiner, determiner);
  expect(state.agent!.adjective, adjective);
  if (adjectives != null) {
    expect(state.agent!.adjectiveList, adjectives);
  }
}

void expectObject(
  SentenceState state, {
  required String text,
  Determiner? determiner,
  Adjective? adjective,
  List<Adjective>? adjectives,
}) {
  expect(state.object, isNotNull);
  expect(state.object!.text.toLowerCase(), text.toLowerCase());
  expect(state.object!.determiner, determiner);
  expect(state.object!.adjective, adjective);
  if (adjectives != null) {
    expect(state.object!.adjectiveList, adjectives);
  }
}

void expectRecipient(
  SentenceState state, {
  required String text,
  Determiner? determiner,
  Adjective? adjective,
  List<Adjective>? adjectives,
}) {
  expect(state.recipient, isNotNull);
  expect(state.recipient!.text.toLowerCase(), text.toLowerCase());
  expect(state.recipient!.determiner, determiner);
  expect(state.recipient!.adjective, adjective);
  if (adjectives != null) {
    expect(state.recipient!.adjectiveList, adjectives);
  }
}
