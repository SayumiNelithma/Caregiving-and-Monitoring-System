import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'widgets/role_based_wrapper.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ElderCareApp());
}

class ElderCareApp extends StatelessWidget {
  const ElderCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elder Care System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196F3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 18),
          bodyMedium: TextStyle(fontSize: 16),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        useMaterial3: true,
      ),
      home: const RoleBasedWrapper(),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  final AppUser user;
  
  const HomeDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Elder Care System',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome${user.name != null ? ", ${user.name}" : ""}!',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.role).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getRoleColor(user.role),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        user.role.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getRoleColor(user.role),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your care services dashboard',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: _getRoleBasedFeatures(user.role),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.caregiver:
        return Colors.blue;
      case UserRole.elder:
        return Colors.green;
      case UserRole.familyMember:
        return Colors.orange;
    }
  }

  List<Widget> _getRoleBasedFeatures(UserRole role) {
    // Base features available to all
    List<Map<String, dynamic>> allFeatures = [
      {
        'title': 'AI Voice Chatbot',
        'icon': Icons.mic,
        'color': const Color(0xFF4CAF50),
        'description': 'Voice-based AI assistant',
        'roles': [UserRole.elder, UserRole.familyMember, UserRole.caregiver, UserRole.admin],
      },
      {
        'title': 'Daily Routine',
        'icon': Icons.calendar_today,
        'color': const Color(0xFF2196F3),
        'description': 'Manage daily activities',
        'roles': [UserRole.elder, UserRole.familyMember, UserRole.caregiver, UserRole.admin],
      },
      {
        'title': 'AI Therapist',
        'icon': Icons.psychology,
        'color': const Color(0xFF9C27B0),
        'description': 'Mental health support',
        'roles': [UserRole.elder, UserRole.familyMember, UserRole.caregiver, UserRole.admin],
      },
      {
        'title': 'Meal Planner',
        'icon': Icons.restaurant,
        'color': const Color(0xFFFF9800),
        'description': 'AI-powered meal planning',
        'roles': [UserRole.elder, UserRole.familyMember, UserRole.caregiver, UserRole.admin],
      },
    ];

    // Admin-only features
    if (role == UserRole.admin) {
      allFeatures.addAll([
        {
          'title': 'User Management',
          'icon': Icons.people,
          'color': Colors.red,
          'description': 'Manage users and roles',
          'roles': [UserRole.admin],
        },
        {
          'title': 'System Settings',
          'icon': Icons.settings,
          'color': Colors.grey,
          'description': 'System configuration',
          'roles': [UserRole.admin],
        },
      ]);
    }

    // Filter features based on role
    final availableFeatures = allFeatures
        .where((feature) => feature['roles'].contains(role))
        .toList();

    return availableFeatures.map((feature) {
      return _buildFeatureCard(
        title: feature['title'],
        icon: feature['icon'],
        color: feature['color'],
        description: feature['description'],
      );
    }).toList();
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final authService = AuthService();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      try {
        await authService.signOut();
        
        if (context.mounted) {
          // Navigate to login page and clear navigation stack
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
            (route) => false,
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
