/// Authentication package entrypoint.
///
/// Exposes auth contracts, models, and Riverpod providers used to build the
/// app-wide authentication flow.
library;

export 'src/auth_notifier.dart'
    show AuthNotifier, authProvider, profileIdProvider;
export 'src/contracts/auth_contract.dart';
export 'src/contracts/profile_contract.dart';
export 'src/models/app_profile.dart';
export 'src/models/auth_credentials.dart';
export 'src/models/auth_result.dart';
export 'src/models/auth_state.dart';
export 'src/models/signed_in_user.dart';
export 'src/providers/auth_providers.dart'
    show authServiceProvider, profileServiceProvider;
