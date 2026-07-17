import 'package:flutter/material.dart';
import 'dart:js' as js;
import '../theme/app_theme.dart';

/// Faint hairline grid — the only background texture in the app. No radial
/// glow, no gradient wash. Reads as a drafting table, not a launch page.
class GridBackground extends StatelessWidget {
  const GridBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: _GridPainter()),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withOpacity(0.22)
      ..strokeWidth = 0.5;
    const spacing = 64.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}

/// Wraps section content with a consistent max width and horizontal
/// padding so every section lines up on the same grid regardless of who
/// wrote it.
class SectionContainer extends StatelessWidget {
  final Widget child;
  final bool mobile;
  final Color? background;
  const SectionContainer({
    super.key,
    required this.child,
    required this.mobile,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: background,
      padding: EdgeInsets.symmetric(
        horizontal: mobile
            ? AppSpacing.horizontalPadMobile
            : AppSpacing.horizontalPadDesktop,
        vertical: mobile ? AppSpacing.sectionMobile : AppSpacing.section,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.pageMaxWidth),
          child: child,
        ),
      ),
    );
  }
}

/// A rule + eyebrow + heading — used to open every section identically.
class SectionLabel extends StatelessWidget {
  final String text;
  final String subtitle;
  const SectionLabel({super.key, required this.text, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 20, height: 1, color: AppColors.accent),
        const SizedBox(width: 10),
        Text(text.toUpperCase(),
            style: AppText.mono(color: AppColors.accent, size: 11, letterSpacing: 3)),
      ]),
      const SizedBox(height: 10),
      Text(text, style: AppText.h2()),
      const SizedBox(height: 10),
      Text(subtitle, style: AppText.body(color: AppColors.textMuted)),
    ]);
  }
}

class PrimaryButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const PrimaryButton(
      {super.key, required this.label, required this.icon, required this.onTap});
  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          decoration: BoxDecoration(
            color: _hover ? AppColors.accentDim : AppColors.accent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(widget.label,
                style: AppText.mono(color: AppColors.bg, size: 13, weight: FontWeight.w700)),
            const SizedBox(width: 8),
            Icon(widget.icon, color: AppColors.bg, size: 15),
          ]),
        ),
      ),
    );
  }
}

class OutlineButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const OutlineButton(
      {super.key, required this.label, required this.icon, required this.onTap});
  @override
  State<OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<OutlineButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          decoration: BoxDecoration(
            color: _hover ? AppColors.card : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: _hover ? AppColors.borderStrong : AppColors.border),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(widget.icon, color: _hover ? AppColors.text : AppColors.textMuted, size: 15),
            const SizedBox(width: 8),
            Text(widget.label,
                style: AppText.mono(color: _hover ? AppColors.text : AppColors.textMuted)),
          ]),
        ),
      ),
    );
  }
}

class StatRow extends StatelessWidget {
  final String label;
  final String value;
  const StatRow(this.label, this.value, {super.key});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label, style: AppText.mono(size: 12)),
      const Spacer(),
      Text(value, style: AppText.mono(color: AppColors.text, size: 12, weight: FontWeight.w700)),
    ]);
  }
}

/// Small outlined icon-button used for external links on cards.
class IconLink extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const IconLink({super.key, required this.icon, required this.tooltip, required this.onTap});
  @override
  State<IconLink> createState() => _IconLinkState();
}

class _IconLinkState extends State<IconLink> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(widget.icon,
                size: 17, color: _hover ? AppColors.accent : AppColors.textDim),
          ),
        ),
      ),
    );
  }
}

/// Generic tag chip used for tech-stack labels throughout the app.
class TagChip extends StatelessWidget {
  final String label;
  const TagChip(this.label, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: AppText.mono(color: AppColors.textDim, size: 10)),
    );
  }
}

/// Opens a URL in a new tab (web) — isolated here so only one file in the
/// app touches platform interop.
void openUrl(String url) => js.context.callMethod('open', [url]);

/// Opens the user's mail client with a prefilled recipient.
void openMail(String email) => openUrl('mailto:$email');