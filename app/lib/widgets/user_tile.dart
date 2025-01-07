// lib/widgets/user_tile.dart
import 'package:dwaya_flutter/extensions/string_extension.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';

class UserTile extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const UserTile({Key? key, required this.user, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          user.actif ? Icons.check_circle : Icons.cancel,
          color: user.actif ? Colors.green : Colors.red,
          size: 40,
        ),
        title: Text('${user.nom} ${user.prenom}'),
        subtitle: Text('${user.ville.capitalize()}, ${user.region.capitalize()}'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
