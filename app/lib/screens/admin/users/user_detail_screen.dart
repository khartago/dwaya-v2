import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/admin_api.dart';
import '../../../widgets/side_navigation_bar.dart';

class UserDetailScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserDetailScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late Map<String, dynamic> _userDetails;

  @override
  void initState() {
    super.initState();
    _userDetails = Map.from(widget.user);
  }

  void _toggleUserStatus(bool isActive) async {
    try {
      await AdminApi.toggleUserStatus(_userDetails['_id'], isActive);
      setState(() {
        _userDetails['actif'] = isActive;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Utilisateur ${isActive ? 'activé' : 'désactivé'} avec succès.",
          ),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Détails de ${_userDetails['nom']}",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      drawer: const SideNavigationBar(),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nom: ${_userDetails['nom']} ${_userDetails['prenom']}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 10.h),
            Text(
              "Téléphone: ${_userDetails['telephone']}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 10.h),
            Text(
              "Email: ${_userDetails['email'] ?? 'Non fourni'}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 10.h),
            Text(
              "Région: ${_userDetails['region']['name']}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 10.h),
            Text(
              "Ville: ${_userDetails['ville']['name']}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () =>
                  _toggleUserStatus(!_userDetails['actif']),
              child: Text(
                _userDetails['actif'] ? "Désactiver" : "Activer",
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
