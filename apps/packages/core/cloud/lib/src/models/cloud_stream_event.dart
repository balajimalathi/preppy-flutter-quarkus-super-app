import 'package:meta/meta.dart';

import 'cloud_document.dart';

/// Granular change event produced by [CloudCollection.watchEvents].
sealed class CloudStreamEvent<T> {
  const CloudStreamEvent();
}

@immutable
/// A document was added to the watched result set.
final class CloudStreamAdded<T> extends CloudStreamEvent<T> {
  const CloudStreamAdded(this.doc);

  final CloudDocument<T> doc;
}

@immutable
/// A document already in the watched result set was modified.
final class CloudStreamModified<T> extends CloudStreamEvent<T> {
  const CloudStreamModified(this.doc);

  final CloudDocument<T> doc;
}

@immutable
/// A document was removed from the watched result set.
final class CloudStreamRemoved<T> extends CloudStreamEvent<T> {
  const CloudStreamRemoved(this.id);

  final String id;
}
