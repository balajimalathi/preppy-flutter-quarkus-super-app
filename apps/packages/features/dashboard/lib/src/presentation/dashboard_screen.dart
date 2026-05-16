import 'package:auth/feature_auth.dart';
import 'package:core_state/core_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';

import '../application/providers/dashboard_providers.dart';
import '../application/state/dashboard_summary_state.dart';
import '../application/view_models/dashboard_view_model.dart';
import '../domain/entities/dashboard_summary.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState
    extends
        StateViewModel<
          DashboardScreen,
          DashboardSummaryState,
          DashboardViewModel
        > {
  @override
  AsyncNotifierProvider<DashboardViewModel, DashboardSummaryState>
  get viewModelProvider => dashboardViewModelProvider;

  @override
  void onViewInit() {
    viewModel.loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(dashboardViewModelProvider);

    return PreppyScaffold(
      title: 'Dashboard',
      body: switch (asyncState) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError(:final error) => _ErrorBody(
          message: error.toString(),
          onRetry: viewModel.loadSummary,
        ),
        AsyncData(:final value) => _DashboardBody(
          state: value,
          onRetry: viewModel.loadSummary,
        ),
      },
      actions: [
        TextButton(
          onPressed: () => context.push('/status'),
          child: const Text('Status'),
        ),
      ],
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.state, required this.onRetry});

  final DashboardSummaryState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (state.phase) {
      UiPhase.initial ||
      UiPhase.loading => const Center(child: CircularProgressIndicator()),
      UiPhase.error => _ErrorBody(
        message: state.errorMessage ?? 'Something went wrong',
        onRetry: onRetry,
      ),
      UiPhase.success => _SummaryContent(summary: state.summary!),
    };
  }
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(summary.greeting, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 24),
        _StatCard(label: 'Streak', value: '${summary.streakDays} days'),
        const SizedBox(height: 12),
        _StatCard(label: 'Cards due today', value: '${summary.cardsDueToday}'),
        const SizedBox(height: 12),
        _StatCard(label: 'Coverage', value: '${summary.coveragePercent}%'),
        const SizedBox(height: 32),
        LogoutButton(
          label: 'Sign out',
          style: LogoutButtonStyle.text,
          onSignedOut: () => context.go('/login'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
