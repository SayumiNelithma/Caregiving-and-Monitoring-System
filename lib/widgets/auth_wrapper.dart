import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pages/login_page.dart';
import '../models/user_model.dart';
import '../pages/home_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Logged in
        if (snapshot.hasData && snapshot.data != null) {
          final firebaseUser = snapshot.data!;

          final appUser = AppUser(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName,
            role: UserRole.elder, // TEMP default (later from Firestore)
            createdAt: DateTime.now(),
          );

          return HomeDashboard(user: appUser);
        }

        // Not logged in
        return const LoginPage();
      },
    );
  }
}
