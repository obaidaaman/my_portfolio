import 'package:flutter/material.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

class HeroSection extends StatelessWidget {
  final bool mobile;
  final VoidCallback onContact;
  const HeroSection({super.key, required this.mobile, required this.onContact});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      mobile: mobile,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 560),
        child: mobile
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _HeroCard(),
                const SizedBox(height: 40),
                _HeroContent(onContact: onContact),
              ])
            : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(flex: 6, child: _HeroContent(onContact: onContact)),
                const SizedBox(width: 60),
                const Expanded(flex: 4, child: _HeroCard()),
              ]),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  final VoidCallback onContact;
  const _HeroContent({required this.onContact});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 20, height: 1, color: AppColors.accent),
        const SizedBox(width: 10),
        Text('AVAILABLE FOR OPPORTUNITIES',
            style: AppText.mono(color: AppColors.accent, size: 11)),
      ]),
      const SizedBox(height: 26),
      Text(Profile.name, style: AppText.h1()),
      const SizedBox(height: 16),
      Row(children: [
        Text('Software Engineer  —  ', style: AppText.body(color: AppColors.textMuted)),
        const _RoleRotator(),
      ]),
      const SizedBox(height: 20),
      SizedBox(
        width: 480,
        child: Text(Profile.tagline, style: AppText.body(color: AppColors.textMuted)),
      ),
      const SizedBox(height: 36),
      Wrap(spacing: 12, runSpacing: 12, children: [
        PrimaryButton(label: 'Get In Touch', icon: Icons.arrow_forward_rounded, onTap: onContact),
        OutlineButton(
          label: 'Resume',
          icon: Icons.download_rounded,
          onTap: () => openUrl(Profile.resumeAssetPath),
        ),
        OutlineButton(
          label: 'GitHub',
          icon: Icons.code_rounded,
          onTap: () => openUrl(Profile.github),
        ),
        OutlineButton(
          label: 'LinkedIn',
          icon: Icons.person_outline_rounded,
          onTap: () => openUrl(Profile.linkedin),
        ),
      ]),
    ]);
  }
}

/// Crossfades between role labels on a slow interval. Deliberately not a
/// per-character typewriter — that reads as a template effect rather than
/// a considered detail.
class _RoleRotator extends StatefulWidget {
  const _RoleRotator();
  @override
  State<_RoleRotator> createState() => _RoleRotatorState();
}

class _RoleRotatorState extends State<_RoleRotator> {
  int _index = 0;
  @override
  void initState() {
    super.initState();
    _schedule();
  }

  void _schedule() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % Profile.rotatingRoles.length);
      _schedule();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        Profile.rotatingRoles[_index],
        key: ValueKey(_index),
        style: AppText.mono(color: AppColors.accent, size: 15),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bg,
              border: Border.all(color: AppColors.accent, width: 1.4),
            ),
            child: Text(Profile.initials,
                style: AppText.mono(color: AppColors.accent, size: 15, weight: FontWeight.w700)),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(Profile.name, style: AppText.h3()),
            Text(Profile.role, style: AppText.mono(size: 12)),
          ]),
        ]),
        const SizedBox(height: 22),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: 18),
        for (final stat in Profile.stats) ...[
          StatRow(stat.label, stat.value),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 6),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: 16),
        Text('CORE STACK', style: AppText.mono(color: AppColors.textDim, size: 11)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [for (final t in Profile.coreStack) TagChip(t)],
        ),
      ]),
    );
  }
}