// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:dwaya_flutter/services/api_service.dart';
import 'package:dwaya_flutter/utils/token_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final r = await TokenManager.getUserRole();
    setState(() => _role = r);
  }

  Future<void> _handleLogout() async {
    await ApiService.logout();
    if (!mounted) return;
    Fluttertoast.showToast(
      msg: "Déconnexion réussie !",
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final roleText = _role?.toUpperCase() ?? "CLIENT";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accueil Dwaya.tn"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: "Se Déconnecter",
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 150,
              ),
              const SizedBox(height: 30),
              Text(
                "Bienvenue sur Dwaya.tn",
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Vous êtes connecté en tant que : $roleText",
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      "Se Déconnecter",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
