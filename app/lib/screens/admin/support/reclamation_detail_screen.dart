// lib/screens/admin/support/reclamation_detail_screen.dart
import 'package:flutter/material.dart';
import '../../../models/reclamation.dart';
import '../../../services/admin_api.dart';
import '../../../widgets/side_navigation_bar.dart';

class ReclamationDetailScreen extends StatefulWidget {
  final Reclamation reclamation;

  const ReclamationDetailScreen({Key? key, required this.reclamation}) : super(key: key);

  @override
  _ReclamationDetailScreenState createState() => _ReclamationDetailScreenState();
}

class _ReclamationDetailScreenState extends State<ReclamationDetailScreen> {
  final _reponseController = TextEditingController();
  bool _isLoading = false;

  void _submitReponse() async {
    if (_reponseController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AdminApi.respondReclamation(widget.reclamation.id, _reponseController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Réponse ajoutée avec succès')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateStatus(String status) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AdminApi.updateReclamationStatus(widget.reclamation.id, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut de la réclamation mis à jour')),
      );
      setState(() {
        widget.reclamation.status = status;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _reponseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Reclamation reclamation = widget.reclamation;

    return Scaffold(
      drawer: SideNavigationBar(),
      appBar: AppBar(
        title: Text('Détails Réclamation'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              _updateStatus(value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'en cours',
                child: Text('Marquer comme en cours'),
              ),
              PopupMenuItem(
                value: 'résolue',
                child: Text('Marquer comme résolue'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: ListView(
                children: [
                  _buildDetailTile('Type', _capitalize(reclamation.type)),
                  _buildDetailTile('Sujet', reclamation.sujet),
                  _buildDetailTile('Description', reclamation.description),
                  _buildDetailTile('Statut', _capitalize(reclamation.status)),
                  if (reclamation.status == 'résolue')
                    _buildDetailTile('Date de Résolution',
                        reclamation.dateResolution != null ? _formatDate(reclamation.dateResolution!) : 'N/A'),
                  if (reclamation.reponse != null)
                    _buildDetailTile('Réponse', reclamation.reponse!),
                  SizedBox(height: 20),
                  if (reclamation.status != 'résolue') ...[
                    TextField(
                      controller: _reponseController,
                      decoration: InputDecoration(
                        labelText: 'Ajouter une réponse',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitReponse,
                      child: Text('Envoyer la Réponse'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
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

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
