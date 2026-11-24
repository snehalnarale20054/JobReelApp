import 'package:flutter/material.dart';
import '../models/reel_model.dart';

/// Bottom-left overlay showing uploader name, caption and skill chips.
class ReelOverlay extends StatelessWidget {
  final ReelModel reel;

  const ReelOverlay({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Uploader name
          Text(
            reel.uploaderName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
            ),
          ),

          if (reel.caption != null && reel.caption!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _Caption(text: reel.caption!),
          ],

          if (reel.skillTags.isNotEmpty) ...[
            const SizedBox(height: 10),
            _SkillChips(tags: reel.skillTags),
          ],
        ],
      ),
    );
  }
}

// ── Caption with expand/collapse ─────────────────────────────────────────────

class _Caption extends StatefulWidget {
  final String text;
  const _Caption({required this.text});

  @override
  State<_Caption> createState() => _CaptionState();
}

class _CaptionState extends State<_Caption> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Text(
        widget.text,
        maxLines: _expanded ? null : 2,
        overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.4,
          shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
        ),
      ),
    );
  }
}

// ── Skill tag chips ──────────────────────────────────────────────────────────

class _SkillChips extends StatelessWidget {
  final List<String> tags;
  const _SkillChips({required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags.map((tag) => _Chip(label: tag)).toList(),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white38),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
