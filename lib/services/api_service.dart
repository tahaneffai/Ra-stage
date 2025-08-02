import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gare.dart';

/// Service pour gérer les appels API vers le backend
/// 
/// Ce service centralise toutes les communications avec l'API REST
/// et gère la sérialisation/désérialisation des données.
class ApiService {
  /// URL de base de l'API backend
  static const String baseUrl = 'http://localhost:3000/api';

  /// Timeout pour les requêtes HTTP (en secondes)
  static const Duration timeout = Duration(seconds: 10);

  /// Méthode pour récupérer toutes les gares depuis l'API
  /// 
  /// Retourne une liste de toutes les gares disponibles
  /// Lance une exception en cas d'erreur de connexion ou de serveur
  static Future<List<Gare>> fetchGares() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/gares'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> garesJson = jsonResponse['data'];
          return garesJson.map((json) => Gare.fromJson(json)).toList();
        } else {
          throw Exception('Erreur dans la réponse API: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Méthode pour récupérer une gare spécifique par son ID
  /// 
  /// [id] : Identifiant de la gare à récupérer
  /// Retourne l'objet Gare correspondant
  static Future<Gare> fetchGareById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/gares/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return Gare.fromJson(jsonResponse['data']);
        } else {
          throw Exception('Erreur dans la réponse API: ${jsonResponse['message']}');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Gare non trouvée');
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Méthode pour créer une nouvelle gare
  /// 
  /// [gare] : Objet Gare à créer
  /// Retourne la gare créée avec son ID généré
  static Future<Gare> createGare(Gare gare) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/gares'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(gare.toJson()),
      ).timeout(timeout);

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return Gare.fromJson(jsonResponse['data']);
        } else {
          throw Exception('Erreur dans la réponse API: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Méthode pour mettre à jour une gare existante
  /// 
  /// [id] : Identifiant de la gare à modifier
  /// [gare] : Nouvelles données de la gare
  /// Retourne la gare mise à jour
  static Future<Gare> updateGare(int id, Gare gare) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/gares/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(gare.toJson()),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return Gare.fromJson(jsonResponse['data']);
        } else {
          throw Exception('Erreur dans la réponse API: ${jsonResponse['message']}');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Gare non trouvée');
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Méthode pour supprimer une gare
  /// 
  /// [id] : Identifiant de la gare à supprimer
  /// Retourne true si la suppression a réussi
  static Future<bool> deleteGare(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/gares/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['success'] == true;
      } else if (response.statusCode == 404) {
        throw Exception('Gare non trouvée');
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Méthode pour vérifier la connectivité de l'API
  /// 
  /// Retourne true si l'API est accessible
  static Future<bool> checkApiHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(timeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
} 