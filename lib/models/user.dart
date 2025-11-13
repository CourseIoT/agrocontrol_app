class User {
  final int id;
  final String email;
  final String? token;
  final List<String> roles;

  const User({
    required this.id,
    required this.email,
    this.token,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final rolesFromJson = json['roles'];
    final List<String> rolesList = List<String>.from(rolesFromJson);

    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      token: json['token'] as String?,
      roles: rolesList,
    );
  }
}
