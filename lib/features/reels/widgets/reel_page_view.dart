import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reel_model.dart';
import '../providers/reel_player_provider.dart';
import '../providers/reels_provider.dart';
import 'reel_page.dart';

/// The vertical PageView that drives the entire Reels feed.
/// Handles: autoplay, preloading, pagination trigger.
class ReelPageView extends ConsumerStatefulWidget {
  final List<ReelModel> reels;

  const ReelPageView({super.key, required this.reels});

  @override
  ConsumerState<ReelPageView> createState() => _ReelPageViewState();
}

class _ReelPageViewState extends ConsumerState<ReelPageView> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Seed the player notifier with the reel list
    final playerNotifier = ref.read(reelPlayerProvider.notifier);
    playerNotifier.setReels(widget.reels);

    // Kick off the first page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      playerNotifier.onPageChanged(0);
    });
  }

  @override
  void didUpdateWidget(ReelPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reels != oldWidget.reels) {
      ref.read(reelPlayerProvider.notifier).setReels(widget.reels);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    _currentIndex = index;

    // Trigger preload + autoplay
    ref.read(reelPlayerProvider.notifier).onPageChanged(index);

    // Paginate when 3 reels from the end
    if (index >= widget.reels.length - 3) {
      ref.read(reelsProvider.notifier).fetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: widget.reels.length,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) {
        return ReelPage(
          reel: widget.reels[index],
          index: index,
          isActive: index == _currentIndex,
        );
      },
    );
  }
}
