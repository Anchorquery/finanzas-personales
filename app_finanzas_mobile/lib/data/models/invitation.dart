import 'package:app_finanzas_mobile/data/models/organization.dart';

class Invitation {
  final String id;
  final String email;
  final String organizationId;
  final String role;
  final String status;
  final DateTime dateCreated;
  final Organization? organization;

  Invitation({
    required this.id,
    required this.email,
    required this.organizationId,
    required this.role,
    required this.status,
    required this.dateCreated,
    this.organization,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      organizationId: json['organization'] is Map ? json['organization']['id']?.toString() ?? '' : json['organization']?.toString() ?? '',
      role: json['role']?.toString() ?? 'member',
      status: json['status']?.toString() ?? 'pending',
      dateCreated: DateTime.tryParse(json['date_created']?.toString() ?? '') ?? DateTime.now(),
      organization: json['organization'] is Map ? Organization.fromJson(json['organization']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'organization': organizationId,
      'role': role,
      'status': status,
      'date_created': dateCreated.toIso8601String(),
    };
  }
}
