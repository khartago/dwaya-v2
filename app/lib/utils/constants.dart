// lib/utils/constants.dart

import 'package:flutter/material.dart';

class Constants {
  // =========================
  //        API CONFIGURATION
  // =========================

  /// URL de base de votre backend
  static const String baseUrl = 'https://api.dwaya.tn'; // Remplacez par votre URL réelle

  /// Endpoints Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminPharmacies = '/admin/pharmacies';
  static const String adminUsers = '/admin/users';
  static const String adminRequests = '/admin/requests';
  static const String adminReclamations = '/admin/reclamations';
  static const String adminMessages = '/admin/requests/messages';

  // =========================
  //          ASSETS
  // =========================

  /// Chemin vers le logo de l'application
  static const String logoPath = 'assets/logo.png';

  // =========================
  //        UI CONFIGURATION
  // =========================

  /// Durée d'attente pour les requêtes API avant timeout
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Couleurs principales de l'application
  static const Color primaryColor = Color(0xFF4CAF50); // Vert
  static const Color secondaryColor = Color(0xFFFF9800); // Orange
  static const Color backgroundColor = Color(0xFFF5F5F5); // Gris clair
  static const Color accentColor = Color(0xFF2196F3); // Bleu
  static const Color errorColor = Color(0xFFF44336); // Rouge

  /// Text Styles (optionnel)
  static const TextStyle headlineStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static const TextStyle subheadlineStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: Colors.black54,
  );

  // =========================
  //        ROUTES
  // =========================

  /// Routes administratives
  static const String routeAdminDashboard = '/admin/dashboard';
  static const String routeAdminPharmacies = '/admin/pharmacies';
  static const String routeAdminPharmacyDetail = '/admin/pharmacies/detail';
  static const String routeAdminPharmacyForm = '/admin/pharmacies/form';
  static const String routeAdminUsers = '/admin/users';
  static const String routeAdminUserDetail = '/admin/users/detail';
  static const String routeAdminRequests = '/admin/requests';
  static const String routeAdminRequestDetail = '/admin/requests/detail';
  static const String routeAdminReclamations = '/admin/support/reclamations';
  static const String routeAdminReclamationDetail = '/admin/support/reclamations/detail';
  static const String routeAdminReports = '/admin/reports';

  /// Routes d'authentification
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeForgotPassword = '/forgot-password';

  // =========================
  //        MESSAGES
  // =========================

  /// Messages d'erreur génériques
  static const String errorNetwork = 'Erreur réseau. Veuillez vérifier votre connexion.';
  static const String errorServer = 'Erreur du serveur. Veuillez réessayer plus tard.';
  static const String errorUnauthorized = 'Accès non autorisé. Veuillez vous reconnecter.';
  static const String errorUnknown = 'Une erreur inconnue est survenue.';
}
