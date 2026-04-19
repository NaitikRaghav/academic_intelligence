// lib/models/user_model.dart

enum UserRole { student, teacher }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? profileImageUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImageUrl,
    required this.createdAt,
  });

  // 🔄 Creates a copy of this model with optional new values (Crucial for Riverpod)
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 📤 Converts the object into a Map so we can save it to Firebase Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name, // saves 'student' or 'teacher' as a string
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // 📥 Reads data from Firebase Firestore and converts it back into a UserModel object
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      // Safely parse the enum from a string
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.student, // Default fallback
      ),
      profileImageUrl: map['profileImageUrl'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }
}