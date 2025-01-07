// lib/screens/admin/support/reclamation_list_screen.dart
import 'package:flutter/material.dart';
import '../../../models/reclamation.dart';
import '../../../services/admin_api.dart';
import '../../../widgets/reclamation_tile.dart';
import 'reclamation_detail_screen.dart';

class ReclamationListScreen extends StatefulWidget {
  const ReclamationListScreen({Key? key}) : super(key: key);

  @override
  _ReclamationListScreenState createState() => _ReclamationListScreenState();
}

class _ReclamationListScreenState extends State<ReclamationListScreen> {
  late Future<List<Reclamation>> _reclamationsFuture;
  String? _selectedType;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _reclamationsFuture = AdminApi.getReclamations();
  }

  void _refreshReclamations() {
    setState(() {
      _reclamationsFuture = AdminApi.getReclamations(
        type: _selectedType,
        status: _selectedStatus,
      );
    });
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempType = _selectedType;
        String? tempStatus = _selectedStatus;

        return AlertDialog(
          title: Text('Filtres Avancés'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Dropdown pour Type
                DropdownButtonFormField<String>(
                  value: tempType,
                  decoration: InputDecoration(labelText: 'Type'),
                  hint: Text('Sélectionnez un type'),
                  items: ['client', 'pharmacie'].map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(_capitalize(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    tempType = value;
                  },
                ),
                SizedBox(height: 10),
                // Dropdown pour Status
                DropdownButtonFormField<String>(
                  value: tempStatus,
                  decoration: InputDecoration(labelText: 'Status'),
                  hint: Text('Sélectionnez un statut'),
                  items: ['ouverte', 'en cours', 'résolue'].map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(_capitalize(status)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    tempStatus = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedType = tempType;
                  _selectedStatus = tempStatus;
                });
                _refreshReclamations();
                Navigator.pop(context);
              },
              child: Text('Appliquer'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedType = null;
                  _selectedStatus = null;
                });
                _refreshReclamations();
                Navigator.pop(context);
              },
              child: Text('Réinitialiser'),
            ),
          ],
        );
      },
    );
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Réclamations'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _openFilterDialog,
            tooltip: 'Filtres Avancés',
          ),
        ],
      ),
      body: FutureBuilder<List<Reclamation>>(
        future: _reclamationsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Reclamation> reclamations = snapshot.data!;
            if (reclamations.isEmpty) {
              return Center(child: Text('Aucune réclamation trouvée.'));
            }
            return ListView.builder(
              itemCount: reclamations.length,
              itemBuilder: (context, index) {
                Reclamation reclamation = reclamations[index];
                return ReclamationTile(
                  reclamation: reclamation,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReclamationDetailScreen(reclamation: reclamation),
                      ),
                    ).then((_) => _refreshReclamations());
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
    );
  }
}
