// lib/screens/admin/requests/request_list_screen.dart
import 'package:flutter/material.dart';
import '../../../models/request.dart';
import '../../../services/admin_api.dart';
import '../../../widgets/request_tile.dart';
import 'request_detail_screen.dart';

class RequestListScreen extends StatefulWidget {
  const RequestListScreen({Key? key}) : super(key: key);

  @override
  _RequestListScreenState createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> {
  late Future<List<RequestModel>> _requestsFuture;
  String? _selectedRegion;
  String? _selectedVille;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _requestsFuture = AdminApi.getRequests();
  }

  void _refreshRequests() {
    setState(() {
      _requestsFuture = AdminApi.getRequests(
        region: _selectedRegion,
        ville: _selectedVille,
        status: _selectedStatus,
      );
    });
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempRegion = _selectedRegion;
        String? tempVille = _selectedVille;
        String? tempStatus = _selectedStatus;

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
                // Dropdown pour Status
                DropdownButtonFormField<String>(
                  value: tempStatus,
                  decoration: InputDecoration(labelText: 'Status'),
                  hint: Text('Sélectionnez un statut'),
                  items: ['pending', 'in-progress', 'completed', 'expired', 'refused']
                      .map((status) {
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
                  _selectedRegion = tempRegion;
                  _selectedVille = tempVille;
                  _selectedStatus = tempStatus;
                });
                _refreshRequests();
                Navigator.pop(context);
              },
              child: Text('Appliquer'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedRegion = null;
                  _selectedVille = null;
                  _selectedStatus = null;
                });
                _refreshRequests();
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
        title: Text('Suivi des Demandes'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _openFilterDialog,
            tooltip: 'Filtres Avancés',
          ),
        ],
      ),
      body: FutureBuilder<List<RequestModel>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<RequestModel> requests = snapshot.data!;
            if (requests.isEmpty) {
              return Center(child: Text('Aucune demande trouvée.'));
            }
            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                RequestModel request = requests[index];
                return RequestTile(
                  request: request,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestDetailScreen(request: request),
                      ),
                    ).then((_) => _refreshRequests());
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
