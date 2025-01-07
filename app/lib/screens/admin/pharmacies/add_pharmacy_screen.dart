import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/admin_api.dart';
import '../../../widgets/side_navigation_bar.dart';

class AddPharmacyScreen extends StatefulWidget {
  const AddPharmacyScreen({Key? key}) : super(key: key);

  @override
  _AddPharmacyScreenState createState() => _AddPharmacyScreenState();
}

class _AddPharmacyScreenState extends State<AddPharmacyScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  List<Map<String, dynamic>> _regions = [];
  List<Map<String, dynamic>> _cities = [];

  String? _selectedRegionId;
  String? _selectedCityId;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    try {
      final response = await AdminApi.getRegions();
      setState(() {
        _regions = List<Map<String, dynamic>>.from(response);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement des régions: $error")),
      );
    }
  }

  Future<void> _loadCities(String regionId) async {
    try {
      final response = await AdminApi.getCities(regionId);
      setState(() {
        _cities = List<Map<String, dynamic>>.from(response);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement des villes: $error")),
      );
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AdminApi.createPharmacy(_formData);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pharmacie créée avec succès!")),
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
        title: const Text("Ajouter une Pharmacie"),
      ),
      drawer: const SideNavigationBar(),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Ajouter une Nouvelle Pharmacie",
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.local_pharmacy),
                  ),
                  onSaved: (value) => _formData['nom'] = value,
                  validator: (value) => value == null || value.isEmpty ? 'Nom requis' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  onSaved: (value) => _formData['telephone'] = value,
                  validator: (value) => value == null || value.isEmpty ? 'Téléphone requis' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => _formData['email'] = value,
                  validator: (value) => value == null || value.isEmpty ? 'Email requis' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Lien Google Maps',
                    prefixIcon: Icon(Icons.map),
                  ),
                  onSaved: (value) => _formData['lien_google_maps'] = value,
                  validator: (value) => value == null || value.isEmpty ? 'Lien requis' : null,
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Région',
                    prefixIcon: Icon(Icons.map),
                  ),
                  items: _regions
                      .map((region) => DropdownMenuItem<String>(
                            value: region['_id'],
                            child: Text(region['name']),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRegionId = value;
                      _cities = [];
                      _selectedCityId = null;
                    });
                    if (value != null) {
                      _loadCities(value);
                    }
                  },
                  validator: (value) => value == null ? 'Région requise' : null,
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Ville',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  items: _cities
                      .map((city) => DropdownMenuItem<String>(
                            value: city['_id'],
                            child: Text(city['name']),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCityId = value;
                    });
                  },
                  validator: (value) => value == null ? 'Ville requise' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  onSaved: (value) => _formData['mot_de_passe'] = value,
                  validator: (value) => value == null || value.isEmpty ? 'Mot de passe requis' : null,
                ),
                SizedBox(height: 30.h),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitForm,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                          child: Text(
                            "Créer",
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
