// lib/models/dashboard_stats.dart
class DashboardStats {
  final int userCount;
  final int pharmacyCount;
  final int requestCount;
  final int reclamationCount;
  final int activePharmacies;
  final int inactivePharmacies;
  final int totalUsers;
  final int totalRequests;
  final int totalReclamations;
  final int totalReports;

  DashboardStats({
    required this.userCount,
    required this.pharmacyCount,
    required this.requestCount,
    required this.reclamationCount,
    required this.activePharmacies,
    required this.inactivePharmacies,
    required this.totalUsers,
    required this.totalRequests,
    required this.totalReclamations,
    required this.totalReports,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      userCount: json['userCount'] ?? 0,
      pharmacyCount: json['pharmacyCount'] ?? 0,
      requestCount: json['requestCount'] ?? 0,
      reclamationCount: json['reclamationCount'] ?? 0,
      activePharmacies: json['activePharmacies'] ?? 0,
      inactivePharmacies: json['inactivePharmacies'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      totalRequests: json['totalRequests'] ?? 0,
      totalReclamations: json['totalReclamations'] ?? 0,
      totalReports: json['totalReports'] ?? 0,
    );
  }
}
