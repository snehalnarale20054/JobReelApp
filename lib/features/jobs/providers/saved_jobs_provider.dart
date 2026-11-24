import 'package:flutter_riverpod/flutter_riverpod.dart';

final savedJobsProvider = StateNotifierProvider<SavedJobsNotifier, Set<String>>((ref) {
  return SavedJobsNotifier();
});

class SavedJobsNotifier extends StateNotifier<Set<String>> {
  SavedJobsNotifier() : super({});

  void toggleSave(String jobId) {
    if (state.contains(jobId)) {
      state = {...state}..remove(jobId);
    } else {
      state = {...state, jobId};
    }
  }

  bool isSaved(String jobId) => state.contains(jobId);
}
