import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/screens/home_screen.dart';

void main() {
  final mainScroll = find
      .descendant(
        of: find.byKey(const Key('main-scroll')),
        matching: find.byType(Scrollable),
      )
      .first;

  test(
    'object number family key keeps singular and plural variants together',
    () {
      expect(objectNumberFamilyKey('bridges'), objectNumberFamilyKey('bridge'));
      expect(objectNumberFamilyKey('houses'), objectNumberFamilyKey('house'));
      expect(objectNumberFamilyKey('classes'), objectNumberFamilyKey('class'));
      expect(objectNumberFamilyKey('boxes'), objectNumberFamilyKey('box'));
      expect(
        objectNumberFamilyKey('potatoes'),
        objectNumberFamilyKey('potato'),
      );
      expect(objectNumberFamilyKey('books'), objectNumberFamilyKey('book'));
    },
  );

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

  Future<void> filterRail(
    WidgetTester tester,
    String railTitle,
    String query,
  ) async {
    await tester.enterText(find.byKey(Key('rail-search-$railTitle')), query);
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

  bool appearsBefore(WidgetTester tester, Finder left, Finder right) {
    final leftOffset = tester.getTopLeft(left);
    final rightOffset = tester.getTopLeft(right);

    if ((leftOffset.dy - rightOffset.dy).abs() < 1) {
      return leftOffset.dx < rightOffset.dx;
    }

    return leftOffset.dy < rightOffset.dy;
  }

  List<String> highlightedTextForTooltip(WidgetTester tester, String tooltip) {
    final selectableTexts = find
        .descendant(
          of: find.byTooltip(tooltip),
          matching: find.byType(SelectableText),
        )
        .evaluate()
        .map((element) => element.widget)
        .cast<SelectableText>();

    for (final selectableText in selectableTexts) {
      final textSpan =
          selectableText.textSpan ?? TextSpan(text: selectableText.data);
      final highlighted = _textSpans(textSpan)
          .where((span) => span.style?.backgroundColor != null)
          .map((span) => span.text ?? '')
          .toList();

      if (highlighted.isNotEmpty) {
        return highlighted;
      }
    }

    final richTexts = find
        .descendant(
          of: find.byTooltip(tooltip),
          matching: find.byType(RichText),
        )
        .evaluate()
        .map((element) => element.widget)
        .cast<RichText>();

    final richText = richTexts.firstWhere(
      (richText) => _textSpans(
        richText.text,
      ).any((span) => span.style?.backgroundColor != null),
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
    expect(find.text('Padlock Developer Console'), findsOneWidget);
    expect(find.byKey(const Key('app-footer-brand')), findsOneWidget);
    expect(find.text('Logos Dynamics 2026'), findsOneWidget);
    expect(find.text('Verb:'), findsOneWidget);
    expect(find.text('Verb'), findsNothing);
    expect(find.byTooltip('Current: You learn.'), findsWidgets);
    expect(find.byType(SelectableText), findsWidgets);

    await tapAfterScroll(tester, find.byTooltip('You give.'));
    await tester.drag(mainScroll, const Offset(0, 1000));
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), 'You give.');
    expect(find.text('Move trace'), findsOneWidget);
    expect(find.textContaining('verb -> give'), findsOneWidget);
  });

  testWidgets('Top controls expose guided form choices only', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Form'), findsOneWidget);
    expect(find.text('statement'), findsOneWidget);
    expect(find.text('question'), findsOneWidget);
    expect(find.text('exclamation'), findsOneWidget);
    expect(find.text('imperative'), findsOneWidget);
    expect(find.text('Full cache'), findsOneWidget);
    expect(find.text('Bounded'), findsOneWidget);
    expect(find.text('Preview cache'), findsOneWidget);
    expect(find.byKey(const Key('preview-cache-size')), findsOneWidget);
    expect(find.byKey(const Key('wipe-preview-cache-button')), findsOneWidget);
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
    expect(find.text('Language alert'), findsOneWidget);
    expect(find.text('2 signals'), findsOneWidget);
    expect(find.text('verb predicate frame type violation'), findsOneWidget);
    expect(find.text('passive configuration shape violation'), findsOneWidget);
    expect(find.text('work cannot be passive in this frame.'), findsOneWidget);
    expect(
      find.text('Passive object focus requires an object.'),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SelectableText &&
            widget.data == 'work cannot be passive in this frame.',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SelectableText &&
            widget.data == 'Passive object focus requires an object.',
      ),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        const ConfigurationMessage.blocked(
          'work cannot be passive in this frame.',
        ).tooltip,
      ),
      findsOneWidget,
    );
    expect(find.text('Move trace'), findsOneWidget);
    expect(find.textContaining('voice -> passive'), findsOneWidget);
    expect(find.textContaining('kept You work.'), findsOneWidget);
  });

  testWidgets('Move trace records moves and reset clears the route', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Move trace'), findsOneWidget);
    expect(find.text('0 moves'), findsOneWidget);
    expect(find.text('No moves since reset.'), findsOneWidget);

    await tapAfterScroll(tester, find.byTooltip('You give.'));
    await expandRail(tester, 'Object');
    await tapAfterScroll(tester, find.byTooltip('You give book.'));

    expect(find.text('Move trace'), findsOneWidget);
    expect(find.byKey(const Key('move-trace-text')), findsOneWidget);
    expect(find.text('2 moves'), findsOneWidget);
    expect(find.textContaining('verb -> give'), findsOneWidget);
    expect(find.textContaining('object -> book'), findsOneWidget);
    expect(
      find.textContaining(
        RegExp(r'\[(accepted|blocked), logic (<1|\d+) ms, ui (<1|\d+) ms\]'),
      ),
      findsWidgets,
    );

    for (var index = 0; index < 9; index++) {
      await pressOutlinedText(tester, index.isEven ? 'past' : 'present');
    }

    expect(find.text('10 moves'), findsOneWidget);

    await tapVisible(tester, find.byTooltip('Reset'));
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), 'You learn.');
    expect(find.text('Move trace'), findsOneWidget);
    expect(find.text('1 move'), findsOneWidget);
    expect(find.textContaining('reset | You learn.'), findsOneWidget);
  });

  testWidgets('Diagnostics bar collapses while keeping latest move visible', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapAfterScroll(tester, find.byTooltip('You give.'));

    expect(find.text('Move trace'), findsOneWidget);
    expect(find.textContaining('verb -> give'), findsWidgets);

    await tester.tap(find.byTooltip('Collapse diagnostics bar'));
    await tester.pumpAndSettle();

    expect(find.text('Move trace'), findsNothing);
    final alertCount = tester.widget<Text>(
      find.byKey(const Key('diagnostics-collapsed-alert-count')),
    );
    expect(alertCount.data, startsWith('Language alert '));
    expect(
      find.byKey(const Key('diagnostics-collapsed-move-text')),
      findsOneWidget,
    );
    expect(find.textContaining('verb -> give'), findsOneWidget);

    await tester.tap(find.byTooltip('Expand diagnostics bar'));
    await tester.pumpAndSettle();

    expect(find.text('Move trace'), findsOneWidget);
  });

  testWidgets('Translate button toggles the header sentence', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(renderedSentence(tester), 'You learn.');
    final translated = tester
        .widget<SelectableText>(find.byKey(const Key('translation-gloss')))
        .data!;
    expect(translated, startsWith('(Ty) '));
    expect(translated, endsWith('.)'));
    expect(find.byTooltip('Hide sentence translation'), findsOneWidget);

    await tapVisible(tester, find.byTooltip('Hide sentence translation'));

    expect(renderedSentence(tester), 'You learn.');
    expect(find.byKey(const Key('translation-gloss')), findsNothing);

    await tapVisible(tester, find.byTooltip('Translate sentence'));

    expect(find.byKey(const Key('translation-gloss')), findsOneWidget);
  });

  testWidgets(
    'Translate verbs button toggles Polish verb glosses on verb chips',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.byTooltip('Translate verbs'), findsOneWidget);
      expect(find.text('(uczyć się)'), findsNothing);

      await tapVisible(tester, find.byTooltip('Translate verbs'));

      expect(find.byTooltip('Hide verb translations'), findsOneWidget);
      expect(find.text('(uczyć się)'), findsWidgets);

      await tapVisible(tester, find.byTooltip('Hide verb translations'));

      expect(find.byTooltip('Translate verbs'), findsOneWidget);
      expect(find.text('(uczyć się)'), findsNothing);
    },
  );

  testWidgets('Dark mode toggles the developer console theme', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.byTooltip('Dark mode'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.light,
    );

    await tapVisible(tester, find.byTooltip('Dark mode'));

    expect(find.byTooltip('Light mode'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );

    await tapVisible(tester, find.byTooltip('Light mode'));

    expect(find.byTooltip('Dark mode'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.light,
    );
  });

  testWidgets('Guided UI opens right action rail from a verb that wakes it', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapAfterScroll(tester, find.byTooltip('You want.'));
    await expandRail(tester, 'Right action');
    await tapAfterScroll(tester, find.byTooltip('You want to go.'));

    expect(renderedSentence(tester), 'You want to go.');

    final translated = tester
        .widget<SelectableText>(find.byKey(const Key('translation-gloss')))
        .data!;
    expect(translated, contains('(do)'));
    expect(translated, endsWith('.)'));
  });

  testWidgets('Guided UI can exit lexical be through verb suggestions', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapAfterScroll(tester, find.byTooltip('You are.'));

    await expandRail(tester, 'Adjective complement');
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

  testWidgets('Suggestion display mode keeps only change and word chips', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Sentence'), findsNothing);
    expect(find.text('Change'), findsOneWidget);
    expect(find.text('Word'), findsOneWidget);

    await tapVisible(tester, find.text('Word'));

    expect(find.text('give', findRichText: true), findsOneWidget);
    expect(find.text('You give.'), findsNothing);
  });

  testWidgets('Suggestion chips expose selectable text labels', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    final teachLabel = tester.widget<Text>(
      find.byKey(const Key('suggestion-label-action-teach')),
    );

    expect(
      teachLabel.data ?? teachLabel.textSpan?.toPlainText(),
      contains('teach'),
    );
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

  testWidgets(
    'Portrait rails expand into the page instead of tiny rail scrolls',
    (tester) async {
      tester.view.physicalSize = const Size(430, 930);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();

      final verbRailSize = tester.getSize(
        find.byKey(const ValueKey('section-frame-Verb')),
      );

      expect(verbRailSize.height, greaterThan(300));
    },
  );

  testWidgets('Wide verb rail expands into the page for full vocabulary', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(2048, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    final verbRailSize = tester.getSize(
      find.byKey(const ValueKey('section-frame-Verb')),
    );

    expect(verbRailSize.height, greaterThan(300));
  });

  testWidgets(
    'Verb rail hydrates late vocabulary without a show-more control',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('suggestion-label-action-practice')),
        findsOneWidget,
      );
      expect(
        find.textContaining('show more', findRichText: true),
        findsNothing,
      );
    },
  );

  testWidgets(
    'Guided Mode hides broad phrase rails until authored routes wake them',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(renderedSentence(tester), 'You learn.');
      await tapAfterScroll(
        tester,
        find.byKey(const Key('suggestion-label-action-want')),
      );

      expect(renderedSentence(tester), 'You want.');
      expect(find.text('Place phrase:'), findsNothing);
      expect(find.text('Manner phrase:'), findsNothing);
      expect(find.text('Time phrase:'), findsOneWidget);

      await tapAfterScroll(
        tester,
        find.byKey(const Key('suggestion-label-action-go')),
      );

      expect(renderedSentence(tester), 'You go.');
      expect(find.text('Place phrase:'), findsOneWidget);
      expect(find.text('Manner phrase:'), findsOneWidget);
    },
  );

  testWidgets(
    'Rail policy follows a procedural route across predicate frames',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(renderedSentence(tester), 'You learn.');
      expect(find.text('Subject:'), findsOneWidget);
      expect(find.text('Right action:'), findsOneWidget);
      expect(find.text('Object determiner:'), findsNothing);
      expect(find.text('By-agent:'), findsNothing);

      await tapAfterScroll(tester, find.byTooltip('You want.'));

      expect(find.text('Right action:'), findsOneWidget);
      await expandRail(tester, 'Right action');
      await tapAfterScroll(tester, find.byTooltip('You want to go.'));
      expect(renderedSentence(tester), 'You want to go.');

      await tapVisible(tester, find.text('Word'));
      await tapAfterScroll(
        tester,
        find.text('no right action', findRichText: true),
      );
      expect(renderedSentence(tester), 'You want.');

      await tapAfterScroll(
        tester,
        find.byKey(const Key('suggestion-label-action-give')),
      );

      expect(renderedSentence(tester), 'You give.');
      expect(find.text('Object:'), findsOneWidget);
      expect(find.text('Recipient:'), findsNothing);
      expect(find.text('Right action:'), findsNothing);
      expect(find.text('Object determiner:'), findsNothing);

      await expandRail(tester, 'Object');
      await tapAfterScroll(
        tester,
        find.byKey(const Key('suggestion-label-object-book')),
      );

      expect(renderedSentence(tester), 'You give book.');
      expect(find.text('Object determiner:'), findsOneWidget);
      expect(find.text('Object adjective:'), findsOneWidget);
      expect(find.text('Recipient:'), findsOneWidget);

      await tapAfterScroll(tester, find.text('passive'));

      expect(renderedSentence(tester), 'Book is given by you.');
      expect(find.text('By-agent:'), findsOneWidget);

      await tapAfterScroll(
        tester,
        find.text('hide by-agent', findRichText: true),
      );
      expect(renderedSentence(tester), 'Book is given.');
      expect(find.text('By-agent:'), findsOneWidget);

      await tapVisible(tester, find.text('Word'));
      await expandRail(tester, 'By-agent');
      await tapAfterScroll(tester, find.text('Mary', findRichText: true));
      await tapAfterScroll(
        tester,
        find.text('show by-agent', findRichText: true),
      );
      expect(renderedSentence(tester), 'Book is given by Mary.');

      await tapAfterScroll(
        tester,
        find.byKey(const Key('suggestion-label-action-be')),
      );

      expect(renderedSentence(tester), 'Mary is.');
      expect(find.text('Noun complement:'), findsOneWidget);
      expect(find.text('Adjective complement:'), findsOneWidget);
      expect(find.text('By-agent:'), findsNothing);
      expect(find.text('Recipient:'), findsNothing);
    },
  );

  testWidgets(
    'Rail policy keeps hidden passive by-agent reachable across predicate changes',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      await tapVisible(tester, find.text('Word'));
      await filterRail(tester, 'Verb', 'introduce');
      await tapAfterScroll(
        tester,
        find.byKey(const Key('suggestion-label-action-introduce')),
      );
      await expandRail(tester, 'Addressee');
      await filterRail(tester, 'Addressee', 'teacher');
      await tapAfterScroll(
        tester,
        find.byKey(const Key('suggestion-label-addressee-teacher')),
      );
      expect(renderedSentence(tester), 'You introduce to teacher.');

      await expandRail(tester, 'Addressee determiner');
      await tapAfterScroll(tester, find.text('a', findRichText: true));
      expect(renderedSentence(tester), 'You introduce to a teacher.');

      await expandRail(tester, 'Object');
      await tapAfterScroll(tester, find.text('dog', findRichText: true));
      expect(renderedSentence(tester), 'You introduce dog to a teacher.');

      await tapAfterScroll(tester, find.text('passive'));
      expect(
        renderedSentence(tester),
        'Dog is introduced to a teacher by you.',
      );

      await tapAfterScroll(
        tester,
        find.text('hide by-agent', findRichText: true),
      );
      expect(renderedSentence(tester), 'Dog is introduced to a teacher.');
      expect(find.text('By-agent:'), findsOneWidget);

      await tapAfterScroll(tester, find.text('future'));
      expect(renderedSentence(tester), 'Dog will be introduced to a teacher.');
      expect(find.text('By-agent:'), findsOneWidget);

      await tapAfterScroll(
        tester,
        find.text('no determiner', findRichText: true),
      );
      expect(renderedSentence(tester), 'Dog will be introduced to teacher.');

      await tapAfterScroll(tester, find.text('this', findRichText: true));
      expect(
        renderedSentence(tester),
        'Dog will be introduced to this teacher.',
      );
      expect(find.text('By-agent:'), findsOneWidget);

      await filterRail(tester, 'Verb', 'see');
      await tapAfterScroll(
        tester,
        find.byKey(const Key('suggestion-label-action-see')),
      );
      expect(renderedSentence(tester), 'Dog will be seen.');
      expect(find.text('By-agent:'), findsOneWidget);

      await expandRail(tester, 'Object');
      await tapAfterScroll(tester, find.text('cat', findRichText: true));
      expect(renderedSentence(tester), 'Cat will be seen.');
      expect(find.text('By-agent:'), findsOneWidget);

      await expandRail(tester, 'By-agent');
      await tapAfterScroll(
        tester,
        find.byKey(const Key('suggestion-label-passiveAgentNoun-mary')),
      );
      await tapAfterScroll(
        tester,
        find.text('show by-agent', findRichText: true),
      );

      expect(renderedSentence(tester), 'Cat will be seen by Mary.');
    },
  );

  testWidgets(
    'Rail policy old bread-to-cat route marks future semantic filtering',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      await tapVisible(tester, find.text('Word'));
      await tapAfterScroll(
        tester,
        find.byKey(const Key('suggestion-label-action-introduce')),
      );
      await expandRail(tester, 'Addressee');
      await tapAfterScroll(tester, find.text('a cat', findRichText: true));
      expect(renderedSentence(tester), 'You introduce to a cat.');

      await expandRail(tester, 'Object');
      await tapAfterScroll(tester, find.text('bread', findRichText: true));
      expect(renderedSentence(tester), 'You introduce bread to a cat.');

      await tapAfterScroll(tester, find.text('passive'));
      expect(renderedSentence(tester), 'Bread is introduced to a cat by you.');

      await tapAfterScroll(
        tester,
        find.text('hide by-agent', findRichText: true),
      );
      expect(renderedSentence(tester), 'Bread is introduced to a cat.');
      expect(find.text('By-agent:'), findsOneWidget);

      await tapAfterScroll(tester, find.text('future'));
      expect(renderedSentence(tester), 'Bread will be introduced to a cat.');
      expect(find.text('By-agent:'), findsOneWidget);

      await expandRail(tester, 'Addressee determiner');
      await tapAfterScroll(
        tester,
        find.text('no determiner', findRichText: true),
      );
      expect(renderedSentence(tester), 'Bread will be introduced to cat.');

      await tapAfterScroll(tester, find.text('this', findRichText: true));
      expect(renderedSentence(tester), 'Bread will be introduced to this cat.');
      expect(find.text('By-agent:'), findsOneWidget);

      await tapAfterScroll(
        tester,
        find.byKey(const Key('suggestion-label-action-see')),
      );
      expect(renderedSentence(tester), 'Bread will be seen.');
      expect(find.text('By-agent:'), findsOneWidget);

      await expandRail(tester, 'Object');
      await tapAfterScroll(tester, find.text('cat', findRichText: true));
      expect(renderedSentence(tester), 'Cat will be seen.');
      expect(find.text('By-agent:'), findsOneWidget);

      await expandRail(tester, 'By-agent');
      await tapAfterScroll(tester, find.text('Mary', findRichText: true));
      await tapAfterScroll(
        tester,
        find.text('show by-agent', findRichText: true),
      );

      expect(renderedSentence(tester), 'Cat will be seen by Mary.');
    },
    // Future semantic filtering should block or downgrade introducing bread to a cat.
    skip: true,
  );

  testWidgets(
    'Rail policy keeps filled object recipient and right-action layers reachable',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      await tapVisible(tester, find.text('Word'));
      await tapAfterScroll(
        tester,
        find.byKey(const Key('suggestion-label-action-give')),
      );
      expect(find.text('Object:'), findsOneWidget);
      expect(find.text('Recipient:'), findsNothing);

      await expandRail(tester, 'Object');
      await tapAfterScroll(
        tester,
        find.byKey(const Key('suggestion-label-object-book')),
      );
      expect(renderedSentence(tester), 'You give book.');
      expect(find.text('Object determiner:'), findsOneWidget);
      expect(find.text('Object adjective:'), findsOneWidget);
      expect(find.text('Recipient:'), findsOneWidget);

      await expandRail(tester, 'Object determiner');
      await tapAfterScroll(tester, find.text('a', findRichText: true));
      expect(renderedSentence(tester), 'You give a book.');
      expect(find.text('Object:'), findsOneWidget);
      expect(find.text('Object determiner:'), findsOneWidget);

      await expandRail(tester, 'Recipient');
      await tapAfterScroll(tester, find.text('teacher', findRichText: true));
      expect(renderedSentence(tester), 'You give teacher a book.');
      expect(find.text('Recipient determiner:'), findsOneWidget);
      expect(find.text('Recipient adjective:'), findsOneWidget);

      await expandRail(tester, 'Recipient adjective');
      await tapAfterScroll(tester, find.text('happy', findRichText: true));
      expect(renderedSentence(tester), 'You give happy teacher a book.');
      expect(find.text('Recipient:'), findsOneWidget);
      expect(find.text('Recipient adjective:'), findsOneWidget);

      await tapVisible(tester, find.byTooltip('Reset'));
      expect(renderedSentence(tester), 'You learn.');

      await tapAfterScroll(
        tester,
        find.byKey(const Key('suggestion-label-action-want')),
      );
      expect(renderedSentence(tester), 'You want.');
      expect(find.text('Right action:'), findsOneWidget);

      await expandRail(tester, 'Right action');
      await tapAfterScroll(
        tester,
        find.byKey(const Key('suggestion-label-rightAction-learn')),
      );

      expect(renderedSentence(tester), 'You want to learn.');
      expect(find.text('Right action:'), findsOneWidget);
    },
  );

  testWidgets('Right action opens its owned object and companion rails', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));
    await expandRail(tester, 'Right action');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-rightAction-speak')),
    );

    expect(renderedSentence(tester), 'You learn to speak.');
    expect(find.text('Language:'), findsOneWidget);
    expect(find.text('Companion:'), findsOneWidget);

    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-object-english')),
    );
    expect(renderedSentence(tester), 'You learn to speak English.');

    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-companion-anyone')),
    );
    expect(renderedSentence(tester), 'You learn to speak English with anyone.');
  });

  testWidgets('Guided UI can switch main verb by shaving right-action tail', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));
    await expandRail(tester, 'Right action');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-rightAction-speak')),
    );
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-object-english')),
    );
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-companion-anyone')),
    );

    expect(renderedSentence(tester), 'You learn to speak English with anyone.');

    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-action-build')),
    );

    expect(renderedSentence(tester), 'You build.');
    expect(find.textContaining('right action -> none'), findsNothing);
  });

  testWidgets('Guided UI shaves right-action tail but keeps compatible rails', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));
    await expandRail(tester, 'Right action');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-rightAction-speak')),
    );
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-object-english')),
    );
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-companion-anyone')),
    );

    expect(renderedSentence(tester), 'You learn to speak English with anyone.');

    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-action-teach')),
    );

    expect(renderedSentence(tester), 'You teach English with anyone.');
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

  testWidgets('Change preview highlights whole changed words', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapAfterScroll(tester, find.byTooltip('You give.'));
    await expandRail(tester, 'Object');
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
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-action-give')),
    );
    await expandRail(tester, 'Object');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-object-book')),
    );
    await expandRail(tester, 'Recipient');
    await tapAfterScroll(tester, find.text('Mary', findRichText: true));
    await tapAfterScroll(tester, find.text('passive'));

    expect(renderedSentence(tester), 'Book is given to Mary by you.');

    await tapAfterScroll(tester, find.byTooltip('recipient'));
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
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-action-give')),
    );
    await expandRail(tester, 'Object');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-object-book')),
    );
    await expandRail(tester, 'Recipient');
    await tapAfterScroll(tester, find.text('him', findRichText: true));
    await tapAfterScroll(tester, find.text('past'));
    await tapAfterScroll(tester, find.text('passive'));

    expect(renderedSentence(tester), 'Book was given to him by you.');
    final showByAgent = find.text('show by-agent', findRichText: true);
    final hideByAgent = find.text('hide by-agent', findRichText: true);
    expect(showByAgent, findsOneWidget);
    expect(hideByAgent, findsOneWidget);
    expect(appearsBefore(tester, showByAgent, hideByAgent), isTrue);

    await tapAfterScroll(
      tester,
      find.text('hide by-agent', findRichText: true),
    );
    expect(appearsBefore(tester, showByAgent, hideByAgent), isTrue);

    expect(renderedSentence(tester), 'Book was given to him.');
  });

  testWidgets('Passive by-agent rail can change hidden remembered agent', (
    tester,
  ) async {
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
    await tapAfterScroll(tester, find.text('past'));
    await tapAfterScroll(tester, find.text('passive'));

    expect(renderedSentence(tester), 'Book was given by you.');

    await tapAfterScroll(
      tester,
      find.text('hide by-agent', findRichText: true),
    );
    expect(renderedSentence(tester), 'Book was given.');

    await expandRail(tester, 'By-agent');
    await tapAfterScroll(tester, find.text('Mary', findRichText: true));
    expect(renderedSentence(tester), 'Book was given.');

    await tapAfterScroll(
      tester,
      find.text('show by-agent', findRichText: true),
    );
    expect(renderedSentence(tester), 'Book was given by Mary.');
  });

  testWidgets(
    'Active voice restores subject-form pronoun from hidden passive by-agent',
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
      await tapAfterScroll(tester, find.text('past'));
      await tapAfterScroll(tester, find.text('passive'));

      expect(renderedSentence(tester), 'Book was given by you.');

      await tapAfterScroll(
        tester,
        find.text('hide by-agent', findRichText: true),
      );
      await expandRail(tester, 'By-agent');
      await tapAfterScroll(tester, find.text('me', findRichText: true));
      await tapAfterScroll(tester, find.text('active'));

      expect(renderedSentence(tester), 'I gave book.');
    },
  );

  testWidgets('Recipient rail can clear optional passive to phrase', (
    tester,
  ) async {
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
    await expandRail(tester, 'Recipient');
    await tapAfterScroll(tester, find.text('him', findRichText: true));
    await tapAfterScroll(tester, find.text('past'));
    await tapAfterScroll(tester, find.text('passive'));

    expect(renderedSentence(tester), 'Book was given to him by you.');

    await tapAfterScroll(tester, find.text('no recipient', findRichText: true));

    expect(renderedSentence(tester), 'Book was given by you.');
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

    final giveSuggestion = find.byTooltip('give');
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

    await tapVisible(tester, find.byTooltip('Random sentence'));

    expect(renderedSentence(tester), isNotEmpty);
    expect(renderedSentence(tester).endsWith('.'), isTrue);
    expect(find.text('Move trace'), findsOneWidget);
    expect(find.textContaining('random sentence'), findsOneWidget);
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
