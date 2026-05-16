# core_state

Minimal Riverpod helpers for feature ViewModels:

- [`BaseViewModel`](lib/src/vm/base_view_model.dart) — `AsyncNotifier` with `currentValue` / `valueOr` for safe reads during `AsyncLoading`

Loading, errors, and UI side effects stay in feature state (`ApiResult`, `AsyncValue`, `ref.listen`, etc.).

## Usage

```dart
import 'package:core_state/core_state.dart';

class DashboardViewModel extends BaseViewModel<DashboardSummary> {
  @override
  Future<DashboardSummary> buildInitial() async {
    final result = await ref.read(getDashboardSummaryUseCaseProvider).execute();
    return switch (result) {
      ApiSuccess(:final data) => data,
      ApiError(:final message) => throw StateError(message),
      _ => throw StateError('Unexpected result'),
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(buildInitial);
  }
}
```
