// lib/screens/admin/pharmacies/pharmacy_form_screen.dart
import 'package:flutter/material.dart';
import '../../../models/pharmacy.dart';
import '../../../services/admin_api.dart';

class PharmacyFormScreen extends StatefulWidget {
  final Pharmacy? pharmacy;

  const PharmacyFormScreen({Key? key, this.pharmacy}) : super(key: key);

  @override
  _PharmacyFormScreenState createState() => _PharmacyFormScreenState();
}

class _PharmacyFormScreenState extends State<PharmacyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Champs du formulaire
  String? _nom;
  String? _telephone;
  String? _email;
  String? _adresse;
  String? _region;
  String? _ville;
  String? _plan;
  DateTime? _dateDebut;
  DateTime? _dateFin;
  String? _lienGoogleMaps;

  // Listes pour les dropdowns
  final List<String> _regions = ['Region 1', 'Region 2', 'Region 3'];
  final List<String> _villes = ['Ville A', 'Ville B', 'Ville C'];
  final List<String> _plans = ['1 mois', '3 mois', '6 mois', '12 mois'];

  @override
  void initState() {
    super.initState();
    if (widget.pharmacy != null) {
      _nom = widget.pharmacy!.nom;
      _telephone = widget.pharmacy!.telephone;
      _email = widget.pharmacy!.email;
      _adresse = widget.pharmacy!.adresse;
      _region = widget.pharmacy!.region;
      _ville = widget.pharmacy!.ville;
      _plan = widget.pharmacy!.abonnement.plan;
      _dateDebut = widget.pharmacy!.abonnement.dateDebut;
      _dateFin = widget.pharmacy!.abonnement.dateFin;
      _lienGoogleMaps = widget.pharmacy!.lienGoogleMaps;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> pharmacyData = {
      'nom': _nom,
      'telephone': _telephone,
      'email': _email,
      'adresse': _adresse,
      'region': _region,
      'ville': _ville,
      'abonnement': {
        'plan': _plan,
        'date_debut': _dateDebut!.toIso8601String(),
        'date_fin': _dateFin!.toIso8601String(),
        'actif': true,
      },
      'lien_google_maps': _lienGoogleMaps,
    };

    try {
      if (widget.pharmacy == null) {
        // Créer une nouvelle pharmacie
        Pharmacy newPharmacy = await AdminApi.createPharmacy(pharmacyData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pharmacie créée avec succès')),
        );
      } else {
        // Mettre à jour la pharmacie existante
        await AdminApi.updatePharmacy(widget.pharmacy!.id, pharmacyData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pharmacie mise à jour avec succès')),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = isStartDate
        ? (_dateDebut ?? DateTime.now())
        : (_dateFin ?? DateTime.now().add(Duration(days: 30)));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _dateDebut = picked;
          // Ajuster la date_fin en fonction de la date_debut et du plan
          int months = int.parse(_plan!.split(' ')[0]);
          _dateFin = picked.add(Duration(days: 30 * months));
        } else {
          _dateFin = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.pharmacy != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier Pharmacie' : 'Ajouter Pharmacie'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Nom
                    TextFormField(
                      initialValue: _nom,
                      decoration: InputDecoration(labelText: 'Nom'),
                      validator: (value) => value == null || value.isEmpty ? 'Nom requis' : null,
                      onSaved: (value) => _nom = value,
                    ),
                    SizedBox(height: 10),
                    // Téléphone
                    TextFormField(
                      initialValue: _telephone,
                      decoration: InputDecoration(labelText: 'Téléphone'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Téléphone requis';
                        if (!RegExp(r'^\d{8}$').hasMatch(value)) return 'Téléphone doit contenir 8 chiffres';
                        return null;
                      },
                      onSaved: (value) => _telephone = value,
                    ),
                    SizedBox(height: 10),
                    // Email
                    TextFormField(
                      initialValue: _email,
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && !RegExp(r'^\S+@\S+\.\S+$').hasMatch(value)) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                      onSaved: (value) => _email = value,
                    ),
                    SizedBox(height: 10),
                    // Adresse
                    TextFormField(
                      initialValue: _adresse,
                      decoration: InputDecoration(labelText: 'Adresse'),
                      validator: (value) => value == null || value.isEmpty ? 'Adresse requise' : null,
                      onSaved: (value) => _adresse = value,
                    ),
                    SizedBox(height: 10),
                    // Région
                    DropdownButtonFormField<String>(
                      value: _region,
                      decoration: InputDecoration(labelText: 'Région'),
                      items: _regions.map((region) {
                        return DropdownMenuItem<String>(
                          value: region,
                          child: Text(region),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _region = value;
                          _ville = null; // Réinitialiser la ville
                        });
                      },
                      validator: (value) => value == null || value.isEmpty ? 'Région requise' : null,
                      onSaved: (value) => _region = value,
                    ),
                    SizedBox(height: 10),
                    // Ville
                    DropdownButtonFormField<String>(
                      value: _ville,
                      decoration: InputDecoration(labelText: 'Ville'),
                      items: _villes.map((ville) {
                        return DropdownMenuItem<String>(
                          value: ville,
                          child: Text(ville),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _ville = value;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty ? 'Ville requise' : null,
                      onSaved: (value) => _ville = value,
                    ),
                    SizedBox(height: 10),
                    // Plan d'abonnement
                    DropdownButtonFormField<String>(
                      value: _plan,
                      decoration: InputDecoration(labelText: 'Plan d\'abonnement'),
                      items: _plans.map((plan) {
                        return DropdownMenuItem<String>(
                          value: plan,
                          child: Text(plan),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _plan = value;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty ? 'Plan requis' : null,
                      onSaved: (value) => _plan = value,
                    ),
                    SizedBox(height: 10),
                    // Date de début
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Date de début'),
                      subtitle: Text(_dateDebut != null
                          ? '${_dateDebut!.day}/${_dateDebut!.month}/${_dateDebut!.year}'
                          : 'Sélectionnez une date'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, true),
                    ),
                    SizedBox(height: 10),
                    // Date de fin
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Date de fin'),
                      subtitle: Text(_dateFin != null
                          ? '${_dateFin!.day}/${_dateFin!.month}/${_dateFin!.year}'
                          : 'Sélectionnez une date'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, false),
                    ),
                    SizedBox(height: 10),
                    // Lien Google Maps
                    TextFormField(
                      initialValue: _lienGoogleMaps,
                      decoration: InputDecoration(labelText: 'Lien Google Maps'),
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Lien Google Maps requis';
                        if (!Uri.parse(value).isAbsolute) return 'Lien invalide';
                        return null;
                      },
                      onSaved: (value) => _lienGoogleMaps = value,
                    ),
                    SizedBox(height: 20),
                    // Bouton de soumission
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(isEdit ? 'Mettre à jour' : 'Créer'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
