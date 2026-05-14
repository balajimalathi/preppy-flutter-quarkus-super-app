/// Public surface of [core_network]. Re-exports the Dio client builder and
/// shared interceptors so feature packages can `import 'package:core_network/core_network.dart';`
/// without reaching into `src/`.

library;

export 'src/http/api_client.dart'
    show ApiClient, apiClientProvider, baseUrlProvider;
