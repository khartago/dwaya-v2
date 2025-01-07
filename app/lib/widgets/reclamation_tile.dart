// lib/widgets/reclamation_tile.dart
import 'package:flutter/material.dart';
import '../models/reclamation.dart';

class ReclamationTile extends StatelessWidget {
  final Reclamation reclamation;
  final VoidCallback onTap;

  const ReclamationTile({Key? key, required this.reclamation, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (reclamation.status) {
      case 'ouverte':
        statusColor = Colors.orange;
        break;
      case 'en cours':
        statusColor = Colors.blue;
        break;
      case 'résolue':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.black;
    }

    IconData typeIcon = reclamation.type == 'client' ? Icons.person : Icons.local_pharmacy;

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          typeIcon,
          color: statusColor,
          size: 40,
        ),
        title: Text(reclamation.sujet),
        subtitle: Text('Status: ${_capitalize(reclamation.status)}'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
