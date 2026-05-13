import 'dart:async';

import 'connectivity_contract.dart';
import 'connectivity_state.dart';

/// Shared [onStatusChange] pipeline: debounce rapid plugin events, then drop
/// consecutive duplicates.
abstract base class BaseConnectivityMonitor implements ConnectivityContract {
  BaseConnectivityMonitor({this.debounce = const Duration(milliseconds: 300)});

  /// Quiet period before emitting after the last raw event.
  final Duration debounce;

  final StreamController<ConnectivityState> _out =
      StreamController<ConnectivityState>.broadcast();

  StreamSubscription<ConnectivityState>? _upstream;
  Timer? _debounceTimer;
  ConnectivityState? _lastEmitted;

  /// Subclasses call this once after construction with a mapped plugin stream.
  void bindUpstream(Stream<ConnectivityState> source) {
    _upstream = source.listen(
      _onUpstreamEvent,
      onError: (Object error, StackTrace stack) {
        if (!_out.isClosed) {
          _out.addError(error, stack);
        }
      },
    );
  }

  void _onUpstreamEvent(ConnectivityState event) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () {
      if (_lastEmitted != event) {
        _lastEmitted = event;
        if (!_out.isClosed) {
          _out.add(event);
        }
      }
    });
  }

  @override
  Stream<ConnectivityState> get onStatusChange => _out.stream;

  @override
  Future<ConnectivityState> get currentStatus;

  /// Releases timers, upstream subscription, and closes [onStatusChange].
  void dispose() {
    _debounceTimer?.cancel();
    _upstream?.cancel();
    if (!_out.isClosed) {
      _out.close();
    }
  }
}
