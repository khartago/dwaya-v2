// lib/widgets/pharmacy_tile.dart
import 'package:flutter/material.dart';
import '../models/pharmacy.dart';
import '../extensions/string_extension.dart';

class PharmacyTile extends StatelessWidget {
  final Pharmacy pharmacy;
  final VoidCallback onTap;

  const PharmacyTile({Key? key, required this.pharmacy, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          pharmacy.actif ? Icons.check_circle : Icons.cancel,
          color: pharmacy.actif ? Colors.green : Colors.red,
          size: 40,
        ),
        title: Text(
          pharmacy.nom,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        subtitle: Text('${pharmacy.ville.capitalize()}, ${pharmacy.region.capitalize()}'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
