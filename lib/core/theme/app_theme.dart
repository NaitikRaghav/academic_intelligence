import 'package:flutter/cupertino.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  static const CupertinoThemeData darkTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    primaryContrastingColor: CupertinoColors.white,
    scaffoldBackgroundColor: AppColors.background,
    barBackgroundColor: AppColors.surface,
    
    // 🔤 Injecting our strict SF Pro typography system globally
    textTheme: CupertinoTextThemeData(
      primaryColor: AppColors.textPrimary,
      textStyle: AppTypography.body,
      actionTextStyle: TextStyle(
        color: AppColors.primary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      navTitleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      navLargeTitleTextStyle: AppTypography.largeTitle,
    ),
  );
}