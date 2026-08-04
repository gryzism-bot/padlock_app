import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/idioms/idiom_patterns.dart';
import 'package:padlock_app/engine/idiom_progress_store_stub.dart'
    as idiom_store;
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

  Future<void> revealLazyFinder(
    WidgetTester tester,
    Finder finder, {
    double delta = 500,
  }) async {
    if (finder.evaluate().isNotEmpty) {
      return;
    }

    final direction = delta < 0 ? -1.0 : 1.0;
    final scrollDelta = direction * 120;
    final viewportDragPoint = tester.getCenter(find.byType(Scaffold));
    for (var i = 0; i < 90 && finder.evaluate().isEmpty; i += 1) {
      await tester.dragFrom(viewportDragPoint, Offset(0, -scrollDelta));
      await tester.pumpAndSettle();
    }
  }

  Future<void> tapAfterScroll(
    WidgetTester tester,
    Finder finder, {
    double delta = 500,
  }) async {
    await revealLazyFinder(tester, finder, delta: delta);

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

    final buttonTarget = descendantButton.evaluate().isNotEmpty
        ? descendantButton.first
        : ancestorButton.evaluate().isNotEmpty
        ? ancestorButton.first
        : null;
    final iconButtonTarget = descendantIconButton.evaluate().isNotEmpty
        ? descendantIconButton.first
        : ancestorIconButton.evaluate().isNotEmpty
        ? ancestorIconButton.first
        : null;

    if (buttonTarget != null) {
      tester.widget<OutlinedButton>(buttonTarget).onPressed?.call();
      await tester.pumpAndSettle();
      return;
    }
    if (iconButtonTarget != null) {
      tester.widget<IconButton>(iconButtonTarget).onPressed?.call();
      await tester.pumpAndSettle();
      return;
    }

    await tester.scrollUntilVisible(target, delta, scrollable: mainScroll);
    await tester.pumpAndSettle();

    await tester.tap(target, warnIfMissed: false);
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

  String? participantDoorKeyForTitle(String title) {
    return switch (title) {
      'Object' || 'Subject' || 'Activity' || 'Text' || 'Openable' => 'object',
      'Object complement' => 'objectComplement',
      'Object adjective complement' => 'objectAdjectiveComplement',
      'Recipient' => 'recipient',
      'Addressee' => 'addressee',
      'Companion' => 'companion',
      'Instrument' => 'instrument',
      'Destination' => 'destination',
      'Topic' => 'topic',
      'Beneficiary' => 'beneficiary',
      'Source' => 'source',
      'Right action' => 'rightAction',
      'By-agent' => 'passiveAgent',
      'Noun complement' => 'complement',
      'Adjective complement' => 'adjectiveComplement',
      _ => null,
    };
  }

  Future<void> expandRail(WidgetTester tester, String title) async {
    final railToggle = find.byKey(Key('rail-toggle-$title'));
    if (railToggle.evaluate().isNotEmpty) {
      tester.widget<IconButton>(railToggle.first).onPressed?.call();
      await tester.pumpAndSettle();
      return;
    }

    final doorKey = participantDoorKeyForTitle(title);
    if (doorKey != null) {
      final doorOpener = find.byKey(Key('participant-door-$doorKey'));
      if (doorOpener.evaluate().isNotEmpty) {
        tester.widget<OutlinedButton>(doorOpener.first).onPressed?.call();
        await tester.pumpAndSettle();
        return;
      }
    }

    final oldOpener = find.byTooltip('Open $title rail');
    if (oldOpener.evaluate().isNotEmpty) {
      await tapAfterScroll(tester, oldOpener);
      return;
    }

    final normalizedTitle = title.toLowerCase();
    final doorOpener = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data != null &&
          widget.data!.toLowerCase().startsWith('$normalizedTitle:') &&
          widget.data!.contains('('),
    );
    if (doorOpener.evaluate().isNotEmpty) {
      await tapAfterScroll(tester, doorOpener.first);
    }
  }

  Future<void> filterRailIfPresent(
    WidgetTester tester,
    String railTitle,
    String query,
  ) async {
    final search = find.byKey(Key('rail-search-$railTitle'));
    if (search.evaluate().isEmpty) {
      await revealLazyFinder(tester, find.text('$railTitle:'));
    }
    if (search.evaluate().isEmpty) {
      return;
    }

    await tester.enterText(search, query);
    await tester.pumpAndSettle();
  }

  Future<void> selectVerb(WidgetTester tester, String verbKey) async {
    await filterRailIfPresent(tester, 'Verb', verbKey);
    await tapAfterScroll(
      tester,
      find.byKey(Key('suggestion-label-action-$verbKey')),
    );
  }

  Future<void> selectRightParticle(WidgetTester tester, String particle) async {
    await expandRail(tester, 'Right particle');
    await filterRailIfPresent(tester, 'Right particle', particle);
    await tapAfterScroll(
      tester,
      find.byKey(Key('suggestion-label-rightParticle-$particle')),
    );
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
    await selectVerb(tester, 'buy');
    await expandRail(tester, 'Object');
    await filterRailIfPresent(tester, 'Object', 'book');

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

    await filterRailIfPresent(tester, 'Object', 'no object');
    await tapAfterScroll(tester, find.text('no object', findRichText: true));

    expect(renderedSentence(tester), 'You buy.');
  });

  testWidgets('Give object rail exposes habit nouns for give up routes', (
    tester,
  ) async {
    idiom_store.resetStoredIdiomIdsForTests();
    addTearDown(idiom_store.resetStoredIdiomIdsForTests);
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));
    await selectVerb(tester, 'give');
    await expandRail(tester, 'Object');
    await filterRailIfPresent(tester, 'Object', 'smok');

    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-object-smoking')),
    );
    await expandRail(tester, 'Right particle');
    await filterRailIfPresent(tester, 'Right particle', 'up');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-rightParticle-up')),
    );

    expect(renderedSentence(tester), 'You give up smoking.');
    expect(find.text('1 / $idiomTargetCount idioms found'), findsOneWidget);
    expect(find.byKey(const Key('idiom-toast')), findsOneWidget);
    expect(find.text('Idiom found'), findsOneWidget);
    expect(find.text('give up: stop doing something'), findsOneWidget);
  });

  testWidgets('Idiom discovery badge accumulates unique particle idioms', (
    tester,
  ) async {
    idiom_store.resetStoredIdiomIdsForTests();
    addTearDown(idiom_store.resetStoredIdiomIdsForTests);
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));
    expect(find.text('0 / $idiomTargetCount idioms found'), findsOneWidget);

    await selectVerb(tester, 'give');
    await selectRightParticle(tester, 'up');

    expect(renderedSentence(tester), 'You give up.');
    expect(find.text('1 / $idiomTargetCount idioms found'), findsOneWidget);
    expect(find.text('give up: stop trying'), findsOneWidget);

    await selectVerb(tester, 'write');
    await selectRightParticle(tester, 'back');

    expect(renderedSentence(tester), 'You write back.');
    expect(find.text('2 / $idiomTargetCount idioms found'), findsOneWidget);
    expect(find.text('write back: reply in writing'), findsOneWidget);

    await selectVerb(tester, 'take');
    await selectRightParticle(tester, 'off');

    expect(renderedSentence(tester), 'You take off.');
    expect(find.text('3 / $idiomTargetCount idioms found'), findsOneWidget);
    expect(
      find.text('take off: leave the ground or remove something'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('idiom-found-count')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('found-idioms-overlay')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('found-idioms-overlay')),
        matching: find.text('3 / $idiomTargetCount idioms found'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('found-idiom-give-up')), findsOneWidget);
    expect(find.byKey(const Key('found-idiom-write-back')), findsOneWidget);
    expect(find.byKey(const Key('found-idiom-take-off')), findsOneWidget);
    expect(find.text('stop trying'), findsOneWidget);
    expect(find.text('reply in writing'), findsOneWidget);
  });

  testWidgets('Fixed text rail keeps plural determiner and adjective surface', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));
    await selectVerb(tester, 'read');
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
    await selectVerb(tester, 'close');
    await expandRail(tester, 'Openable');

    expect(find.text('door', findRichText: true), findsOneWidget);
    expect(find.text('doors', findRichText: true), findsNothing);

    await switchLastNounNumber(tester, Number.plural);

    expect(find.text('doors', findRichText: true), findsWidgets);
    expect(find.text('door', findRichText: true), findsNothing);

    await switchLastNounNumber(tester, Number.singular);

    await filterRailIfPresent(tester, 'Openable', 'door');
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
    await selectVerb(tester, 'listen');
    await expandRail(tester, 'Addressee');

    await filterRailIfPresent(tester, 'Addressee', 'dog');
    expect(
      find.byKey(const Key('suggestion-label-addressee-dog')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('suggestion-label-addressee-dogs')),
      findsNothing,
    );
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-addressee-dog')),
    );

    expect(renderedSentence(tester), 'You listen to dog.');

    await switchLastNounNumber(tester, Number.plural);

    expect(renderedSentence(tester), 'You listen to dogs.');
    expect(
      find.byKey(const Key('suggestion-label-addressee-dogs')),
      findsWidgets,
    );
  });

  testWidgets('Companion rail number switch changes the selected companion', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));
    await expandRail(tester, 'Companion');
    await filterRailIfPresent(tester, 'Companion', 'girl');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-companion-girl')),
    );

    expect(renderedSentence(tester), 'You learn with girl.');
    expect(
      find.byKey(const Key('suggestion-label-companion-girl')),
      findsWidgets,
    );
    expect(
      find.byKey(const Key('suggestion-label-companion-girls')),
      findsNothing,
    );

    await switchLastNounNumber(tester, Number.plural);

    expect(renderedSentence(tester), 'You learn with girls.');
    expect(
      find.byKey(const Key('suggestion-label-companion-girls')),
      findsWidgets,
    );
    expect(
      find.byKey(const Key('suggestion-label-companion-girl')),
      findsNothing,
    );

    await switchLastNounNumber(tester, Number.singular);

    expect(renderedSentence(tester), 'You learn with girl.');
    expect(
      find.byKey(const Key('suggestion-label-companion-girl')),
      findsWidgets,
    );
  });

  testWidgets(
    'Fixed subject rail stays visible when number switch has no plural variant',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      await tapVisible(tester, find.text('Word'));
      await expandRail(tester, 'Subject');
      await filterRailIfPresent(tester, 'Subject', 'science');
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
      await selectVerb(tester, 'give');
      await expandRail(tester, 'Object');
      await filterRailIfPresent(tester, 'Object', 'book');
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

      await filterRailIfPresent(tester, 'By-agent', 'people');
      await tapAfterScroll(tester, find.text('people', findRichText: true));

      expect(renderedSentence(tester), 'Book is given by people.');
    },
  );
}
