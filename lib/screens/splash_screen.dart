import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/creative_background.dart';
import 'home_screen.dart';

/// Écran de démarrage avec animations
///
/// Affiche le logo TrainSight avec des animations fluides
/// et une transition vers l'écran d'accueil.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  /// Contrôleur pour l'animation du logo
  late AnimationController _logoController;
  
  /// Contrôleur pour l'animation du texte
  late AnimationController _textController;
  
  /// Contrôleur pour l'animation de transition
  late AnimationController _transitionController;

  /// Animation du logo
  late Animation<double> _logoAnimation;
  
  /// Animation du texte
  late Animation<double> _textAnimation;
  
  /// Animation de transition
  late Animation<double> _transitionAnimation;

  @override
  void initState() {
    super.initState();

    // Initialiser les contrôleurs d'animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Configurer les animations
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _transitionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));

    // Démarrer les animations
    _startAnimations();
  }

  /// Méthode pour démarrer les animations
  void _startAnimations() async {
    // Démarrer l'animation du logo
    await _logoController.forward();
    
    // Démarrer l'animation du texte
    await _textController.forward();
    
    // Attendre un peu avant la transition
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Démarrer l'animation de transition
    await _transitionController.forward();
    
    // Naviguer vers l'écran d'accueil
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan créatif animé
          CreativeBackground(
            isDark: isDark,
            child: Container(), // Empty container as child
          ),
          
          // Contenu principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animé
                AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoAnimation.value,
                      child: Transform.rotate(
                        angle: _logoAnimation.value * 0.1,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(90),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.train,
                            size: 90,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Texte du titre
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, (1 - _textAnimation.value) * 50),
                      child: Opacity(
                        opacity: _textAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            'TrainSight',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: const Offset(0, 3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Sous-titre
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, (1 - _textAnimation.value) * 30),
                      child: Opacity(
                        opacity: _textAnimation.value,
                        child: Text(
                          'Découvrez les gares du Maroc',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 60),
                
                // Indicateur de chargement
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chargement...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Informations de version
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _textAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _textAnimation.value,
                  child: Column(
                    children: [
                      Text(
                        'Version 1.0.0',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Stage ONCF - TrainSight',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 