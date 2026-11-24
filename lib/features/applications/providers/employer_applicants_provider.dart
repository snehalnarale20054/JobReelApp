import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';
import '../../auth/providers/auth_provider.dart';

final employerApplicantsProvider = StateNotifierProvider.family<
    EmployerApplicantsNotifier, AsyncValue<List<ApplicationModel>>, String?>(
  (ref, jobId) {
    final user = ref.watch(currentUserProvider);
    return EmployerApplicantsNotifier(user?.id, jobId);
  },
);

class EmployerApplicantsNotifier
    extends StateNotifier<AsyncValue<List<ApplicationModel>>> {
  final String? employerId;
  final String? jobId;
  final _supabase = Supabase.instance.client;

  EmployerApplicantsNotifier(this.employerId, this.jobId)
      : super(const AsyncValue.loading()) {
    loadApplicants();
  }

  Future<void> loadApplicants() async {
    if (employerId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      var query = _supabase
          .from('applications')
          .select('*, jobs!inner(*), candidate_profiles!candidate_id(*)');

      if (jobId != null) {
        query = query.eq('job_id', jobId!);
      } else {
        query = query.eq('jobs.company_id', employerId!);
      }

      final res = await query.order('created_at', ascending: false);
      final list = (res as List).map((a) => ApplicationModel.fromJson(a)).toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus(String applicationId, ApplicationStatus newStatus) async {
    try {
      await _supabase.from('applications').update({
        'status': newStatus.name,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', applicationId);

      final current = state.valueOrNull ?? [];
      state = AsyncValue.data(
        current.map((app) {
          if (app.id == applicationId) {
            return ApplicationModel(
              id: app.id,
              jobId: app.jobId,
              candidateId: app.candidateId,
              status: newStatus,
              notes: app.notes,
              createdAt: app.createdAt,
              updatedAt: DateTime.now(),
              job: app.job,
              candidateProfile: app.candidateProfile,
            );
          }
          return app;
        }).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
