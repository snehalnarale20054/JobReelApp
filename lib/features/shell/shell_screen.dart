import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/locale_provider.dart';

/// The persistent shell that holds the bottom navigation bar.
/// Each tab branch is managed by [StatefulShellRoute.indexedStack]
/// so tab state survives navigation.
class ShellScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ShellScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          // Restore system UI when leaving the Reels tab (index 0)
          if (index != 0) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        l10n: l10n,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final AppLocalizations l10n;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.play_circle_outline),
          activeIcon: const Icon(Icons.play_circle),
          label: l10n.tabReels,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.search_outlined),
          activeIcon: const Icon(Icons.search),
          label: l10n.tabJobs,
        ),
        BottomNavigationBarItem(
          icon: Container(
            width: AppTheme.minTouchTarget,
            height: AppTheme.minTouchTarget,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
          activeIcon: Container(
            width: AppTheme.minTouchTarget,
            height: AppTheme.minTouchTarget,
            decoration: const BoxDecoration(
              color: AppTheme.primaryDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
          label: l10n.tabPost,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat_bubble_outline),
          activeIcon: const Icon(Icons.chat_bubble),
          label: l10n.tabMessages,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: l10n.tabProfile,
        ),
      ],
    );
  }
}
