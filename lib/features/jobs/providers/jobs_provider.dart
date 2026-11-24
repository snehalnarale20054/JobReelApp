import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job_model.dart';

class JobFilterState {
  final String query;
  final String? category;
  final String? city;
  final String? experience;
  final String? jobType;

  const JobFilterState({
    this.query = '',
    this.category,
    this.city,
    this.experience,
    this.jobType,
  });

  JobFilterState copyWith({
    String? query,
    String? category,
    String? city,
    String? experience,
    String? jobType,
    bool clearCategory = false,
    bool clearCity = false,
    bool clearExperience = false,
    bool clearJobType = false,
  }) {
    return JobFilterState(
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      city: clearCity ? null : (city ?? this.city),
      experience: clearExperience ? null : (experience ?? this.experience),
      jobType: clearJobType ? null : (jobType ?? this.jobType),
    );
  }

  bool get hasActiveFilters =>
      category != null || city != null || experience != null || jobType != null;
}

final jobFilterProvider = StateProvider<JobFilterState>((ref) {
  return const JobFilterState();
});

final jobsProvider = StateNotifierProvider<JobsNotifier, AsyncValue<List<JobModel>>>((ref) {
  final filter = ref.watch(jobFilterProvider);
  return JobsNotifier(filter);
});

class JobsNotifier extends StateNotifier<AsyncValue<List<JobModel>>> {
  final JobFilterState filter;
  final _supabase = Supabase.instance.client;

  JobsNotifier(this.filter) : super(const AsyncValue.loading()) {
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    state = const AsyncValue.loading();
    try {
      var query = _supabase
          .from('jobs')
          .select('*, companies(*)')
          .eq('is_active', true)
          .isFilter('deleted_at', null);

      if (filter.query.trim().isNotEmpty) {
        // Postgres Full-Text Search using generated tsvector
        query = query.textSearch('search_tsv', filter.query.trim());
      }

      if (filter.category != null && filter.category!.isNotEmpty) {
        query = query.eq('category', filter.category!);
      }

      if (filter.city != null && filter.city!.isNotEmpty) {
        query = query.ilike('city', '%${filter.city!}%');
      }

      if (filter.experience != null && filter.experience!.isNotEmpty) {
        query = query.eq('min_experience', filter.experience!);
      }

      if (filter.jobType != null && filter.jobType!.isNotEmpty) {
        query = query.eq('job_type', filter.jobType!);
      }

      final res = await query.order('created_at', ascending: false).limit(30);

      final list = (res as List).map((j) => JobModel.fromJson(j)).toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
