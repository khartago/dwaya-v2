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
  late List<Stat> data; // Déclarez data ici pour y accéder dans les getTitles

  @override
  void initState() {
    super.initState();
    _statsFuture = AdminApi.getDashboardStats();
  }

  List<BarChartGroupData> _createSampleData(DashboardStats stats) {
    data = [
      Stat('Pharmacies Actives', stats.activePharmacies),
      Stat('Pharmacies Inactives', stats.inactivePharmacies),
      Stat('Utilisateurs', stats.totalUsers),
      Stat('Demandes', stats.totalRequests),
      Stat('Réclamations', stats.totalReclamations),
      Stat('Rapports', stats.totalReports),
    ];

    return data.asMap().entries.map((entry) {
      int index = entry.key;
      Stat stat = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: stat.value.toDouble(),
            color: Colors.blue,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();
  }

  void _exportCSV() async {
    try {
      DashboardStats stats = await _statsFuture;
      List<List<dynamic>> rows = [
        ['Label', 'Value'],
        ['Pharmacies Actives', stats.activePharmacies],
        ['Pharmacies Inactives', stats.inactivePharmacies],
        ['Utilisateurs', stats.totalUsers],
        ['Demandes', stats.totalRequests],
        ['Réclamations', stats.totalReclamations],
        ['Rapports', stats.totalReports],
      ];

      String csv = const ListToCsvConverter().convert(rows);
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/dashboard_stats.csv';
      final file = File(path);
      await file.writeAsString(csv);

      await Share.shareXFiles([XFile(path)], text: 'Dashboard Stats CSV');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'export CSV: $e')),
      );
    }
  }

  void _exportPDF() async {
    try {
      DashboardStats stats = await _statsFuture;

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'Dashboard Stats',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  headers: ['Label', 'Value'],
                  data: [
                    ['Pharmacies Actives', stats.activePharmacies.toString()],
                    ['Pharmacies Inactives', stats.inactivePharmacies.toString()],
                    ['Utilisateurs', stats.totalUsers.toString()],
                    ['Demandes', stats.totalRequests.toString()],
                    ['Réclamations', stats.totalReclamations.toString()],
                    ['Rapports', stats.totalReports.toString()],
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/dashboard_stats.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(path)], text: 'Dashboard Stats PDF');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'export PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideNavigationBar(),
      appBar: AppBar(
        title: Text('Rapports'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder<DashboardStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            DashboardStats stats = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Graphique des statistiques
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        backgroundColor: Colors.grey,
                        maxY: (stats.activePharmacies > stats.inactivePharmacies
                                ? stats.activePharmacies
                                : stats.inactivePharmacies)
                            .toDouble() +
                            10, // Ajouter un peu de marge
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              String label = data[group.x].label;
                              return BarTooltipItem(
                                '$label\n',
                                TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '${rod.toY}',
                                    style: TextStyle(
                                      color: Colors.yellow,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                if (value.toInt() < data.length) {
                                  String label = data[value.toInt()].label;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 10,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        barGroups: _createSampleData(stats),
                        gridData: FlGridData(show: true),
                      ),
                      duration: Duration(milliseconds: 350), // Optionnel
                    ),
                  ),
                  SizedBox(height: 20),
                  // Boutons d'exportation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _exportCSV,
                        icon: Icon(Icons.download),
                        label: Text('Exporter en CSV'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _exportPDF,
                        icon: Icon(Icons.download),
                        label: Text('Exporter en PDF'),
                      ),
                    ],
                  ),
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
}

class Stat {
  final String label;
  final int value;

  Stat(this.label, this.value);
}

