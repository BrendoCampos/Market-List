import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Roxo Moderno
  static const primary = Color(0xFF6366F1);
  static const primaryLight = Color(0xFF818CF8);
  static const primaryDark = Color(0xFF4F46E5);
  
  // Secondary Colors
  static const secondary = Color(0xFF8B5CF6);
  static const secondaryLight = Color(0xFFA78BFA);
  
  // Accent Colors
  static const accent = Color(0xFF10B981);
  static const accentLight = Color(0xFF34D399);
  
  // Status Colors
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
  
  // Neutral Colors
  static const background = Color(0xFFF9FAFB);
  static const surface = Colors.white;
  static const surfaceVariant = Color(0xFFF3F4F6);
  
  // Dark Theme - Cores mais claras para melhor contraste
  static const backgroundDark = Color(0xFF1A1A2E);
  static const surfaceDark = Color(0xFF25274D);
  static const surfaceVariantDark = Color(0xFF2E3047);
  
  // Text Colors
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  
  static const textPrimaryDark = Color(0xFFFFFFFF);
  static const textSecondaryDark = Color(0xFFE0E0E0);
  
  // Border Colors
  static const border = Color(0xFFE5E7EB);
  
  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const accentGradient = LinearGradient(
    colors: [accent, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFFAFAFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
