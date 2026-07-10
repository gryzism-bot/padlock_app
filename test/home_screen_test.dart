import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/screens/home_screen.dart';

void main() {
  testWidgets('Guided UI renders compass suggestions and applies a move', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('He works.'), findsOneWidget);
    expect(find.text('Padlock Guided Mode'), findsOneWidget);
    expect(find.text('Verb'), findsOneWidget);
    expect(find.textContaining('give ->'), findsWidgets);

    final giveSuggestion = find.textContaining('give ->').first;
    await tester.ensureVisible(giveSuggestion);
    await tester.pumpAndSettle();
    await tester.tap(
      find.ancestor(of: giveSuggestion, matching: find.byType(OutlinedButton)),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable), const Offset(0, 1000));
    await tester.pumpAndSettle();

    expect(find.text('He gives.'), findsOneWidget);
  });

  testWidgets('Manual lock probes show blocked messages', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.tap(find.text('no agent'));
    await tester.pumpAndSettle();

    expect(find.text('Active voice requires an agent.'), findsOneWidget);
    expect(find.text('He works.'), findsOneWidget);
  });

  testWidgets('Guided UI can exit lexical be through verb suggestions', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    final happySuggestions = find.textContaining('happy ->');
    await tester.scrollUntilVisible(happySuggestions, 500);
    final happySuggestion = happySuggestions.first;
    await tester.pumpAndSettle();
    await tester.tap(
      find.ancestor(of: happySuggestion, matching: find.byType(OutlinedButton)),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable), const Offset(0, 1000));
    await tester.pumpAndSettle();

    final workSuggestions = find.textContaining('work -> He works.');
    final workSuggestion = workSuggestions.first;
    await tester.pumpAndSettle();
    await tester.tap(
      find.ancestor(of: workSuggestion, matching: find.byType(OutlinedButton)),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable), const Offset(0, 1000));
    await tester.pumpAndSettle();

    expect(find.text('He works.'), findsOneWidget);
  });
}
