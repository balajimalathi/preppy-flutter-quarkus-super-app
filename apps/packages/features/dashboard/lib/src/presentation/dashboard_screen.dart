import 'package:auth/feature_auth.dart';
import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';

import '../application/state/dashboard_screen_state.dart';
import '../application/view_models/dashboard_view_model.dart';
import '../domain/entities/dashboard_summary.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardViewModelProvider);

    return PreppyScaffold(
      title: 'Dashboard',
      body: _buildBody(context, ref, state),
      actions: [
        TextButton(
          onPressed: () => context.push('/status'),
          child: const Text('Status'),
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    DashboardScreenState state,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError && !state.hasData) {
      return ErrorBody(
        error: state.error!,
        onRetry: () => ref.read(dashboardViewModelProvider.notifier).load(),
      );
    }

    if (!state.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardViewModelProvider.notifier).refresh(),
      child: _SummaryContent(
        summary: state.data!,
        isRefreshing: state.isRefreshing,
        error: state.error,
        onRetry: () => ref.read(dashboardViewModelProvider.notifier).load(),
      ),
    );
  }
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({
    required this.summary,
    required this.isRefreshing,
    required this.error,
    required this.onRetry,
  });

  final DashboardSummary summary;
  final bool isRefreshing;
  final AppError? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        if (isRefreshing)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: LinearProgressIndicator(),
          ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: MaterialBanner(
              content: Text(resolveErrorMessage(error!)),
              actions: [
                TextButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ),
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
