// lib/models/reclamation.dart
class Reclamation {
  final String id;
  final String type; // 'client' ou 'pharmacie'
  final String sujet;
  final String description;
  String status; // mutable pour mise à jour
  String? reponse;
  DateTime? dateResolution;

  Reclamation({
    required this.id,
    required this.type,
    required this.sujet,
    required this.description,
    required this.status,
    this.reponse,
    this.dateResolution,
  });

  factory Reclamation.fromJson(Map<String, dynamic> json) {
    return Reclamation(
      id: json['id'],
      type: json['type'],
      sujet: json['sujet'],
      description: json['description'],
      status: json['status'],
      reponse: json['reponse'],
      dateResolution: json['date_resolution'] != null
          ? DateTime.parse(json['date_resolution'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'sujet': sujet,
      'description': description,
      'status': status,
      'reponse': reponse,
      'date_resolution': dateResolution?.toIso8601String(),
    };
  }
}
