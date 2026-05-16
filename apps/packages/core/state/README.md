# core_state

Riverpod foundations and Flutter UI bridge for feature ViewModels:

- [`BaseViewModel`](lib/src/vm/base_view_model.dart) — `AsyncNotifier` with a scoped `UiEvent` stream
- [`StateViewModel`](lib/src/vm/state_view_model.dart) — subscribes to events and handles navigation, snackbars, dialogs
- [`UiEvent`](lib/src/events/ui_event.dart) — navigation, snackbars, dialogs (no `BuildContext` in the VM)
- [`UiPhase`](lib/src/phase/ui_phase.dart) — screen lifecycle inside feature state

## Usage

```dart
import 'package:core_state/core_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyViewModel extends BaseViewModel<MyState> {
  @override
  Future<MyState> buildInitial() async => MyState.initial();
}

class _MyScreenState extends StateViewModel<MyScreen, MyState, MyViewModel> {
  @override
  AsyncNotifierProvider<MyViewModel, MyState> get viewModelProvider =>
      myViewModelProvider;

  @override
  void onViewInit() => viewModel.load();
}
```

## Dependencies

`core_models`, `riverpod`, `flutter_riverpod`, `go_router`.
