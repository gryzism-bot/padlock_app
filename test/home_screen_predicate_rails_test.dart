import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/predicate/predicate_paths.dart';
import 'package:padlock_app/data/predicate/semantic_icons.dart';
import 'package:padlock_app/data/predicate/verb_influence.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
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

  int semanticOutputCountFor(Verb action) {
    final influenceKeys = [
      for (final influence in predicateInfluencesFor(action)) influence.key,
    ];
    final profile = predicateSemanticIconProfileFor(
      infinitive: action.infinitive,
      influenceKeys: influenceKeys,
    );

    return predicateSemanticOutputCount(
      infinitive: action.infinitive,
      influenceKeys: influenceKeys,
      profile: profile,
    );
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

    await tester.scrollUntilVisible(target, delta, scrollable: mainScroll);
    await tester.pumpAndSettle();

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
    } else if (iconButtonTarget != null) {
      tester.widget<IconButton>(iconButtonTarget).onPressed?.call();
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

  Future<void> filterRail(
    WidgetTester tester,
    String railTitle,
    String query,
  ) async {
    await tester.enterText(find.byKey(Key('rail-search-$railTitle')), query);
    await tester.pumpAndSettle();
  }

  Future<void> selectVerb(WidgetTester tester, String verbKey) async {
    await filterRail(tester, 'Verb', verbKey);
    await tapAfterScroll(
      tester,
      find.byKey(Key('suggestion-label-action-$verbKey')),
    );
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

  void expectRailSurfaceMarker(
    WidgetTester tester,
    String railTitle,
    String marker,
  ) {
    final markerFinder = find.byKey(Key('rail-surface-marker-$railTitle'));

    expect(markerFinder, findsOneWidget);
    expect(tester.widget<Text>(markerFinder).data, '[$marker]');
  }

  Future<void> runFixedRailRoute(
    WidgetTester tester,
    _FixedRailRoute route,
  ) async {
    await tapVisible(tester, find.byTooltip('Reset'));
    await tapVisible(tester, find.text('Word'));
    await filterRail(tester, 'Verb', route.actionKey);

    await tapAfterScroll(
      tester,
      find.byKey(Key('suggestion-label-action-${route.actionKey}')),
    );

    expect(renderedSentence(tester), route.emptySentence);
    expect(find.text('${route.railTitle}:'), findsOneWidget);
    expect(
      find.byKey(Key('suggestion-label-object-${route.choiceKey}')),
      findsNothing,
    );

    await expandRail(tester, route.railTitle);
    expect(
      find.byKey(Key('suggestion-label-object-${route.choiceKey}')),
      findsOneWidget,
      reason: '${route.actionKey} should expose ${route.choiceKey}',
    );
    await tapAfterScroll(
      tester,
      find.byKey(Key('suggestion-label-object-${route.choiceKey}')),
    );

    expect(renderedSentence(tester), route.filledSentence);
    expect(find.text('${route.railTitle}:'), findsOneWidget);
  }

  testWidgets('right action keeps owned object and companion rails reachable', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await expandRail(tester, 'Right action');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-rightAction-speak')),
    );

    expect(renderedSentence(tester), 'You learn to speak.');
    expect(find.text('Language:', skipOffstage: false), findsOneWidget);
    expect(find.text('Companion:', skipOffstage: false), findsOneWidget);
    expect(
      find.byKey(const Key('suggestion-label-object-polish')),
      findsNothing,
    );

    await expandRail(tester, 'Language');
    expect(
      find.byKey(const Key('suggestion-label-object-polish')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('suggestion-label-object-science')),
      findsNothing,
    );

    await tapAfterScroll(tester, find.byTooltip('You learn to speak Polish.'));
    expect(renderedSentence(tester), 'You learn to speak Polish.');

    await expandRail(tester, 'Companion');
    await tapAfterScroll(
      tester,
      find.byTooltip('You learn to speak Polish with anyone.'),
    );
    expect(renderedSentence(tester), 'You learn to speak Polish with anyone.');
  });

  testWidgets('Verb chips mark predicate extensions they can wake', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await filterRail(tester, 'Verb', 'be');
    expect(find.byKey(const Key('verb-wake-be-complement')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-output-be')), findsOneWidget);

    await filterRail(tester, 'Verb', 'learn');
    expect(find.byKey(const Key('verb-wake-learn-subject')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-learn-purpose')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('verb-wake-output-learn')),
        matching: find.byType(Icon),
      ),
      findsNWidgets(semanticOutputCountFor(learn)),
    );

    await filterRail(tester, 'Verb', 'think');
    expect(find.byKey(const Key('verb-wake-think-topic')), findsOneWidget);

    await filterRail(tester, 'Verb', 'work');
    expect(find.byKey(const Key('verb-wake-work-topic')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-work-instrument')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-work-object')), findsNothing);
    expect(find.byKey(const Key('verb-wake-work-recipient')), findsNothing);
    expect(find.byKey(const Key('verb-wake-work-complement')), findsNothing);

    await filterRail(tester, 'Verb', 'play');
    expect(find.byKey(const Key('verb-wake-play-activity')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-output-play')), findsOneWidget);

    await filterRail(tester, 'Verb', 'go');
    expect(find.byKey(const Key('verb-wake-go-destination')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-go-topic')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-go-purpose')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('verb-wake-output-go')),
        matching: find.byType(Icon),
      ),
      findsNWidgets(semanticOutputCountFor(go)),
    );

    await filterRail(tester, 'Verb', 'read');
    expect(find.byKey(const Key('verb-wake-read-addressee')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-read-companion')), findsOneWidget);

    await filterRail(tester, 'Verb', 'drive');
    expect(find.byKey(const Key('verb-wake-drive-vehicle')), findsOneWidget);

    await filterRail(tester, 'Verb', 'give');
    expect(find.byKey(const Key('verb-wake-give-object')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-give-recipient')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-give-companion')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-give-beneficiary')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-give-manner')), findsOneWidget);
    expect(
      find.byKey(const Key('verb-wake-give-right-particle')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('verb-wake-give-time')), findsNothing);
    expect(find.byKey(const Key('verb-wake-output-give')), findsOneWidget);

    final giveRecipientIcon = tester.widget<Icon>(
      find
          .descendant(
            of: find.byKey(const Key('verb-wake-icon-give-recipient')),
            matching: find.byType(Icon),
          )
          .first,
    );
    expect(giveRecipientIcon.icon, Icons.pan_tool_outlined);
    expect(
      find.descendant(
        of: find.byKey(const Key('verb-wake-output-give')),
        matching: find.byType(Icon),
      ),
      findsNWidgets(semanticOutputCountFor(give)),
    );

    await filterRail(tester, 'Verb', 'run');
    expect(find.byKey(const Key('verb-wake-run-destination')), findsOneWidget);
  });

  testWidgets('Verb rail search matches predicate influence labels', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.enterText(
      find.byKey(const Key('rail-search-Verb')),
      'right action',
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('suggestion-label-action-learn')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('suggestion-label-action-need')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('suggestion-label-action-be')), findsNothing);
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

    expect(
      find.byKey(const Key('suggestion-label-object-english')),
      findsNothing,
    );
    await expandRail(tester, 'Subject');
    expect(
      find.byKey(const Key('suggestion-label-object-english')),
      findsOneWidget,
    );
    expect(find.text('Object determiner:'), findsNothing);
    expect(find.text('Object adjective:'), findsNothing);

    await selectVerb(tester, 'play');

    expect(find.text('Activity:'), findsOneWidget);
    expect(
      find.byKey(const Key('suggestion-label-object-volleyball')),
      findsNothing,
    );
    expect(find.text('Object:'), findsNothing);
    expect(find.text('Object determiner:'), findsNothing);
    expect(find.text('Object adjective:'), findsNothing);

    await expandRail(tester, 'Activity');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-object-volleyball')),
    );

    expect(renderedSentence(tester), 'You play volleyball.');
    expect(find.text('Activity:'), findsOneWidget);

    await selectVerb(tester, 'be');

    expect(find.text('Noun complement:'), findsOneWidget);
    expect(find.text('Adjective complement:'), findsOneWidget);
    expect(find.text('Object:'), findsNothing);

    await selectVerb(tester, 'buy');

    expect(find.text('Object:'), findsOneWidget);
    expect(find.byKey(const Key('suggestion-label-object-book')), findsNothing);
    expect(find.text('Object determiner:'), findsNothing);
    expect(find.text('Object adjective:'), findsNothing);

    await expandRail(tester, 'Object');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-object-book')),
    );

    expect(find.text('Object determiner:'), findsOneWidget);
    expect(
      find.byKey(const Key('suggestion-label-objectDeterminer-a')),
      findsNothing,
    );
    expect(find.text('Object adjective:'), findsOneWidget);
    expect(find.text('Recipient:'), findsOneWidget);

    await selectVerb(tester, 'give');

    expect(find.text('Recipient:'), findsOneWidget);
  });

  testWidgets('Rail policy exposes every fixed semantic object rail', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    const routes = [
      _FixedRailRoute(
        actionKey: 'play',
        railTitle: 'Activity',
        choiceKey: 'volleyball',
        emptySentence: 'You play.',
        filledSentence: 'You play volleyball.',
      ),
      _FixedRailRoute(
        actionKey: 'learn',
        railTitle: 'Subject',
        choiceKey: 'english',
        emptySentence: 'You learn.',
        filledSentence: 'You learn English.',
      ),
      _FixedRailRoute(
        actionKey: 'speak',
        railTitle: 'Language',
        choiceKey: 'english',
        emptySentence: 'You speak.',
        filledSentence: 'You speak English.',
      ),
      _FixedRailRoute(
        actionKey: 'read',
        railTitle: 'Text',
        choiceKey: 'book',
        emptySentence: 'You read.',
        filledSentence: 'You read book.',
      ),
      _FixedRailRoute(
        actionKey: 'use',
        railTitle: 'Tool',
        choiceKey: 'phone',
        emptySentence: 'You use.',
        filledSentence: 'You use phone.',
      ),
      _FixedRailRoute(
        actionKey: 'watch',
        railTitle: 'Media',
        choiceKey: 'television',
        emptySentence: 'You watch.',
        filledSentence: 'You watch television.',
      ),
      _FixedRailRoute(
        actionKey: 'drive',
        railTitle: 'Vehicle',
        choiceKey: 'car',
        emptySentence: 'You drive.',
        filledSentence: 'You drive car.',
      ),
      _FixedRailRoute(
        actionKey: 'close',
        railTitle: 'Openable',
        choiceKey: 'door',
        emptySentence: 'You close.',
        filledSentence: 'You close door.',
      ),
    ];

    for (final route in routes) {
      await runFixedRailRoute(tester, route);
    }
  });

  testWidgets('Rails label their surface connector words', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tapVisible(tester, find.text('Word'));

    expectRailSurfaceMarker(tester, 'Subject', '-');
    expectRailSurfaceMarker(tester, 'Companion', 'with');
    expectRailSurfaceMarker(tester, 'Right action', 'to');

    await selectVerb(tester, 'work');
    expectRailSurfaceMarker(tester, 'Beneficiary', 'for');
    expectRailSurfaceMarker(tester, 'Topic', 'on');
    await expandRail(tester, 'Topic');
    await filterRail(tester, 'Topic', 'grammar');
    expect(
      find.byKey(const Key('suggestion-label-topic-on-grammar')),
      findsOneWidget,
    );
    await filterRail(tester, 'Topic', 'car');
    expect(
      find.byKey(const Key('suggestion-label-topic-on-car')),
      findsOneWidget,
    );
    await filterRail(tester, 'Topic', 'project');
    expect(
      find.byKey(const Key('suggestion-label-topic-on-project')),
      findsOneWidget,
    );

    await filterRail(tester, 'Topic', 'tool');
    expect(
      find.byKey(const Key('suggestion-label-topic-on-tool')),
      findsOneWidget,
    );

    await tapVisible(
      tester,
      find.descendant(
        of: find.byKey(const Key('noun-number-switch-Topic')),
        matching: find.text('pl'),
      ),
    );
    expect(
      find.byKey(const Key('suggestion-label-topic-on-tools')),
      findsOneWidget,
    );

    await selectVerb(tester, 'learn');
    expectRailSurfaceMarker(tester, 'Source', 'from');

    await selectVerb(tester, 'introduce');

    expectRailSurfaceMarker(tester, 'Object', '-');
    expectRailSurfaceMarker(tester, 'Addressee', 'to');

    await selectVerb(tester, 'give');
    await expandRail(tester, 'Object');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-object-book')),
    );

    expectRailSurfaceMarker(tester, 'Object', '-');
    expectRailSurfaceMarker(tester, 'Recipient', 'to/for/-');

    await tapAfterScroll(tester, find.text('passive'));

    expectRailSurfaceMarker(tester, 'By-agent', 'by');

    await selectVerb(tester, 'be');

    expectRailSurfaceMarker(tester, 'Noun complement', '-');
    expectRailSurfaceMarker(tester, 'Adjective complement', '-');
  });

  testWidgets('Movement place rail exposes source-place choices', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await selectVerb(tester, 'go');

    expect(find.text('Place phrase:'), findsNothing);
    expect(find.text('Source place:'), findsOneWidget);
    expectRailSurfaceMarker(tester, 'Source place', 'from');

    await expandRail(tester, 'Source place');
    expect(find.byTooltip('You go from work.'), findsOneWidget);

    await tapAfterScroll(tester, find.byTooltip('You go from work.'));

    expect(renderedSentence(tester), 'You go from work.');
  });

  testWidgets('Essential verb chips expose their expected cockpit rails', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tapVisible(tester, find.text('Word'));

    for (final verb in essentialVerbs) {
      await tapVisible(tester, find.byTooltip('Reset'));
      await selectVerb(tester, verb.infinitive);

      expect(
        renderedSentence(tester),
        isNotEmpty,
        reason: '${verb.infinitive} should render after its action chip.',
      );
      expect(
        find.textContaining('[blocked'),
        findsNothing,
        reason: '${verb.infinitive} should be directly selectable.',
      );

      for (final title in _expectedImmediateRailTitlesFor(verb)) {
        expect(
          find.text('$title:'),
          findsOneWidget,
          reason:
              '${verb.infinitive} advertises ${title.toLowerCase()} and should expose that rail.',
        );
      }
    }
  });

  testWidgets('Object complement rails open after object-complement verbs', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tapVisible(tester, find.text('Word'));

    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-action-make')),
    );
    expect(find.text('Object complement:'), findsNothing);
    expect(find.text('Object adjective complement:'), findsNothing);

    await expandRail(tester, 'Object');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-object-cake')),
    );

    expect(renderedSentence(tester), 'You make cake.');
    expect(find.text('Object complement:'), findsOneWidget);
    expect(find.text('Object adjective complement:'), findsOneWidget);

    await expandRail(tester, 'Object adjective complement');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-objectAdjectiveComplement-calm')),
    );

    expect(renderedSentence(tester), 'You make cake calm.');

    await tapAfterScroll(
      tester,
      find.byKey(
        const Key(
          'suggestion-label-objectAdjectiveComplement-no-object-adjective-complement',
        ),
      ),
    );
    expect(renderedSentence(tester), 'You make cake.');

    await selectVerb(tester, 'call');
    await expandRail(tester, 'Object');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-object-cat')),
    );
    await expandRail(tester, 'Object complement');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-objectComplement-teacher')),
    );

    expect(renderedSentence(tester), 'You call cat teacher.');
    expect(find.text('Object complement determiner:'), findsOneWidget);
    expect(find.text('Object complement adjective:'), findsOneWidget);

    await expandRail(tester, 'Object complement determiner');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-objectComplementDeterminer-a')),
    );
    expect(renderedSentence(tester), 'You call cat a teacher.');
  });

  testWidgets('Core participant surface maps predicate doors to rails', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Core participant surface:'), findsOneWidget);
    expect(find.text('predicate: learn (filled)'), findsOneWidget);
    expect(find.text('subject: you (filled)'), findsOneWidget);
    expect(find.text('study subject: none (awake)'), findsOneWidget);
    expect(find.text('recipient: none (asleep)'), findsOneWidget);

    await selectVerb(tester, 'give');

    expect(find.text('predicate: give (filled)'), findsOneWidget);
    expect(find.text('object: none (awake)'), findsOneWidget);
    expect(find.text('recipient: none (awake)'), findsOneWidget);
    expect(find.text('Object:'), findsOneWidget);
    expect(find.text('Recipient:'), findsNothing);
    expect(find.byTooltip('You give book.'), findsNothing);

    await tapAfterScroll(tester, find.text('recipient: none (awake)'));

    expect(find.text('recipient: none (open)'), findsOneWidget);
    expect(find.text('Recipient:'), findsNothing);

    await tapAfterScroll(tester, find.text('object: none (awake)'));

    expect(find.text('object: none (open)'), findsOneWidget);
    expect(find.byTooltip('You give book.'), findsWidgets);

    await tapAfterScroll(tester, find.byTooltip('You give book.'));

    expect(renderedSentence(tester), 'You give book.');
    expect(find.text('Recipient:'), findsOneWidget);
  });

  testWidgets('Object-gated predicate doors wake only after object exists', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await selectVerb(tester, 'do');

    expect(renderedSentence(tester), 'You do.');
    expect(find.text('object: none (awake)'), findsOneWidget);
    expect(find.text('companion: none (asleep)'), findsOneWidget);
    expect(find.text('beneficiary: none (asleep)'), findsOneWidget);
    expect(find.text('purpose: none (asleep)'), findsOneWidget);
    expect(find.text('Purpose:'), findsNothing);
    expect(find.text('Location:'), findsNothing);

    await tapAfterScroll(tester, find.text('object: none (awake)'));
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-object-something')),
    );

    expect(renderedSentence(tester), 'You do something.');
    expect(find.text('companion: none (awake)'), findsOneWidget);
    expect(find.text('beneficiary: none (awake)'), findsOneWidget);
    expect(find.text('purpose: none (awake)'), findsOneWidget);
    expect(find.text('Location:'), findsOneWidget);

    await tapAfterScroll(tester, find.text('purpose: none (awake)'));
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-purpose-fun')),
    );

    expect(renderedSentence(tester), 'You do something for fun.');
  });

  testWidgets('Guided UI names authored location rails explicitly', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await selectVerb(tester, 'work');

    expect(renderedSentence(tester), 'You work.');
    expect(find.text('Location:'), findsOneWidget);
    expect(find.text('Place phrase:'), findsNothing);
    expectRailSurfaceMarker(tester, 'Location', 'at/in');

    await expandRail(tester, 'Location');
    await tapAfterScroll(tester, find.byTooltip('You work at school.'));

    expect(renderedSentence(tester), 'You work at school.');

    await tapAfterScroll(tester, find.byTooltip('Reset'));
    await selectVerb(tester, 'buy');

    expect(renderedSentence(tester), 'You buy.');
    expect(find.text('Location:'), findsOneWidget);
    expectRailSurfaceMarker(tester, 'Location', 'at/in');
    await expandRail(tester, 'Location');
    await tapAfterScroll(tester, find.byTooltip('You buy at the shop.'));

    expect(renderedSentence(tester), 'You buy at the shop.');

    await tapAfterScroll(tester, find.byTooltip('Reset'));
    await selectVerb(tester, 'sleep');

    expect(renderedSentence(tester), 'You sleep.');
    expect(find.text('Location:'), findsOneWidget);
    expectRailSurfaceMarker(tester, 'Location', 'at/in/on');
    await expandRail(tester, 'Location');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-placePhrase-on-the-bed')),
    );

    expect(renderedSentence(tester), 'You sleep on the bed.');
  });

  testWidgets('Guided UI exposes reviewed phrase routes for think', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await selectVerb(tester, 'think');

    expect(renderedSentence(tester), 'You think.');
    expect(find.text('Topic:'), findsOneWidget);
    expect(find.text('Companion:'), findsOneWidget);
    expect(find.text('Manner phrase:'), findsOneWidget);
    expect(find.text('Time phrase:'), findsOneWidget);
    await expandRail(tester, 'Topic');
    await expandRail(tester, 'Manner phrase');
    await expandRail(tester, 'Time phrase');
    expect(find.byTooltip('You think about grammar.'), findsOneWidget);
    expect(find.byTooltip('You think of John.'), findsOneWidget);
    expect(find.byTooltip('You think carefully.'), findsOneWidget);
    expect(find.byTooltip('You think quickly.'), findsOneWidget);
    expect(find.byTooltip('You think today.'), findsOneWidget);
    expect(find.byTooltip('You think now.'), findsOneWidget);
  });
}

