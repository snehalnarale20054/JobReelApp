import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../shared/empty_tab_screen.dart';

// PHASE 5: Replace with Supabase Realtime chat — text, emoji, image, document, job cards.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyTabScreen(
      title: l10n.tabMessages,
      icon: Icons.chat_bubble_outline,
    );
  }
}
