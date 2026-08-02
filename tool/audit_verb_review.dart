import 'dart:io';

import 'package:padlock_app/data/predicate/predicate_paths.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';

void main(List<String> args) {
  final review = File('zzzreadmes/VERB_REVIEW.md');
  if (!review.existsSync()) {
    throw StateError('Missing ${review.path}');
  }

  final verbByInfinitive = {
    for (final verb in verbs) verb.infinitive.toLowerCase(): verb,
  };
  final rows = _reviewRows(review, verbByInfinitive);
  final missing = [
    for (final row in rows)
      if (!_rowIsReachable(row)) row,
  ];

  print('verb review route audit (${rows.length} rows)');
  print('reachable: ${rows.length - missing.length}');
  print('missing: ${missing.length}');
  print('');

  final byVerb = <String, List<_ReviewRow>>{};
  for (final row in missing) {
    byVerb.putIfAbsent(row.verb.infinitive, () => []).add(row);
  }

  for (final entry in byVerb.entries) {
    print('${entry.key} (${entry.value.length})');
    for (final row in entry.value) {
      print('- ${row.raw}');
      print(
        '  expected: ${row.expectations.map(_expectationLabel).join(' or ')}',
      );
    }
    print('');
  }
}

List<_ReviewRow> _reviewRows(File review, Map<String, Verb> verbByInfinitive) {
  final rows = <_ReviewRow>[];

  for (final line in review.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty ||
        trimmed.startsWith('#') ||
        !trimmed.contains(' - ')) {
      continue;
    }

    final split = trimmed.split(' - ');
    final verb = verbByInfinitive[split.first.toLowerCase()];
    if (verb == null) {
      throw StateError('Unknown reviewed verb: ${split.first}');
    }

    final surface = split.sublist(1).join(' - ').trim();
    rows.add(
      _ReviewRow(
        verb: verb,
        surface: surface,
        raw: trimmed,
        expectations: _expectationsFor(verb, surface),
      ),
    );
  }

  return rows;
}

