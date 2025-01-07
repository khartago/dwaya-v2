// lib/screens/admin/pharmacies/pharmacy_detail_screen.dart
import 'package:flutter/material.dart';
import '../../../models/pharmacy.dart';
import '../../../widgets/side_navigation_bar.dart';
import '../../../services/admin_api.dart';
import 'pharmacy_form_screen.dart';

class PharmacyDetailScreen extends StatefulWidget {
  final Pharmacy pharmacy;

  const PharmacyDetailScreen({Key? key, required this.pharmacy}) : super(key: key);

  @override
  _PharmacyDetailScreenState createState() => _PharmacyDetailScreenState();
}

class _PharmacyDetailScreenState extends State<PharmacyDetailScreen> {
  bool _isUpdating = false;

  void _toggleStatus() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await AdminApi.updatePharmacyStatus(widget.pharmacy.id, !widget.pharmacy.actif);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut mis à jour avec succès')),
      );
      Navigator.pop(context); // Retour à la liste des pharmacies
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

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PharmacyFormScreen(pharmacy: widget.pharmacy),
      ),
    ).then((_) => Navigator.pop(context)); // Rafraîchir la liste après modification
  }

  @override
  Widget build(BuildContext context) {
    Pharmacy pharmacy = widget.pharmacy;

    return Scaffold(
      drawer: SideNavigationBar(),
      appBar: AppBar(
        title: Text(pharmacy.nom),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _navigateToEdit,
            tooltip: 'Modifier',
          ),
          IconButton(
            icon: _isUpdating
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : Icon(pharmacy.actif ? Icons.cancel : Icons.check_circle),
            color: pharmacy.actif ? Colors.red : Colors.green,
            onPressed: _isUpdating ? null : _toggleStatus,
            tooltip: pharmacy.actif ? 'Désactiver' : 'Activer',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailTile('Nom', pharmacy.nom),
            _buildDetailTile('Téléphone', pharmacy.telephone),
            _buildDetailTile('Email', pharmacy.email ?? 'Non fourni'),
            _buildDetailTile('Adresse', pharmacy.adresse),
            _buildDetailTile('Région', pharmacy.region),
            _buildDetailTile('Ville', pharmacy.ville),
            _buildDetailTile(
                'Abonnement',
                '${pharmacy.abonnement.plan} '
                '(${_formatDate(pharmacy.abonnement.dateDebut)} - ${_formatDate(pharmacy.abonnement.dateFin)})'),
            _buildDetailTile('Lien Google Maps', pharmacy.lienGoogleMaps),
            _buildDetailTile('Actif', pharmacy.actif ? 'Oui' : 'Non'),
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
