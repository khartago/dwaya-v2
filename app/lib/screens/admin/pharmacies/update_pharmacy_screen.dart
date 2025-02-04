import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/admin_api.dart';
import '../../../widgets/side_navigation_bar.dart';

class UpdatePharmacyScreen extends StatefulWidget {
  final Map<String, dynamic> pharmacy;

  const UpdatePharmacyScreen({Key? key, required this.pharmacy}) : super(key: key);

  @override
  _UpdatePharmacyScreenState createState() => _UpdatePharmacyScreenState();
}

class _UpdatePharmacyScreenState extends State<UpdatePharmacyScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _formData = Map.from(widget.pharmacy);
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    final response = await AdminApi.updatePharmacy(_formData['_id'], _formData);

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pharmacie mise à jour avec succès!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modifier ${_formData['nom']}"),
      ),
      drawer: const SideNavigationBar(),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _formData['nom'],
                  decoration: const InputDecoration(labelText: 'Nom'),
                  onSaved: (value) => _formData['nom'] = value,
                  validator: (value) => value == null || value.isEmpty ? 'Nom requis' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  initialValue: _formData['telephone'],
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                  onSaved: (value) => _formData['telephone'] = value,
                  validator: (value) => value == null || value.isEmpty ? 'Téléphone requis' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  initialValue: _formData['email'],
                  decoration: const InputDecoration(labelText: 'Email'),
                  onSaved: (value) => _formData['email'] = value,
                  validator: (value) => value == null || value.isEmpty ? 'Email requis' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  initialValue: _formData['adresse'],
                  decoration: const InputDecoration(labelText: 'Adresse'),
                  onSaved: (value) => _formData['adresse'] = value,
                  validator: (value) => value == null || value.isEmpty ? 'Adresse requise' : null,
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<String>(
                  value: _formData['statut_abonnement'],
                  decoration: const InputDecoration(labelText: 'Statut d’Abonnement'),
                  items: ["Actif", "Inactif"]
                      .map((statut) => DropdownMenuItem<String>(
                            value: statut,
                            child: Text(statut),
                          ))
                      .toList(),
                  onChanged: (value) => _formData['statut_abonnement'] = value,
                  validator: (value) => value == null ? 'Statut requis' : null,
                ),
                SizedBox(height: 30.h),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text("Enregistrer"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
