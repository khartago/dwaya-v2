// lib/models/dashboard_stats.dart
class DashboardStats {
  final int activePharmacies;
  final int inactivePharmacies;
  final int totalUsers;
  final int totalRequests;
  final int totalReclamations;
  final int totalReports;

  DashboardStats({
    required this.activePharmacies,
    required this.inactivePharmacies,
    required this.totalUsers,
    required this.totalRequests,
    required this.totalReclamations,
    required this.totalReports,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      activePharmacies: json['active_pharmacies'] ?? 0,
      inactivePharmacies: json['inactive_pharmacies'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
      totalRequests: json['total_requests'] ?? 0,
      totalReclamations: json['total_reclamations'] ?? 0,
      totalReports: json['total_reports'] ?? 0,
    );
  }
}
