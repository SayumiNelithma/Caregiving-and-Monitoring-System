import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin,
  caregiver,
  elder,
  familyMember,
}

// ENUM EXTENSION
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.caregiver:
        return 'Caregiver';
      case UserRole.elder:
        return 'Elder';
      case UserRole.familyMember:
        return 'Family Member';
    }
  }

  // Convert enum to string for Firestore
  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.caregiver:
        return 'caregiver';
      case UserRole.elder:
        return 'elder';
      case UserRole.familyMember:
        return 'family_member';
    }
  }

  // Convert string from Firestore to enum
  static UserRole fromString(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'caregiver':
        return UserRole.caregiver;
      case 'elder':
        return UserRole.elder;
      case 'family_member':
        return UserRole.familyMember;
      default:
        return UserRole.elder; // fallback to elder
    }
  }
}

// USER MODEL
class AppUser {
  final String uid;
  final String email;
  final String? name;
  final UserRole role;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.createdAt,
    this.name,
  });

  // Convert AppUser → Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.value,                  // store enum as string
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Convert Firestore Map → AppUser
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      role: UserRoleExtension.fromString(map['role'] ?? 'elder'),
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
