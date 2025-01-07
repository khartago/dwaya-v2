import 'dart:convert';

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

    try {
      final response = await AdminApi.updatePharmacy(_formData['_id'], _formData);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pharmacie mise à jour avec succès!")),
        );
        Navigator.pop(context);
      } else {
        final errorMessage = json.decode(response.body)['message'] ?? "Erreur inconnue";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $errorMessage")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $error")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.local_pharmacy),
                  ),
                  onSaved: (value) => _formData['nom'] = value,
                  validator: (value) => value == null || value.isEmpty ? 'Nom requis' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  initialValue: _formData['telephone'],
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  onSaved: (value) => _formData['telephone'] = value,
                  validator: (value) => value == null || value.isEmpty ? 'Téléphone requis' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  initialValue: _formData['email'],
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  onSaved: (value) => _formData['email'] = value,
                  validator: (value) => value == null || value.isEmpty ? 'Email requis' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  initialValue: _formData['adresse'],
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  onSaved: (value) => _formData['adresse'] = value,
                  validator: (value) => value == null || value.isEmpty ? 'Adresse requise' : null,
                ),
                SizedBox(height: 30.h),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitForm,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                          child: Text(
                            "Enregistrer",
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
