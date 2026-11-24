import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/candidate_profile_model.dart';
import '../../auth/providers/auth_provider.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<CandidateProfileModel?>>((ref) {
  final user = ref.watch(currentUserProvider);
  return ProfileNotifier(user?.id);
});

class ProfileNotifier extends StateNotifier<AsyncValue<CandidateProfileModel?>> {
  final String? userId;
  final _supabase = Supabase.instance.client;

  ProfileNotifier(this.userId) : super(const AsyncValue.loading()) {
    if (userId != null) {
      loadProfile();
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> loadProfile() async {
    if (userId == null) {
      state = const AsyncValue.data(null);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final res = await _supabase
          .from('candidate_profiles')
          .select()
          .eq('id', userId!)
          .maybeSingle();

      if (res == null) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.data(CandidateProfileModel.fromJson(res));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> uploadAvatar(File file) async {
    if (userId == null) return null;
    try {
      final ext = file.path.split('.').last;
      final fileName = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await _supabase.storage.from('avatars').upload(
        fileName,
        file,
        fileOptions: const FileOptions(upsert: true),
      );
      return _supabase.storage.from('avatars').getPublicUrl(fileName);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveProfile(CandidateProfileModel profile) async {
    state = const AsyncValue.loading();
    try {
      final data = profile.toJson();
      await _supabase.from('candidate_profiles').upsert(data);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
