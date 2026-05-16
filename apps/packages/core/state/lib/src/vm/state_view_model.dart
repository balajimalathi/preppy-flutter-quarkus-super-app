import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../events/ui_event.dart';
import 'base_view_model.dart';

/// Binds a [BaseViewModel] to [BuildContext] for [UiEvent] handling.
abstract class StateViewModel<
  W extends ConsumerStatefulWidget,
  S,
  N extends BaseViewModel<S>
>
    extends ConsumerState<W> {
  /// Feature [AsyncNotifierProvider] (state + notifier).
  AsyncNotifierProvider<N, S> get viewModelProvider;

  N get viewModel => ref.read(viewModelProvider.notifier);

  StreamSubscription<UiEvent>? _eventSub;

  /// Override to trigger loads after the first frame (called after event subscribe).
  void onViewInit() {}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _eventSub = viewModel.events.listen(_handleEvent);
      viewModel.onInit();
      onViewInit();
    });
  }

  @override
  void dispose() {
    unawaited(_eventSub?.cancel());
    _eventSub = null;
    super.dispose();
  }

  void _handleEvent(UiEvent event) {
    if (!mounted) return;
    switch (event) {
      case NavigateTo():
        onNavigateTo(event);
      case NavigateBack():
        onNavigateBack(event);
      case ShowSnackbar():
        onShowSnackbar(event);
      case ShowDialogEvent():
        onShowDialog(event);
      case ShowBottomSheetEvent():
        onShowBottomSheet(event);
      case LocalizedMessage():
        onLocalizedMessage(event);
    }
  }

  void onNavigateTo(NavigateTo event) {
    context.go(event.route, extra: event.args);
  }

  void onNavigateBack(NavigateBack event) {
    context.pop(event.result);
  }

  void onShowSnackbar(ShowSnackbar event) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(event.message),
        backgroundColor: _snackbarColor(event.type),
      ),
    );
  }

  void onShowDialog(ShowDialogEvent event) {
    final builder = event.builder;
    if (builder is Widget Function(BuildContext)) {
      showDialog<void>(context: context, builder: builder);
    }
  }

  void onShowBottomSheet(ShowBottomSheetEvent event) {
    final builder = event.builder;
    if (builder is Widget Function(BuildContext)) {
      showModalBottomSheet<void>(context: context, builder: builder);
    }
  }

  void onLocalizedMessage(LocalizedMessage event) {
    onShowSnackbar(ShowSnackbar(event.resolver(), type: event.type));
  }

  Color? _snackbarColor(SnackbarType type) {
    final scheme = Theme.of(context).colorScheme;
    return switch (type) {
      SnackbarType.info => null,
      SnackbarType.success => scheme.primaryContainer,
      SnackbarType.warning => scheme.tertiaryContainer,
      SnackbarType.error => scheme.errorContainer,
    };
  }
}
