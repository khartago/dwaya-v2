// lib/screens/admin/pharmacies/pharmacy_list_screen.dart
import 'package:flutter/material.dart';
import '../../../models/pharmacy.dart';
import '../../../services/admin_api.dart';
import '../../../widgets/pharmacy_tile.dart';
import './pharmacy_detail_screen.dart';
import './pharmacy_form_screen.dart';

class PharmacyListScreen extends StatefulWidget {
  const PharmacyListScreen({Key? key}) : super(key: key);

  @override
  _PharmacyListScreenState createState() => _PharmacyListScreenState();
}

class _PharmacyListScreenState extends State<PharmacyListScreen> {
  late Future<List<Pharmacy>> _pharmaciesFuture;
  String? _selectedRegion;
  String? _selectedVille;
  bool? _isActive;

  @override
  void initState() {
    super.initState();
    _pharmaciesFuture = AdminApi.getPharmacies();
  }

  void _refreshPharmacies() {
    setState(() {
      _pharmaciesFuture = AdminApi.getPharmacies(
        region: _selectedRegion,
        ville: _selectedVille,
        actif: _isActive,
      );
    });
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempRegion = _selectedRegion;
        String? tempVille = _selectedVille;
        bool? tempActive = _isActive;

        return AlertDialog(
          title: Text('Filtres Avancés'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Dropdown pour Région
                DropdownButtonFormField<String>(
                  value: tempRegion,
                  decoration: InputDecoration(labelText: 'Région'),
                  hint: Text('Sélectionnez une région'),
                  items: ['Region 1', 'Region 2', 'Region 3'].map((region) {
                    return DropdownMenuItem<String>(
                      value: region,
                      child: Text(region),
                    );
                  }).toList(),
                  onChanged: (value) {
                    tempRegion = value;
                  },
                ),
                SizedBox(height: 10),
                // Dropdown pour Ville
                DropdownButtonFormField<String>(
                  value: tempVille,
                  decoration: InputDecoration(labelText: 'Ville'),
                  hint: Text('Sélectionnez une ville'),
                  items: ['Ville A', 'Ville B', 'Ville C'].map((ville) {
                    return DropdownMenuItem<String>(
                      value: ville,
                      child: Text(ville),
                    );
                  }).toList(),
                  onChanged: (value) {
                    tempVille = value;
                  },
                ),
                SizedBox(height: 10),
                // Checkbox pour Actif
                CheckboxListTile(
                  title: Text('Actif'),
                  value: tempActive ?? false,
                  onChanged: (value) {
                    tempActive = value;
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedRegion = tempRegion;
                  _selectedVille = tempVille;
                  _isActive = tempActive;
                });
                _refreshPharmacies();
                Navigator.pop(context);
              },
              child: Text('Appliquer'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedRegion = null;
                  _selectedVille = null;
                  _isActive = null;
                });
                _refreshPharmacies();
                Navigator.pop(context);
              },
              child: Text('Réinitialiser'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToCreatePharmacy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PharmacyFormScreen()),
    ).then((_) => _refreshPharmacies());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Pharmacies'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _openFilterDialog,
            tooltip: 'Filtres Avancés',
          ),
        ],
      ),
      body: FutureBuilder<List<Pharmacy>>(
        future: _pharmaciesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Pharmacy> pharmacies = snapshot.data!;
            if (pharmacies.isEmpty) {
              return Center(child: Text('Aucune pharmacie trouvée.'));
            }
            return ListView.builder(
              itemCount: pharmacies.length,
              itemBuilder: (context, index) {
                Pharmacy pharmacy = pharmacies[index];
                return PharmacyTile(
                  pharmacy: pharmacy,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PharmacyDetailScreen(pharmacy: pharmacy),
                      ),
                    ).then((_) => _refreshPharmacies());
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePharmacy,
        child: Icon(Icons.add),
        tooltip: 'Ajouter une Pharmacie',
      ),
    );
  }
}
