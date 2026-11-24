import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../jobs/models/job_model.dart';
import '../profile/providers/profile_provider.dart';
import '../providers/applications_provider.dart';

class ApplyBottomSheet extends ConsumerStatefulWidget {
  final JobModel job;

  const ApplyBottomSheet({super.key, required this.job});

  @override
  ConsumerState<ApplyBottomSheet> createState() => _ApplyBottomSheetState();
}

class _ApplyBottomSheetState extends ConsumerState<ApplyBottomSheet> {
  bool _isSubmitting = false;

  void _confirmApply() async {
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(myApplicationsProvider.notifier)
          .submitApplication(widget.job.id);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
        context.push('/my-applications');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit application: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Confirm Job Application',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'You are applying for ${widget.job.title} at ${widget.job.company?.name ?? 'Reputed Company'}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),

            profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Could not load profile preview'),
              data: (profile) {
                if (profile == null) {
                  return Column(
                    children: [
                      const Text(
                        'You need to create your profile before applying.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.push('/profile-setup');
                        },
                        child: const Text('Complete Profile'),
                      ),
                    ],
                  );
                }

                return Card(
                  color: AppTheme.background,
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.primary.withOpacity(0.1),
                          child: const Icon(Icons.person, color: AppTheme.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 2),
                              Text('${profile.workCategory} • ${profile.experienceYears} exp', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text('📍 ${profile.currentCity}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle, color: AppTheme.success, size: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isSubmitting ? null : _confirmApply,
              child: _isSubmitting
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('CONFIRM & SEND RESUME'),
            ),
          ],
        ),
      ),
    );
  }
}
