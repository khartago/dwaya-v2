// lib/models/pharmacy.dart
import 'abonnement.dart';

class Pharmacy {
  final String id;
  final String nom;
  final String telephone;
  final String? email;
  final String adresse;
  final String region;
  final String ville;
  final Abonnement abonnement;
  final String lienGoogleMaps;
  final bool actif;

  Pharmacy({
    required this.id,
    required this.nom,
    required this.telephone,
    this.email,
    required this.adresse,
    required this.region,
    required this.ville,
    required this.abonnement,
    required this.lienGoogleMaps,
    required this.actif,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      id: json['id'],
      nom: json['nom'],
      telephone: json['telephone'],
      email: json['email'],
      adresse: json['adresse'],
      region: json['region'],
      ville: json['ville'],
      abonnement: Abonnement.fromJson(json['abonnement']),
      lienGoogleMaps: json['lien_google_maps'],
      actif: json['actif'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'telephone': telephone,
      'email': email,
      'adresse': adresse,
      'region': region,
      'ville': ville,
      'abonnement': abonnement.toJson(),
      'lien_google_maps': lienGoogleMaps,
      'actif': actif,
    };
  }
}
