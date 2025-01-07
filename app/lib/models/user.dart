// lib/models/user.dart

class Note {
  final double moyenne;
  final int count;

  Note({required this.moyenne, required this.count});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      moyenne: (json['moyenne'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moyenne': moyenne,
      'count': count,
    };
  }
}

class User {
  final String id;
  final String nom;
  final String prenom;
  final String telephone;
  final String? email;
  final String region;
  final String ville;
  final Note note;
  final bool actif;
  final DateTime dateInscription;
  final DateTime? dateDerniereConnexion;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    this.email,
    required this.region,
    required this.ville,
    required this.note,
    required this.actif,
    required this.dateInscription,
    this.dateDerniereConnexion,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      telephone: json['telephone'],
      email: json['email'],
      region: json['region'],
      ville: json['ville'],
      note: Note.fromJson(json['note'] ?? {}),
      actif: json['actif'],
      dateInscription: DateTime.parse(json['date_inscription']),
      dateDerniereConnexion: json['date_derniere_connexion'] != null
          ? DateTime.parse(json['date_derniere_connexion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'email': email,
      'region': region,
      'ville': ville,
      'note': note.toJson(),
      'actif': actif,
      'date_inscription': dateInscription.toIso8601String(),
      'date_derniere_connexion': dateDerniereConnexion?.toIso8601String(),
    };
  }
}
