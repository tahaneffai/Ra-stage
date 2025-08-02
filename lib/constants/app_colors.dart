import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color secondary = Color(0xFF4CAF50);
  static const Color accent = Color(0xFFFF9800);

  // Couleurs pour les gares
  static const Color tangerColor = Color(0xFFE53935); // Rouge
  static const Color rabatColor = Color(0xFF2196F3);  // Bleu
  static const Color casablancaColor = Color(0xFF4CAF50); // Vert

  // Couleurs de fond
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Couleurs de texte
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);

  // Couleurs de gradient
  static const List<Color> gradientPrimary = [
    Color(0xFF2196F3),
    Color(0xFF1976D2),
  ];

  static const List<Color> gradientSecondary = [
    Color(0xFF4CAF50),
    Color(0xFF388E3C),
  ];

  // Couleurs orange modernes
  static const List<Color> gradientOrange = [
    Color(0xFFFF5722), // Orange vif
    Color(0xFFE64A19), // Orange foncé
    Color(0xFFD84315), // Orange très foncé
  ];

  static const List<Color> gradientOrangeDark = [
    Color(0xFFD84315), // Orange très foncé
    Color(0xFFBF360C), // Orange bordeaux
    Color(0xFF8D2F0A), // Orange marron foncé
  ];

  static const List<Color> gradientOrangeLight = [
    Color(0xFFFF7043), // Orange clair
    Color(0xFFFF5722), // Orange vif
    Color(0xFFE64A19), // Orange foncé
  ];

  // Couleurs d'état
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Couleurs pour les filtres et recherche
  static const Color searchBarBackground = Color(0xFFF8F9FA);
  static const Color filterButtonColor = Color(0xFF6C757D);
  static const Color bottomSheetBackground = Color(0xFFFFFFFF);
} 