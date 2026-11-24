import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/reels_provider.dart';
import 'widgets/reel_page_view.dart';

/// Root screen for the Reels tab.
/// Renders edge-to-edge (no AppBar, no status bar) for the full TikTok-style feel.
class ReelsScreen extends ConsumerWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Edge-to-edge: hide status bar while this screen is visible
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final feedAsync = ref.watch(reelsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: feedAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (e, _) => _ErrorState(onRetry: () {
          ref.read(reelsProvider.notifier).fetchInitial();
        }),
        data: (reels) {
          if (reels.isEmpty) {
            return const _EmptyState();
          }
          return ReelPageView(reels: reels);
        },
      ),
    );
  }
}

// ── Error state ──────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, color: Colors.white54, size: 56),
          const SizedBox(height: 16),
          const Text(
            'Could not load videos.\nCheck your connection.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_circle_outline, color: Colors.white38, size: 64),
          SizedBox(height: 16),
          Text(
            'No reels yet.\nCheck back soon!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
