import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../models/reel_model.dart';
import '../providers/reel_player_provider.dart';
import '../providers/reels_provider.dart';

/// Right-side vertical action bar: Like, Mute, Share.
class ReelActionsBar extends ConsumerWidget {
  final ReelModel reel;
  final int index;

  const ReelActionsBar({super.key, required this.reel, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedIds = ref.watch(localLikesProvider);
    final isLiked = likedIds.contains(reel.id);
    final isMuted = ref.watch(mutedProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like
        _ActionButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Colors.red : Colors.white,
          label: _formatCount(reel.likeCount + (isLiked ? 1 : 0)),
          onTap: () => ref.read(localLikesProvider.notifier).toggle(reel.id),
        ),
        const SizedBox(height: 20),

        // Mute / Unmute
        _ActionButton(
          icon: isMuted ? Icons.volume_off : Icons.volume_up,
          color: Colors.white,
          label: isMuted ? 'Muted' : 'Sound',
          onTap: () {
            final next = !isMuted;
            ref.read(mutedProvider.notifier).state = next;
            ref.read(reelPlayerProvider.notifier).setMuted(next);
          },
        ),
        const SizedBox(height: 20),

        // Share
        _ActionButton(
          icon: Icons.share,
          color: Colors.white,
          label: 'Share',
          onTap: () => Share.share(
            '${reel.uploaderName} — ${reel.caption ?? ''}\n${reel.playbackUrl}',
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 56,       // ≥ 48dp touch target
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32,
                shadows: const [Shadow(blurRadius: 6, color: Colors.black54)]),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
