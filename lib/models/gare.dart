import 'dart:math';
import 'package:flutter/material.dart';

/// Modèle représentant une gare dans l'application TrainSight
/// 
/// Ce modèle contient toutes les informations nécessaires pour afficher
/// une gare sur la carte et dans les interfaces utilisateur.
class Gare {
  /// Identifiant unique de la gare
  final int id;
  
  /// Nom de la gare (ex: "Tanger", "Rabat")
  final String nom;
  
  /// Ville où se trouve la gare
  final String ville;
  
  /// Latitude de la gare (coordonnées GPS)
  final double latitude;
  
  /// Longitude de la gare (coordonnées GPS)
  final double longitude;
  
  /// Numéro de téléphone de la gare
  final String telephone;
  
  /// Description détaillée de la gare
  final String description;

  /// Constructeur de la classe Gare
  /// 
  /// [id] : Identifiant unique
  /// [nom] : Nom de la gare
  /// [ville] : Ville de localisation
  /// [latitude] : Coordonnée GPS latitude
  /// [longitude] : Coordonnée GPS longitude
  /// [telephone] : Numéro de contact
  /// [description] : Description détaillée
  Gare({
    required this.id,
    required this.nom,
    required this.ville,
    required this.latitude,
    required this.longitude,
    required this.telephone,
    required this.description,
  });

  /// Factory constructor pour créer un objet Gare depuis JSON
  /// 
  /// Utilisé pour désérialiser les données reçues de l'API
  /// [json] : Map contenant les données JSON de la gare
  factory Gare.fromJson(Map<String, dynamic> json) {
    return Gare(
      id: json['id'],
      nom: json['nom'],
      ville: json['ville'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      telephone: json['telephone'] ?? '',
      description: json['description'] ?? '',
    );
  }

  /// Méthode pour convertir l'objet Gare en JSON
  /// 
  /// Utilisé pour sérialiser les données avant envoi à l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'ville': ville,
      'latitude': latitude,
      'longitude': longitude,
      'telephone': telephone,
      'description': description,
    };
  }

  /// Méthode pour calculer la distance entre cette gare et un point donné
  /// 
  /// [targetLat] : Latitude du point cible
  /// [targetLng] : Longitude du point cible
  /// Retourne la distance approximative en kilomètres
  double calculateDistance(double targetLat, double targetLng) {
    const double earthRadius = 6371; // Rayon de la Terre en km
    
    double latDiff = (targetLat - latitude) * (pi / 180);
    double lngDiff = (targetLng - longitude) * (pi / 180);
    
    double a = sin(latDiff / 2) * sin(latDiff / 2) +
        cos(latitude * pi / 180) * cos(targetLat * pi / 180) * sin(lngDiff / 2) * sin(lngDiff / 2);
    double c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }

  /// Méthode pour obtenir la couleur associée à cette gare
  /// 
  /// Utilisée pour personnaliser l'affichage des marqueurs sur la carte
  Color getMarkerColor() {
    switch (ville.toLowerCase()) {
      case 'tanger':
        return const Color(0xFFE53935); // Rouge
      case 'rabat':
        return const Color(0xFF2196F3); // Bleu
      case 'casablanca':
        return const Color(0xFF4CAF50); // Vert
      case 'fès':
        return const Color(0xFF9C27B0); // Violet
      case 'marrakech':
        return const Color(0xFFFF9800); // Orange
      case 'oujda':
        return const Color(0xFF795548); // Marron
      case 'kénitra':
        return const Color(0xFF607D8B); // Bleu gris
      case 'settat':
        return const Color(0xFF009688); // Teal
      case 'oued zem':
        return const Color(0xFF673AB7); // Indigo
      case 'mohammedia':
        return const Color(0xFF00BCD4); // Cyan
      case 'el jadida':
        return const Color(0xFFFF5722); // Rouge orange
      default:
        return const Color(0xFF757575); // Gris
    }
  }

  @override
  String toString() {
    return 'Gare(id: $id, nom: $nom, ville: $ville, latitude: $latitude, longitude: $longitude, telephone: $telephone, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Gare && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 