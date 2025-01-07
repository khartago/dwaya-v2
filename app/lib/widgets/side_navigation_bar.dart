import 'package:flutter/material.dart';
import '../screens/admin/dashboard_screen.dart';
import '../screens/admin/pharmacies/pharmacy_list_screen.dart';
//import '../screens/admin/users/user_list_screen.dart';
//import '../screens/admin/requests/request_list_screen.dart';
////import '../screens/admin/reports/reports_screen.dart';
import '../services/api_service.dart';

class SideNavigationBar extends StatelessWidget {
  const SideNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).primaryColorDark.withOpacity(0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDrawerHeader(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildNavItem(
                    context,
                    icon: Icons.dashboard_outlined,
                    title: 'Tableau de bord',
                    route: DashboardScreen(),
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.local_pharmacy_outlined,
                    title: 'Pharmacies',
                    route: PharmacyListScreen(),
                  ),
                  /*_buildNavItem(
                    context,
                    icon: Icons.people_outline,
                    title: 'Utilisateurs',
                    route: UserListScreen(),
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.list_alt,
                    title: 'Demandes',
                    route: RequestListScreen(),
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.bar_chart_outlined,
                    title: 'Rapports',
                    route: ReportsScreen(),
                  ),*/
                  const Divider(color: Colors.white70, thickness: 1),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.white, size: 24),
                    title: Text(
                      'Se déconnecter',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white),
                    ),
                    onTap: () async {
                      await ApiService.logout(); // Add your logout functionality
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false);
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white70, thickness: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Version 1.0.0',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColorDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.admin_panel_settings_outlined,
              size: 40,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Panneau Admin',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget route,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: Colors.white),
      ),
      hoverColor: Colors.white24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        Navigator.pop(context); // Close the drawer
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => route),
        );
      },
    );
  }
}
