import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

class ContactSection extends StatelessWidget {
  final bool mobile;
  const ContactSection({super.key, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      mobile: mobile,
      background: AppColors.surface.withOpacity(0.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionLabel(
          text: 'Contact',
          subtitle: "Let's build something great together",
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: contactChannels.map((c) => _ContactCard(channel: c, mobile: mobile)).toList(),
        ),
      ]),
    );
  }
}

class _ContactCard extends StatefulWidget {
  final ContactChannel channel;
  final bool mobile;
  const _ContactCard({required this.channel, required this.mobile});
  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _hover = false;
  bool _copied = false;

  IconData get _icon {
    switch (widget.channel.label) {
      case 'Email':
        return Icons.email_outlined;
      case 'LinkedIn':
        return Icons.person_outline_rounded;
      default:
        return Icons.code_rounded;
    }
  }

  void _open() {
    final c = widget.channel;
    c.kind == ContactKind.email ? openMail(c.value) : openUrl(c.value);
  }

  void _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.channel.value));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.channel;
    final displayValue = c.kind == ContactKind.email
        ? c.value
        : c.value.replaceFirst('https://', '').replaceFirst('www.', '');

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: _open,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: widget.mobile ? double.infinity : 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _hover ? AppColors.cardHover : AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: _hover ? AppColors.borderStrong : AppColors.border),
          ),
          child: Column(children: [
            Icon(_icon, color: _hover ? AppColors.accent : AppColors.textMuted, size: 22),
            const SizedBox(height: 12),
            Text(c.label, style: AppText.h3(size: 15)),
            const SizedBox(height: 4),
            Text(
              displayValue,
              style: AppText.mono(size: 10),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            _pill(icon: Icons.open_in_new_rounded, label: 'Open', onTap: _open),
            const SizedBox(height: 8),
            _pill(
              icon: _copied ? Icons.check_rounded : Icons.copy_rounded,
              label: _copied ? 'Copied' : 'Copy',
              onTap: _copy,
              highlighted: _copied,
            ),
          ]),
        ),
      ),
    );
  }

  Widget _pill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    final color = highlighted ? AppColors.accent : AppColors.textMuted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(label, style: AppText.mono(color: color, size: 11)),
        ]),
      ),
    );
  }
}