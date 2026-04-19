import 'package:flutter/cupertino.dart';

class AppColors {
  // 🌑 Core Backgrounds (OLED Optimized for "Hard" Theme)
  static const Color background = Color(0xFF000000); // Pure OLED Black
  static const Color surface = Color(0xFF1C1C1E); // iOS Secondary System Background
  static const Color surfaceElevated = Color(0xFF2C2C2E); // iOS Tertiary Background

  // ✨ Brand & AI Accents
  static const Color primary = CupertinoColors.activeBlue; 
  static const Color aiAccent = Color(0xFF5E5CE6); // iOS System Indigo (perfect for AI magic)
  static const Color accentGlow = Color(0x330A84FF); // Soft blue glow for active AI states

  // 📝 Typography
  static const Color textPrimary = CupertinoColors.white;
  static const Color textSecondary = Color(0x99EBEBF5); // iOS Secondary Label (60% Opacity)
  static const Color textTertiary = Color(0x4DEBEBF5); // iOS Tertiary Label (30% Opacity) 

  // 🪟 Glassmorphism & Material Borders
  static const Color glassOverlay = Color(0x12FFFFFF); // Ultra-sheer white
  static const Color glassBorder = Color(0x26FFFFFF); // Edge reflection
  static const Color divider = Color(0xA6545458); // iOS Opaque Separator (65% Opacity)

  // 🚦 System Semantics
  static const Color success = CupertinoColors.systemGreen;
  static const Color warning = CupertinoColors.systemOrange;
  static const Color destructive = CupertinoColors.systemRed;
}
