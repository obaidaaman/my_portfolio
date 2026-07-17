import 'package:flutter/material.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPadDesktop,
        vertical: 26,
      ),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 8,
        children: [
          Text(Profile.name.toUpperCase(),
              style: AppText.mono(color: AppColors.textMuted, size: 12, weight: FontWeight.w700)),
          Text('Built with Flutter', style: AppText.mono(color: AppColors.textDim, size: 11)),
          Text('© 2025 ${Profile.name}', style: AppText.mono(color: AppColors.textDim, size: 11)),
        ],
      ),
    );
  }
}