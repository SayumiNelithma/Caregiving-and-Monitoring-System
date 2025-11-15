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

class RoleBasedWrapper extends StatelessWidget {
  const RoleBasedWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is not logged in, show login page
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        // If user is logged in, check their role and show appropriate dashboard
        final currentUser = snapshot.data;
        if (currentUser == null) {
          return const LoginPage();
        }

        // Use StreamBuilder to reactively get user data from Firestore
        // Also use a timeout to prevent infinite loading
        return StreamBuilder<AppUser?>(
          stream: UserService().getUserStream(currentUser.uid)
              .timeout(
                const Duration(seconds: 10),
                onTimeout: (sink) {
                  sink.add(null);
                  sink.close();
                },
              ),
          builder: (context, userSnapshot) {
            // Show loading only for a short time, then try to fetch directly
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              // After 2 seconds, try fetching directly instead of waiting for stream
              return FutureBuilder<AppUser?>(
                future: Future.delayed(
                  const Duration(seconds: 2),
                  () => UserService().getUser(currentUser.uid),
                ),
                builder: (context, futureSnapshot) {
                  if (futureSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  final appUser = futureSnapshot.data;
                  if (appUser == null) {
                    // Show error screen
                    return _buildErrorScreen(context, currentUser);
                  }
                  
                  return _buildDashboard(appUser);
                },
              );
            }

            final appUser = userSnapshot.data;
            if (appUser == null) {
              return _buildErrorScreen(context, currentUser);
            }

            return _buildDashboard(appUser);
          },
        );
      },
    );
  }

  Widget _buildDashboard(AppUser appUser) {
    // Route to role-specific dashboard with proper authorization
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
  }

  Widget _buildErrorScreen(BuildContext context, User currentUser) {
    // User document doesn't exist in Firestore - show error with instructions
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Required'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              const Text(
                'User Profile Not Found',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your account exists but doesn\'t have a profile in the database.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'To fix this:\n\n'
                '1. Go to Firebase Console\n'
                '2. Navigate to Firestore Database\n'
                '3. Create a document in the "users" collection\n'
                '4. Use your User ID as the document ID\n'
                '5. Add fields: uid, email, name, role (set to "admin"), createdAt',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await AuthService().signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Logout'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Refresh the page
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const RoleBasedWrapper(),
                        ),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'User ID: ${currentUser.uid}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
