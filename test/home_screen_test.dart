import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
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
        .widget<SelectableText>(find.byKey(const Key('rendered-sentence')))
        .data!;
  }

  Future<void> tapAfterScroll(
    WidgetTester tester,
    Finder finder, {
    double delta = 500,
  }) async {
    final descendantButton = find.descendant(
      of: finder,
      matching: find.byType(OutlinedButton),
    );
    final ancestorButton = find.ancestor(
      of: finder,
      matching: find.byType(OutlinedButton),
    );
    final descendantIconButton = find.descendant(
      of: finder,
      matching: find.byType(IconButton),
    );
    final ancestorIconButton = find.ancestor(
      of: finder,
      matching: find.byType(IconButton),
    );
    final target = descendantButton.evaluate().isNotEmpty
        ? descendantButton.first
        : ancestorButton.evaluate().isNotEmpty
        ? ancestorButton.first
        : descendantIconButton.evaluate().isNotEmpty
        ? descendantIconButton.first
        : ancestorIconButton.evaluate().isNotEmpty
        ? ancestorIconButton.first
        : finder;

    await tester.scrollUntilVisible(target, delta, scrollable: mainScroll);
    await tester.pumpAndSettle();
    if (descendantButton.evaluate().isNotEmpty ||
        ancestorButton.evaluate().isNotEmpty) {
      tester.widget<OutlinedButton>(target).onPressed?.call();
    } else if (descendantIconButton.evaluate().isNotEmpty ||
        ancestorIconButton.evaluate().isNotEmpty) {
      tester.widget<IconButton>(target).onPressed?.call();
    } else {
      await tester.tap(target, warnIfMissed: false);
    }
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

    expect(renderedSentence(tester), 'You learn.');
    expect(find.text('Padlock Guided Mode'), findsOneWidget);
    expect(find.text('Verb:'), findsOneWidget);
    expect(find.text('Verb'), findsNothing);
    expect(find.byTooltip('Current: You learn.'), findsWidgets);
    expect(find.byType(SelectableText), findsWidgets);

    await tapAfterScroll(tester, find.byTooltip('You give.'));
    await tester.drag(mainScroll, const Offset(0, 1000));
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), 'You give.');
  });

  testWidgets('Top controls expose guided form choices only', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Form'), findsOneWidget);
    expect(find.text('statement'), findsOneWidget);
    expect(find.text('question'), findsOneWidget);
    expect(find.text('exclamation'), findsOneWidget);
    expect(find.text('imperative'), findsOneWidget);
    expect(find.text('no agent'), findsNothing);
    expect(renderedSentence(tester), 'You learn.');
  });

  testWidgets('Blocked guided moves show lock source and diagnostic tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapAfterScroll(tester, find.byTooltip('You work.'));
    await tapAfterScroll(tester, find.text('passive'));

    expect(renderedSentence(tester), 'You work.');
    expect(find.text('Blocked by Lock'), findsWidgets);
    expect(find.text('work cannot be passive in this frame.'), findsOneWidget);
    expect(
      find.byTooltip(
        const ConfigurationMessage.blocked(
          'work cannot be passive in this frame.',
        ).tooltip,
      ),
      findsOneWidget,
    );
  });

  testWidgets('Guided UI can exit lexical be through verb suggestions', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapAfterScroll(tester, find.byTooltip('You are.'));

    await tapAfterScroll(tester, find.byTooltip('You are happy.'));

    await tester.drag(mainScroll, const Offset(0, 1000));
    await tester.pumpAndSettle();

    await tapAfterScroll(tester, find.byTooltip('You work.'), delta: -500);
    await tester.drag(mainScroll, const Offset(0, 1000));
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), 'You work.');
  });

  testWidgets('Verb rail keeps work available after choosing another verb', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapAfterScroll(tester, find.byTooltip('You buy.'));

    expect(renderedSentence(tester), 'You buy.');
    expect(find.byTooltip('You work.'), findsWidgets);
  });

  testWidgets('Suggestion display mode can switch to word chips', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));

    expect(find.text('give', findRichText: true), findsOneWidget);
    expect(find.text('You give.'), findsNothing);
  });

  testWidgets('Verb chips mark predicate extensions they can wake', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.byKey(const Key('verb-wake-be-complement')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-learn-subject')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-play-activity')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-go-destination')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-give-object')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-give-recipient')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-work-object')), findsNothing);
    expect(find.byKey(const Key('verb-wake-work-recipient')), findsNothing);
    expect(find.byKey(const Key('verb-wake-work-complement')), findsNothing);
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
    expect(find.text('3rd person'), findsNothing);
    expect(find.byTooltip('Show 3rd person singular nouns'), findsOneWidget);
    expect(find.byTooltip('Show 3rd person plural nouns'), findsOneWidget);
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

  testWidgets('Wide control deck keeps primary groups on one row', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(2048, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    final titles = [
      find.text('Tense and aspect'),
      find.text('Subject'),
      find.text('Modal'),
      find.text('Voice'),
      find.text('Polarity'),
      find.text('Form'),
    ];
    final titleTops = [for (final title in titles) tester.getTopLeft(title).dy];

    expect(titleTops.reduce(max) - titleTops.reduce(min), lessThan(2));
  });

  testWidgets('Predicate extension rails appear only when their frame opens', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Verb:'), findsOneWidget);
    expect(find.text('Subject:'), findsOneWidget);
    expect(find.text('Object determiner:'), findsNothing);
    expect(find.text('Object adjective:'), findsNothing);
    expect(find.text('Object:'), findsNothing);
    expect(find.text('Recipient:'), findsNothing);
    expect(find.text('Noun complement:'), findsNothing);
    expect(find.text('Adjective complement:'), findsNothing);

    expect(find.byTooltip('You learn English.'), findsWidgets);
    expect(find.text('Object determiner:'), findsNothing);
    expect(find.text('Object adjective:'), findsNothing);

    await tapAfterScroll(tester, find.byTooltip('You play.'), delta: -500);

    expect(find.text('Activity:'), findsOneWidget);
    expect(find.text('Object:'), findsNothing);
    expect(find.text('Object determiner:'), findsNothing);
    expect(find.text('Object adjective:'), findsNothing);

    await tapAfterScroll(tester, find.byTooltip('You play volleyball.'));

    expect(renderedSentence(tester), 'You play volleyball.');
    expect(find.text('Activity:'), findsOneWidget);

    await tapAfterScroll(tester, find.byTooltip('You are.'));

    expect(find.text('Noun complement:'), findsOneWidget);
    expect(find.text('Adjective complement:'), findsOneWidget);
    expect(find.text('Object:'), findsNothing);

    await tapAfterScroll(tester, find.byTooltip('You buy.'), delta: -500);

    expect(find.text('Object:'), findsOneWidget);
    expect(find.text('Object determiner:'), findsNothing);
    expect(find.text('Object adjective:'), findsNothing);

    await tapAfterScroll(tester, find.byTooltip('You buy book.'));

    expect(find.text('Object determiner:'), findsOneWidget);
    expect(find.text('Object adjective:'), findsOneWidget);
    expect(find.text('Recipient:'), findsOneWidget);

    await tapAfterScroll(tester, find.byTooltip('You give book.'), delta: -500);

    expect(find.text('Recipient:'), findsOneWidget);
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

    await tapAfterScroll(
      tester,
      find.byTooltip('Show 3rd person singular nouns'),
    );
    expect(find.text('cat'), findsOneWidget);

    await tapAfterScroll(tester, find.text('cat'));
    expect(renderedSentence(tester), 'Cat learns.');

    await tapAfterScroll(
      tester,
      find.byTooltip('Show 3rd person plural nouns'),
    );
    expect(find.text('cats'), findsOneWidget);

    await tapAfterScroll(tester, find.text('cats'));
    expect(renderedSentence(tester), 'Cats learn.');
  });

  testWidgets('Object rail number switch changes the selected object', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));
    await tapAfterScroll(tester, find.byTooltip('You buy.'));

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

    expect(renderedSentence(tester), 'You buy book.');

    tester
        .widget<SegmentedButton<Number>>(
          find.byType(SegmentedButton<Number>).last,
        )
        .onSelectionChanged
        ?.call({Number.plural});
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), 'You buy books.');
    expect(find.text('book', findRichText: true), findsNothing);
    expect(find.text('books', findRichText: true), findsWidgets);
  });

  testWidgets('Change preview highlights whole changed words', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapAfterScroll(tester, find.byTooltip('You give.'));
    await tapAfterScroll(tester, find.byTooltip('You give book.'));
    await tester.scrollUntilVisible(
      find.byTooltip('You buy book.'),
      -500,
      scrollable: mainScroll,
    );
    await tester.drag(mainScroll, const Offset(0, 120));
    await tester.pumpAndSettle();

    expect(highlightedTextForTooltip(tester, 'You buy book.'), ['buy']);
  });

  testWidgets('Passive focus can return to the null default focus', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));
    await tapAfterScroll(tester, find.byTooltip('You give.'));
    await tapAfterScroll(tester, find.byTooltip('You give book.'));
    await tapAfterScroll(tester, find.byTooltip('You give Mary book.'));
    await tapAfterScroll(tester, find.text('passive'));

    expect(renderedSentence(tester), 'Book is given to Mary by you.');

    await tapAfterScroll(tester, find.byTooltip('Mary is given book by you.'));
    expect(renderedSentence(tester), 'Mary is given book by you.');

    await tapAfterScroll(
      tester,
      find.text('no passive focus', findRichText: true),
    );
    expect(renderedSentence(tester), 'Book is given to Mary by you.');
  });

  testWidgets('Recipient object pronouns can render passive to phrases', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));
    await tapAfterScroll(tester, find.byTooltip('You give.'));
    await tapAfterScroll(tester, find.byTooltip('You give book.'));
    await tapAfterScroll(tester, find.byTooltip('You give him book.'));
    await tapAfterScroll(tester, find.text('past'));
    await tapAfterScroll(tester, find.text('passive'));

    expect(renderedSentence(tester), 'Book was given to him by you.');

    await tapAfterScroll(
      tester,
      find.text('hide by-agent', findRichText: true),
    );

    expect(renderedSentence(tester), 'Book was given to him.');
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
    expect(renderedSentence(tester), 'You learn.');
    expect(find.text('give', findRichText: true), findsOneWidget);
    expect(find.text('You give.'), findsNothing);

    final giveSuggestion = find.byTooltip('You give.');
    final hoverRegion = tester.widget<MouseRegion>(
      find
          .ancestor(of: giveSuggestion, matching: find.byType(MouseRegion))
          .first,
    );
    hoverRegion.onEnter?.call(const PointerEnterEvent());
    await tester.pump();

    expect(renderedSentence(tester), 'You give.');

    hoverRegion.onExit?.call(const PointerExitEvent());
    await tester.pump();

    expect(renderedSentence(tester), 'You learn.');
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
