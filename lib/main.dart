import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'constants/app_themes.dart';

/// Point d'entrée principal de l'application TrainSight
/// 
/// Configure l'application avec les thèmes et démarre sur l'écran d'accueil.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations for mobile
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style for full-screen mobile experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
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
      // Mobile-specific configurations
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0, // Prevent text scaling issues on mobile
          ),
          child: child!,
        );
      },
    );
  }
} 