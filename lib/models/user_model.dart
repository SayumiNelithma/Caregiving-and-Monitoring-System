enum UserRole {
  admin,
  caregiver,
  elder,
  familyMember;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.caregiver:
        return 'Care Giver';
      case UserRole.elder:
        return 'Elder';
      case UserRole.familyMember:
        return 'Family Member';
    }
  }

  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.caregiver:
        return 'caregiver';
      case UserRole.elder:
        return 'elder';
      case UserRole.familyMember:
        return 'familyMember';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'caregiver':
        return UserRole.caregiver;
      case 'elder':
        return UserRole.elder;
      case 'familyMember':
        return UserRole.familyMember;
      default:
        return UserRole.elder;
    }
  }
}

class AppUser {
  final String uid;
  final String email;
  final String? name;
  final UserRole role;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    this.name,
    required this.role,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.value,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firestore document
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      role: UserRole.fromString(map['role'] ?? 'elder'),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  // Create from Firebase User
  factory AppUser.fromFirebaseUser(
    String uid,
    String email,
    String? name,
    UserRole role,
  ) {
    return AppUser(
      uid: uid,
      email: email,
      name: name,
      role: role,
      createdAt: DateTime.now(),
    );
  }
}

