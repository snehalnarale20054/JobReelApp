import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/reel_model.dart';

/// Manages the lifecycle of [VideoPlayerController]s for the feed.
///
/// Strategy: keep controllers alive for the window [i-1 .. i+2].
/// Everything outside that window is disposed to free memory.
/// This is the main defence against stutter on low-end devices.
final reelPlayerProvider =
    StateNotifierProvider<ReelPlayerNotifier, Map<int, VideoPlayerController>>(
  (ref) => ReelPlayerNotifier(),
);

class ReelPlayerNotifier
    extends StateNotifier<Map<int, VideoPlayerController>> {
  ReelPlayerNotifier() : super({});

  /// The reels list — set once from the feed widget.
  List<ReelModel> _reels = [];

  void setReels(List<ReelModel> reels) {
    _reels = reels;
  }

  /// Called whenever the page index changes.
  /// Initialises controllers for [i-1, i, i+1, i+2] and disposes the rest.
  Future<void> onPageChanged(int index) async {
    final keepIndices = {index - 1, index, index + 1, index + 2}
        .where((i) => i >= 0 && i < _reels.length)
        .toSet();

    // Dispose controllers that have scrolled out of the keep window
    final toRemove = state.keys
        .where((i) => !keepIndices.contains(i))
        .toList();

    final next = Map<int, VideoPlayerController>.from(state);
    for (final i in toRemove) {
      await next[i]?.dispose();
      next.remove(i);
    }

    // Pause all non-current controllers
    for (final entry in next.entries) {
      if (entry.key != index) {
        await entry.value.pause();
      }
    }

    // Initialise and buffer new controllers in the keep window
    for (final i in keepIndices) {
      if (!next.containsKey(i)) {
        final ctrl = VideoPlayerController.networkUrl(
          Uri.parse(_reels[i].playbackUrl),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
        );
        next[i] = ctrl;
        // Don't await — initialise in background so the UI doesn't block
        ctrl.initialize().then((_) {
          ctrl.setLooping(true);
          if (i == index) ctrl.play();
        }).catchError((e) {
          debugPrint('VideoPlayer init error [$i]: $e');
        });
      }
    }

    // Play the current index if already initialised
    if (next[index]?.value.isInitialized == true) {
      await next[index]?.play();
    }

    state = next;
  }

  VideoPlayerController? controllerFor(int index) => state[index];

  /// Mute / unmute all controllers together.
  Future<void> setMuted(bool muted) async {
    for (final ctrl in state.values) {
      await ctrl.setVolume(muted ? 0 : 1);
    }
  }

  @override
  void dispose() {
    for (final ctrl in state.values) {
      ctrl.dispose();
    }
    super.dispose();
  }
}

// ── Simple mute state ────────────────────────────────────────────────────────
final mutedProvider = StateProvider<bool>((ref) => false);
