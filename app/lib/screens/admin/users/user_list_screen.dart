// lib/screens/admin/users/user_list_screen.dart
import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../services/admin_api.dart';
import '../../../widgets/user_tile.dart';
import 'user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<User>> _usersFuture;
  String? _selectedRegion;
  String? _selectedVille;
  bool? _isActive;

  @override
  void initState() {
    super.initState();
    _usersFuture = AdminApi.getUsers();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = AdminApi.getUsers(
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
                _refreshUsers();
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
                _refreshUsers();
                Navigator.pop(context);
              },
              child: Text('Réinitialiser'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Utilisateurs'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _openFilterDialog,
            tooltip: 'Filtres Avancés',
          ),
        ],
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<User> users = snapshot.data!;
            if (users.isEmpty) {
              return Center(child: Text('Aucun utilisateur trouvé.'));
            }
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                User user = users[index];
                return UserTile(
                  user: user,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailScreen(user: user),
                      ),
                    ).then((_) => _refreshUsers());
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
