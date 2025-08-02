import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Utilitaire pour gérer le mode démo et les fonctionnalités spécifiques au web
///
/// Détecte automatiquement si l'application tourne sur web/desktop
/// et active les fonctionnalités de démonstration appropriées.
class DemoMode {
  /// Vérifie si l'application tourne sur web
  static bool get isWeb => kIsWeb;
  
  /// Vérifie si l'application tourne sur desktop
  static bool get isDesktop {
    if (kIsWeb) return true;
    // Pour les plateformes natives, on peut ajouter d'autres vérifications
    return false;
  }
  
  /// Vérifie si le mode démo est activé
  static bool get isDemoMode => isWeb || isDesktop;
  
  /// Retourne le message de mode démo
  static String get demoMessage {
    if (isWeb) return 'Mode Web - Démo activé';
    if (isDesktop) return 'Mode Desktop - Démo activé';
    return '';
  }
  
  /// Retourne la couleur du bandeau de démo
  static Color get demoBannerColor {
    if (isWeb) return Colors.blue;
    if (isDesktop) return Colors.green;
    return Colors.transparent;
  }
  
  /// Retourne l'icône du mode démo
  static IconData get demoIcon {
    if (isWeb) return Icons.web;
    if (isDesktop) return Icons.computer;
    return Icons.info;
  }
  
  /// Vérifie si les fonctionnalités AR sont disponibles
  static bool get isARAvailable {
    // En mode démo, on simule l'AR
    return isDemoMode;
  }
  
  /// Vérifie si les fonctionnalités de capture d'écran sont disponibles
  static bool get isScreenshotAvailable {
    // En mode démo, on simule la capture d'écran
    return isDemoMode;
  }
  
  /// Retourne les fonctionnalités disponibles en mode démo
  static List<String> get demoFeatures {
    return [
      'Simulation AR avancée',
      'Panneaux 3D flottants',
      'Animations fluides',
      'Interface responsive',
      'Capture d\'écran simulée',
    ];
  }
  
  /// Retourne les limitations du mode démo
  static List<String> get demoLimitations {
    return [
      'Fonctionnalités AR simulées',
      'Pas de géolocalisation réelle',
      'Données statiques',
      'Pas de caméra AR',
    ];
  }
}

/// Widget pour afficher le bandeau de mode démo
class DemoBanner extends StatelessWidget {
  const DemoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!DemoMode.isDemoMode) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DemoMode.demoBannerColor.withOpacity(0.9),
            DemoMode.demoBannerColor.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: DemoMode.demoBannerColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            DemoMode.demoIcon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            DemoMode.demoMessage,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour afficher les informations de démo
class DemoInfoCard extends StatelessWidget {
  const DemoInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (!DemoMode.isDemoMode) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                DemoMode.demoIcon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Mode Démo Actif',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Fonctionnalités disponibles :',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...DemoMode.demoFeatures.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  feature,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
} 