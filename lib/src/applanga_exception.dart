class ApplangaFlutterException implements Exception {
  final String msg;

  ApplangaFlutterException(this.msg);

  @override
  String toString() => 'ApplangaFlutterException: $msg';
}

class ApplangaConfigException extends ApplangaFlutterException {
  ApplangaConfigException(String msg) : super(msg);
}

class ApplangaCliException extends ApplangaFlutterException {
  ApplangaCliException(String msg) : super(msg);
}

class ApplangaCliOutdatedException extends ApplangaFlutterException {
  final String currentVersion;
  final String minVersion;

  ApplangaCliOutdatedException(
      {required this.currentVersion, required this.minVersion})
      : super("-> applanga cli is outdated.\n"
      "Current version: $currentVersion.\n"
      "Required minVersion: $minVersion.");
}

class ApplangaCliNotFoundException extends ApplangaCliException {
  ApplangaCliNotFoundException() : super("applanga cli not found in path.");
}

class ApplangaFlutterContextException extends ApplangaFlutterException {
  ApplangaFlutterContextException() : super("Context is not valid.\n"
      "Applanga can't detect string positions within this Context.\n"
      "Set your context within your WidgetsApp, CupertinoApp or MaterialApp.\n"
      "Don't forget to dispose the context with ApplangaFlutter.I.dispose(context).");
}
