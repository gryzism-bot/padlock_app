import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

    final segmentedButton = find.ancestor(
      of: finder,
      matching: find.byWidgetPredicate((widget) => widget is SegmentedButton),
    );
    if (segmentedButton.evaluate().isNotEmpty) {
      final label = tester.widget<Text>(finder).data;
      final dynamic segmented = tester.widget(segmentedButton.first);
      final Object? segment = segmented.segments.cast<dynamic>().firstWhere(
        (dynamic segment) => (segment.label as Text).data == label,
      );
      final dynamic selection = segmented.selected.toSet();
      selection
        ..clear()
        ..add((segment as dynamic).value);
      segmented.onSelectionChanged(selection);
    } else {
      await tester.tap(finder, warnIfMissed: false);
    }
    await tester.pumpAndSettle();
  }

  Future<void> expandRail(WidgetTester tester, String title) async {
    await tapAfterScroll(tester, find.byTooltip('Open $title rail'));
  }

  Future<void> pressOutlinedText(WidgetTester tester, String label) async {
    final button = find
        .ancestor(of: find.text(label), matching: find.byType(OutlinedButton))
        .first;
    tester.widget<OutlinedButton>(button).onPressed?.call();
    await tester.pumpAndSettle();
  }

  Future<void> switchLastNounNumber(WidgetTester tester, Number number) async {
    tester
        .widget<SegmentedButton<Number>>(
          find.byType(SegmentedButton<Number>).last,
        )
        .onSelectionChanged
        ?.call({number});
    await tester.pumpAndSettle();
  }

  testWidgets('Object rail number switch changes the selected object', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-action-buy')),
    );
    await expandRail(tester, 'Object');

    await tester.scrollUntilVisible(
      find.text('sg'),
      500,
      scrollable: mainScroll,
    );
    await tester.drag(mainScroll, const Offset(0, 120));
    await tester.pumpAndSettle();

    expect(find.text('sg'), findsOneWidget);
    expect(find.text('pl'), findsOneWidget);
    expect(
      find.byKey(const Key('suggestion-label-object-book')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('suggestion-label-object-books')),
      findsNothing,
    );

    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-object-book')),
    );

    expect(renderedSentence(tester), 'You buy book.');

    await switchLastNounNumber(tester, Number.plural);

    expect(renderedSentence(tester), 'You buy books.');
    expect(find.byKey(const Key('suggestion-label-object-book')), findsNothing);
    expect(
      find.byKey(const Key('suggestion-label-object-books')),
      findsWidgets,
    );

    await switchLastNounNumber(tester, Number.singular);

    expect(renderedSentence(tester), 'You buy book.');

    await tapAfterScroll(tester, find.text('no object', findRichText: true));

    expect(renderedSentence(tester), 'You buy.');
  });

  testWidgets('Fixed text rail keeps plural determiner and adjective surface', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-action-read')),
    );
    await pressOutlinedText(tester, 'future');
    await expandRail(tester, 'Text');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-object-book')),
    );

    await switchLastNounNumber(tester, Number.plural);

    expect(renderedSentence(tester), 'You will read books.');
    expect(find.text('Text determiner:'), findsOneWidget);
    expect(find.text('Text adjective:'), findsOneWidget);

    await tapVisible(tester, find.text('Change'));
    await expandRail(tester, 'Text determiner');

    expect(
      find.byKey(const Key('suggestion-label-objectDeterminer-some')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('suggestion-label-objectDeterminer-all')),
      findsOneWidget,
    );
    expect(find.byTooltip('You will read all books.'), findsOneWidget);

    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-objectDeterminer-some')),
    );

    expect(renderedSentence(tester), 'You will read some books.');

    await expandRail(tester, 'Text adjective');

    expect(
      find.byKey(const Key('suggestion-label-objectAdjective-full')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('suggestion-label-objectAdjective-free')),
      findsOneWidget,
    );
    expect(find.byTooltip('You will read some full books.'), findsOneWidget);
    expect(find.byTooltip('You will read some free books.'), findsOneWidget);
  });

  testWidgets('Fixed openable rail follows the object number switch', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-action-close')),
    );
    await expandRail(tester, 'Openable');

    expect(find.text('door', findRichText: true), findsOneWidget);
    expect(find.text('doors', findRichText: true), findsNothing);

    await switchLastNounNumber(tester, Number.plural);

    expect(find.text('doors', findRichText: true), findsWidgets);
    expect(find.text('door', findRichText: true), findsNothing);

    await switchLastNounNumber(tester, Number.singular);

    await tapAfterScroll(tester, find.text('door', findRichText: true));
    expect(renderedSentence(tester), 'You close door.');

    await switchLastNounNumber(tester, Number.plural);

    expect(renderedSentence(tester), 'You close doors.');
  });

  testWidgets('Addressee rail number switch changes the selected addressee', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-action-listen')),
    );
    await expandRail(tester, 'Addressee');

    expect(find.text('person', findRichText: true), findsOneWidget);
    expect(find.text('people', findRichText: true), findsNothing);

    await tapAfterScroll(tester, find.text('dog', findRichText: true));

    expect(renderedSentence(tester), 'You listen to dog.');

    await switchLastNounNumber(tester, Number.plural);

    expect(renderedSentence(tester), 'You listen to dogs.');
    expect(find.text('dogs', findRichText: true), findsWidgets);
  });

  testWidgets('Companion rail number switch changes the selected companion', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));
    await expandRail(tester, 'Companion');
    await tapAfterScroll(tester, find.text('girl', findRichText: true));

    expect(renderedSentence(tester), 'You learn with girl.');
    expect(find.text('girl', findRichText: true), findsWidgets);
    expect(find.text('girls', findRichText: true), findsNothing);

    await switchLastNounNumber(tester, Number.plural);

    expect(renderedSentence(tester), 'You learn with girls.');
    expect(find.text('girls', findRichText: true), findsWidgets);
    expect(find.text('girl', findRichText: true), findsNothing);

    await switchLastNounNumber(tester, Number.singular);

    expect(renderedSentence(tester), 'You learn with girl.');
    expect(find.text('girl', findRichText: true), findsWidgets);
  });

  testWidgets('Personal pronoun rail number switches preserve pronoun family', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    final cases = [
      (
        actionKey: 'buy',
        rail: 'Source',
        singularKey: 'suggestion-label-source-me',
        singular: 'You buy from me.',
        plural: 'You buy from us.',
      ),
      (
        actionKey: 'listen',
        rail: 'Addressee',
        singularKey: 'suggestion-label-addressee-me',
        singular: 'You listen to me.',
        plural: 'You listen to us.',
      ),
      (
        actionKey: 'learn',
        rail: 'Companion',
        singularKey: 'suggestion-label-companion-me',
        singular: 'You learn with me.',
        plural: 'You learn with us.',
      ),
    ];

    for (final example in cases) {
      await tapVisible(tester, find.byTooltip('Reset'));
      await tapVisible(tester, find.text('Word'));
      await tapAfterScroll(
        tester,
        find.byKey(Key('suggestion-label-action-${example.actionKey}')),
      );
      await expandRail(tester, example.rail);
      await tapAfterScroll(tester, find.byKey(Key(example.singularKey)));

      expect(renderedSentence(tester), example.singular);

      await switchLastNounNumber(tester, Number.plural);

      expect(renderedSentence(tester), example.plural);

      await switchLastNounNumber(tester, Number.singular);

      expect(renderedSentence(tester), example.singular);
    }
  });

  testWidgets(
    'Fixed subject rail stays visible when number switch has no plural variant',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      await tapVisible(tester, find.text('Word'));
      await expandRail(tester, 'Subject');
      await tapAfterScroll(tester, find.text('science', findRichText: true));

      expect(renderedSentence(tester), 'You learn science.');
      expect(find.text('Subject:'), findsOneWidget);

      await switchLastNounNumber(tester, Number.plural);

      expect(renderedSentence(tester), 'You learn science.');
      expect(find.text('Subject:'), findsOneWidget);
      expect(find.text('science', findRichText: true), findsWidgets);
    },
  );

  testWidgets(
    'Passive by-agent rail number switch changes the remembered agent',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      await tapVisible(tester, find.text('Word'));
      await tapAfterScroll(
        tester,
        find.byKey(const Key('suggestion-label-action-give')),
      );
      await expandRail(tester, 'Object');
      await tapAfterScroll(
        tester,
        find.byKey(const Key('suggestion-label-object-book')),
      );
      await tapAfterScroll(tester, find.text('passive'));
      await expandRail(tester, 'By-agent');

      expect(find.text('sg'), findsWidgets);
      expect(find.text('pl'), findsWidgets);
      expect(find.text('person', findRichText: true), findsOneWidget);
      expect(find.text('people', findRichText: true), findsNothing);

      await switchLastNounNumber(tester, Number.plural);

      expect(find.text('people', findRichText: true), findsWidgets);
      expect(find.text('person', findRichText: true), findsNothing);

      await tapAfterScroll(tester, find.text('people', findRichText: true));

      expect(renderedSentence(tester), 'Book is given by people.');
    },
  );
}
