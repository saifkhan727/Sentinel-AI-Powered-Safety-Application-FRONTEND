import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color deepPurple = Color(0xFF4A148C);
  static const Color softPurple = Color(0xFF7B1FA2);
  static const Color lightPurple = Color(0xFFCE93D8);

  // Danger/SOS
  static const Color sosRed = Color(0xFFE53935);
  static const Color sosRedLight = Color(0xFFFFCDD2);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF212121);
  static const Color mediumGrey = Color(0xFF757575);

  // Status
  static const Color successGreen = Color(0xFF43A047);
  static const Color warningAmber = Color(0xFFFFB300);

  // Gradient
  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4A148C),
      Color(0xFF7B1FA2),
      Color(0xFF4A148C),
    ],
  );

  static const LinearGradient purpleGradientVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF4A148C),
      Color(0xFF7B1FA2),
    ],
  );
}