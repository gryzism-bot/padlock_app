import 'dart:convert';
import 'dart:html' as html;

const _storageKey = 'padlock.idioms.found.v1';

Set<String> loadStoredIdiomIds() {
  final raw = html.window.localStorage[_storageKey];
  if (raw == null || raw.isEmpty) {
    return {};
  }

  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.whereType<String>().toSet();
    }
  } on FormatException {
    return {};
  }

  return {};
}

void saveStoredIdiomIds(Set<String> ids) {
  final sortedIds = ids.toList()..sort();
  html.window.localStorage[_storageKey] = jsonEncode(sortedIds);
}
