// lib/screens/admin/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/side_navigation_bar.dart';
import '../../services/admin_api.dart';
import '../../models/dashboard_stats.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = AdminApi.getDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideNavigationBar(),
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: FutureBuilder<DashboardStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            DashboardStats stats = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard('Pharmacies Actives', stats.activePharmacies, Colors.green),
                  _buildStatCard('Pharmacies Inactives', stats.inactivePharmacies, Colors.red),
                  _buildStatCard('Utilisateurs', stats.totalUsers, Colors.blue),
                  _buildStatCard('Demandes', stats.totalRequests, Colors.orange),
                  _buildStatCard('Réclamations', stats.totalReclamations, Colors.purple),
                  _buildStatCard('Rapports', stats.totalReports, Colors.teal),
                  // Ajoutez d'autres statistiques si nécessaire
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
