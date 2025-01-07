import 'package:flutter/material.dart';
import 'package:dwaya_flutter/utils/constants.dart';
import 'package:dwaya_flutter/screens/auth/splash_screen.dart';
import 'package:dwaya_flutter/screens/auth/login_screen.dart';
import 'package:dwaya_flutter/screens/auth/register_client_screen.dart';
import 'package:dwaya_flutter/screens/auth/forgot_password_screen.dart';

// Import des écrans administratifs nécessaires
import 'package:dwaya_flutter/screens/admin/dashboard_screen.dart';
import 'package:dwaya_flutter/screens/admin/pharmacies/pharmacy_list_screen.dart';
import 'package:dwaya_flutter/screens/admin/pharmacies/pharmacy_detail_screen.dart';
import 'package:dwaya_flutter/screens/admin/pharmacies/pharmacy_form_screen.dart';
import 'package:dwaya_flutter/screens/admin/reports/reports_screen.dart';

import 'package:dwaya_flutter/models/pharmacy.dart';

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

      // Routes administratives
      case Constants.routeAdminDashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case Constants.routeAdminPharmacies:
        return MaterialPageRoute(builder: (_) => const PharmacyListScreen());
      case Constants.routeAdminPharmacyDetail:
        final args = settings.arguments;
        if (args is Pharmacy) {
          return MaterialPageRoute(builder: (_) => PharmacyDetailScreen(pharmacy: args));
        }
        return _errorScreen('Arguments invalides pour PharmacyDetailScreen');
      case Constants.routeAdminPharmacyForm:
        final args = settings.arguments;
        if (args is Pharmacy?) {
          return MaterialPageRoute(builder: (_) => PharmacyFormScreen(pharmacy: args));
        }
        return _errorScreen('Arguments invalides pour PharmacyFormScreen');
      case Constants.routeAdminReports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());

      // Route inconnue
      default:
        return _errorScreen('Route inconnue: ${settings.name}');
    }
  }

  static MaterialPageRoute<dynamic> _errorScreen(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(
          child: Text(
            message,
            style: const TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
