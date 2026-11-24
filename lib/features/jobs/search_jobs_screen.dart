import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/theme/app_theme.dart';
import 'providers/jobs_provider.dart';
import 'widgets/job_card.dart';
import 'widgets/job_filter_sheet.dart';

class SearchJobsScreen extends ConsumerStatefulWidget {
  const SearchJobsScreen({super.key});

  @override
  ConsumerState<SearchJobsScreen> createState() => _SearchJobsScreenState();
}

class _SearchJobsScreenState extends ConsumerState<SearchJobsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String val) {
    ref.read(jobFilterProvider.notifier).update(
          (state) => state.copyWith(query: val.trim()),
        );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (_) => const JobFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final jobsAsync = ref.watch(jobsProvider);
    final filterState = ref.watch(jobFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabJobs),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(68),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: _onSearch,
                    decoration: InputDecoration(
                      hintText: 'Search Electrician, Welder, Pune...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearch('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _showFilterModal,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: filterState.hasActiveFilters
                          ? AppTheme.primary
                          : AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: filterState.hasActiveFilters
                            ? AppTheme.primary
                            : AppTheme.divider,
                      ),
                    ),
                    child: Icon(
                      Icons.tune,
                      color: filterState.hasActiveFilters ? Colors.white : AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 50, color: AppTheme.textSecondary),
              const SizedBox(height: 12),
              Text('Failed to load jobs: $e'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(jobsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (jobs) {
          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off, size: 64, color: AppTheme.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'No jobs found matching your search.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      ref.read(jobFilterProvider.notifier).update((_) => const JobFilterState());
                    },
                    child: const Text('Clear Filters'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(jobsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                return JobCard(job: jobs[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
