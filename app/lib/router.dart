// lib/router.dart

import 'package:flutter/material.dart';
import 'package:dwaya_flutter/utils/constants.dart';
import 'package:dwaya_flutter/screens/auth/splash_screen.dart';
import 'package:dwaya_flutter/screens/auth/login_screen.dart';
import 'package:dwaya_flutter/screens/auth/register_client_screen.dart';
import 'package:dwaya_flutter/screens/auth/forgot_password_screen.dart';

// Import des écrans administratifs
import 'package:dwaya_flutter/screens/admin/dashboard_screen.dart';
import 'package:dwaya_flutter/screens/admin/pharmacies/pharmacy_list_screen.dart';
import 'package:dwaya_flutter/screens/admin/pharmacies/pharmacy_detail_screen.dart';
import 'package:dwaya_flutter/screens/admin/pharmacies/pharmacy_form_screen.dart';
import 'package:dwaya_flutter/screens/admin/users/user_list_screen.dart';
import 'package:dwaya_flutter/screens/admin/users/user_detail_screen.dart';
import 'package:dwaya_flutter/screens/admin/requests/request_list_screen.dart';
import 'package:dwaya_flutter/screens/admin/requests/request_detail_screen.dart';
import 'package:dwaya_flutter/screens/admin/reports/reports_screen.dart';
import 'package:dwaya_flutter/screens/admin/support/reclamation_list_screen.dart';
import 'package:dwaya_flutter/screens/admin/support/reclamation_detail_screen.dart';

// Import des modèles
import 'package:dwaya_flutter/models/pharmacy.dart';
import 'package:dwaya_flutter/models/user.dart';
import 'package:dwaya_flutter/models/request.dart';
import 'package:dwaya_flutter/models/reclamation.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Routes d'authentification
      case Constants.routeSplash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Constants.routeLogin:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Constants.routeRegister:
        return MaterialPageRoute(builder: (_) => const RegisterClientScreen());
      case Constants.routeForgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      // Routes administratives protégées
      case Constants.routeAdminDashboard:
      case Constants.routeAdminPharmacies:
      case Constants.routeAdminPharmacyDetail:
      case Constants.routeAdminPharmacyForm:
      case Constants.routeAdminUsers:
      case Constants.routeAdminUserDetail:
      case Constants.routeAdminRequests:
      case Constants.routeAdminRequestDetail:
      case Constants.routeAdminReclamations:
      case Constants.routeAdminReclamationDetail:
      case Constants.routeAdminReports:
        return _buildAdminRoute(settings);

      // Routes inconnues
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Erreur')),
            body: Center(
              child: Text(
                'Route inconnue: ${settings.name}',
                style: Constants.bodyStyle,
              ),
            ),
          ),
        );
    }
  }

  static Route<dynamic> _buildAdminRoute(RouteSettings settings) {
    // Ici, vous devriez vérifier si l'utilisateur est administrateur.
    // Pour simplifier, nous supposerons que l'utilisateur est toujours admin.
    // Vous devriez intégrer une logique d'authentification réelle ici.

    return MaterialPageRoute(builder: (_) => _getAdminScreen(settings));
  }

  static Widget _getAdminScreen(RouteSettings settings) {
    switch (settings.name) {
      case Constants.routeAdminDashboard:
        return const DashboardScreen();
      case Constants.routeAdminPharmacies:
        return const PharmacyListScreen();
      case Constants.routeAdminPharmacyDetail:
        final args = settings.arguments;
        if (args is Pharmacy) {
          return PharmacyDetailScreen(pharmacy: args);
        }
        return _errorScreen('Arguments invalides pour PharmacyDetailScreen');
      case Constants.routeAdminPharmacyForm:
        final args = settings.arguments;
        if (args is Pharmacy?) {
          return PharmacyFormScreen(pharmacy: args);
        }
        return _errorScreen('Arguments invalides pour PharmacyFormScreen');
      case Constants.routeAdminUsers:
        return const UserListScreen();
      case Constants.routeAdminUserDetail:
        final args = settings.arguments;
        if (args is User) {
          return UserDetailScreen(user: args);
        }
        return _errorScreen('Arguments invalides pour UserDetailScreen');
      case Constants.routeAdminRequests:
        return const RequestListScreen();
      case Constants.routeAdminRequestDetail:
        final args = settings.arguments;
        if (args is RequestModel) {
          return RequestDetailScreen(request: args);
        }
        return _errorScreen('Arguments invalides pour RequestDetailScreen');
      case Constants.routeAdminReclamations:
        return const ReclamationListScreen();
      case Constants.routeAdminReclamationDetail:
        final args = settings.arguments;
        if (args is Reclamation) {
          return ReclamationDetailScreen(reclamation: args);
        }
        return _errorScreen('Arguments invalides pour ReclamationDetailScreen');
      case Constants.routeAdminReports:
        return const ReportsScreen();
      default:
        return _errorScreen('Route inconnue: ${settings.name}');
    }
  }

  static Widget _errorScreen(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Text(
          message,
          style: Constants.errorColor == Colors.red
              ? TextStyle(color: Constants.errorColor, fontSize: 18)
              : Constants.bodyStyle,
        ),
      ),
    );
  }
}
