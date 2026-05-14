import 'package:meta/meta.dart';

import 'cloud_document.dart';

sealed class CloudStreamEvent<T> {
  const CloudStreamEvent();
}

@immutable
final class CloudStreamAdded<T> extends CloudStreamEvent<T> {
  const CloudStreamAdded(this.doc);

  final CloudDocument<T> doc;
}

@immutable
final class CloudStreamModified<T> extends CloudStreamEvent<T> {
  const CloudStreamModified(this.doc);

  final CloudDocument<T> doc;
}

@immutable
final class CloudStreamRemoved<T> extends CloudStreamEvent<T> {
  const CloudStreamRemoved(this.id);

  final String id;
}
