// lib/models/message.dart
class MessageModel {
  final String id;
  final String expediteurId;
  final String expediteurModel; // e.g., 'Admin' ou 'User'
  final String message;
  final DateTime dateEnvoye;

  MessageModel({
    required this.id,
    required this.expediteurId,
    required this.expediteurModel,
    required this.message,
    required this.dateEnvoye,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      expediteurId: json['expediteur_id'],
      expediteurModel: json['expediteur_model'],
      message: json['message'],
      dateEnvoye: DateTime.parse(json['date_envoye']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expediteur_id': expediteurId,
      'expediteur_model': expediteurModel,
      'message': message,
      'date_envoye': dateEnvoye.toIso8601String(),
    };
  }
}
