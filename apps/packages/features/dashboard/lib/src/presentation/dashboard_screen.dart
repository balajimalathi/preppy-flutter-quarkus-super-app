import 'package:auth/feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';

import '../application/providers/dashboard_providers.dart';
import '../domain/entities/dashboard_summary.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(dashboardViewModelProvider);

    return PreppyScaffold(
      title: 'Dashboard',
      body: switch (asyncState) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError(:final error) => _ErrorBody(
          message: error.toString(),
          onRetry: () =>
              ref.read(dashboardViewModelProvider.notifier).refresh(),
        ),
        AsyncData(:final value) => _SummaryContent(summary: value),
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