class _FixedRailRoute {
  final String actionKey;
  final String railTitle;
  final String choiceKey;
  final String emptySentence;
  final String filledSentence;

  const _FixedRailRoute({
    required this.actionKey,
    required this.railTitle,
    required this.choiceKey,
    required this.emptySentence,
    required this.filledSentence,
  });
}

Set<String> _expectedImmediateRailTitlesFor(Verb verb) {
  final titles = <String>{};
  final locationConnectors = _immediateLocationConnectorsFor(verb);
  final sourceLocationConnectors = _immediateSourceLocationConnectorsFor(verb);

  for (final influence in predicateInfluencesFor(verb)) {
    if (!_isImmediatelyReachableInfluence(verb, influence.key)) {
      continue;
    }

    switch (influence.key) {
      case 'activity':
        titles.add('Activity');
      case 'subject':
        titles.add('Subject');
      case 'language':
        titles.add('Language');
      case 'text':
        titles.add('Text');
      case 'tool':
        titles.add('Tool');
      case 'media':
        titles.add('Media');
      case 'vehicle':
        titles.add('Vehicle');
      case 'openable':
        titles.add('Openable');
      case 'object':
        titles.add('Object');
      case 'addressee':
        titles.add('Addressee');
      case 'companion':
        titles.add('Companion');
      case 'instrument':
        titles.add('Instrument');
      case 'destination':
        titles.add('Destination');
      case 'topic':
        titles.add('Topic');
      case 'beneficiary':
        titles.add('Beneficiary');
      case 'source':
        titles.add('Source');
      case 'at-location':
      case 'in-location':
      case 'on-location':
      case 'from-location':
        break;
      case 'right-action':
        titles.add('Right action');
      case 'right-particle':
        titles.add('Right particle');
      case 'complement':
        titles.addAll(['Noun complement', 'Adjective complement']);
      case 'place':
        break;
      case 'time':
        titles.add('Time phrase');
      case 'frequency':
        titles.add('Frequency phrase');
      case 'manner':
        titles.add('Manner phrase');
      case 'recipient':
      case 'object-complement':
        break;
    }
  }

  if (locationConnectors.length > 1) {
    titles.add('Location');
  } else if (locationConnectors.length == 1) {
    final connector = locationConnectors.single;
    titles.add(
      '${connector[0].toUpperCase()}${connector.substring(1)} location',
    );
  }

  if (sourceLocationConnectors.isNotEmpty) {
    titles.add('Source place');
  }

  return titles;
}

