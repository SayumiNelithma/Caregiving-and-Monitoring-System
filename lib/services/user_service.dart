import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Save user to Firestore
  Future<void> saveUser(AppUser user) async {
    try {
      await _firestore.collection(_collection).doc(user.uid).set(user.toMap());
    } catch (e) {
      throw 'Error saving user: $e';
    }
  }

  // Get user by UID
  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Error getting user: $e';
    }
  }

  // Update user role (Admin only)
  Future<void> updateUserRole(String uid, UserRole newRole) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'role': newRole.value,
      });
    } catch (e) {
      throw 'Error updating user role: $e';
    }
  }

  // Stream user data
  Stream<AppUser?> getUserStream(String uid) {
    return _firestore
        .collection(_collection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? AppUser.fromMap(doc.data()!) : null);
  }

  // Get all users (Admin only)
  Future<List<AppUser>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => AppUser.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw 'Error getting users: $e';
    }
  }

  // Get users by role
  Future<List<AppUser>> getUsersByRole(UserRole role) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('role', isEqualTo: role.value)
          .get();
      return snapshot.docs
          .map((doc) => AppUser.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw 'Error getting users by role: $e';
    }
  }
}

