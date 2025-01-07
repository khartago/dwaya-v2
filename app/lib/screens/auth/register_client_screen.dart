// lib/screens/register_client_screen.dart
import 'package:flutter/material.dart';
import 'package:dwaya_flutter/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterClientScreen extends StatefulWidget {
  const RegisterClientScreen({Key? key}) : super(key: key);

  @override
  State<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mdpCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _telCtrl.dispose();
    _emailCtrl.dispose();
    _mdpCtrl.dispose();
    _regionCtrl.dispose();
    _villeCtrl.dispose();
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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      // Validation échouée
      return;
    }

    setState(() {
      _loading = true;
    });

    String nom = _nomCtrl.text.trim();
    String prenom = _prenomCtrl.text.trim();
    String telephone = _telCtrl.text.trim();
    String email = _emailCtrl.text.trim();
    String motDePasse = _mdpCtrl.text.trim();
    String region = _regionCtrl.text.trim();
    String ville = _villeCtrl.text.trim();

    try {
      await ApiService.registerClient(
        nom: nom,
        prenom: prenom,
        telephone: telephone,
        email: email.isEmpty ? null : email, // Peut être null
        motDePasse: motDePasse,
        region: region,
        ville: ville,
      );
      if (!mounted) return;
      showSuccess("Inscription réussie ! Bienvenue chez Dwaya.tn.");
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      showError(e.toString());
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _clearForm() async {
    _nomCtrl.clear();
    _prenomCtrl.clear();
    _telCtrl.clear();
    _emailCtrl.clear();
    _mdpCtrl.clear();
    _regionCtrl.clear();
    _villeCtrl.clear();
    setState(() {
      // Pas de message d'erreur à nettoyer ici
    });
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

  String? _validateNonEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName est requis.";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Utilisez MediaQuery pour une meilleure responsivité
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // AppBar stylisée via le thème
      appBar: AppBar(
        title: const Text("Inscription"),
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
                    "Créez votre compte Dwaya.tn en quelques étapes simples",
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _nomCtrl,
                    decoration: const InputDecoration(
                      labelText: "Nom *",
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) => _validateNonEmpty(value, "Nom"),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _prenomCtrl,
                    decoration: const InputDecoration(
                      labelText: "Prénom *",
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) => _validateNonEmpty(value, "Prénom"),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _telCtrl,
                    decoration: const InputDecoration(
                      labelText: "Téléphone *",
                      hintText: "Ex : 98 123 456",
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: _validateTelephone,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: "Email (optionnel)",
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    // Pas de validation si optionnel
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _mdpCtrl,
                    decoration: const InputDecoration(
                      labelText: "Mot de passe *",
                      hintText: "•••••••",
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _regionCtrl,
                    decoration: const InputDecoration(
                      labelText: "Région *",
                      prefixIcon: Icon(Icons.map),
                    ),
                    validator: (value) => _validateNonEmpty(value, "Région"),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _villeCtrl,
                    decoration: const InputDecoration(
                      labelText: "Ville *",
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    validator: (value) => _validateNonEmpty(value, "Ville"),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _handleRegister,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              elevation: 5,
                              padding: const EdgeInsets.symmetric(vertical: 14.0),
                            ),
                            child: const Text(
                              "S'inscrire",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _clearForm,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        side: BorderSide(color: Colors.green[700]!),
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                      ),
                      child: const Text(
                        "Effacer les champs",
                        style: TextStyle(fontSize: 18),
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
