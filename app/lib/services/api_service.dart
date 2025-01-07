// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Remplacez par votre URL backend

  // Fonction de connexion
  static Future<void> login(String telephone, String motDePasse) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'telephone': telephone,
        'motDePasse': motDePasse,
      }),
    );

    if (response.statusCode == 200) {
      // Traitez la réponse de connexion
      final data = jsonDecode(response.body);
      // Par exemple, stocker le token JWT
      // await TokenManager.saveToken(data['token']);
    } else {
      // Gérer les erreurs de connexion
      throw Exception('Échec de la connexion. Veuillez vérifier vos identifiants.');
    }
  }

  // Fonction d'inscription
  static Future<void> registerClient({
    required String nom,
    required String prenom,
    required String telephone,
    String? email, // Rend ce paramètre nullable
    required String motDePasse,
    required String region,
    required String ville,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'email': email, // Peut être null
        'motDePasse': motDePasse,
        'region': region,
        'ville': ville,
      }),
    );

    if (response.statusCode == 201) {
      // Traitez la réponse d'inscription
    } else {
      // Gérer les erreurs d'inscription
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Échec de l\'inscription.');
    }
  }

  // Fonction de vérification de token
  static Future<bool> checkToken() async {
    // Implémentez la vérification du token ici
    // Par exemple, en vérifiant la validité du token stocké
    return false;
  }

  // Fonction de déconnexion
  static Future<void> logout() async {
    // Implémentez la logique de déconnexion ici
    // Par exemple, supprimer le token stocké
  }

  // Fonction de mot de passe oublié
  static Future<void> forgotPassword({
    String? telephone,
    String? email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'telephone': telephone,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      // Traitez la réponse de demande de réinitialisation
    } else {
      // Gérer les erreurs de demande de réinitialisation
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Échec de la demande de réinitialisation.');
    }
  }

  // Fonction de réinitialisation de mot de passe
  static Future<void> resetPassword({
    required String code,
    required String newPassword,
    String? telephone,
    String? email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'code': code,
        'newPassword': newPassword,
        'telephone': telephone,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      // Traitez la réponse de réinitialisation
    } else {
      // Gérer les erreurs de réinitialisation
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Échec de la réinitialisation du mot de passe.');
    }
  }
}
