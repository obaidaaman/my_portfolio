import 'package:flutter/material.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

class ExperienceSection extends StatelessWidget {
  final bool mobile;
  const ExperienceSection({super.key, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      mobile: mobile,
      background: AppColors.surface.withOpacity(0.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionLabel(
          text: 'Experience',
          subtitle: "Where I've built real-world AI systems",
        ),
        const SizedBox(height: 40),
        const _ExperienceCard(),
        const SizedBox(height: 16),
        const _EducationCard(),
      ]),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(experience.role, style: AppText.h3()),
              const SizedBox(height: 3),
              Text(experience.company, style: AppText.mono(color: AppColors.accent, size: 13)),
            ]),
          ),
          Text(experience.period, style: AppText.mono(size: 11)),
        ]),
        const SizedBox(height: 22),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: 18),
        ...experience.achievements.map(
          (a) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 12),
                child: Container(width: 4, height: 4, color: AppColors.accent),
              ),
              Expanded(
                child: Text(a, style: AppText.body(color: AppColors.textMuted, size: 14)),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _EducationCard extends StatelessWidget {
  const _EducationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(education.degree, style: AppText.h3(size: 16)),
            const SizedBox(height: 4),
            Text(education.institution, style: AppText.mono(color: AppColors.accent, size: 12)),
          ]),
        ),
        Text(education.period, style: AppText.mono(size: 11)),
      ]),
    );
  }
}