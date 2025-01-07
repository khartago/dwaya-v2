import 'package:flutter/material.dart';
import '../screens/admin/dashboard_screen.dart';
import '../screens/admin/pharmacies/pharmacy_list_screen.dart';
import '../screens/admin/pharmacies/add_pharmacy_screen.dart';
import '../screens/admin/pharmacies/update_pharmacy_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_client_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/splash_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Authentication Routes
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterClientScreen());
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      // Admin Routes
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case '/pharmacies':
        return MaterialPageRoute(builder: (_) => const PharmacyListScreen());
      case '/add-pharmacy':
        return MaterialPageRoute(builder: (_) => const AddPharmacyScreen());
      case '/update-pharmacy':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => UpdatePharmacyScreen(pharmacy: args),
        );

      // Unknown Route
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Erreur')),
            body: Center(
              child: Text(
                'Route inconnue: ${settings.name}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        );
    }
  }
}
