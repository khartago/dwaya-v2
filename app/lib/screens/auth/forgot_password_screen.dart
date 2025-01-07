import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dwaya_flutter/services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();

  bool step1 = true;
  bool _loading = false;

  @override
  void dispose() {
    _telCtrl.dispose();
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  void showToast(String message, bool success) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: success ? Theme.of(context).colorScheme.primary : Colors.red,
      textColor: Colors.white,
    );
  }

  Future<void> _requestCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ApiService.forgotPassword(
        telephone: _telCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );
      setState(() => step1 = false);
      showToast("Code envoyé. Vérifiez votre téléphone ou votre email.", true);
    } catch (e) {
      showToast(e.toString(), false);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ApiService.resetPassword(
        telephone: _telCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        code: _codeCtrl.text.trim(),
        newPassword: _newPassCtrl.text.trim(),
      );
      showToast("Mot de passe réinitialisé avec succès !", true);
      Navigator.pop(context);
    } catch (e) {
      showToast(e.toString(), false);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mot de passe oublié"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: step1 ? _buildStep1() : _buildStep2(),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Image.asset(
          'assets/logo.png', // Ensure the logo is in the correct assets path
          height: 150,
        ),
        const SizedBox(height: 20),
        Text(
          "Réinitialiser votre mot de passe",
          style: Theme.of(context).textTheme.displayLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          "Entrez votre numéro de téléphone ou adresse email pour recevoir un code de réinitialisation.",
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _telCtrl,
          decoration: InputDecoration(
            labelText: "Numéro de téléphone",
            hintText: "Entrez votre numéro",
            prefixIcon: const Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Veuillez entrer votre numéro de téléphone.";
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailCtrl,
          decoration: InputDecoration(
            labelText: "Adresse email",
            hintText: "Entrez votre email",
            prefixIcon: const Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Veuillez entrer votre email.";
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _requestCode,
            child: _loading
                ? const CircularProgressIndicator()
                : const Text("Envoyer le code"),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Image.asset(
          'assets/logo.png', // Ensure the logo is in the correct assets path
          height: 100,
        ),
        const SizedBox(height: 20),
        Text(
          "Configurer un nouveau mot de passe",
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          "Entrez le code de réinitialisation reçu ainsi que votre nouveau mot de passe.",
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _codeCtrl,
          decoration: InputDecoration(
            labelText: "Code de réinitialisation",
            hintText: "Entrez le code",
            prefixIcon: const Icon(Icons.security),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Veuillez entrer le code.";
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _newPassCtrl,
          decoration: InputDecoration(
            labelText: "Nouveau mot de passe",
            hintText: "Entrez votre mot de passe",
            prefixIcon: const Icon(Icons.lock),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Veuillez entrer un nouveau mot de passe.";
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _resetPassword,
            child: _loading
                ? const CircularProgressIndicator()
                : const Text("Réinitialiser le mot de passe"),
          ),
        ),
      ],
    );
  }
}
