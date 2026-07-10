import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/screens/home_screen.dart';

void main() {
  String renderedSentence(WidgetTester tester) {
    return tester
        .widget<Text>(find.byKey(const Key('rendered-sentence')))
        .data!;
  }

  testWidgets('Guided UI renders compass suggestions and applies a move', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(renderedSentence(tester), 'He works.');
    expect(find.text('Padlock Guided Mode'), findsOneWidget);
    expect(find.text('Verb'), findsOneWidget);

    final giveSuggestion = find.byTooltip('He gives.');
    await tester.ensureVisible(giveSuggestion);
    await tester.pumpAndSettle();
    await tester.tap(giveSuggestion);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable), const Offset(0, 1000));
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), 'He gives.');
  });

  testWidgets('Manual lock probes show blocked messages', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.tap(find.text('no agent'));
    await tester.pumpAndSettle();

    expect(find.text('Active voice requires an agent.'), findsOneWidget);
    expect(renderedSentence(tester), 'He works.');
  });

  testWidgets('Guided UI can exit lexical be through verb suggestions', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    final beSuggestion = find.byTooltip('He is.');
    await tester.ensureVisible(beSuggestion);
    await tester.pumpAndSettle();
    await tester.tap(beSuggestion);
    await tester.pumpAndSettle();

    final happySuggestion = find.byTooltip('He is happy.');
    await tester.scrollUntilVisible(happySuggestion, 500);
    await tester.pumpAndSettle();
    await tester.tap(happySuggestion);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable), const Offset(0, 1000));
    await tester.pumpAndSettle();

    final workSuggestion = find.byTooltip('He works.');
    await tester.ensureVisible(workSuggestion);
    await tester.pumpAndSettle();
    await tester.tap(workSuggestion);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable), const Offset(0, 1000));
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), 'He works.');
  });

  testWidgets('Suggestion display mode can switch to word chips', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.tap(find.text('Word'));
    await tester.pumpAndSettle();

    expect(find.text('give'), findsOneWidget);
    expect(find.text('He gives.'), findsNothing);
  });

  testWidgets('Random sentence button keeps the UI renderable', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.tap(find.byTooltip('Random sentence'));
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), isNotEmpty);
    expect(renderedSentence(tester).endsWith('.'), isTrue);
  });
}
