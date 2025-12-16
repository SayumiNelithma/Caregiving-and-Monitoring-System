import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/elder_profile_model.dart';
import 'onboarding_mobility_page.dart';

class OnboardingAgePage extends StatefulWidget {
  final AppUser user;
  final ElderProfile initialProfile;
  final Function(ElderProfile) onProfileUpdate;
  final VoidCallback onComplete;

  const OnboardingAgePage({
    super.key,
    required this.user,
    required this.initialProfile,
    required this.onProfileUpdate,
    required this.onComplete,
  });

  @override
  State<OnboardingAgePage> createState() => _OnboardingAgePageState();
}

class _OnboardingAgePageState extends State<OnboardingAgePage> {
  late String _selectedAgeGroup;
  final List<String> ageGroups = ['60-65', '65-70', '70-75', '75-80', '>80'];

  @override
  void initState() {
    super.initState();
    _selectedAgeGroup = widget.initialProfile.ageGroup.isEmpty
        ? ageGroups[0]
        : widget.initialProfile.ageGroup;
  }

  void _nextPage() {
    final updatedProfile =
        widget.initialProfile.copyWith(ageGroup: _selectedAgeGroup);
    widget.onProfileUpdate(updatedProfile);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingMobilityPage(
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
            colors: [Color(0xFF87CEEB), Color(0xFFE0F2F7)],
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
                      'Step 2 of 6',
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
                          value: 2 / 6,
                          minHeight: 4,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF2196F3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Question
                const Text(
                  'Which age group do you belong to?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This helps us tailor activities for you',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                // Age group options
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: ageGroups
                        .map((age) => _buildAgeCard(age))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
                // Next button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
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

  Widget _buildAgeCard(String age) {
    final isSelected = _selectedAgeGroup == age;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAgeGroup = age;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white70,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              age,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF2196F3) : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Years old',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2196F3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
