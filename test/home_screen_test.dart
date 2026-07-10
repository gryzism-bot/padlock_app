import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/screens/home_screen.dart';

void main() {
  final mainScroll = find
      .descendant(
        of: find.byKey(const Key('main-scroll')),
        matching: find.byType(Scrollable),
      )
      .first;

  String renderedSentence(WidgetTester tester) {
    return tester
        .widget<Text>(find.byKey(const Key('rendered-sentence')))
        .data!;
  }

  Future<void> tapAfterScroll(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 500, scrollable: mainScroll);
    await tester.drag(mainScroll, const Offset(0, 120));
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  List<String> highlightedTextForTooltip(WidgetTester tester, String tooltip) {
    final richText = tester.widget<RichText>(
      find
          .descendant(
            of: find.byTooltip(tooltip),
            matching: find.byType(RichText),
          )
          .first,
    );

    return _textSpans(richText.text)
        .where((span) => span.style?.backgroundColor != null)
        .map((span) => span.text ?? '')
        .toList();
  }

  testWidgets('Guided UI renders compass suggestions and applies a move', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(renderedSentence(tester), 'He works.');
    expect(find.text('Padlock Guided Mode'), findsOneWidget);
    expect(find.text('Verb'), findsOneWidget);

    final giveSuggestion = find.byTooltip('He gives.');
    await tester.scrollUntilVisible(
      giveSuggestion,
      500,
      scrollable: mainScroll,
    );
    await tester.drag(mainScroll, const Offset(0, 120));
    await tester.pumpAndSettle();
    await tester.tap(giveSuggestion);
    await tester.pumpAndSettle();
    await tester.drag(mainScroll, const Offset(0, 1000));
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), 'He gives.');
  });

  testWidgets('Top controls expose guided form choices only', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Form'), findsOneWidget);
    expect(find.text('statement'), findsOneWidget);
    expect(find.text('question'), findsOneWidget);
    expect(find.text('exclamation'), findsOneWidget);
    expect(find.text('imperative'), findsOneWidget);
    expect(find.text('no agent'), findsNothing);
    expect(renderedSentence(tester), 'He works.');
  });

  testWidgets('Guided UI can exit lexical be through verb suggestions', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    final beSuggestion = find.byTooltip('He is.');
    await tester.scrollUntilVisible(beSuggestion, 500, scrollable: mainScroll);
    await tester.drag(mainScroll, const Offset(0, 120));
    await tester.pumpAndSettle();
    await tester.tap(beSuggestion);
    await tester.pumpAndSettle();

    final happySuggestion = find.byTooltip('He is happy.');
    await tester.scrollUntilVisible(
      happySuggestion,
      500,
      scrollable: mainScroll,
    );
    await tester.drag(mainScroll, const Offset(0, 120));
    await tester.pumpAndSettle();
    await tester.tap(happySuggestion);
    await tester.pumpAndSettle();

    await tester.drag(mainScroll, const Offset(0, 1000));
    await tester.pumpAndSettle();

    final workSuggestion = find.byTooltip('He works.');
    await tester.scrollUntilVisible(
      workSuggestion,
      -500,
      scrollable: mainScroll,
    );
    await tester.drag(mainScroll, const Offset(0, 120));
    await tester.pumpAndSettle();
    await tester.tap(workSuggestion);
    await tester.pumpAndSettle();
    await tester.drag(mainScroll, const Offset(0, 1000));
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), 'He works.');
  });

  testWidgets('Suggestion display mode can switch to word chips', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));

    expect(find.text('give', findRichText: true), findsOneWidget);
    expect(find.text('He gives.'), findsNothing);
  });

  testWidgets('Guided UI exposes split control groups and larger chip rails', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Tense and aspect'), findsOneWidget);
    expect(find.text('Subject'), findsOneWidget);
    expect(find.text('singular'), findsOneWidget);
    expect(find.text('plural'), findsOneWidget);
    expect(find.text('I'), findsOneWidget);
    expect(find.text('you'), findsNWidgets(2));
    expect(find.text('he'), findsOneWidget);
    expect(find.text('she'), findsOneWidget);
    expect(find.text('it'), findsOneWidget);
    expect(find.text('we'), findsOneWidget);
    expect(find.text('they'), findsOneWidget);
    expect(find.text('3rd person'), findsNWidgets(2));
    expect(find.text('Modal'), findsOneWidget);
    expect(find.text('Voice'), findsOneWidget);
    expect(find.text('Polarity'), findsOneWidget);
    expect(find.text('Form'), findsOneWidget);
    expect(find.text('3rd singular'), findsNothing);
    expect(find.text('3rd plural'), findsNothing);
    expect(find.text('Voice and modal'), findsNothing);
    expect(find.text('Display and form'), findsNothing);
    expect(find.text('Manual lock probes'), findsNothing);
    expect(find.byKey(const Key('main-scroll')), findsOneWidget);

    await tapVisible(tester, find.text('Word'));

    expect(find.byType(OutlinedButton), findsWidgets);
    expect(find.byType(OutlinedButton).evaluate().length, greaterThan(6));
  });

  testWidgets('Subject rows can expand into noun subjects', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('I'), findsOneWidget);
    expect(find.text('you'), findsNWidgets(2));
    expect(find.text('he'), findsOneWidget);
    expect(find.text('she'), findsOneWidget);
    expect(find.text('it'), findsOneWidget);
    expect(find.text('we'), findsOneWidget);
    expect(find.text('they'), findsOneWidget);
    expect(find.text('cat'), findsNothing);
    expect(find.text('cats'), findsNothing);

    await tester.tap(find.byTooltip('Show 3rd person singular nouns'));
    await tester.pumpAndSettle();
    expect(find.text('cat'), findsOneWidget);

    await tester.tap(find.text('cat'));
    await tester.pumpAndSettle();
    expect(renderedSentence(tester), 'Cat works.');

    await tapAfterScroll(
      tester,
      find.byTooltip('Show 3rd person plural nouns'),
    );
    expect(find.text('cats'), findsOneWidget);

    await tester.tap(find.text('cats'));
    await tester.pumpAndSettle();
    expect(renderedSentence(tester), 'Cats work.');
  });

  testWidgets('Object rail number switch changes the selected object', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));
    await tapAfterScroll(tester, find.byTooltip('He buys.'));

    await tester.scrollUntilVisible(
      find.text('sg'),
      500,
      scrollable: mainScroll,
    );
    await tester.drag(mainScroll, const Offset(0, 120));
    await tester.pumpAndSettle();

    expect(find.text('sg'), findsOneWidget);
    expect(find.text('pl'), findsOneWidget);
    expect(find.text('book', findRichText: true), findsOneWidget);
    expect(find.text('books', findRichText: true), findsNothing);

    await tester.tap(find.text('book', findRichText: true));
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), 'He buys book.');

    await tester.tap(find.text('pl'));
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), 'He buys books.');
    expect(find.text('book', findRichText: true), findsNothing);
    expect(find.text('books', findRichText: true), findsOneWidget);
  });

  testWidgets('Change preview highlights whole changed words', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapAfterScroll(tester, find.byTooltip('He gives.'));
    await tapAfterScroll(tester, find.byTooltip('He gives book.'));
    await tester.scrollUntilVisible(
      find.byTooltip('He buys book.'),
      -500,
      scrollable: mainScroll,
    );
    await tester.drag(mainScroll, const Offset(0, 120));
    await tester.pumpAndSettle();

    expect(highlightedTextForTooltip(tester, 'He buys book.'), ['buys']);
  });

  testWidgets('Passive focus can return to the null default focus', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));
    await tapAfterScroll(tester, find.byTooltip('He gives.'));
    await tapAfterScroll(tester, find.byTooltip('He gives book.'));
    await tapAfterScroll(tester, find.byTooltip('He gives Mary book.'));
    await tapAfterScroll(tester, find.text('passive'));

    expect(renderedSentence(tester), 'Book is given to Mary by him.');

    await tapAfterScroll(tester, find.byTooltip('Mary is given book by him.'));
    expect(renderedSentence(tester), 'Mary is given book by him.');

    await tapAfterScroll(
      tester,
      find.text('no passive focus', findRichText: true),
    );
    expect(renderedSentence(tester), 'Book is given to Mary by him.');
  });

  testWidgets('Hover header previews a word chip without committing it', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));
    await tapVisible(tester, find.text('Hover header'));

    final headerMode = tester.widget<SegmentedButton<HeaderPreviewMode>>(
      find.byType(SegmentedButton<HeaderPreviewMode>),
    );

    expect(headerMode.selected, {HeaderPreviewMode.hover});
    expect(renderedSentence(tester), 'He works.');
    expect(find.text('give', findRichText: true), findsOneWidget);
    expect(find.text('He gives.'), findsNothing);

    final giveSuggestion = find.byTooltip('He gives.');
    final hoverRegion = tester.widget<MouseRegion>(
      find
          .ancestor(of: giveSuggestion, matching: find.byType(MouseRegion))
          .first,
    );
    hoverRegion.onEnter?.call(const PointerEnterEvent());
    await tester.pump();

    expect(renderedSentence(tester), 'He gives.');

    hoverRegion.onExit?.call(const PointerExitEvent());
    await tester.pump();

    expect(renderedSentence(tester), 'He works.');
  });

  testWidgets('Random sentence button keeps the UI renderable', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.tap(find.byTooltip('Random sentence'));
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), isNotEmpty);
    expect(renderedSentence(tester).endsWith('.'), isTrue);
  });
}

Iterable<TextSpan> _textSpans(InlineSpan span) sync* {
  if (span is TextSpan) {
    yield span;
    for (final child in span.children ?? const <InlineSpan>[]) {
      yield* _textSpans(child);
    }
  }
}
