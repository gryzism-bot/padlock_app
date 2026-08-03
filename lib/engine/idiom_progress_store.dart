import 'idiom_progress_store_stub.dart'
    if (dart.library.html) 'idiom_progress_store_web.dart';

class IdiomProgressStore {
  const IdiomProgressStore();

  Set<String> loadFoundIds() => loadStoredIdiomIds();

  void saveFoundIds(Set<String> ids) => saveStoredIdiomIds(ids);
}
