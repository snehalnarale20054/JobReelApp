import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../applications/widgets/apply_bottom_sheet.dart';
import '../applications/providers/applications_provider.dart';
import '../auth/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'models/job_model.dart';
import 'providers/saved_jobs_provider.dart';

class JobDetailScreen extends ConsumerWidget {
  final JobModel job;

  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(savedJobsProvider).contains(job.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSaved ? AppTheme.accent : null,
            ),
            onPressed: () =>
                ref.read(savedJobsProvider.notifier).toggleSave(job.id),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                'Job Opening: ${job.title} at ${job.company?.name ?? 'Reputed Company'}\n'
                'Location: ${job.city}, ${job.state}\n'
                'Salary: ${job.salaryDisplay}\n'
                'Apply via JobReels App!',
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(top: BorderSide(color: AppTheme.divider)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Salary Offered', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    Text(
                      job.salaryDisplay,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final hasApplied = ref
                        .watch(myApplicationsProvider.notifier)
                        .hasApplied(job.id);

                    if (hasApplied) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                        ),
                        onPressed: () => context.push('/my-applications'),
                        child: const Text('VIEW STATUS'),
                      );
                    }

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                      ),
                      onPressed: () {
                        final user = ref.read(currentUserProvider);
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Sign in to apply for this job!'),
                              action: SnackBarAction(
                                label: 'Sign In',
                                onPressed: () => context.push('/auth'),
                              ),
                            ),
                          );
                          return;
                        }

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(AppTheme.radiusLg),
                            ),
                          ),
                          builder: (_) => ApplyBottomSheet(job: job),
                        );
                      },
                      child: const Text('APPLY NOW'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Company and Job Title Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      job.company?.name ?? 'Verified Employer',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${job.city}, ${job.district != null ? '${job.district}, ' : ''}${job.state}',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Key Highlights Card (Vacancies, Job Type, Education, Experience)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Job Overview', style: Theme.of(context).textTheme.titleLarge),
                    const Divider(height: 20),
                    _buildOverviewItem(Icons.people_outline, 'Total Vacancies', '${job.vacancies} Openings'),
                    _buildOverviewItem(Icons.timelapse_outlined, 'Job Type', job.jobType),
                    _buildOverviewItem(Icons.school_outlined, 'Minimum Education', job.minEducation),
                    _buildOverviewItem(Icons.work_history_outlined, 'Experience Required', job.minExperience),
                    _buildOverviewItem(Icons.contact_phone_outlined, 'Contact Person', job.contactPerson),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Required Skills
            if (job.skillsRequired.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Skills Required', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: job.skillsRequired.map((skill) {
                          return Chip(
                            label: Text(skill),
                            backgroundColor: AppTheme.primary.withOpacity(0.08),
                            labelStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w500),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Benefits & Perks
            if (job.benefits.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Perks & Benefits', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: job.benefits.map((benefit) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle, size: 14, color: AppTheme.success),
                                const SizedBox(width: 6),
                                Text(
                                  benefit,
                                  style: const TextStyle(
                                    color: AppTheme.success,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Full Job Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Job Description', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    Text(
                      job.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
