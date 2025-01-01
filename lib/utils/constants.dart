import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFFFF7B2C);
  static const Color primaryLight = Color(0xFFFFEDE6);
  
  // Base Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF222222);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);
  
  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceBackground = Color(0xFFF8F8F8);
  
  // Border & Divider Colors
  static const Color border = Color(0xFFEEEEEE);
  static const Color divider = Color(0xFFF1F1F1);
  
  // Input Field Colors
  static const Color inputBackground = Color(0xFFFAFAFA);
  static const Color inputBorder = Color(0xFFE0E0E0);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF2196F3);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFFFF7B2C),
    Color(0xFFFF9A5A),
  ];
}

class AppSpacing {
  // Padding & Margin
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  
  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  
  // Button Heights
  static const double buttonHeight = 52.0;
  static const double inputHeight = 48.0;
}

class AppShadows {
  static const BoxShadow small = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );
  
  static const BoxShadow medium = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );
}

class AppFontSizes {
  static const double h1 = 32.0;
  static const double h2 = 24.0;
  static const double h3 = 20.0;
  static const double h4 = 18.0;
  static const double body1 = 16.0;
  static const double body2 = 14.0;
  static const double caption = 12.0;
}