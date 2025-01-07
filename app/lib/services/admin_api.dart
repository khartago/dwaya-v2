import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminApi {
  static const String _baseUrl = "http://10.0.2.2:5000/api"; // Replace with actual API URL
  static final _storage = FlutterSecureStorage();

  // Helper to get token dynamically
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception("Token not found. Please login again.");
    }
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // Fetch dashboard data
  static Future<Map<String, dynamic>> getDashboardData() async {
    final url = Uri.parse("$_baseUrl/dashboard");
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur lors du chargement des données: ${response.body}");
    }
  }

  // Fetch all pharmacies
  static Future<List<dynamic>> getPharmacies() async {
    final url = Uri.parse("$_baseUrl/pharmacies");
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur lors du chargement des pharmacies: ${response.body}");
    }
  }

  // Add a new pharmacy
  static Future<http.Response> createPharmacy(Map<String, dynamic> pharmacyData) async {
    final url = Uri.parse("$_baseUrl/pharmacies");
    final headers = await _getHeaders();
    return await http.post(
      url,
      headers: headers,
      body: json.encode(pharmacyData),
    );
  }

  // Update pharmacy details
  static Future<http.Response> updatePharmacy(String pharmacyId, Map<String, dynamic> pharmacyData) async {
    final url = Uri.parse("$_baseUrl/pharmacies/$pharmacyId");
    final headers = await _getHeaders();
    return await http.put(
      url,
      headers: headers,
      body: json.encode(pharmacyData),
    );
  }

  // Fetch pharmacy by ID
  static Future<Map<String, dynamic>> getPharmacyById(String pharmacyId) async {
    final url = Uri.parse("$_baseUrl/pharmacies/$pharmacyId");
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur lors du chargement de la pharmacie: ${response.body}");
    }
  }

  // Delete a pharmacy
  static Future<http.Response> deletePharmacy(String pharmacyId) async {
    final url = Uri.parse("$_baseUrl/pharmacies/$pharmacyId");
    final headers = await _getHeaders();
    return await http.delete(url, headers: headers);
  }

  // Fetch all regions
  static Future<List<dynamic>> getRegions() async {
    final url = Uri.parse("$_baseUrl/regions");
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur lors du chargement des régions: ${response.body}");
    }
  }

  // Fetch cities in a region
  static Future<List<dynamic>> getCities(String regionId) async {
    final url = Uri.parse("$_baseUrl/regions/$regionId/cities");
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur lors du chargement des villes: ${response.body}");
    }
  }
}
