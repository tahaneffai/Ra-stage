import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Arrière-plan créatif avec éléments animés
/// 
/// Remplace l'arrière-plan simple par des éléments créatifs
/// tout en gardant la couleur orange foncé comme base
class CreativeBackground extends StatefulWidget {
  final bool isDark;
  final Widget child;

  const CreativeBackground({
    super.key,
    required this.isDark,
    required this.child,
  });

  @override
  State<CreativeBackground> createState() => _CreativeBackgroundState();
}

class _CreativeBackgroundState extends State<CreativeBackground>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _waveController;
  late AnimationController _particleController;
  late AnimationController _gradientController;

  late Animation<double> _floatingAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _gradientAnimation;

  final List<_FloatingElement> _floatingElements = [];
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Contrôleur pour les éléments flottants
    _floatingController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    // Contrôleur pour les vagues
    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Contrôleur pour les particules
    _particleController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    // Contrôleur pour le dégradé
    _gradientController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    // Animations
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.linear,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));

    // Initialiser les éléments flottants
    _initializeFloatingElements();
    
    // Initialiser les particules
    _initializeParticles();

    // Démarrer les animations
    _floatingController.repeat();
    _waveController.repeat();
    _particleController.repeat();
    _gradientController.repeat();
  }

  void _initializeFloatingElements() {
    final random = math.Random();
    for (int i = 0; i < 8; i++) {
      _floatingElements.add(_FloatingElement(
        x: random.nextDouble() * 400 - 200,
        y: random.nextDouble() * 400 - 200,
        size: random.nextDouble() * 20 + 10,
        speed: random.nextDouble() * 0.5 + 0.3,
        delay: random.nextDouble() * 2,
        type: random.nextBool() ? _ElementType.circle : _ElementType.square,
      ));
    }
  }

  void _initializeParticles() {
    final random = math.Random();
    for (int i = 0; i < 15; i++) {
      _particles.add(_Particle(
        x: random.nextDouble() * 400 - 200,
        y: random.nextDouble() * 400 - 200,
        size: random.nextDouble() * 3 + 1,
        speed: random.nextDouble() * 0.8 + 0.2,
        delay: random.nextDouble() * 3,
      ));
    }
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _waveController.dispose();
    _particleController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B4513), // Dark orange base
            const Color(0xFFD2691E), // Chocolate orange
            const Color(0xFFCD853F), // Peru orange
            const Color(0xFF8B4513), // Back to dark orange
          ],
          stops: [
            0.0,
            0.3,
            0.7,
            1.0,
          ],
        ),
      ),
      child: Stack(
        children: [
                    // Dégradé animé en arrière-plan
          AnimatedBuilder(
            animation: _gradientAnimation,
            builder: (context, child) {
              try {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF8B4513),
                        const Color(0xFFD2691E),
                        const Color(0xFFCD853F),
                        const Color(0xFF8B4513),
                      ],
                      stops: [
                        0.0,
                        (_gradientAnimation.value * 0.5 + 0.2).clamp(0.0, 1.0),
                        (_gradientAnimation.value * 0.3 + 0.6).clamp(0.0, 1.0),
                        1.0,
                      ],
                    ),
                  ),
                );
              } catch (e) {
                // Return a fallback container if there's an error with gradient
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF8B4513),
                        Color(0xFFD2691E),
                        Color(0xFFCD853F),
                        Color(0xFF8B4513),
                      ],
                    ),
                  ),
                );
              }
            },
          ),

          // Vagues animées
          _buildWaves(),

          // Éléments flottants
          _buildFloatingElements(),

          // Particules
          _buildParticles(),

          // Enfant (contenu principal)
          widget.child,
        ],
      ),
    );
    } catch (e) {
      // Return a simple fallback container if there's a critical error
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFF8B4513), // Dark orange fallback
        ),
        child: widget.child,
      );
    }
  }

  Widget _buildWaves() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        try {
          return CustomPaint(
            painter: _WavePainter(
              animation: _waveAnimation.value,
              isDark: widget.isDark,
            ),
            size: Size.infinite,
          );
        } catch (e) {
          // Return an empty container if there's an error with waves
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        try {
          return Stack(
            children: _floatingElements.map((element) {
              try {
                final progress = (_floatingAnimation.value + element.delay) % 1.0;
                final x = element.x + math.sin(progress * 2 * math.pi) * 50;
                final y = element.y + math.cos(progress * 2 * math.pi) * 30;
                final opacity = (0.3 + 0.4 * math.sin(progress * 4 * math.pi)).clamp(0.0, 1.0);

                // Ensure x and y are within reasonable bounds
                final safeX = (x + 200).clamp(0.0, MediaQuery.of(context).size.width - element.size);
                final safeY = (y + 200).clamp(0.0, MediaQuery.of(context).size.height - element.size);

                return Positioned(
                  left: safeX,
                  top: safeY,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: element.size,
                      height: element.size,
                      decoration: BoxDecoration(
                        color: element.type == _ElementType.circle
                            ? Colors.white.withOpacity(0.2)
                            : Colors.transparent,
                        shape: element.type == _ElementType.circle
                            ? BoxShape.circle
                            : BoxShape.rectangle,
                        border: element.type == _ElementType.square
                            ? Border.all(
                                color: Colors.white.withOpacity(0.3), width: 1)
                            : null,
                      ),
                    ),
                  ),
                );
              } catch (e) {
                // Return an empty container if there's an error with this element
                return const SizedBox.shrink();
              }
            }).toList(),
          );
        } catch (e) {
          // Return an empty container if there's an error with the entire stack
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        try {
          return Stack(
            children: _particles.map((particle) {
              try {
                final progress = (_particleAnimation.value + particle.delay) % 1.0;
                final x = particle.x + progress * 100;
                final y = particle.y + math.sin(progress * 2 * math.pi) * 20;
                final opacity = (0.6 + 0.4 * math.sin(progress * 3 * math.pi)).clamp(0.0, 1.0);

                // Ensure x and y are within reasonable bounds
                final safeX = (x + 200).clamp(0.0, MediaQuery.of(context).size.width - particle.size);
                final safeY = (y + 200).clamp(0.0, MediaQuery.of(context).size.height - particle.size);

                return Positioned(
                  left: safeX,
                  top: safeY,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: particle.size,
                      height: particle.size,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              } catch (e) {
                // Return an empty container if there's an error with this particle
                return const SizedBox.shrink();
              }
            }).toList(),
          );
        } catch (e) {
          // Return an empty container if there's an error with the entire stack
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animation;
  final bool isDark;

  _WavePainter({required this.animation, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 20.0;
    final frequency = 0.02;

    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.8 + math.sin(animation * 2 * math.pi) * waveHeight);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.8 +
          math.sin((x * frequency) + (animation * 2 * math.pi)) * waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Deuxième vague
    final paint2 = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height);
    path2.lineTo(0, size.height * 0.7 + math.sin(animation * 2 * math.pi + 1) * waveHeight * 0.7);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.7 +
          math.sin((x * frequency * 0.7) + (animation * 2 * math.pi + 1)) * waveHeight * 0.7;
      path2.lineTo(x, y);
    }

    path2.lineTo(size.width, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _FloatingElement {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double delay;
  final _ElementType type;

  _FloatingElement({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.delay,
    required this.type,
  });
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double delay;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.delay,
  });
}

enum _ElementType { circle, square }
