# core_state

Presentation-layer Riverpod helpers for feature ViewModels (MVVM):

- [`ScreenState`](lib/src/screen/screen_state.dart) — domain `data`, typed `AppError`, and `LoadPhase`
- [`BaseViewModel`](lib/src/vm/base_view_model.dart) — `Notifier` with `runAction`, `loadData`, `refreshData`

Use cases live in the feature `application/use_cases/` layer. They must **not** import `core_state`. Map repository `Result` failures with `Result.getOrThrow()` from `core_models`.

## Simple feature recipe

1. **Entity** in `domain/entities/`
2. **Concrete repository** in `data/repositories/` using `dioGetEnvelope` + `fetchWithOfflineCache` from `core_network`
3. **Use case** — plain class with `execute()`; use `(await repository.getX()).getOrThrow()` and throw `AppError` for validation
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
