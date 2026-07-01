enum AppColorScheme {
  deepPurple,
  blue,
  green,
  orange,
  teal;

  static const AppColorScheme defaultScheme = AppColorScheme.deepPurple;

  String get storageValue => name;

  static AppColorScheme fromStorage(String? raw) {
    if (raw == null || raw.isEmpty) {
      return defaultScheme;
    }
    for (final scheme in AppColorScheme.values) {
      if (scheme.name == raw) {
        return scheme;
      }
    }
    return defaultScheme;
  }
}
