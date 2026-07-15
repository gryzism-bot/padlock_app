import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/data/predicate/verb_influence.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/engine/configuration_engine.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
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
    await tester.tap(finder);
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

  Future<void> runFixedRailRoute(
    WidgetTester tester,
    _FixedRailRoute route,
  ) async {
    await tapVisible(tester, find.byTooltip('Reset'));
    await tapVisible(tester, find.text('Word'));

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
    expect(find.text('Padlock Guided Mode'), findsOneWidget);
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

    expect(find.text('Move trace'), findsNothing);

    await tapAfterScroll(tester, find.byTooltip('You give.'));
    await expandRail(tester, 'Object');
    await tapAfterScroll(tester, find.byTooltip('You give book.'));

    expect(find.text('Move trace'), findsOneWidget);
    expect(find.byKey(const Key('move-trace-text')), findsOneWidget);
    expect(find.text('2 moves'), findsOneWidget);
    expect(find.textContaining('verb -> give'), findsOneWidget);
    expect(find.textContaining('object -> book'), findsOneWidget);
    expect(
      find.textContaining(RegExp(r'\[(accepted|blocked), (<1|\d+) ms\]')),
      findsWidgets,
    );

    for (var index = 0; index < 9; index++) {
      await pressOutlinedText(tester, index.isEven ? 'past' : 'present');
    }

    expect(find.text('10 moves'), findsOneWidget);

    await tester.tap(find.byTooltip('Reset'));
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), 'You learn.');
    expect(find.text('Move trace'), findsNothing);
  });

  testWidgets('Translate button toggles the header sentence', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(renderedSentence(tester), 'You learn.');

    await tester.tap(find.byTooltip('Translate sentence'));
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), 'You learn.');
    final translated = tester
        .widget<SelectableText>(find.byKey(const Key('translation-gloss')))
        .data!;
    expect(translated, startsWith('(Ty) '));
    expect(translated, endsWith('.)'));
    expect(find.byTooltip('Show English sentence'), findsOneWidget);

    await tester.tap(find.byTooltip('Show English sentence'));
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), 'You learn.');
    expect(find.byKey(const Key('translation-gloss')), findsNothing);
  });

  testWidgets('Guided UI opens right action rail from a verb that wakes it', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapAfterScroll(tester, find.byTooltip('You want.'));
    await expandRail(tester, 'Right action');
    await tapAfterScroll(tester, find.byTooltip('You want to go.'));

    expect(renderedSentence(tester), 'You want to go.');

    await tester.tap(find.byTooltip('Translate sentence'));
    await tester.pumpAndSettle();

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

  testWidgets('Suggestion display mode can switch to word chips', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tapVisible(tester, find.text('Word'));

    expect(find.text('give', findRichText: true), findsOneWidget);
    expect(find.text('You give.'), findsNothing);
  });

  testWidgets('Suggestion chips expose selectable text labels', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    final teachLabel = tester.widget<SelectableText>(
      find.byKey(const Key('suggestion-label-action-teach')),
    );

    expect(
      teachLabel.data ?? teachLabel.textSpan?.toPlainText(),
      contains('teach'),
    );
  });

  testWidgets('Verb chips mark predicate extensions they can wake', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.byKey(const Key('verb-wake-be-complement')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-learn-subject')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-play-activity')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-go-destination')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-read-text')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-drive-vehicle')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-give-object')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-give-recipient')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-run-destination')), findsOneWidget);
    expect(find.byTooltip('You catch.'), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-work-object')), findsNothing);
    expect(find.byKey(const Key('verb-wake-work-recipient')), findsNothing);
    expect(find.byKey(const Key('verb-wake-work-complement')), findsNothing);
    expect(find.byKey(const Key('verb-wake-output-be')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-output-give')), findsOneWidget);
    expect(find.byKey(const Key('verb-wake-output-play')), findsOneWidget);

    final giveRecipientIcon = tester.widget<Icon>(
      find
          .descendant(
            of: find.byKey(const Key('verb-wake-give-recipient')),
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
      findsNWidgets(2),
    );
    expect(
      find.byTooltip(
        'give unlocks recipient, object. grammar frame: recipient, object. '
        'It can wake 2 rails.',
      ),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        'read unlocks text. predicate property: text. '
        'It can wake 1 rail.',
      ),
      findsOneWidget,
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

    expect(find.byTooltip('You learn English.'), findsNothing);
    await expandRail(tester, 'Subject');
    expect(find.byTooltip('You learn English.'), findsWidgets);
    expect(find.text('Object determiner:'), findsNothing);
    expect(find.text('Object adjective:'), findsNothing);

    await tapAfterScroll(tester, find.byTooltip('You play.'), delta: -500);

    expect(find.text('Activity:'), findsOneWidget);
    expect(find.byTooltip('You play volleyball.'), findsNothing);
    expect(find.text('Object:'), findsNothing);
    expect(find.text('Object determiner:'), findsNothing);
    expect(find.text('Object adjective:'), findsNothing);

    await expandRail(tester, 'Activity');
    await tapAfterScroll(tester, find.byTooltip('You play volleyball.'));

    expect(renderedSentence(tester), 'You play volleyball.');
    expect(find.text('Activity:'), findsOneWidget);

    await tapAfterScroll(tester, find.byTooltip('You are.'));

    expect(find.text('Noun complement:'), findsOneWidget);
    expect(find.text('Adjective complement:'), findsOneWidget);
    expect(find.text('Object:'), findsNothing);

    await tapAfterScroll(tester, find.byTooltip('You buy.'), delta: -500);

    expect(find.text('Object:'), findsOneWidget);
    expect(find.byTooltip('You buy book.'), findsNothing);
    expect(find.text('Object determiner:'), findsNothing);
    expect(find.text('Object adjective:'), findsNothing);

    await expandRail(tester, 'Object');
    await tapAfterScroll(tester, find.byTooltip('You buy book.'));

    expect(find.text('Object determiner:'), findsOneWidget);
    expect(find.byTooltip('You buy a book.'), findsNothing);
    expect(find.text('Object adjective:'), findsOneWidget);
    expect(find.text('Recipient:'), findsOneWidget);

    await tapAfterScroll(tester, find.byTooltip('You give book.'), delta: -500);

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

  testWidgets('Essential verb chips expose their expected cockpit rails', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tapVisible(tester, find.text('Word'));

    for (final verb in essentialVerbs) {
      await tapVisible(tester, find.byTooltip('Reset'));
      await tapAfterScroll(
        tester,
        find.byKey(Key('suggestion-label-action-${verb.infinitive}')),
      );

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
      find.byKey(const Key('suggestion-label-object-book')),
    );

    expect(renderedSentence(tester), 'You make book.');
    expect(find.text('Object complement:'), findsOneWidget);
    expect(find.text('Object adjective complement:'), findsOneWidget);

    await expandRail(tester, 'Object adjective complement');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-objectAdjectiveComplement-calm')),
    );

    expect(renderedSentence(tester), 'You make book calm.');

    await tapAfterScroll(
      tester,
      find.byKey(
        const Key(
          'suggestion-label-objectAdjectiveComplement-no-object-adjective-complement',
        ),
      ),
    );
    expect(renderedSentence(tester), 'You make book.');

    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-action-call')),
    );
    await expandRail(tester, 'Object');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-object-cat')),
    );
    await expandRail(tester, 'Object complement');
    await tapAfterScroll(
      tester,
      find.byKey(const Key('suggestion-label-objectComplement-a-teacher')),
    );

    expect(renderedSentence(tester), 'You call cat a teacher.');
    expect(find.text('Object complement determiner:'), findsOneWidget);
    expect(find.text('Object complement adjective:'), findsOneWidget);
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

    await tapAfterScroll(tester, find.byTooltip('You give.'));

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
      await tapAfterScroll(
        tester,
        find.byKey(const Key('suggestion-label-action-introduce')),
      );
      await expandRail(tester, 'Addressee');
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

    tester
        .widget<SegmentedButton<Number>>(
          find.byType(SegmentedButton<Number>).last,
        )
        .onSelectionChanged
        ?.call({Number.plural});
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), 'You buy books.');
    expect(find.byKey(const Key('suggestion-label-object-book')), findsNothing);
    expect(
      find.byKey(const Key('suggestion-label-object-books')),
      findsWidgets,
    );

    tester
        .widget<SegmentedButton<Number>>(
          find.byType(SegmentedButton<Number>).last,
        )
        .onSelectionChanged
        ?.call({Number.singular});
    await tester.pumpAndSettle();

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

    tester
        .widget<SegmentedButton<Number>>(
          find.byType(SegmentedButton<Number>).last,
        )
        .onSelectionChanged
        ?.call({Number.plural});
    await tester.pumpAndSettle();

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

    tester
        .widget<SegmentedButton<Number>>(
          find.byType(SegmentedButton<Number>).last,
        )
        .onSelectionChanged
        ?.call({Number.plural});
    await tester.pumpAndSettle();

    expect(find.text('doors', findRichText: true), findsWidgets);
    expect(find.text('door', findRichText: true), findsNothing);

    tester
        .widget<SegmentedButton<Number>>(
          find.byType(SegmentedButton<Number>).last,
        )
        .onSelectionChanged
        ?.call({Number.singular});
    await tester.pumpAndSettle();

    await tapAfterScroll(tester, find.text('door', findRichText: true));
    expect(renderedSentence(tester), 'You close door.');

    tester
        .widget<SegmentedButton<Number>>(
          find.byType(SegmentedButton<Number>).last,
        )
        .onSelectionChanged
        ?.call({Number.plural});
    await tester.pumpAndSettle();

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

    tester
        .widget<SegmentedButton<Number>>(
          find.byType(SegmentedButton<Number>).last,
        )
        .onSelectionChanged
        ?.call({Number.plural});
    await tester.pumpAndSettle();

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

    tester
        .widget<SegmentedButton<Number>>(
          find.byType(SegmentedButton<Number>).last,
        )
        .onSelectionChanged
        ?.call({Number.plural});
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), 'You learn with girls.');
    expect(find.text('girls', findRichText: true), findsWidgets);
    expect(find.text('girl', findRichText: true), findsNothing);

    tester
        .widget<SegmentedButton<Number>>(
          find.byType(SegmentedButton<Number>).last,
        )
        .onSelectionChanged
        ?.call({Number.singular});
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), 'You learn with girl.');
    expect(find.text('girl', findRichText: true), findsWidgets);
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

      tester
          .widget<SegmentedButton<Number>>(
            find.byType(SegmentedButton<Number>).last,
          )
          .onSelectionChanged
          ?.call({Number.plural});
      await tester.pumpAndSettle();

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

      tester
          .widget<SegmentedButton<Number>>(
            find.byType(SegmentedButton<Number>).last,
          )
          .onSelectionChanged
          ?.call({Number.plural});
      await tester.pumpAndSettle();

      expect(find.text('people', findRichText: true), findsWidgets);
      expect(find.text('person', findRichText: true), findsNothing);

      await tapAfterScroll(tester, find.text('people', findRichText: true));

      expect(renderedSentence(tester), 'Book is given by people.');
    },
  );

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

    await tester.tap(find.byTooltip('Random sentence'));
    await tester.pumpAndSettle();

    expect(renderedSentence(tester), isNotEmpty);
    expect(renderedSentence(tester).endsWith('.'), isTrue);
    expect(find.text('Move trace'), findsOneWidget);
    expect(find.textContaining('random sentence'), findsOneWidget);
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

  for (final influence in predicateInfluencesFor(verb)) {
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
      case 'destination':
        titles.add('Destination');
      case 'right-action':
        titles.add('Right action');
      case 'complement':
        titles.addAll(['Noun complement', 'Adjective complement']);
      case 'recipient':
      case 'object-complement':
        break;
    }
  }

  return titles;
}

Iterable<TextSpan> _textSpans(InlineSpan span) sync* {
  if (span is TextSpan) {
    yield span;
    for (final child in span.children ?? const <InlineSpan>[]) {
      yield* _textSpans(child);
    }
  }
}
