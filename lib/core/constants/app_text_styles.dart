import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const _font = 'Roboto';

  static const displayLarge = TextStyle(
    fontFamily: _font, fontSize: 32,
    fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static const displayMedium = TextStyle(
    fontFamily: _font, fontSize: 26,
    fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static const headlineLarge = TextStyle(
    fontFamily: _font, fontSize: 22,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const headlineMedium = TextStyle(
    fontFamily: _font, fontSize: 18,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const headlineSmall = TextStyle(
    fontFamily: _font, fontSize: 16,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const bodyLarge = TextStyle(
    fontFamily: _font, fontSize: 15,
    fontWeight: FontWeight.w400, color: AppColors.textPrimary,
  );
  static const bodyMedium = TextStyle(
    fontFamily: _font, fontSize: 13,
    fontWeight: FontWeight.w400, color: AppColors.textSecondary,
  );
  static const bodySmall = TextStyle(
    fontFamily: _font, fontSize: 11,
    fontWeight: FontWeight.w400, color: AppColors.textHint,
  );
  static const labelLarge = TextStyle(
    fontFamily: _font, fontSize: 14,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const amountLarge = TextStyle(
    fontFamily: _font, fontSize: 36,
    fontWeight: FontWeight.w700, color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  static const amountMedium = TextStyle(
    fontFamily: _font, fontSize: 20,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
}