bool _isImmediatelyReachableInfluence(Verb verb, String key) {
  final kinds = _pathKindsForInfluenceKey(key);
  if (kinds == null) {
    return true;
  }

  final paths = predicatePathsFor(
    verb,
  ).where((path) => kinds.contains(path.kind));
  var hasAuthoredPath = false;
  for (final path in paths) {
    hasAuthoredPath = true;
    if (!path.requiresObject && !path.requiresRecipient) {
      return true;
    }
  }

  return !hasAuthoredPath;
}

List<PredicatePathKind>? _pathKindsForInfluenceKey(String key) {
  return switch (key) {
    'addressee' => const [PredicatePathKind.toAddressee],
    'companion' => const [PredicatePathKind.withCompanion],
    'instrument' => const [PredicatePathKind.withInstrument],
    'destination' => const [PredicatePathKind.toDestination],
    'topic' => predicateTopicPathKinds,
    'beneficiary' => const [PredicatePathKind.forBeneficiary],
    'source' => const [PredicatePathKind.fromSource],
    'right-action' => const [PredicatePathKind.toRightAction],
    'right-particle' => const [PredicatePathKind.rightParticle],
    _ => null,
  };
}

List<String> _immediateLocationConnectorsFor(Verb verb) {
  return [
    for (final kind in predicateLocationPathKinds)
      if (_hasImmediatePath(verb, kind)) predicatePlaceConnectorFor(kind)!,
  ];
}

List<String> _immediateSourceLocationConnectorsFor(Verb verb) {
  return [
    for (final kind in predicateSourceLocationPathKinds)
      if (_hasImmediatePath(verb, kind)) predicatePlaceConnectorFor(kind)!,
  ];
}

bool _hasImmediatePath(Verb verb, PredicatePathKind kind) {
  return predicatePathsFor(verb).any(
    (path) =>
        path.kind == kind && !path.requiresObject && !path.requiresRecipient,
  );
}
