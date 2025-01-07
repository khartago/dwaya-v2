// lib/screens/admin/reports/reports_screen.dart
import 'package:flutter/material.dart';
import '../../../widgets/side_navigation_bar.dart';
import '../../../services/admin_api.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/dashboard_stats.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<DashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = AdminApi.getDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rapports"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      drawer: const SideNavigationBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DashboardStats>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Erreur lors du chargement des données.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            } else if (snapshot.hasData) {
              return _buildReportsContent(snapshot.data!);
            } else {
              return Center(
                child: Text(
                  "Aucune donnée disponible.",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildReportsContent(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Rapports Généraux",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              _buildChartSection(),
              const SizedBox(height: 16),
              _buildStatTable(stats),
              const SizedBox(height: 16),
              _buildExportButtons(stats),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Distribution des Pharmacies",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 60,
                      title: 'Actives',
                      color: Colors.green,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: 40,
                      title: 'Inactives',
                      color: Colors.red,
                      radius: 50,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTable(DashboardStats stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Statistiques",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Table(
              children: [
                _buildTableRow("Pharmacies Actives", stats.activePharmacies.toString()),
                _buildTableRow("Pharmacies Inactives", stats.inactivePharmacies.toString()),
                _buildTableRow("Total Utilisateurs", stats.totalUsers.toString()),
                _buildTableRow("Total Requêtes", stats.totalRequests.toString()),
                _buildTableRow("Total Réclamations", stats.totalReclamations.toString()),
                _buildTableRow("Total Rapports", stats.totalReports.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildExportButtons(DashboardStats stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => _exportToCsv(stats),
          icon: const Icon(Icons.file_download),
          label: const Text("Exporter CSV"),
        ),
        ElevatedButton.icon(
          onPressed: () => _exportToPdf(stats),
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text("Exporter PDF"),
        ),
      ],
    );
  }

  Future<void> _exportToCsv(DashboardStats stats) async {
    final csvData = [
      ["Statistique", "Valeur"],
      ["Pharmacies Actives", stats.activePharmacies],
      ["Pharmacies Inactives", stats.inactivePharmacies],
      ["Total Utilisateurs", stats.totalUsers],
      ["Total Requêtes", stats.totalRequests],
      ["Total Réclamations", stats.totalReclamations],
      ["Total Rapports", stats.totalReports],
    ];

    final csvString = const ListToCsvConverter().convert(csvData);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/rapport.csv');
    await file.writeAsString(csvString);

    await Share.shareFiles([file.path], text: 'Rapport CSV');
  }

  Future<void> _exportToPdf(DashboardStats stats) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text("Rapport Statistiques", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              data: [
                ["Statistique", "Valeur"],
                ["Pharmacies Actives", stats.activePharmacies],
                ["Pharmacies Inactives", stats.inactivePharmacies],
                ["Total Utilisateurs", stats.totalUsers],
                ["Total Requêtes", stats.totalRequests],
                ["Total Réclamations", stats.totalReclamations],
                ["Total Rapports", stats.totalReports],
              ],
            ),
          ],
        ),
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/rapport.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareFiles([file.path], text: 'Rapport PDF');
  }
}
