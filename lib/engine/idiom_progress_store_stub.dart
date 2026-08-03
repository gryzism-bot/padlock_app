Set<String> _memoryFoundIds = const {};

Set<String> loadStoredIdiomIds() => {..._memoryFoundIds};

void saveStoredIdiomIds(Set<String> ids) {
  _memoryFoundIds = {...ids};
}
