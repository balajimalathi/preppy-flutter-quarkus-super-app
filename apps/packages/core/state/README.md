# core_state

Riverpod helpers for feature ViewModels using `ScreenState<S>`:

- [`ScreenState`](lib/src/screen/screen_state.dart) — domain `data`, typed `AppError`, and `LoadPhase`
- [`BaseViewModel`](lib/src/vm/base_view_model.dart) — `Notifier` with `runAction`, `loadData`, `refreshData`
- [`ResultUseCase`](lib/src/use_case/result_use_case.dart) — maps `Result` failures to `AppError` in `execute()`

## Simple feature recipe

1. **Entity** in `domain/entities/`
2. **Concrete repository** in `data/repositories/` using `dioGetEnvelope` + `fetchWithOfflineCache` from `core_network`
3. **Use case** extending `ResultUseCase<T>`; override `execute()` for validation only
4. **ViewModel** extending `BaseViewModel<S, YourScreenState>`:

```dart
class DashboardViewModel extends BaseViewModel<DashboardSummary, DashboardScreenState> {
  @override
  DashboardScreenState initialState() => const DashboardScreenState.initial();

  @override
  void initialize() => Future.microtask(load);

  Future<void> load() => loadData(
    () => ref.read(getDashboardSummaryUseCaseProvider).execute(),
  );

  Future<void> refresh() => refreshData(
    () => ref.read(getDashboardSummaryUseCaseProvider).execute(),
  );
}
```

5. **Screen** watches one `NotifierProvider`; branch on `isLoading`, `hasError && !hasData`, then content.

See `features/dashboard` for the reference slice.
