// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:dwaya_flutter/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telephoneCtrl = TextEditingController();
  final _mdpCtrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _telephoneCtrl.dispose();
    _mdpCtrl.dispose();
    super.dispose();
  }

  void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      // Validation échouée
      return;
    }

    setState(() {
      _loading = true;
    });

    String telephone = _telephoneCtrl.text.trim();
    String motDePasse = _mdpCtrl.text.trim();

    try {
      await ApiService.login(telephone, motDePasse);
      if (!mounted) return;
      showSuccess("Connexion réussie ! Bienvenue chez Dwaya.tn.");
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      showError(e.toString());
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String? _validateTelephone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Le téléphone est requis.";
    }
    // Validation : exactement 8 chiffres
    final phoneRegExp = RegExp(r'^\d{8}$');
    if (!phoneRegExp.hasMatch(value.trim())) {
      return "Le téléphone doit contenir exactement 8 chiffres.";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Le mot de passe est requis.";
    }
    if (value.length < 6) {
      return "Le mot de passe doit contenir au moins 6 caractères.";
    }
    // Vous pouvez ajouter d'autres critères de validation ici
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Utilisez MediaQuery pour une meilleure responsivité
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // AppBar stylisée via le thème
      appBar: AppBar(
        title: const Text("Connexion"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth < 600 ? screenWidth : 500, // Limiter la largeur sur grands écrans
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction, // Activation de la validation en temps réel
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 150,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Connectez-vous à votre compte Dwaya.tn",
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _telephoneCtrl,
                    decoration: const InputDecoration(
                      labelText: "Téléphone",
                      hintText: "Ex : 98 123 456",
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: _validateTelephone,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _mdpCtrl,
                    decoration: const InputDecoration(
                      labelText: "Mot de passe",
                      hintText: "•••••••",
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              elevation: 5,
                              padding: const EdgeInsets.symmetric(vertical: 14.0),
                            ),
                            child: const Text(
                              "Se Connecter",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        side: BorderSide(color: Colors.green[700]!),
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                      ),
                      child: const Text(
                        "Créer un nouveau compte",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      child: const Text(
                        "Mot de passe oublié ?",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
