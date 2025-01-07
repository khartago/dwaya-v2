// lib/widgets/side_navigation_bar.dart
import 'package:flutter/material.dart';
// Assurez-vous que vous avez un modèle User
import '../utils/token_manager.dart';

class SideNavigationBar extends StatelessWidget {
  const SideNavigationBar({Key? key}) : super(key: key);

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context); // Ferme le drawer
    Navigator.pushNamed(context, route);
  }

  void _logout(BuildContext context) async {
    // Implémentez la logique de déconnexion ici
    // Par exemple, effacez les tokens et redirigez vers l'écran de login
    await TokenManager.clearToken();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Admin'),
            accountEmail: Text('admin@dwaya.tn'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, color: Colors.green, size: 40),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () => _navigate(context, '/admin/dashboard'),
          ),
          ListTile(
            leading: Icon(Icons.local_pharmacy),
            title: Text('Pharmacies'),
            onTap: () => _navigate(context, '/admin/pharmacies'),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Utilisateurs'),
            onTap: () => _navigate(context, '/admin/users'),
          ),
          ListTile(
            leading: Icon(Icons.request_page),
            title: Text('Demandes'),
            onTap: () => _navigate(context, '/admin/requests'),
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Rapports'),
            onTap: () => _navigate(context, '/admin/reports'),
          ),
          ListTile(
            leading: Icon(Icons.support_agent),
            title: Text('Support/Réclamations'),
            onTap: () => _navigate(context, '/admin/support/reclamations'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Déconnexion'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
