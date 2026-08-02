import 'package:padlock_app/models/language.dart';

enum AdjectiveOrder {
  opinion,
  size,
  age,
  condition,
  color,
  origin,
  material,
  purpose,
  other,
}

class Adjective {
  final String text;

  final AdjectiveOrder order;

  final Map<Language, String> translations;

  const Adjective({
    required this.text,
    this.order = AdjectiveOrder.other,
    required this.translations,
  });

  AdjectiveOrder get canonicalOrder =>
      order == AdjectiveOrder.other ? _orderByText[text] ?? order : order;
}

List<Adjective> orderAdjectives(Iterable<Adjective> adjectives) {
  final indexed = <({Adjective adjective, int index})>[];
  var index = 0;

  for (final adjective in adjectives) {
    indexed.add((adjective: adjective, index: index));
    index++;
  }

  indexed.sort((left, right) {
    final orderComparison = left.adjective.canonicalOrder.index.compareTo(
      right.adjective.canonicalOrder.index,
    );

    if (orderComparison != 0) {
      return orderComparison;
    }

    return left.index.compareTo(right.index);
  });

  return [for (final entry in indexed) entry.adjective];
}

const _orderByText = {
  'beautiful': AdjectiveOrder.opinion,
  'ugly': AdjectiveOrder.opinion,
  'handsome': AdjectiveOrder.opinion,
  'pretty': AdjectiveOrder.opinion,
  'good': AdjectiveOrder.opinion,
  'bad': AdjectiveOrder.opinion,
  'fast': AdjectiveOrder.opinion,
  'slow': AdjectiveOrder.opinion,
  'strong': AdjectiveOrder.opinion,
  'weak': AdjectiveOrder.opinion,
  'big': AdjectiveOrder.size,
  'small': AdjectiveOrder.size,
  'large': AdjectiveOrder.size,
  'little': AdjectiveOrder.size,
  'tall': AdjectiveOrder.size,
  'short': AdjectiveOrder.size,
  'long': AdjectiveOrder.size,
  'new': AdjectiveOrder.age,
  'old': AdjectiveOrder.age,
  'young': AdjectiveOrder.age,
  'clean': AdjectiveOrder.condition,
  'dirty': AdjectiveOrder.condition,
  'wet': AdjectiveOrder.condition,
  'dry': AdjectiveOrder.condition,
  'happy': AdjectiveOrder.condition,
  'sad': AdjectiveOrder.condition,
  'angry': AdjectiveOrder.condition,
  'calm': AdjectiveOrder.condition,
  'tired': AdjectiveOrder.condition,
  'hungry': AdjectiveOrder.condition,
  'thirsty': AdjectiveOrder.condition,
  'full': AdjectiveOrder.condition,
  'free': AdjectiveOrder.condition,
  'ready': AdjectiveOrder.condition,
  'late': AdjectiveOrder.condition,
  'hot': AdjectiveOrder.condition,
  'cold': AdjectiveOrder.condition,
  'warm': AdjectiveOrder.condition,
  'cool': AdjectiveOrder.condition,
  'sunny': AdjectiveOrder.condition,
  'rainy': AdjectiveOrder.condition,
  'cloudy': AdjectiveOrder.condition,
  'windy': AdjectiveOrder.condition,
  'black': AdjectiveOrder.color,
  'white': AdjectiveOrder.color,
  'red': AdjectiveOrder.color,
  'blue': AdjectiveOrder.color,
  'green': AdjectiveOrder.color,
  'yellow': AdjectiveOrder.color,
  'brown': AdjectiveOrder.color,
  'grey': AdjectiveOrder.color,
};
