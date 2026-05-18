import 'package:riverpod/riverpod.dart';

import 'connectivity_contract.dart';
import 'connectivity_provider.dart';

/// Mix into repositories that need [ConnectivityContract] without constructor
/// injection. Requires a [ref] (typically from the Riverpod provider callback).
mixin ConnectivityAware {
  Ref get ref;

  ConnectivityContract get connectivity =>
      ref.read(connectivityServiceProvider);
}
