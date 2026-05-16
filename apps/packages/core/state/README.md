# core_state

Riverpod helpers for feature ViewModels using `ScreenState<S>`:

- [`ScreenState`](lib/src/screen/screen_state.dart) — domain `data`, typed `AppError`, and `LoadPhase`
- [`BaseViewModel`](lib/src/vm/base_view_model.dart) — `Notifier` with `runAction`, `currentData`, and `dataOr`

## Usage

```dart
import 'package:core_state/core_state.dart';

class DashboardViewModel extends BaseViewModel<DashboardSummary, DashboardScreenState> {
  @override
  DashboardScreenState initialState() => const DashboardScreenState.initial();

  @override
  void initialize() => Future.microtask(load);

  Future<void> load() => runAction(() async {
    state = state.copyWith(phase: LoadPhase.loading) as DashboardScreenState;
    final summary = await ref.read(getDashboardSummaryUseCaseProvider).execute();
    return state.copyWith(data: summary, phase: LoadPhase.idle, error: null)
        as DashboardScreenState;
  });
}
```

Feature packages extend `ScreenState` for UI-only fields (tabs, drawers, etc.).
