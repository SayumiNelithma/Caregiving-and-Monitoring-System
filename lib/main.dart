import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'widgets/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initFirebaseSafely();

  runApp(const ElderCareApp());
}

Future<void> _initFirebaseSafely() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    // Happens on hot restart / engine reattach: native already has DEFAULT
    if (e.code == 'duplicate-app') {
      // ignore and continue
      return;
    }
    rethrow;
  }
}

class ElderCareApp extends StatelessWidget {
  const ElderCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elder Care System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal,
          secondary: Colors.orangeAccent,
          surface: Colors.grey[50]!,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        
        // Typography: Larger, clearer fonts
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal), // Headers
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87), // Subheaders
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black87), // Card Titles
          bodyLarge: TextStyle(fontSize: 18, color: Colors.black87, height: 1.5), // Main text
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5), // Secondary text
        ),

        // Inputs: Big, clear, readable
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.teal, width: 2)),
          labelStyle: const TextStyle(fontSize: 18, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),

        // Buttons: Big, touch-friendly
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
        ),
        
        // Cards: Softer shadows, rounded
        cardTheme: CardThemeData(
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.white,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
