import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';

import 'api_client.dart';

/// Mix into repositories that need [Dio] without constructor injection.
///
/// Resolve via [ref] (e.g. [ProviderContainer] with `dioProvider` overrides in
/// tests).
mixin DioAware {
  Ref get ref;

  Dio get dio => ref.read(dioProvider);
}
