class UserModel {
  final String uid;
  final String email;
  final String role; // 'customer', 'restaurant', 'driver'
  final String? name;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'customer', // Default to customer
      name: map['name'],
    );
  }
}
