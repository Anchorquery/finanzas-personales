class Organization {
  final String id;
  final String name;
  final String? ownerId;

  Organization({
    required this.id,
    required this.name,
    this.ownerId,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    String? ownerId;
    if (json['owner'] != null) {
      if (json['owner'] is Map) {
        ownerId = json['owner']['id']?.toString();
      } else {
        ownerId = json['owner']?.toString();
      }
    }

    return Organization(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      ownerId: ownerId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      if (ownerId != null) 'owner': ownerId,
    };
  }
}
