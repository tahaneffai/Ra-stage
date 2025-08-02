import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'constants/app_themes.dart';

/// Point d'entrée principal de l'application TrainSight
/// 
/// Configure l'application avec les thèmes et démarre sur l'écran d'accueil.
void main() {
  runApp(const TrainSightApp());
}

/// Application principale TrainSight
/// 
/// Configure l'application avec les thèmes clair et sombre,
/// et définit l'écran d'accueil comme point de départ.
class TrainSightApp extends StatelessWidget {
  const TrainSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrainSight',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
                home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
} 