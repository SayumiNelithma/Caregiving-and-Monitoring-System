import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/elder_profile_model.dart';
import 'onboarding_mental_health_issues_page.dart';

class OnboardingCognitivePage extends StatefulWidget {
  final AppUser user;
  final ElderProfile initialProfile;
  final Function(ElderProfile) onProfileUpdate;
  final VoidCallback onComplete;

  const OnboardingCognitivePage({
    super.key,
    required this.user,
    required this.initialProfile,
    required this.onProfileUpdate,
    required this.onComplete,
  });

  @override
  State<OnboardingCognitivePage> createState() => _OnboardingCognitivePageState();
}

class _OnboardingCognitivePageState extends State<OnboardingCognitivePage> {
  late CognitiveLevel _selectedLevel;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialProfile.cognitiveLevel;
  }

  void _nextPage() {
    final updatedProfile =
        widget.initialProfile.copyWith(cognitiveLevel: _selectedLevel);
    widget.onProfileUpdate(updatedProfile);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingMentalHealthIssuesPage(
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
            colors: [Color(0xFFCE93D8), Color(0xFFF3E5F5)],
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
                      'Step 4 of 6',
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
                          value: 4 / 6,
                          minHeight: 4,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFAB47BC),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Question
                const Text(
                  'How is your memory and thinking?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This helps us customize your experience',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                // Cognitive options
                Expanded(
                  child: ListView(
                    children: [
                      _buildCognitiveCard(
                        level: CognitiveLevel.excellent,
                        title: 'Excellent',
                        description: 'Sharp memory and thinking',
                      ),
                      const SizedBox(height: 12),
                      _buildCognitiveCard(
                        level: CognitiveLevel.good,
                        title: 'Good',
                        description: 'Mostly clear, occasional forgetfulness',
                      ),
                      const SizedBox(height: 12),
                      _buildCognitiveCard(
                        level: CognitiveLevel.moderate,
                        title: 'Moderate',
                        description: 'Some memory challenges',
                      ),
                      const SizedBox(height: 12),
                      _buildCognitiveCard(
                        level: CognitiveLevel.mild,
                        title: 'Mild Decline',
                        description: 'Noticeable memory issues',
                      ),
                      const SizedBox(height: 12),
                      _buildCognitiveCard(
                        level: CognitiveLevel.severe,
                        title: 'Significant Decline',
                        description: 'Significant cognitive challenges',
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
                      backgroundColor: const Color(0xFFAB47BC),
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

  Widget _buildCognitiveCard({
    required CognitiveLevel level,
    required String title,
    required String description,
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
            color: isSelected ? const Color(0xFFAB47BC) : Colors.transparent,
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
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFAB47BC).withOpacity(0.2)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.psychology,
                color:
                    isSelected ? const Color(0xFFAB47BC) : Colors.grey[600],
                size: 28,
              ),
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
                  color: Color(0xFFAB47BC),
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
