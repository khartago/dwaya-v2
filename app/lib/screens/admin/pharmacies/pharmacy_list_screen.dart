import 'package:flutter/material.dart';
import '../../../services/admin_api.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'add_pharmacy_screen.dart';
import 'update_pharmacy_screen.dart';

class PharmacyListScreen extends StatefulWidget {
  const PharmacyListScreen({Key? key}) : super(key: key);

  @override
  _PharmacyListScreenState createState() => _PharmacyListScreenState();
}

class _PharmacyListScreenState extends State<PharmacyListScreen> {
  late Future<List<dynamic>> _pharmacies;

  @override
  void initState() {
    super.initState();
    _pharmacies = AdminApi.getPharmacies();
  }

  void _navigateToAddPharmacy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddPharmacyScreen()),
    ).then((_) {
      setState(() {
        _pharmacies = AdminApi.getPharmacies();
      });
    });
  }

  void _navigateToUpdatePharmacy(Map<String, dynamic> pharmacy) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpdatePharmacyScreen(pharmacy: pharmacy),
      ),
    ).then((_) {
      setState(() {
        _pharmacies = AdminApi.getPharmacies();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des Pharmacies"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: FutureBuilder<List<dynamic>>(
          future: _pharmacies,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Erreur: ${snapshot.error}",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Aucune pharmacie disponible."));
            } else {
              return ListView.separated(
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => Divider(height: 1.h),
                itemBuilder: (context, index) {
                  final pharmacy = snapshot.data![index];
                  return ListTile(
                    title: Text(pharmacy['nom']),
                    subtitle: Text(pharmacy['region']),
                    trailing: Switch(
                      value: pharmacy['actif'],
                      onChanged: (value) async {
                        await AdminApi.togglePharmacyStatus(pharmacy['_id'], value);
                        setState(() {
                          _pharmacies = AdminApi.getPharmacies();
                        });
                      },
                    ),
                    onTap: () => _navigateToUpdatePharmacy(pharmacy),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPharmacy,
        child: const Icon(Icons.add),
      ),
    );
  }
}