List<_RouteExpectation> _expectationsFor(Verb verb, String surface) {
  final lower = surface.toLowerCase();
  final cleaned = _cleanNounSurface(lower);

  if (verb.infinitive == 'be') {
    return const [_RouteExpectation.lexicalBe()];
  }

  if (lower.contains(' from someone')) {
    return const [_RouteExpectation(PredicatePathKind.fromSource, null)];
  }

  if (lower == 'for someone' || lower.contains(' for someone')) {
    return const [_RouteExpectation(PredicatePathKind.forBeneficiary, null)];
  }

  final purposeMatch = RegExp(r'\bfor (.+)$').firstMatch(lower);
  if (purposeMatch != null) {
    return [
      _RouteExpectation(
        PredicatePathKind.forPurpose,
        _cleanNounSurface(purposeMatch.group(1)!),
      ),
    ];
  }

  if (lower.contains(' to someone') || lower.startsWith('someone ')) {
    return const [
      _RouteExpectation(PredicatePathKind.toRecipient, null),
      _RouteExpectation(PredicatePathKind.toAddressee, null),
    ];
  }

  if (lower.endsWith(' happy') || lower.endsWith(' calm')) {
    return const [_RouteExpectation.objectComplement()];
  }

  if (_timeSurfaces.contains(lower)) {
    return [_RouteExpectation(PredicatePathKind.timePhrase, lower)];
  }

  if (_mannerSurfaces.contains(lower)) {
    return [_RouteExpectation(PredicatePathKind.mannerPhrase, lower)];
  }

  if (lower.startsWith('to ')) {
    final tail = _cleanNounSurface(lower.substring(3));
    if (tail == 'somewhere') {
      return const [
        _RouteExpectation.place(null, kind: PredicatePathKind.placePhrase),
        _RouteExpectation.place(null, kind: PredicatePathKind.toDestination),
      ];
    }
    if (_barePlaceSurfaces.contains(tail)) {
      return [
        _RouteExpectation(PredicatePathKind.toRightAction, tail),
        _RouteExpectation.place(tail),
      ];
    }
    if (_verbExists(tail)) {
      return [_RouteExpectation(PredicatePathKind.toRightAction, tail)];
    }
    if (tail == 'someone' || tail == 'cat') {
      return [
        _RouteExpectation(PredicatePathKind.toAddressee, tail),
        _RouteExpectation(PredicatePathKind.toDestination, tail),
      ];
    }
    return [
      _RouteExpectation(PredicatePathKind.toAddressee, tail),
      _RouteExpectation.place(tail),
    ];
  }

  if (lower.startsWith('from ')) {
    final tail = _cleanNounSurface(lower.substring(5));
    if (tail == 'someone') {
      return [_RouteExpectation(PredicatePathKind.fromSource, tail)];
    }
    return [
      _RouteExpectation.place(tail, kind: PredicatePathKind.fromLocation),
    ];
  }

  if (lower.startsWith('about ')) {
    return [
      _RouteExpectation(
        PredicatePathKind.aboutTopic,
        _cleanNounSurface(lower.substring(6)),
      ),
    ];
  }

  if (lower.startsWith('of ')) {
    return [
      _RouteExpectation(
        PredicatePathKind.ofTopic,
        _cleanNounSurface(lower.substring(3)),
      ),
    ];
  }

  if (lower.startsWith('on ')) {
    final tail = _cleanNounSurface(lower.substring(3));
    if (_placeLikeSurfaces.contains(tail)) {
      return [
        _RouteExpectation.place(tail, kind: PredicatePathKind.onLocation),
      ];
    }
    return [_RouteExpectation(PredicatePathKind.onTopic, tail)];
  }

  if (lower.startsWith('in ')) {
    return [
      _RouteExpectation.place(
        _cleanNounSurface(lower.substring(3)),
        kind: PredicatePathKind.inLocation,
      ),
    ];
  }

  if (lower.startsWith('at ')) {
    return [
      _RouteExpectation.place(
        _cleanNounSurface(lower.substring(3)),
        kind: PredicatePathKind.atLocation,
      ),
    ];
  }

  if (lower.startsWith('with ')) {
    final tail = _cleanNounSurface(lower.substring(5));
    if (tail == 'tool' || _instrumentSurfaces.contains(tail)) {
      return [_RouteExpectation(PredicatePathKind.withInstrument, tail)];
    }
    if (tail == 'something') {
      return [_RouteExpectation(PredicatePathKind.withTopic, tail)];
    }
    return [_RouteExpectation(PredicatePathKind.withCompanion, tail)];
  }

  if (_barePlaceSurfaces.contains(lower)) {
    return [_RouteExpectation.place(_cleanNounSurface(lower))];
  }

  return [_RouteExpectation(PredicatePathKind.directObject, cleaned)];
}

bool _rowIsReachable(_ReviewRow row) {
  return row.expectations.any((expectation) => expectation.matches(row.verb));
}

String _expectationLabel(_RouteExpectation expectation) {
  if (expectation.isLexicalBe) {
    return 'lexical be complement';
  }
  if (expectation.isObjectComplement) {
    return 'object complement';
  }

  final text = expectation.text == null ? 'any' : '"${expectation.text}"';
  final kind = expectation.kind == null
      ? 'place'
      : expectation.kind.toString().split('.').last;
  return '$kind $text';
}

bool _verbExists(String text) {
  return verbs.any((verb) => verb.infinitive.toLowerCase() == text);
}

String _cleanNounSurface(String surface) {
  var cleaned = surface.trim().toLowerCase();
  const leadingWords = [
    'a ',
    'an ',
    'the ',
    'this ',
    'that ',
    'some ',
    'any ',
    'each ',
    'every ',
    'my ',
    'your ',
    'his ',
    'her ',
    'our ',
    'their ',
    'no ',
  ];

  for (final leadingWord in leadingWords) {
    if (cleaned.startsWith(leadingWord)) {
      cleaned = cleaned.substring(leadingWord.length);
      break;
    }
  }

  return cleaned;
}

const _timeSurfaces = {
  'today',
  'tomorrow',
  'yesterday',
  'now',
  'later',
  'soon',
  'tonight',
  'this morning',
  'this afternoon',
  'this evening',
  'at night',
};

const _mannerSurfaces = {
  'quickly',
  'slowly',
  'carefully',
  'closely',
  'clearly',
  'easily',
  'quietly',
  'silently',
  'loudly',
  'happily',
  'sadly',
  'angrily',
  'politely',
  'patiently',
  'well',
  'badly',
  'together',
  'alone',
  'by hand',
  'in silence',
  'with care',
  'with confidence',
  'by accident',
  'on purpose',
  'manually',
  'again',
  'already',
  'away',
  'back',
  'here',
  'there',
  'outside',
};

