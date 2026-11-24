import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';
import '../../auth/providers/auth_provider.dart';

final myApplicationsProvider =
    StateNotifierProvider<MyApplicationsNotifier, AsyncValue<List<ApplicationModel>>>(
  (ref) {
    final user = ref.watch(currentUserProvider);
    return MyApplicationsNotifier(user?.id);
  },
);

class MyApplicationsNotifier extends StateNotifier<AsyncValue<List<ApplicationModel>>> {
  final String? userId;
  final _supabase = Supabase.instance.client;

  MyApplicationsNotifier(this.userId) : super(const AsyncValue.loading()) {
    if (userId != null) {
      loadMyApplications();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadMyApplications() async {
    if (userId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final res = await _supabase
          .from('applications')
          .select('*, jobs(*, companies(*))')
          .eq('candidate_id', userId!)
          .order('created_at', ascending: false);

      final list = (res as List).map((a) => ApplicationModel.fromJson(a)).toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> submitApplication(String jobId) async {
    if (userId == null) throw Exception('User not logged in');

    await _supabase.from('applications').insert({
      'job_id': jobId,
      'candidate_id': userId,
      'status': 'applied',
    });

    await loadMyApplications();
  }

  bool hasApplied(String jobId) {
    final list = state.valueOrNull ?? [];
    return list.any((app) => app.jobId == jobId);
  }
}
