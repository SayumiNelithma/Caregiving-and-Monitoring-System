import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../pages/login_page.dart';
import '../pages/elder/onboarding_flow.dart';
import 'role_based_wrapper.dart'; // This is the correct "Home" logic

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final UserService _userService = UserService();
  
  // We need to track the Future to avoid recreation on every build
  Future<bool>? _profileCheckFuture;
  String? _currentUserId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          // Reset future if logged out
          _profileCheckFuture = null;
          _currentUserId = null;
          return const LoginPage();
        }

        final User firebaseUser = snapshot.data!;
        
        // Only create the future ONCE when the user ID changes
        if (_currentUserId != firebaseUser.uid) {
           _currentUserId = firebaseUser.uid;
           _profileCheckFuture = _userService.checkProfileExists(firebaseUser.uid);
        }

        return FutureBuilder<bool>(
          future: _profileCheckFuture,
          builder: (context, profileSnapshot) {
             if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
             }
             
             final bool profileExists = profileSnapshot.data ?? false;
             
             // If profile exists, RoleBasedWrapper will handle loading the full User object
             if (profileExists) {
                return const RoleBasedWrapper();
             } else {
                // Determine implicit role or pass data? 
                // For now, we assume if profile is missing, it's a new Elder or similar.
                // But wait, what if it's an Admin? 
                // Admin creates account differently.
                // Assuming "Elder" flow for signups via app for now.
                // We'll pass a 'stub' user or just let Onboarding handle it.
                // ElderOnboardingFlow fetches user from Auth itself.
                return const ElderOnboardingFlow();
             }
          }
        );
      },
    );
  }
}