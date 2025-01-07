// lib/models/abonnement.dart
class Abonnement {
  final String plan;
  final DateTime dateDebut;
  final DateTime dateFin;
  final bool actif;

  Abonnement({
    required this.plan,
    required this.dateDebut,
    required this.dateFin,
    required this.actif,
  });

  factory Abonnement.fromJson(Map<String, dynamic> json) {
    return Abonnement(
      plan: json['plan'],
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      actif: json['actif'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      'actif': actif,
    };
  }
}
