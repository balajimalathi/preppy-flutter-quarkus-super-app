import 'package:gql/language.dart';

/// Minimal query for connectivity checks until real dashboard fields exist.
final dashboardHeartbeatQuery = parseString(r'''
query DashboardHeartbeat {
  __typename
}
''');
