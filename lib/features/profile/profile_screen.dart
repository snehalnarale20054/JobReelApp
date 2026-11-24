import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/locale_provider.dart';
import 'providers/profile_provider.dart';
import '../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(profileProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.tabProfile)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              mainAxisAlignment: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle_outlined, size: 80, color: AppTheme.textSecondary),
                const SizedBox(height: 16),
                Text(
                  'Sign in to build your profile & resume',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.push('/auth'),
                  child: const Text('Sign In with Phone'),
                ),
                const SizedBox(height: 32),
                _DebugLanguageSwitcher(l10n: l10n),
              ],
            ),
          ),
        ),
      );
    }

    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.tabProfile)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error loading profile: $e'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(profileProvider.notifier).loadProfile(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (profile) {
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.tabProfile)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.badge_outlined, size: 72, color: AppTheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome! Complete your profile to get a free professional resume.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.push('/profile-setup'),
                      child: const Text('Create Profile (2 min)'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.tabProfile),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Profile',
                onPressed: () => context.push('/profile-setup'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Profile Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppTheme.primary.withOpacity(0.1),
                          backgroundImage: profile.photoUrl != null
                              ? CachedNetworkImageProvider(profile.photoUrl!)
                              : null,
                          child: profile.photoUrl == null
                              ? const Icon(Icons.person, size: 40, color: AppTheme.primary)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.fullName,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.workCategory,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${profile.currentCity} • Exp: ${profile.experienceYears}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Resume Action Button (Primary CTA)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: const Text('View & Download Resume PDF'),
                  onPressed: () => context.push('/resume', extra: profile),
                ),
                const SizedBox(height: 12),

                // Track My Applications Button
                OutlinedButton.icon(
                  icon: const Icon(Icons.assignment_turned_in_outlined),
                  label: const Text('Track My Applications'),
                  onPressed: () => context.push('/my-applications'),
                ),
                const SizedBox(height: 12),

                // Employer Applicants Shortcut
                OutlinedButton.icon(
                  icon: const Icon(Icons.people_alt_outlined),
                  label: const Text('View Received Applicants'),
                  onPressed: () => context.push('/employer-applicants'),
                ),
                const SizedBox(height: 16),

                // Profile Details Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Profile Details', style: Theme.of(context).textTheme.titleLarge),
                        const Divider(height: 24),
                        _buildRow('Education', profile.education),
                        _buildRow('Preferred City', profile.preferredCity ?? profile.currentCity),
                        _buildRow('Expected Salary', profile.expectedSalary),
                        if (profile.about != null && profile.about!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('About', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(profile.about!, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Skills Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Skills', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: profile.skills
                              .map(
                                (s) => Chip(
                                  label: Text(s),
                                  backgroundColor: AppTheme.primary.withOpacity(0.08),
                                  labelStyle: const TextStyle(color: AppTheme.primary),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Out
                OutlinedButton(
                  onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
                  child: const Text('Sign Out'),
                ),
                const SizedBox(height: 24),

                // Debug Language Switcher
                _DebugLanguageSwitcher(l10n: l10n),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DebugLanguageSwitcher extends ConsumerWidget {
  final AppLocalizations l10n;

  const _DebugLanguageSwitcher({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.debugLanguageLabel}:',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _LangButton(
              label: l10n.langEnglish,
              locale: const Locale('en'),
              isSelected: (currentLocale?.languageCode ?? 'en') == 'en',
              onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
            ),
            const SizedBox(width: 8),
            _LangButton(
              label: l10n.langHindi,
              locale: const Locale('hi'),
              isSelected: currentLocale?.languageCode == 'hi',
              onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('hi')),
            ),
            const SizedBox(width: 8),
            _LangButton(
              label: l10n.langMarathi,
              locale: const Locale('mr'),
              isSelected: currentLocale?.languageCode == 'mr',
              onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('mr')),
            ),
          ],
        ),
      ],
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangButton({
    required this.label,
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
