import 'package:flutter/material.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

class SkillsSection extends StatelessWidget {
  final bool mobile;
  const SkillsSection({super.key, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      mobile: mobile,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionLabel(
          text: 'Skills & Technologies',
          subtitle: 'The tools I use to build intelligent systems',
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: skillGroups.map((g) => _SkillGroupCard(group: g)).toList(),
        ),
      ]),
    );
  }
}

class _SkillGroupCard extends StatelessWidget {
  final SkillGroup group;
  const _SkillGroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(group.category.toUpperCase(), style: AppText.mono(color: AppColors.accent, size: 11)),
        const SizedBox(height: 4),
        Container(width: 24, height: 1, color: AppColors.border),
        const SizedBox(height: 14),
        ...group.items.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(s, style: AppText.body(size: 13)),
          ),
        ),
      ]),
    );
  }
}