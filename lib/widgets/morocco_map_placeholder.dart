import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Carte du Maroc de remplacement
/// 
/// Utilisée comme fallback si l'image de carte n'est pas disponible
/// Crée une représentation simple du Maroc avec des éléments géographiques
class MoroccoMapPlaceholder extends StatelessWidget {
  const MoroccoMapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B4513), // Dark orange base
            const Color(0xFFD2691E), // Chocolate orange
            const Color(0xFFCD853F), // Peru orange
          ],
        ),
      ),
      child: CustomPaint(
        painter: _MoroccoMapPainter(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map,
                size: 80,
                color: Colors.white.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Carte du Maroc',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Carte interactive des gares ferroviaires',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Peintre personnalisé pour dessiner une carte simplifiée du Maroc
class _MoroccoMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Forme générale du Maroc (simplifiée)
    final path = Path();
    
    // Commencer en haut à gauche (Tanger)
    path.moveTo(size.width * 0.2, size.height * 0.1);
    
    // Côte méditerranéenne
    path.lineTo(size.width * 0.8, size.height * 0.15);
    
    // Frontière est
    path.lineTo(size.width * 0.9, size.height * 0.25);
    path.lineTo(size.width * 0.85, size.height * 0.4);
    
    // Frontière sud-est
    path.lineTo(size.width * 0.7, size.height * 0.6);
    path.lineTo(size.width * 0.5, size.height * 0.7);
    
    // Côte atlantique sud
    path.lineTo(size.width * 0.3, size.height * 0.65);
    path.lineTo(size.width * 0.2, size.height * 0.5);
    
    // Côte atlantique nord
    path.lineTo(size.width * 0.15, size.height * 0.3);
    path.close();

    // Dessiner la forme du Maroc
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    // Ajouter quelques éléments géographiques
    _drawGeographicFeatures(canvas, size);
  }

  void _drawGeographicFeatures(Canvas canvas, Size size) {
    final featurePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Montagnes de l'Atlas (simplifiées)
    final atlasPath = Path();
    atlasPath.moveTo(size.width * 0.3, size.height * 0.3);
    atlasPath.lineTo(size.width * 0.5, size.height * 0.4);
    atlasPath.lineTo(size.width * 0.7, size.height * 0.5);
    atlasPath.lineTo(size.width * 0.6, size.height * 0.6);
    atlasPath.lineTo(size.width * 0.4, size.height * 0.55);
    atlasPath.lineTo(size.width * 0.25, size.height * 0.45);
    atlasPath.close();
    
    canvas.drawPath(atlasPath, featurePaint);

    // Désert du Sahara (zone sud)
    final desertPath = Path();
    desertPath.moveTo(size.width * 0.4, size.height * 0.65);
    desertPath.lineTo(size.width * 0.6, size.height * 0.7);
    desertPath.lineTo(size.width * 0.7, size.height * 0.75);
    desertPath.lineTo(size.width * 0.5, size.height * 0.8);
    desertPath.lineTo(size.width * 0.3, size.height * 0.75);
    desertPath.close();
    
    canvas.drawPath(desertPath, featurePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}








