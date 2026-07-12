import 'package:flutter_test/flutter_test.dart';
import 'package:padlock_app/engine/grammar_engine.dart';
import 'package:padlock_app/engine/recognition_engine.dart';

void main() {
  final grammar = GrammarEngine();
  final recognition = RecognitionEngine();

  void expectSentenceRoundTrip(String sentence) {
    try {
      final recognized = recognition.recognize(sentence);
      final rendered = grammar.generate(recognized).text;

      expect(rendered, sentence, reason: sentence);
    } catch (error, stackTrace) {
      fail('Failed to round-trip "$sentence": $error\n$stackTrace');
    }
  }

  void expectSentenceRoundTrips(List<String> sentences) {
    for (final sentence in sentences) {
      expectSentenceRoundTrip(sentence);
    }
  }

  group('Two-way one-predicate contract', () {
    test('basic rules stay inside the two-way contract', () {
      expectSentenceRoundTrips([
        'I work.',
        'You work.',
        'He works.',
        'She works.',
        'It works.',
        'We work.',
        'They work.',
        'Mary studied yesterday.',
        'The child studies.',
        'The children study.',
        'Does he work?',
        'Did the dog run?',
        'Do the old workers play football?',
        'That car does not work.',
        'Our students did not study yesterday.',
        'No student worked yesterday.',
        'He works!',
        'You run!',
      ]);
    });

    test('tense and aspect stay inside the two-way contract', () {
      expectSentenceRoundTrips([
        'John worked.',
        'John was working.',
        'John has worked.',
        'John has been working.',
        'John will work.',
        'The old worker had built a bridge.',
        'Had the old worker built a bridge?',
        'The new teacher has not learned at work yesterday.',
        'The young student learned at home yesterday.',
        'The beautiful chef will have been working at home.',
        'Will the beautiful chef have been working at home tomorrow?',
        'Had the old workers been building the new bridge yesterday?',
        'The dog was running in the park yesterday.',
        'Cats have been sleeping at home.',
      ]);
    });

    test('modals and need stay inside the two-way contract', () {
      expectSentenceRoundTrips([
        'They should build it.',
        'John cannot play football.',
        'John could work.',
        'Mary would work.',
        'John could have worked.',
        'Might Mary work?',
        'Can the old workers play tennis?',
        'She should study.',
        'Some dogs must work.',
        'Can the beautiful teacher not work at home?',
        'The beautiful chef can learn at work tomorrow.',
        'John needs a book.',
        'John does not need a book.',
        'John need not work.',
        'Need John work?',
      ]);
    });

    test('passive voice stays inside the two-way contract', () {
      expectSentenceRoundTrips([
        'The bridge was built by John.',
        'The bridge was not built by John.',
        'The new bridge will have been built by John.',
        'The new bridge has been being built.',
        'Had the new bridge been being built by the old workers?',
        'Should bridge not be built?',
        'A book was given to her by him.',
        'A book was given to her.',
        'A book was bought for her by him.',
        'A book was bought for her.',
        'She was given a book by him.',
        'Were the old workers given a book by Mary?',
      ]);
    });

    test('core participants stay inside the two-way contract', () {
      expectSentenceRoundTrips([
        'He saw her.',
        'She helped him.',
        'He gave her a book.',
        'He bought her a book.',
        'He gave a book to her.',
        'He bought a book for her.',
        'She could have made the red book for him.',
        'They saw themselves.',
        'I saw myself.',
        'We saw ourselves.',
        'You gave yourself a book.',
        'They bought a gift for themselves.',
        'They made him calm.',
        'They called him a teacher.',
        'He was made calm by them.',
        'John gave the red book to the old teacher.',
        'John sold her a gift.',
        'Mary wrote him a letter.',
        'The teacher taught them a book.',
      ]);
    });

    test('lexical be stays inside the two-way contract', () {
      expectSentenceRoundTrips([
        'John is a doctor.',
        'Mary was happy.',
        'Is the young doctor happy?',
        'Are the old workers happy?',
        'John will be a teacher.',
        'John has been happy.',
        'Mary is being happy.',
        'You can be happy.',
        'John is at school.',
        'Mary has been at home.',
        'Mary should be at home.',
        'She is from Poland.',
        'Czechia is in Europe.',
        'They are with Mary.',
        'They are with a Mary.',
        'Mary should be with him.',
        'Is the teacher in the office?',
        'Be happy.',
        'Do not be happy.',
      ]);
    });

    test('imperatives and sentence forms stay inside the two-way contract', () {
      expectSentenceRoundTrips([
        'Work.',
        'Do not work.',
        'Build the bridge.',
        'Do not build the bridge.',
        'Cook.',
        'Be a doctor.',
        'John works!',
        'These dogs have learned!',
      ]);
    });

    test('noun phrases and phrases stay inside the two-way contract', () {
      expectSentenceRoundTrips([
        'The beautiful teacher has learned at school every day.',
        'The beautiful young woman built a new house yesterday.',
        'The new teacher built a new house yesterday.',
        'The new teacher built a new house.',
        'John has worked at home today.',
        'John came from school.',
        'This teacher will teach at school tomorrow.',
        'Every beautiful student can travel to work every day.',
        'The old bridge has not been built by the young workers.',
        'Always you speak.',
        'Usually John works at home.',
        'John works at home every day.',
        'Mary studied at university on Monday.',
        'John ran with Mary.',
        'John spoke to Mary.',
        'Mary should talk to him.',
        'John wrote to her.',
        'John wrote a letter to Mary.',
        'They work quietly.',
        'John worked with care.',
        'John built a bridge carefully.',
      ]);
    });

    test('populated everyday data stays inside the two-way contract', () {
      expectSentenceRoundTrips([
        'They swam at school yesterday.',
        'The young doctor drove a car yesterday.',
        'Mary left yesterday.',
        'The beautiful woman explored at school.',
        'They played basketball.',
        'The chef ate a plate.',
        'The old worker froze.',
        'The young student understood.',
        'John read a newspaper.',
        'Mary opened the door.',
        'The manager caught the ball.',
        'The student kicked a ball.',
        'The worker lifted the table.',
        'The children slept at home.',
        'The young engineer is working at work now.',
      ]);
    });

    test('essential verb data stays inside the two-way contract', () {
      expectSentenceRoundTrips([
        'John is happy.',
        'John has a book.',
        'John did.',
        'John found a key.',
        'John sang.',
        'John broke.',
        'John began.',
        'John went to school.',
        'Mary came to school.',
        'John got a gift.',
        'John made Mary a gift.',
        'John took a key.',
        'John gave Mary a book.',
        'John knew Mary.',
        'John thought.',
        'John said.',
        'John saw Mary.',
        'John wanted a book.',
        'John needed a book.',
        'John met Mary.',
        'John liked Mary.',
        'John loved Mary.',
        'John worked.',
        'John bought Mary a gift.',
        'John sold a gift.',
        'John used a computer.',
        'John watched television.',
        'John lost a key.',
        'John played football.',
        'John learned English.',
        'John hated Mary.',
        'John remembered Mary.',
        'John slept.',
        'John opened the door.',
        'John closed the door.',
        'John helped Mary.',
        'John read a newspaper.',
      ]);
    });
  });
}
