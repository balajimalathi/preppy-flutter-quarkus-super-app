import 'package:core_env/core_env.dart';
import 'package:graphql/client.dart';
import 'package:riverpod/riverpod.dart';

import '../http/auth_token.dart';
import 'dashboard_queries.dart';

export 'dashboard_queries.dart';

/// [GraphQLClient] for [appEnvProvider.graphqlHttpUrl] with shared bearer auth.
final graphQLClientProvider = Provider<GraphQLClient>((ref) {
  final env = ref.watch(appEnvProvider);

  final authLink = Link.function((request, [forward]) async* {
    if (forward == null) {
      return;
    }
    final token = await ref.read(authTokenProvider)();
    if (token == null || token.isEmpty) {
      yield* forward(request);
      return;
    }
    final existing = request.context.entry<HttpLinkHeaders>()?.headers ?? {};
    yield* forward(
      request.withContextEntry(
        HttpLinkHeaders(
          headers: {...existing, 'authorization': 'Bearer $token'},
        ),
      ),
    );
  });

  final httpLink = HttpLink(env.graphqlHttpUrl);
  final link = Link.from([authLink, httpLink]);

  return GraphQLClient(
    cache: GraphQLCache(),
    link: link,
    defaultPolicies: DefaultPolicies(
      query: Policies(fetch: FetchPolicy.networkOnly),
    ),
  );
});

/// Smoke query against any GraphQL server (schema introspection not required).
Future<QueryResult<Object?>> fetchDashboardHeartbeat(GraphQLClient client) {
  return client.query(QueryOptions(document: dashboardHeartbeatQuery));
}
