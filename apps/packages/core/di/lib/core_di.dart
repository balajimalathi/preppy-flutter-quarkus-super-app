/// Re-exports every shared provider so feature packages can pull a single
/// import to wire up their dependencies.

library;

export 'package:core_env/core_env.dart';
export 'package:core_network/core_connectivity.dart'
    show
        ConnectivityContract,
        ConnectivityNotifier,
        ConnectivityState,
        connectivityServiceProvider,
        connectivityStateProvider;
export 'package:core_network/core_network.dart'
    show apiClientProvider, baseUrlProvider;
