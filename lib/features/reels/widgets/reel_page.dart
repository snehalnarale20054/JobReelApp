import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/reel_model.dart';
import '../providers/reel_player_provider.dart';
import 'reel_overlay.dart';
import 'reel_actions_bar.dart';

/// One full-screen reel — video + overlay + action buttons.
class ReelPage extends ConsumerWidget {
  final ReelModel reel;
  final int index;
  final bool isActive;

  const ReelPage({
    super.key,
    required this.reel,
    required this.index,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllers = ref.watch(reelPlayerProvider);
    final controller = controllers[index];

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Video / thumbnail background ──────────────────────────────────
        _VideoBackground(
          reel: reel,
          controller: controller,
        ),

        // ── Gradient scrim so overlays are readable ───────────────────────
        const _Scrim(),

        // ── Bottom overlay: name, caption, skill chips ────────────────────
        Positioned(
          left: 0,
          right: 72, // leave room for the action bar on the right
          bottom: 0,
          child: ReelOverlay(reel: reel),
        ),

        // ── Right-side action bar: like, mute, share ──────────────────────
        Positioned(
          right: 8,
          bottom: 80,
          child: ReelActionsBar(reel: reel, index: index),
        ),
      ],
    );
  }
}

// ── Video background widget ──────────────────────────────────────────────────

class _VideoBackground extends StatelessWidget {
  final ReelModel reel;
  final VideoPlayerController? controller;

  const _VideoBackground({required this.reel, required this.controller});

  @override
  Widget build(BuildContext context) {
    final ctrl = controller;

    // Show thumbnail until the controller is ready
    if (ctrl == null || !ctrl.value.isInitialized) {
      return _Thumbnail(url: reel.thumbnailUrl);
    }

    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: ctrl.value.size.width,
        height: ctrl.value.size.height,
        child: VideoPlayer(ctrl),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String? url;
  const _Thumbnail({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return Container(color: Colors.black87);
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: Colors.black87),
      errorWidget: (_, __, ___) => Container(color: Colors.black87),
    );
  }
}

// ── Gradient scrim ───────────────────────────────────────────────────────────

class _Scrim extends StatelessWidget {
  const _Scrim();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.5, 1.0],
          colors: [Colors.transparent, Colors.black87],
        ),
      ),
    );
  }
}
