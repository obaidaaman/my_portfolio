import 'package:flutter/material.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';

class NavBar extends StatelessWidget {
  final bool scrolled;
  final bool mobile;
  final void Function(int index) onTap;

  const NavBar({
    super.key,
    required this.scrolled,
    required this.mobile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? AppSpacing.horizontalPadMobile : AppSpacing.horizontalPadDesktop,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: scrolled ? AppColors.surface.withOpacity(0.94) : Colors.transparent,
        border: scrolled ? const Border(bottom: BorderSide(color: AppColors.border)) : null,
      ),
      child: Row(children: [
        Text(Profile.name.toUpperCase(),
            style: AppText.mono(color: AppColors.text, size: 13, weight: FontWeight.w700)),
        const Spacer(),
        if (!mobile)
          ...navSections.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: _NavItem(label: e.value, onTap: () => onTap(e.key)),
                ),
              ),
      ]),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _NavItem({required this.label, required this.onTap});
  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 120),
          style: AppText.mono(color: _hover ? AppColors.accent : AppColors.textMuted, size: 12),
          child: Text(widget.label.toUpperCase()),
        ),
      ),
    );
  }
}