import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Widget d'arrière-plan moderne avec motifs statiques
/// 
/// Utilisé pour créer un arrière-plan élégant avec des motifs géométriques
/// et des effets de transparence.
class ModernBackground extends StatelessWidget {
  /// Contenu à afficher par-dessus l'arrière-plan
  final Widget child;
  
  /// Indique si le thème sombre est actif
  final bool isDark;

  const ModernBackground({
    super.key,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? AppColors.gradientOrangeDark
            : AppColors.gradientOrangeLight,
        ),
      ),
      child: Stack(
        children: [
          // Motifs géométriques en arrière-plan
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Motifs hexagonaux
          ...List.generate(6, (index) {
            return Positioned(
              top: 100 + (index * 80),
              left: index % 2 == 0 ? -20 : null,
              right: index % 2 == 1 ? -20 : null,
              child: Transform.rotate(
                angle: index * 0.5,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.03),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
              ),
            );
          }),
          // Lignes décoratives
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Contenu principal
          child,
        ],
      ),
    );
  }
}

/// Widget d'arrière-plan moderne avec animations
/// 
/// Version animée de ModernBackground avec des rotations et pulsations
/// pour créer un effet visuel plus dynamique et engageant.
class AnimatedModernBackground extends StatefulWidget {
  /// Contenu à afficher par-dessus l'arrière-plan
  final Widget child;
  
  /// Indique si le thème sombre est actif
  final bool isDark;

  const AnimatedModernBackground({
    super.key,
    required this.child,
    required this.isDark,
  });

  @override
  State<AnimatedModernBackground> createState() => _AnimatedModernBackgroundState();
}

class _AnimatedModernBackgroundState extends State<AnimatedModernBackground>
    with TickerProviderStateMixin {
  /// Contrôleur pour l'animation de rotation
  late AnimationController _rotationController;
  
  /// Contrôleur pour l'animation de pulsation
  late AnimationController _pulseController;
  
  /// Animation de rotation (0 à 2π radians)
  late Animation<double> _rotationAnimation;
  
  /// Animation de pulsation (0.8 à 1.2)
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialiser le contrôleur de rotation (20 secondes pour un tour complet)
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Initialiser le contrôleur de pulsation (3 secondes)
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Créer l'animation de rotation
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(_rotationController);

    // Créer l'animation de pulsation
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(_pulseController);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDark 
            ? AppColors.gradientOrangeDark
            : AppColors.gradientOrangeLight,
        ),
      ),
      child: Stack(
        children: [
          // Motifs animés
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Positioned(
                top: -50,
                right: -50,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: -100,
                left: -100,
                child: Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Motifs hexagonaux animés
          ...List.generate(6, (index) {
            return AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Positioned(
                  top: 100 + (index * 80),
                  left: index % 2 == 0 ? -20 : null,
                  right: index % 2 == 1 ? -20 : null,
                  child: Transform.rotate(
                    angle: (index * 0.5) + (_rotationAnimation.value * 0.1),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.03),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          // Lignes décoratives
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Contenu principal
          widget.child,
        ],
      ),
    );
  }
} 