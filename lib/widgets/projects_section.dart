import 'package:flutter/material.dart';
import '../data/portfolio_data.dart';
import '../models/project.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

class ProjectsSection extends StatelessWidget {
  final bool mobile;
  const ProjectsSection({super.key, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      mobile: mobile,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionLabel(
          text: 'Projects',
          subtitle: "Things I've built, shipped and maintained",
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: projects.map((p) => _ProjectCard(project: p, mobile: mobile)).toList(),
        ),
      ]),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final Project project;
  final bool mobile;
  const _ProjectCard({required this.project, required this.mobile});
  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.mobile ? double.infinity : 330,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _hover ? AppColors.cardHover : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: _hover ? AppColors.borderStrong : AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(p.tag.toUpperCase(), style: AppText.mono(color: AppColors.accent, size: 10)),
            const Spacer(),
            if (p.github != null)
              IconLink(icon: Icons.code_rounded, tooltip: 'GitHub', onTap: () => openUrl(p.github!)),
            if (p.web != null)
              IconLink(
                  icon: Icons.open_in_new_rounded, tooltip: 'Live', onTap: () => openUrl(p.web!)),
          ]),
          const SizedBox(height: 14),
          Text(p.title, style: AppText.h3(size: 18)),
          const SizedBox(height: 10),
          Text(
            p.description,
            style: AppText.body(color: AppColors.textMuted, size: 13),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Wrap(spacing: 6, runSpacing: 6, children: [for (final c in p.chips) TagChip(c)]),
        ]),
      ),
    );
  }
}