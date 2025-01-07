// lib/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:dwaya_flutter/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool step1 = true;

  final _telCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();

  String _message = "";
  bool _loading = false;

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

  Future<void> _requestCode() async {
    String telephone = _telCtrl.text.trim();
    String email = _emailCtrl.text.trim();

    if (telephone.isEmpty && email.isEmpty) {
      showError("Veuillez entrer votre téléphone ou votre email.");
      return;
    }

    setState(() {
      _message = "";
      _loading = true;
    });

    try {
      await ApiService.forgotPassword(
        telephone: telephone.isEmpty ? null : telephone,
        email: email.isEmpty ? null : email,
      );
      setState(() {
        _message = "Un code de réinitialisation a été envoyé. Vérifiez vos SMS/Email.";
        step1 = false;
      });
      showSuccess(_message);
    } catch (e) {
      setState(() => _message = e.toString());
      showError(_message);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    String telephone = _telCtrl.text.trim();
    String email = _emailCtrl.text.trim();
    String code = _codeCtrl.text.trim();
    String newPassword = _newPassCtrl.text.trim();

    if (code.isEmpty || newPassword.isEmpty) {
      showError("Veuillez remplir tous les champs.");
      return;
    }

    setState(() {
      _message = "";
      _loading = true;
    });

    try {
      await ApiService.resetPassword(
        telephone: telephone.isEmpty ? null : telephone,
        email: email.isEmpty ? null : email,
        code: code,
        newPassword: newPassword,
      );
      setState(() {
        _message = "Votre mot de passe a été réinitialisé avec succès.";
      });
      showSuccess(_message);
      Navigator.pop(context);
    } catch (e) {
      setState(() => _message = e.toString());
      showError(_message);
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildStep1() {
    return Column(
      children: [
        Image.asset(
          'assets/logo.png',
          height: 150,
        ),
        const SizedBox(height: 30),
        Text(
          "Réinitialiser votre mot de passe",
          style: Theme.of(context).textTheme.displayLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          "Pour réinitialiser votre mot de passe, veuillez entrer votre téléphone ou votre email. Un code de réinitialisation vous sera envoyé.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _telCtrl,
          decoration: const InputDecoration(
            labelText: "Téléphone",
            hintText: "Ex : 98 123 456",
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _emailCtrl,
          decoration: const InputDecoration(
            labelText: "Email",
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 30),
        if (_message.isNotEmpty)
          Text(
            _message,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: _loading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _requestCode,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      "Obtenir le Code",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        Image.asset(
          'assets/logo.png',
          height: 150,
        ),
        const SizedBox(height: 30),
        Text(
          "Réinitialiser votre mot de passe",
          style: Theme.of(context).textTheme.displayLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          "Entrez le code que vous avez reçu et votre nouveau mot de passe pour terminer la réinitialisation.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _codeCtrl,
          decoration: const InputDecoration(
            labelText: "Code de Réinitialisation",
            hintText: "Ex : 123456",
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _newPassCtrl,
          decoration: const InputDecoration(
            labelText: "Nouveau Mot de Passe",
            hintText: "•••••••",
          ),
          obscureText: true,
        ),
        const SizedBox(height: 30),
        if (_message.isNotEmpty)
          Text(
            _message,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: _loading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      "Réinitialiser le Mot de Passe",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar stylisée via le thème
      appBar: AppBar(
        title: const Text("Mot de Passe Oublié"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: step1 ? _buildStep1() : _buildStep2(),
      ),
    );
  }
}
