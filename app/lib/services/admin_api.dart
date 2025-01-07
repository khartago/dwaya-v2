// lib/services/admin_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pharmacy.dart';
import '../models/user.dart';
import '../models/request.dart';
import '../models/reclamation.dart';
import '../models/dashboard_stats.dart';
import '../models/message.dart';
import '../utils/constants.dart';
import '../utils/token_manager.dart';

class AdminApi {
  // Méthode privée pour obtenir les headers avec le token d'authentification
  static Future<Map<String, String>> _getHeaders() async {
    String? token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('Token d\'authentification manquant');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // =========================
  //        DASHBOARD
  // =========================

  /// Récupère les statistiques du dashboard
  static Future<DashboardStats> getDashboardStats() async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/admin/dashboard'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return DashboardStats.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la récupération des statistiques du dashboard');
    }
  }

  // =========================
  //        PHARMACIES
  // =========================

  /// Récupère la liste des pharmacies avec des filtres optionnels
  static Future<List<Pharmacy>> getPharmacies({String? region, String? ville, bool? actif}) async {
    String url = '${Constants.baseUrl}/admin/pharmacies';
    Map<String, String> queryParams = {};

    if (region != null) queryParams['region'] = region;
    if (ville != null) queryParams['ville'] = ville;
    if (actif != null) queryParams['actif'] = actif.toString();

    if (queryParams.isNotEmpty) {
      url += '?${Uri(queryParameters: queryParams).query}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Pharmacy.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des pharmacies');
    }
  }

  /// Crée une nouvelle pharmacie
  static Future<Pharmacy> createPharmacy(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/admin/pharmacies'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return Pharmacy.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la création de la pharmacie: ${response.body}');
    }
  }

  /// Met à jour le statut actif/inactif d'une pharmacie
  static Future<void> updatePharmacyStatus(String pharmacyId, bool actif) async {
    final response = await http.patch(
      Uri.parse('${Constants.baseUrl}/admin/pharmacies/$pharmacyId/status'),
      headers: await _getHeaders(),
      body: jsonEncode({'actif': actif}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour du statut de la pharmacie: ${response.body}');
    }
  }

  /// Met à jour les informations d'une pharmacie existante
  static Future<void> updatePharmacy(String pharmacyId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${Constants.baseUrl}/admin/pharmacies/$pharmacyId'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour de la pharmacie: ${response.body}');
    }
  }

  // =========================
  //        UTILISATEURS
  // =========================

  /// Récupère la liste des utilisateurs avec des filtres optionnels
  static Future<List<User>> getUsers({String? region, String? ville, bool? actif}) async {
    String url = '${Constants.baseUrl}/admin/users';
    Map<String, String> queryParams = {};

    if (region != null) queryParams['region'] = region;
    if (ville != null) queryParams['ville'] = ville;
    if (actif != null) queryParams['actif'] = actif.toString();

    if (queryParams.isNotEmpty) {
      url += '?${Uri(queryParameters: queryParams).query}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des utilisateurs');
    }
  }

  /// Met à jour le statut actif/inactif d'un utilisateur
  static Future<void> updateUserStatus(String userId, bool actif) async {
    final response = await http.patch(
      Uri.parse('${Constants.baseUrl}/admin/users/$userId/status'),
      headers: await _getHeaders(),
      body: jsonEncode({'actif': actif}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour du statut de l\'utilisateur: ${response.body}');
    }
  }

  // =========================
  //        DEMANDES
  // =========================

  /// Récupère la liste des demandes avec des filtres optionnels
  static Future<List<RequestModel>> getRequests({String? region, String? ville, String? status}) async {
    String url = '${Constants.baseUrl}/admin/requests';
    Map<String, String> queryParams = {};

    if (region != null) queryParams['region'] = region;
    if (ville != null) queryParams['ville'] = ville;
    if (status != null) queryParams['status'] = status;

    if (queryParams.isNotEmpty) {
      url += '?${Uri(queryParameters: queryParams).query}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => RequestModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des demandes');
    }
  }

  /// Met à jour le statut d'une demande
  static Future<void> updateRequestStatus(String requestId, String status) async {
    final response = await http.patch(
      Uri.parse('${Constants.baseUrl}/admin/requests/$requestId/status'),
      headers: await _getHeaders(),
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour du statut de la demande: ${response.body}');
    }
  }

  /// Récupère les messages associés à une demande spécifique
  static Future<List<MessageModel>> getMessages(String requestId) async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/admin/requests/$requestId/messages'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des messages');
    }
  }

  /// Envoie un message dans une demande
  static Future<void> sendMessage(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/admin/requests/messages'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur lors de l\'envoi du message: ${response.body}');
    }
  }

  // =========================
  //        RÉCLAMATIONS
  // =========================

  /// Récupère la liste des réclamations avec des filtres optionnels
  static Future<List<Reclamation>> getReclamations({String? type, String? status}) async {
    String url = '${Constants.baseUrl}/admin/reclamations';
    Map<String, String> queryParams = {};

    if (type != null) queryParams['type'] = type;
    if (status != null) queryParams['status'] = status;

    if (queryParams.isNotEmpty) {
      url += '?${Uri(queryParameters: queryParams).query}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Reclamation.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des réclamations');
    }
  }

  /// Met à jour le statut d'une réclamation
  static Future<void> updateReclamationStatus(String reclamationId, String status) async {
    final response = await http.patch(
      Uri.parse('${Constants.baseUrl}/admin/reclamations/$reclamationId/status'),
      headers: await _getHeaders(),
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour du statut de la réclamation: ${response.body}');
    }
  }

  /// Ajoute une réponse à une réclamation
  static Future<void> respondReclamation(String reclamationId, String responseMessage) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/admin/reclamations/$reclamationId/respond'),
      headers: await _getHeaders(),
      body: jsonEncode({'reponse': responseMessage}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la réponse à la réclamation: ${response.body}');
    }
  }

  // =========================
  //        RAPPORTS
  // =========================

  /// Vous pouvez ajouter des méthodes spécifiques pour les rapports si nécessaire
  /// Par exemple, générer des rapports personnalisés, exporter des données, etc.
}
