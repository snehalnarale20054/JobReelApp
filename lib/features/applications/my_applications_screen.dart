import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'models/application_model.dart';
import 'providers/applications_provider.dart';

class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(myApplicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
      ),
      body: appsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $e'),
              ElevatedButton(
                onPressed: () => ref.read(myApplicationsProvider.notifier).loadMyApplications(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (applications) {
          if (applications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.assignment_outlined, size: 72, color: AppTheme.textSecondary),
                    const SizedBox(height: 16),
                    Text('No Applications Yet', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    const Text(
                      'Browse open jobs in the Jobs tab and apply with one tap.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.go('/jobs'),
                      child: const Text('Search Jobs'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              return _ApplicationCard(application: app);
            },
          );
        },
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel application;

  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final job = application.job;
    final status = application.status;

    Color statusColor;
    switch (status) {
      case ApplicationStatus.applied:
        statusColor = AppTheme.primary;
        break;
      case ApplicationStatus.viewed:
        statusColor = Colors.orange;
        break;
      case ApplicationStatus.shortlisted:
        statusColor = Colors.deepPurple;
        break;
      case ApplicationStatus.interview:
        statusColor = Colors.indigo;
        break;
      case ApplicationStatus.selected:
        statusColor = AppTheme.success;
        break;
      case ApplicationStatus.rejected:
        statusColor = AppTheme.error;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job?.title ?? 'Job Position',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job?.company?.name ?? 'Company',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    status.displayName,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Step Progress Timeline
            _buildTimeline(status),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(ApplicationStatus status) {
    if (status == ApplicationStatus.rejected) {
      return Row(
        children: [
          const Icon(Icons.cancel, color: AppTheme.error, size: 18),
          const SizedBox(width: 8),
          Text(
            'Application not moving forward at this time',
            style: TextStyle(color: AppTheme.error.withOpacity(0.8), fontSize: 12),
          ),
        ],
      );
    }

    final steps = ['Applied', 'Viewed', 'Shortlisted', 'Interview', 'Selected'];
    final currentStep = status.stepIndex;

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepBefore = index ~/ 2;
          final isPast = stepBefore < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: isPast ? AppTheme.primary : AppTheme.divider,
            ),
          );
        }

        final step = index ~/ 2;
        final isDone = step <= currentStep;

        return Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? AppTheme.primary : AppTheme.surface,
                border: Border.all(
                  color: isDone ? AppTheme.primary : AppTheme.divider,
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              steps[step],
              style: TextStyle(
                fontSize: 9,
                fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                color: isDone ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }
}
