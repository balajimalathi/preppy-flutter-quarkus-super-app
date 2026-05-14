final class ProfileSyncException implements Exception {
  ProfileSyncException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'ProfileSyncException: $message';
}

final class ProfileFetchException implements Exception {
  ProfileFetchException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'ProfileFetchException: $message';
}