const _instrumentSurfaces = {
  'tool',
  'key',
  'computer',
  'pen',
  'keyboard',
  'spoon',
  'fork',
  'knife',
  'scissors',
  'map',
  'phone',
  'camera',
};

const _placeLikeSurfaces = {'bed', 'table', 'bridge'};

const _barePlaceSurfaces = {'home', 'here', 'there', 'school', 'work', 'shop'};

class _ReviewRow {
  final Verb verb;
  final String surface;
  final String raw;
  final List<_RouteExpectation> expectations;

  const _ReviewRow({
    required this.verb,
    required this.surface,
    required this.raw,
    required this.expectations,
  });
}

class _RouteExpectation {
  final PredicatePathKind? kind;
  final String? text;
  final bool isLexicalBe;
  final bool isObjectComplement;

  const _RouteExpectation(this.kind, this.text)
    : isLexicalBe = false,
      isObjectComplement = false;

  const _RouteExpectation.place(this.text, {this.kind})
    : isLexicalBe = false,
      isObjectComplement = false;

  const _RouteExpectation.lexicalBe()
    : kind = null,
      text = null,
      isLexicalBe = true,
      isObjectComplement = false;

  const _RouteExpectation.objectComplement()
    : kind = null,
      text = null,
      isLexicalBe = false,
      isObjectComplement = true;

  bool matches(Verb verb) {
    if (isLexicalBe) {
      return verb.infinitive == 'be';
    }
    if (isObjectComplement) {
      return verb.takesObjectComplement;
    }

    final actualKind = kind;
    if (actualKind == null) {
      return _placeMatches(verb, text, kind: null);
    }

    return switch (actualKind) {
      PredicatePathKind.toRightAction => _verbMatches(verb, actualKind, text),
      PredicatePathKind.atLocation ||
      PredicatePathKind.inLocation ||
      PredicatePathKind.onLocation ||
      PredicatePathKind.fromLocation ||
      PredicatePathKind.placePhrase => _placeMatches(
        verb,
        text,
        kind: actualKind,
      ),
      PredicatePathKind.timePhrase => _timeMatches(verb, text),
      PredicatePathKind.frequencyPhrase => false,
      PredicatePathKind.mannerPhrase => _mannerMatches(verb, text),
      _ => _nounMatches(verb, actualKind, text),
    };
  }
}

bool _nounMatches(Verb verb, PredicatePathKind kind, String? text) {
  final choices = predicateNounChoicesFor(verb, kind);
  if (text == null ||
      text == 'someone' ||
      text == 'something' ||
      text == 'tool') {
    return choices.isNotEmpty;
  }

  return choices.any((choice) => choice.text.toLowerCase() == text);
}

bool _verbMatches(Verb verb, PredicatePathKind kind, String? text) {
  final choices = predicateVerbChoicesFor(verb, kind);
  if (text == null) {
    return choices.isNotEmpty;
  }

  return choices.any((choice) => choice.infinitive.toLowerCase() == text);
}

bool _placeMatches(Verb verb, String? text, {PredicatePathKind? kind}) {
  final choices = kind == null
      ? predicateAuthoredPlaceChoicesFor(verb)
      : predicatePlaceChoicesFor(verb, kind);
  if (text == null || text == 'somewhere') {
    return choices.isNotEmpty;
  }

  return choices.any(
    (choice) =>
        choice.noun.toLowerCase() == text ||
        choice.render().toLowerCase() == text ||
        choice.render(PlaceMeaning.destination).toLowerCase() == text ||
        choice.render(PlaceMeaning.source).toLowerCase() == text,
  );
}

bool _timeMatches(Verb verb, String? text) {
  final choices = predicateTimeChoicesFor(verb, PredicatePathKind.timePhrase);
  if (text == null) {
    return choices.isNotEmpty;
  }

  return choices.any((choice) => choice.text.toLowerCase() == text);
}

bool _mannerMatches(Verb verb, String? text) {
  final choices = predicateMannerChoicesFor(
    verb,
    PredicatePathKind.mannerPhrase,
  );
  if (text == null) {
    return choices.isNotEmpty;
  }

  return choices.any((choice) => choice.text.toLowerCase() == text);
}
