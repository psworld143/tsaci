import 'package:flutter/material.dart';

/// TSACI App Colors
/// Tailwind-inspired color palette based on specifications
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2D6A4F); // Forest Green
  static const Color primaryLight = Color(0xFF40916C); // Accent Green
  static const Color primaryDark = Color(0xFF1B4332);

  // Background Colors
  static const Color background = Color(0xFFF8F9FA); // Light Gray
  static const Color backgroundDark = Color(0xFF1A1A1A); // Dark Mode
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2A2A2A);

  // Text Colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFFADB5BD);

  // Semantic Colors
  static const Color success = Color(0xFF28A745);
  static const Color successLight = Color(0xFF48BB78);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFD54F);
  static const Color error = Color(0xFFDC3545);
  static const Color errorLight = Color(0xFFFC8181);
  static const Color info = Color(0xFF17A2B8);
  static const Color infoLight = Color(0xFF63B3ED);

  // Neutral Grays (Tailwind-style)
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Colors
  static Color shadow = Colors.black.withOpacity(0.1);
  static Color shadowMedium = Colors.black.withOpacity(0.15);
  static Color shadowHeavy = Colors.black.withOpacity(0.25);

  // Chart Colors (for data visualization)
  static const List<Color> chartColors = [
    Color(0xFF2D6A4F), // Primary
    Color(0xFF40916C), // Accent
    Color(0xFF52B788), // Light Green
    Color(0xFF74C69D), // Mint
    Color(0xFF95D5B2), // Pale Green
    Color(0xFFB7E4C7), // Very Light Green
    Color(0xFFD8F3DC), // Lightest Green
    Color(0xFF17A2B8), // Info Blue
  ];
}
