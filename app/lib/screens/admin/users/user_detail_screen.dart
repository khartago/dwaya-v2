// lib/screens/admin/users/user_detail_screen.dart
import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../services/admin_api.dart';
import '../../../widgets/side_navigation_bar.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;

  const UserDetailScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  bool _isUpdating = false;

  void _toggleUserStatus() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await AdminApi.updateUserStatus(widget.user.id, !widget.user.actif);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut de l\'utilisateur mis à jour')),
      );
      Navigator.pop(context); // Retour à la liste des utilisateurs
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  // Vous pouvez ajouter des fonctionnalités supplémentaires ici, comme la modification des informations de l'utilisateur

  @override
  Widget build(BuildContext context) {
    User user = widget.user;

    return Scaffold(
      drawer: SideNavigationBar(),
      appBar: AppBar(
        title: Text('${user.nom} ${user.prenom}'),
        actions: [
          IconButton(
            icon: _isUpdating
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : Icon(user.actif ? Icons.cancel : Icons.check_circle),
            color: user.actif ? Colors.red : Colors.green,
            onPressed: _isUpdating ? null : _toggleUserStatus,
            tooltip: user.actif ? 'Désactiver' : 'Activer',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailTile('Nom', user.nom),
            _buildDetailTile('Prénom', user.prenom),
            _buildDetailTile('Téléphone', user.telephone),
            _buildDetailTile('Email', user.email ?? 'Non fourni'),
            _buildDetailTile('Région', user.region),
            _buildDetailTile('Ville', user.ville),
            _buildDetailTile('Note Moyenne', user.note.moyenne.toString()),
            _buildDetailTile('Nombre de Notes', user.note.count.toString()),
            _buildDetailTile('Actif', user.actif ? 'Oui' : 'Non'),
            _buildDetailTile('Date d\'Inscription', _formatDate(user.dateInscription)),
            _buildDetailTile(
                'Dernière Connexion',
                user.dateDerniereConnexion != null
                    ? _formatDate(user.dateDerniereConnexion!)
                    : 'Jamais'),
            // Ajoutez d'autres détails si nécessaire
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(String title, String subtitle) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
