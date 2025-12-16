import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/elder_profile_model.dart';
import 'onboarding_cognitive_page.dart';

class OnboardingMobilityPage extends StatefulWidget {
  final AppUser user;
  final ElderProfile initialProfile;
  final Function(ElderProfile) onProfileUpdate;
  final VoidCallback onComplete;

  const OnboardingMobilityPage({
    super.key,
    required this.user,
    required this.initialProfile,
    required this.onProfileUpdate,
    required this.onComplete,
  });

  @override
  State<OnboardingMobilityPage> createState() => _OnboardingMobilityPageState();
}

class _OnboardingMobilityPageState extends State<OnboardingMobilityPage> {
  late MobilityLevel _selectedLevel;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialProfile.mobilityLevel;
  }

  void _nextPage() {
    final updatedProfile =
        widget.initialProfile.copyWith(mobilityLevel: _selectedLevel);
    widget.onProfileUpdate(updatedProfile);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingCognitivePage(
          user: widget.user,
          initialProfile: updatedProfile,
          onProfileUpdate: widget.onProfileUpdate,
          onComplete: widget.onComplete,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB74D), Color(0xFFFFF9C4)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                Row(
                  children: [
                    const Text(
                      'Step 3 of 6',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: 3 / 6,
                          minHeight: 4,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFB8C00),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Question
                const Text(
                  'How is your mobility?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This helps us suggest suitable activities',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                // Mobility options
                Expanded(
                  child: ListView(
                    children: [
                      _buildMobilityCard(
                        level: MobilityLevel.excellent,
                        title: 'Excellent',
                        description: 'Very active, no limitations',
                        icon: Icons.directions_run,
                      ),
                      const SizedBox(height: 12),
                      _buildMobilityCard(
                        level: MobilityLevel.good,
                        title: 'Good',
                        description: 'Active, minor limitations',
                        icon: Icons.directions_walk,
                      ),
                      const SizedBox(height: 12),
                      _buildMobilityCard(
                        level: MobilityLevel.moderate,
                        title: 'Moderate',
                        description: 'Some physical limitations',
                        icon: Icons.accessibility,
                      ),
                      const SizedBox(height: 12),
                      _buildMobilityCard(
                        level: MobilityLevel.limited,
                        title: 'Limited',
                        description: 'Significant limitations',
                        icon: Icons.wheelchair_pickup,
                      ),
                      const SizedBox(height: 12),
                      _buildMobilityCard(
                        level: MobilityLevel.severe,
                        title: 'Severe',
                        description: 'Very limited mobility',
                        icon: Icons.medical_services,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Next button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFB8C00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobilityCard({
    required MobilityLevel level,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedLevel == level;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = level;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white70,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFB8C00) : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 36,
              color: isSelected ? const Color(0xFFFB8C00) : Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFFFB8C00),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
