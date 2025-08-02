import 'package:flutter/material.dart';
import 'dart:math';
import '../constants/app_colors.dart';
import '../widgets/modern_background.dart';

/// Écran de réalité augmentée (AR) - Simulation avancée
///
/// Affiche une simulation AR avec des panneaux 3D flottants,
/// des trajets animés et des effets de portail pour la présentation PFE.
class ARScreen extends StatefulWidget {
  const ARScreen({super.key});

  @override
  State<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen>
    with TickerProviderStateMixin {
  /// Contrôleur pour l'animation de pulsation de l'icône AR
  late AnimationController _pulseController;
  
  /// Contrôleur pour l'animation des panneaux flottants
  late AnimationController _panelsController;
  
  /// Contrôleur pour l'animation du portail
  late AnimationController _portalController;
  
  /// Contrôleur pour l'animation des trajets
  late AnimationController _routesController;

  /// Animation de pulsation
  late Animation<double> _pulseAnimation;
  
  /// Animation des panneaux
  late Animation<double> _panelsAnimation;
  
  /// Animation du portail
  late Animation<double> _portalAnimation;
  
  /// Animation des trajets
  late Animation<double> _routesAnimation;

  /// État du mode portail
  bool _isPortalActive = false;

  /// Trajets simulés
  final List<Map<String, dynamic>> _routes = [
    {
      'from': 'Tanger',
      'to': 'Rabat',
      'duration': '2h 30min',
      'distance': '280 km',
      'color': AppColors.tangerColor,
    },
    {
      'from': 'Rabat',
      'to': 'Casablanca',
      'duration': '1h 15min',
      'distance': '120 km',
      'color': AppColors.rabatColor,
    },
    {
      'from': 'Casablanca',
      'to': 'Tanger',
      'duration': '3h 45min',
      'distance': '400 km',
      'color': AppColors.casablancaColor,
    },
  ];

  @override
  void initState() {
    super.initState();

    // Initialiser l'animation de pulsation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Initialiser l'animation des panneaux
    _panelsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Initialiser l'animation du portail
    _portalController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialiser l'animation des trajets
    _routesController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _panelsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _panelsController,
      curve: Curves.elasticOut,
    ));

    _portalAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _portalController,
      curve: Curves.easeInOut,
    ));

    _routesAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _routesController,
      curve: Curves.linear,
    ));

    // Démarrer les animations
    _panelsController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _panelsController.dispose();
    _portalController.dispose();
    _routesController.dispose();
    super.dispose();
  }

  /// Méthode pour activer le portail AR
  void _activatePortal() {
    setState(() {
      _isPortalActive = true;
    });
    _portalController.forward();
    
    // Simuler la fermeture du portail après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _portalController.reverse();
        setState(() {
          _isPortalActive = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode AR'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.view_in_ar,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'AR ACTIF',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Arrière-plan animé
          AnimatedModernBackground(
            isDark: isDark,
            child: Container(), // Empty container as child
          ),
          
          // Panneaux AR flottants
          AnimatedBuilder(
            animation: _panelsAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _panelsAnimation.value,
                child: Opacity(
                  opacity: _panelsAnimation.value,
                  child: _buildARPanels(size),
                ),
              );
            },
          ),
          
          // Portail AR (si actif)
          if (_isPortalActive)
            AnimatedBuilder(
              animation: _portalAnimation,
              builder: (context, child) {
                return _buildPortal(size);
              },
            ),
          
          // Contenu principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Titre principal
                  _buildMainTitle(),
                  const SizedBox(height: 40),
                  
                  // Instructions AR
                  _buildARInstructions(),
                  const SizedBox(height: 40),
                  
                  // Bouton d'activation du portail
                  _buildPortalButton(),
                  const Spacer(),
                  
                  // Informations techniques
                  _buildTechInfo(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget pour le titre principal
  Widget _buildMainTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: const Icon(
                  Icons.view_in_ar,
                  size: 48,
                  color: Colors.white,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Réalité Augmentée',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Simulation avancée pour PFE',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Widget pour les instructions AR
  Widget _buildARInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Instructions AR :',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildInstructionItem(
            icon: Icons.touch_app,
            title: 'Touchez les panneaux',
            description: 'Interagissez avec les informations flottantes',
          ),
          const SizedBox(height: 12),
          _buildInstructionItem(
            icon: Icons.explore,
            title: 'Explorez les trajets',
            description: 'Découvrez les itinéraires en temps réel',
          ),
          const SizedBox(height: 12),
          _buildInstructionItem(
            icon: Icons.portrait,
            title: 'Activez le portail',
            description: 'Entrez dans l\'expérience immersive',
          ),
        ],
      ),
    );
  }

  /// Widget pour un élément d'instruction
  Widget _buildInstructionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget pour le bouton du portail
  Widget _buildPortalButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.accent.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _activatePortal,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.portrait,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Entrer dans la gare',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget pour les informations techniques
  Widget _buildTechInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(width: 8),
          Text(
            'Simulation AR - PFE TrainSight',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget pour les panneaux AR flottants
  Widget _buildARPanels(Size size) {
    return Stack(
      children: [
        // Panneau 1 - Tanger → Rabat
        Positioned(
          left: size.width * 0.1,
          top: size.height * 0.3,
          child: AnimatedBuilder(
            animation: _routesAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  (1 - _routesAnimation.value) * 50,
                  sin(_routesAnimation.value * 2 * 3.14159) * 10,
                ),
                child: _buildARPanel(_routes[0], 0),
              );
            },
          ),
        ),
        
        // Panneau 2 - Rabat → Casablanca
        Positioned(
          right: size.width * 0.1,
          top: size.height * 0.4,
          child: AnimatedBuilder(
            animation: _routesAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  -((1 - _routesAnimation.value) * 50),
                  sin(_routesAnimation.value * 2 * 3.14159 + 1) * 10,
                ),
                child: _buildARPanel(_routes[1], 1),
              );
            },
          ),
        ),
        
        // Panneau 3 - Casablanca → Tanger
        Positioned(
          left: size.width * 0.2,
          bottom: size.height * 0.3,
          child: AnimatedBuilder(
            animation: _routesAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  sin(_routesAnimation.value * 2 * 3.14159 + 2) * 20,
                  (1 - _routesAnimation.value) * 30,
                ),
                child: _buildARPanel(_routes[2], 2),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Widget pour un panneau AR individuel
  Widget _buildARPanel(Map<String, dynamic> route, int index) {
    return GestureDetector(
      onTap: () {
        // Animation de feedback au tap
        _panelsController.forward(from: 0.8);
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              route['color'].withOpacity(0.9),
              route['color'].withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: route['color'].withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.train,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Trajet ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route['from'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_downward,
                        color: Colors.white,
                        size: 16,
                      ),
                      Text(
                        route['to'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      route['duration'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      route['distance'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Widget pour le portail AR
  Widget _buildPortal(Size size) {
    return AnimatedBuilder(
      animation: _portalAnimation,
      builder: (context, child) {
        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withOpacity(_portalAnimation.value * 0.8),
                Colors.transparent,
              ],
              stops: [0.0, _portalAnimation.value],
            ),
          ),
          child: Center(
            child: Transform.scale(
              scale: _portalAnimation.value * 2,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(_portalAnimation.value),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(_portalAnimation.value * 0.6),
                      blurRadius: 50,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.portrait,
                    size: 80 * _portalAnimation.value,
                    color: Colors.white.withOpacity(_portalAnimation.value),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 