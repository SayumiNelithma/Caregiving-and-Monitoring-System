import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../pages/login_page.dart';
import '../pages/admin/admin_dashboard.dart';
import '../pages/elder/elder_dashboard.dart';
import '../pages/caregiver/caregiver_dashboard.dart';
import '../main.dart' show HomeDashboard;
import '../pages/setup_required_page.dart';

class RoleBasedWrapper extends StatefulWidget {
  const RoleBasedWrapper({super.key});

  @override
  State<RoleBasedWrapper> createState() => _RoleBasedWrapperState();
}

class _RoleBasedWrapperState extends State<RoleBasedWrapper> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, authSnapshot) {
        // Still restoring auth state
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not logged in → go to login
        final firebaseUser = authSnapshot.data;
        if (firebaseUser == null) {
          return const LoginPage();
        }

        // Logged in → load profile from Firestore
        return FutureBuilder<AppUser?>(
          future: _loadUserWithRetries(firebaseUser.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final appUser = userSnapshot.data;

            // After several retries the profile is still missing
            if (appUser == null) {
              return SetupRequiredPage(
                title: 'User Profile Not Found',
                message:
                    'Your Firebase Auth account exists, but no profile document was found in the "users" collection for this user.\n\n'
                    'This normally should not happen. Please log out and sign in again. If the problem persists, contact support.',
                onSetupPressed: () async {
                  // Default action: sign out and go back to login
                  await _authService.signOut();
                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
              );
            }

            // We have a valid AppUser → route by role
            switch (appUser.role) {
              case UserRole.admin:
                return AdminDashboard(user: appUser);
              case UserRole.elder:
                return ElderDashboard(user: appUser);
              case UserRole.caregiver:
                return CaregiverDashboard(user: appUser);
              case UserRole.familyMember:
                return HomeDashboard(user: appUser);
            }
          },
        );
      },
    );
  }

  /// Try to load the user profile from Firestore a few times.
  /// This makes it robust right after signup or a hard reload.
  Future<AppUser?> _loadUserWithRetries(String uid) async {
    AppUser? appUser;
    int attempts = 0;

    while (appUser == null && attempts < 10) {
      try {
        appUser = await _userService.getUser(uid);
        if (appUser != null) return appUser;
      } catch (_) {
        // ignore and retry
      }
      await Future.delayed(const Duration(milliseconds: 200));
      attempts++;
    }

    return appUser;
  }
}
