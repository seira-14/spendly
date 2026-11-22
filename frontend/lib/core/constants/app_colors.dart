import 'package:flutter/material.dart';

class AppColors {
  // Primary Pink Palette (Matching the Mockup aesthetic)
  static const Color primary = Color(0xFFFF5C8A);
  static const Color primaryDark = Color(0xFFE04573);
  static const Color primaryLight = Color(0xFFFF85A6);
  static const Color primaryGradientStart = Color(0xFFFF8FA3);
  static const Color primaryGradientEnd = Color(0xFFFF5C8A);

  // Background & Surface
  static const Color background = Color(0xFFFFF5F7);
  static const Color backgroundAlt = Color(0xFFFFF0F3);
  static const Color surface = Colors.white;
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // Card & Container Soft Pinks
  static const Color cardPinkLight = Color(0xFFFFF0F5);
  static const Color cardPinkAccent = Color(0xFFFFE4EC);
  static const Color cardPinkBorder = Color(0xFFFFDDE6);
  static const Color cardShadow = Color(0x1AFF5C8A);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D283E);
  static const Color textSecondary = Color(0xFF8E8CA1);
  static const Color textMuted = Color(0xFFB8B6C6);
  static const Color textPink = Color(0xFFFF5C8A);

  // Category & Accent Colors
  static const Color catKebutuhan = Color(0xFFFF6584);
  static const Color catKeinginan = Color(0xFFBA68C8);
  static const Color catTransportasi = Color(0xFFFF8A65);
  static const Color catLainnya = Color(0xFF4DD0E1);
  static const Color catMakanan = Color(0xFFFFB74D);
  static const Color catBelanja = Color(0xFF4DB6AC);
  static const Color catHadiah = Color(0xFFF06292);

  // Donut Chart Slices (Pastel Pink Gradients)
  static const List<Color> donutColors = [
    Color(0xFFFF5C8A), // Kebutuhan (Hot Pink)
    Color(0xFFFF8FA3), // Keinginan (Rose Pink)
    Color(0xFFFFB3C1), // Transportasi (Soft Pink)
    Color(0xFFFFCCD5), // Lainnya (Blush Pink)
    Color(0xFFC77DFF), // Makanan (Lilac)
    Color(0xFF90E0EF), // Belanja (Soft Cyan)
    Color(0xFFFFD166), // Hadiah (Soft Yellow)
  ];

  // Functional Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE04573); // Dark Pink matching app theme
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF29B6F6);

  // Divider & Border
  static const Color divider = Color(0xFFF3EDF0);
  static const Color border = Color(0xFFF0E6EB);
}
