import 'dart:async';

import 'package:riverpod/riverpod.dart';

import '../events/ui_event.dart';

/// Context-free [AsyncNotifier] base with a per-notifier [UiEvent] stream.
abstract class BaseViewModel<S> extends AsyncNotifier<S> {
  StreamController<UiEvent>? _events;

  /// Broadcast stream for one-shot UI side effects.
  Stream<UiEvent> get events {
    final controller = _events;
    if (controller == null) {
      throw StateError(
        'events accessed before build(); subscribe after the notifier is mounted.',
      );
    }
    return controller.stream;
  }

  /// Emit a UI event for the view layer to handle.
  void emit(UiEvent event) {
    _events?.add(event);
  }

  /// Feature state when [state] is [AsyncData]; safe during [AsyncLoading].
  S? get currentValue => state.asData?.value;

  /// [currentValue] or [fallback] — use instead of [AsyncValue.requireValue] in actions.
  S valueOr(S fallback) => currentValue ?? fallback;

  /// Called once when the notifier is first built (after [build] completes).
  void onInit() {}

  /// Called when the notifier is disposed.
  void onDispose() {}

  void _initEventStream() {
    _events?.close();
    _events = StreamController<UiEvent>.broadcast();
    ref.onDispose(() {
      onDispose();
      _events?.close();
      _events = null;
    });
  }

  @override
  Future<S> build() async {
    _initEventStream();
    return buildInitial();
  }

  /// Subclasses return the initial feature state.
  Future<S> buildInitial();
}
