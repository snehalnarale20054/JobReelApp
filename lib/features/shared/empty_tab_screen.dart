import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Reusable empty-state scaffold for Phase 0 placeholder screens.
/// Replaced screen by screen as phases progress.
class EmptyTabScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? debugWidget;

  const EmptyTabScreen({
    super.key,
    required this.title,
    required this.icon,
    this.debugWidget,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 64, color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text(
                    l10n.comingSoon,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (debugWidget != null) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: debugWidget!,
            ),
          ],
        ],
      ),
    );
  }
}
