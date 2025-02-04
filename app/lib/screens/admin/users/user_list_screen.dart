import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/admin_api.dart';
import '../../../widgets/side_navigation_bar.dart';
import 'user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<dynamic>> _users;

  @override
  void initState() {
    super.initState();
    _users = AdminApi.getUsers();
  }

  void _navigateToUserDetail(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserDetailScreen(user: user),
      ),
    ).then((_) {
      setState(() {
        _users = AdminApi.getUsers();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Liste des Utilisateurs",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      drawer: const SideNavigationBar(),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: FutureBuilder<List<dynamic>>(
          future: _users,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Erreur: ${snapshot.error}",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text("Aucun utilisateur disponible."));
            } else {
              return ListView.separated(
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => Divider(height: 1.h),
                itemBuilder: (context, index) {
                  final user = snapshot.data![index];
                  return ListTile(
                    title: Text(
                      "${user['nom']} ${user['prenom']}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    subtitle: Text(user['email'] ?? 'Email non fourni'),
                    trailing: Icon(
                      user['actif'] ? Icons.check_circle : Icons.block,
                      color: user['actif'] ? Colors.green : Colors.red,
                    ),
                    onTap: () => _navigateToUserDetail(user),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
