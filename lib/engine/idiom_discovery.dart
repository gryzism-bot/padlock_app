import 'package:padlock_app/engine/idiom_finder.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

class IdiomDiscovery {
  final IdiomFinder finder;
  Set<String> _foundIds;

  IdiomDiscovery({
    this.finder = const IdiomFinder(),
    Iterable<String> foundIds = const [],
  }) : _foundIds = {...foundIds};

  int get total => finder.total;
  int get foundCount => _foundIds.length;
  Set<String> get foundIds => Set.unmodifiable(_foundIds);

  List<IdiomMatch> record(SentenceState state) {
    final matches = finder.find(state);
    final newlyFound = [
      for (final match in matches)
        if (!_foundIds.contains(match.pattern.id)) match,
    ];

    if (newlyFound.isNotEmpty) {
      _foundIds = {
        ..._foundIds,
        for (final match in newlyFound) match.pattern.id,
      };
    }

    return newlyFound;
  }
}
