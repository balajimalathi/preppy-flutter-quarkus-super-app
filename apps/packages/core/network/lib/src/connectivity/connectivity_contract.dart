import 'connectivity_state.dart';

/// Observable connectivity for the app. Implementations may use platform
/// plugins; consumers depend only on this contract.
abstract interface class ConnectivityContract {
  Stream<ConnectivityState> get onStatusChange;

  Future<ConnectivityState> get currentStatus;
}
