import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'models/application_model.dart';
import 'providers/employer_applicants_provider.dart';

class EmployerApplicantsScreen extends ConsumerWidget {
  final String? jobId;
  final String? jobTitle;

  const EmployerApplicantsScreen({super.key, this.jobId, this.jobTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicantsAsync = ref.watch(employerApplicantsProvider(jobId));

    return Scaffold(
      appBar: AppBar(
        title: Text(jobTitle != null ? 'Applicants: $jobTitle' : 'All Job Applicants'),
      ),
      body: applicantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading applicants: $e')),
        data: (applicants) {
          if (applicants.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline, size: 72, color: AppTheme.textSecondary),
                    SizedBox(height: 16),
                    Text('No Applicants Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      'When candidates apply to your jobs, their profiles will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            itemCount: applicants.length,
            itemBuilder: (context, index) {
              final app = applicants[index];
              return _ApplicantCard(
                application: app,
                onUpdateStatus: (newStatus) {
                  ref
                      .read(employerApplicantsProvider(jobId).notifier)
                      .updateStatus(app.id, newStatus);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final ApplicationModel application;
  final ValueChanged<ApplicationStatus> onUpdateStatus;

  const _ApplicantCard({
    required this.application,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final profile = application.candidateProfile;
    final currentStatus = application.status;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: const Icon(Icons.person, color: AppTheme.primary, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.fullName ?? 'Candidate',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${profile?.workCategory ?? 'Worker'} • ${profile?.experienceYears ?? 'Fresher'} exp',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '📍 ${profile?.currentCity ?? 'Maharashtra'}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (profile != null)
                  IconButton(
                    icon: const Icon(Icons.description_outlined, color: AppTheme.primary),
                    tooltip: 'View Digital Resume',
                    onPressed: () => context.push('/resume', extra: profile),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Skills
            if (profile != null && profile.skills.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: profile.skills.take(4).map((skill) {
                  return Chip(
                    label: Text(skill, style: const TextStyle(fontSize: 10)),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Status Changer Row
            Row(
              children: [
                Text(
                  'Status: ${currentStatus.displayName}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                PopupMenuButton<ApplicationStatus>(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Change Status', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                        Icon(Icons.arrow_drop_down, color: AppTheme.primary, size: 18),
                      ],
                    ),
                  ),
                  onSelected: onUpdateStatus,
                  itemBuilder: (context) {
                    return [
                      ApplicationStatus.viewed,
                      ApplicationStatus.shortlisted,
                      ApplicationStatus.interview,
                      ApplicationStatus.selected,
                      ApplicationStatus.rejected,
                    ].map((st) {
                      return PopupMenuItem(
                        value: st,
                        enabled: currentStatus.canTransitionTo(st),
                        child: Text(st.displayName),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
