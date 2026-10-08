import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Widget tipografi logo resmi Naegablé Bakehaus.
/// Merender logo dengan latar belakang transparan yang tajam di semua resolusi,
/// menghindari artefak kotak putih dari file raster logo solid.
class BrandLogoView extends StatelessWidget {
  const BrandLogoView({
    super.key,
    this.primaryColor = AppColors.textOnDark,
    this.taglineColor = AppColors.accent,
    this.fontSize = 38.0,
  });

  final Color primaryColor;
  final Color taglineColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'naegablé',
          style: AppTypography.brandScript.copyWith(
            fontSize: fontSize,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          'BAKEHAUS',
          style: AppTypography.brandTagline.copyWith(
            fontSize: fontSize * 0.32,
            color: taglineColor,
          ),
        ),
      ],
    );
  }
}
