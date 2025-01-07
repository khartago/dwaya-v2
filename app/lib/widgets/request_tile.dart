// lib/widgets/request_tile.dart
import 'package:flutter/material.dart';
import '../models/request.dart';

class RequestTile extends StatelessWidget {
  final RequestModel request;
  final VoidCallback onTap;

  const RequestTile({Key? key, required this.request, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (request.status) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'in-progress':
        statusColor = Colors.blue;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'expired':
        statusColor = Colors.grey;
        break;
      case 'refused':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.black;
    }

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          Icons.request_page,
          color: statusColor,
          size: 40,
        ),
        title: Text('Demande ID: ${request.id}'),
        subtitle: Text('Status: ${_capitalize(request.status)}'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
