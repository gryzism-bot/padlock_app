import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Future SentenceState shape contracts', () {
    test(
      'semi-modal wrappers would distinguish have-to from modal and right-action',
      () {
        fail(
          'Future pressure examples: I have to go. Does he have to go? '
          'He does not have to go. These need a conjugating wrapper, not a '
          'plain Modal and not only rightAction.',
        );
      },
      skip: 'Future SentenceState field candidate: semiModal / verbWrapper.',
    );

    test(
      'lexical be ability wrappers would keep be as wrapper, not predicate be',
      () {
        fail(
          'Future pressure examples: Mary is able to swim. '
          'They are supposed to leave. These are be-based wrappers around an '
          'inferior action, different from Mary is happy.',
        );
      },
      skip:
          'Future SentenceState field candidate: ability/obligation wrapper '
          'over rightAction.',
    );

    test(
      'purpose infinitives would distinguish purpose action from right action',
      () {
        fail(
          'Future pressure examples: Mary ran to exercise. '
          'I listened to understand. These can render today as rightAction, '
          'but a teaching UI may eventually need purposeAction.',
        );
      },
      skip:
          'Future SentenceState field candidate: purposeAction, only if the '
          'product must teach purpose separately from ordinary rightAction.',
    );

    test(
      'right action participants would support separate main and inferior tails',
      () {
        fail(
          'Future pressure example: You learn with Mary to speak English with '
          'Tom. Current SentenceState has one companion/object surface, so it '
          'cannot keep both main-action and right-action participants apart.',
        );
      },
      skip:
          'Future SentenceState shape candidate: scoped rightAction participant '
          'tail, only if dual-scope tails become product-important.',
    );

    test(
      'clause force would distinguish grammatical polarity from semantic negation',
      () {
        fail(
          'Future pressure examples: Nobody buys books anymore. '
          'Everybody buys books anymore. The verb chain is positive in both, '
          'but the clause force is different.',
        );
      },
      skip:
          'Future SentenceState or semantic-layer candidate: clauseForce. '
          'Probably belongs above Grammar Engine unless rendering needs it.',
    );
  });
}
