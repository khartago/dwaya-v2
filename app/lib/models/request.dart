// lib/models/request.dart
class RequestModel {
  final String id;
  final String clientId;
  final String zone;
  final String? ville;
  final String? region;
  String status; // mutable pour mise à jour

  RequestModel({
    required this.id,
    required this.clientId,
    required this.zone,
    this.ville,
    this.region,
    required this.status,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'],
      clientId: json['client_id'],
      zone: json['zone'],
      ville: json['ville'],
      region: json['region'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'zone': zone,
      'ville': ville,
      'region': region,
      'status': status,
    };
  }
}
