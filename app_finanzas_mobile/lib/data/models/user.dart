class User {
  final String id;
  final String firstName;
  final String email;
  final String? avatarId;

  User({
    required this.id,
    required this.firstName,
    required this.email,
    this.avatarId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle Directus field aliases or direct fields
    final id = json['id']?.toString() ?? '';
    final firstName =
        json['first_name']?.toString() ?? json['firstName']?.toString();
    final email = json['email']?.toString();

    return User(
      id: id,
      firstName: (firstName != null && firstName.isNotEmpty)
          ? firstName
          : 'Usuario',
      email: email ?? '',
      avatarId: json['avatar']?['id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'email': email,
      'avatar': avatarId != null ? {'id': avatarId} : null,
    };
  }
}
