import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/reel_model.dart';

const _pageSize = 10;

// ── Feed provider ────────────────────────────────────────────────────────────

/// Holds the full list of reels loaded so far and handles pagination.
final reelsProvider =
    StateNotifierProvider<ReelsFeedNotifier, AsyncValue<List<ReelModel>>>(
  (ref) => ReelsFeedNotifier(),
);

class ReelsFeedNotifier extends StateNotifier<AsyncValue<List<ReelModel>>> {
  ReelsFeedNotifier() : super(const AsyncValue.loading()) {
    fetchInitial();
  }

  final _db = Supabase.instance.client;
  bool _isFetching = false;
  bool _hasMore = true;

  Future<void> fetchInitial() async {
    state = const AsyncValue.loading();
    _hasMore = true;
    try {
      final rows = await _db
          .from('reels')
          .select()
          .order('created_at', ascending: false)
          .limit(_pageSize);
      final reels = (rows as List).map((r) => ReelModel.fromJson(r)).toList();
      _hasMore = reels.length == _pageSize;
      state = AsyncValue.data(reels);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Call this when the user is 3 reels from the end of the loaded list.
  Future<void> fetchMore() async {
    if (_isFetching || !_hasMore) return;
    final current = state.valueOrNull;
    if (current == null || current.isEmpty) return;

    _isFetching = true;
    try {
      final lastCreatedAt = current.last.createdAt.toIso8601String();
      final rows = await _db
          .from('reels')
          .select()
          .lt('created_at', lastCreatedAt)
          .order('created_at', ascending: false)
          .limit(_pageSize);
      final newReels =
          (rows as List).map((r) => ReelModel.fromJson(r)).toList();
      _hasMore = newReels.length == _pageSize;
      state = AsyncValue.data([...current, ...newReels]);
    } catch (_) {
      // Silently fail — user still sees what's loaded
    } finally {
      _isFetching = false;
    }
  }
}

// ── Local like state (Phase 4 wires this to the DB) ─────────────────────────

/// A Set of reel IDs the user has liked this session.
/// PHASE 4: persist to `likes` table and sync like_count.
final localLikesProvider =
    StateNotifierProvider<LocalLikesNotifier, Set<String>>(
  (ref) => LocalLikesNotifier(),
);

class LocalLikesNotifier extends StateNotifier<Set<String>> {
  LocalLikesNotifier() : super({});

  void toggle(String reelId) {
    if (state.contains(reelId)) {
      state = {...state}..remove(reelId);
    } else {
      state = {...state, reelId};
    }
  }

  bool isLiked(String reelId) => state.contains(reelId);
}
