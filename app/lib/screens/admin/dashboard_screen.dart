// lib/screens/admin/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../../services/admin_api.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/side_navigation_bar.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = AdminApi.getDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tableau de Bord"),
      ),
      drawer: const SideNavigationBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dashboardData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Erreur lors du chargement des données.",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.red),
                ),
              );
            } else if (snapshot.hasData) {
              return _buildDashboard(snapshot.data!);
            } else {
              return const Center(child: Text("Aucune donnée disponible."));
            }
          },
        ),
      ),
    );
  }

  Widget _buildDashboard(Map<String, dynamic> data) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsGrid(data),
          SizedBox(height: 16.h),
          _buildCharts(data),
          SizedBox(height: 16.h),
          _buildAlerts(data['alerts'] ?? []),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> data) {
    return GridView.count(
      crossAxisCount: ScreenUtil().orientation == Orientation.portrait ? 2 : 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      children: [
        _buildStatCard(
            "Total Clients", data['totalClients'], Icons.people, Colors.blue),
        _buildStatCard("Total Pharmacies", data['totalPharmacies'],
            Icons.local_pharmacy, Colors.green),
        _buildStatCard("Demandes Actives", data['activeRequests'],
            Icons.hourglass_top, Colors.orange),
        _buildStatCard("Demandes Complétées", data['completedRequests'],
            Icons.check_circle, Colors.teal),
        _buildStatCard("Demandes Refusées", data['refusedExpiredRequests'],
            Icons.cancel, Colors.red),
        _buildTimeAndDateCard(), // Added Time and Date card
      ],
    );
  }

  Widget _buildTimeAndDateCard() {
    final currentTime = DateFormat('hh:mm a').format(DateTime.now());
    final currentDate = DateFormat('EEE, d MMM y').format(DateTime.now());

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey.withOpacity(0.5), width: 2.w),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 12.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.access_time, size: 40.sp, color: Colors.grey),
              SizedBox(height: 8.h),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    currentTime,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontSize: 20.sp),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    currentDate,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 14.sp),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: color.withOpacity(0.5), width: 2.w),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 12.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 40.sp, color: color),
              SizedBox(height: 8.h),
              Text(
                "$count",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontSize: 20.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 14.sp),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharts(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Graphiques", style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: 16.h),
        SizedBox(
          height: 200.h,
          child: BarChart(
            BarChartData(
              barGroups: (data['trendData'] as List<dynamic>).map((item) {
                return BarChartGroupData(
                  x: DateTime.parse(item['date']).day,
                  barRods: [
                    BarChartRodData(
                      toY: item['requests'].toDouble(),
                      gradient: LinearGradient(
                          colors: [Colors.blue, Colors.lightBlue]),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 200.h,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                    value: data['activePharmacies'],
                    color: Colors.green,
                    title: "Actives"),
                PieChartSectionData(
                    value: data['inactivePharmacies'],
                    color: Colors.red,
                    title: "Inactives"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlerts(List alerts) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: alerts.length,
        separatorBuilder: (context, index) => Divider(height: 1.h),
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return ListTile(
            leading: Icon(
                alert['type'] == "pharmacy" ? Icons.warning : Icons.error,
                color: Colors.red),
            title: Text(alert['message'],
                style: Theme.of(context).textTheme.bodyLarge),
          );
        },
      ),
    );
  }
}
