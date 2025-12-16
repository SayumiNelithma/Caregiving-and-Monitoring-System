import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/elder_profile_model.dart';
import 'onboarding_mental_health_status_page.dart';

class OnboardingMentalHealthIssuesPage extends StatefulWidget {
  final AppUser user;
  final ElderProfile initialProfile;
  final Function(ElderProfile) onProfileUpdate;
  final VoidCallback onComplete;

  const OnboardingMentalHealthIssuesPage({
    super.key,
    required this.user,
    required this.initialProfile,
    required this.onProfileUpdate,
    required this.onComplete,
  });

  @override
  State<OnboardingMentalHealthIssuesPage> createState() =>
      _OnboardingMentalHealthIssuesPageState();
}

class _OnboardingMentalHealthIssuesPageState
    extends State<OnboardingMentalHealthIssuesPage> {
  List<String> _selectedIssues = [];
  final List<String> availableIssues = [
    'Depression',
    'Anxiety',
    'Stress',
    'Loneliness',
    'Sleep Issues',
    'None'
  ];

  @override
  void initState() {
    super.initState();
    _selectedIssues = List.from(widget.initialProfile.mentalHealthIssues);
  }

  void _toggleIssue(String issue) {
    setState(() {
      if (_selectedIssues.contains(issue)) {
        _selectedIssues.remove(issue);
      } else {
        // If selecting "None", remove other options
        if (issue == 'None') {
          _selectedIssues.clear();
        } else {
          // If selecting something else, remove "None"
          _selectedIssues.remove('None');
        }
        _selectedIssues.add(issue);
      }
    });
  }

  void _nextPage() {
    if (_selectedIssues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one option')),
      );
      return;
    }

    final updatedProfile =
        widget.initialProfile.copyWith(mentalHealthIssues: _selectedIssues);
    widget.onProfileUpdate(updatedProfile);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingMentalHealthStatusPage(
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
            colors: [Color(0xFFEF9A9A), Color(0xFFFFCDD2)],
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
                      'Step 5 of 6',
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
                          value: 5 / 6,
                          minHeight: 4,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFE53935),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Question
                const Text(
                  'Any mental health concerns?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Select all that apply (optional)',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                // Issues checkboxes
                Expanded(
                  child: ListView.builder(
                    itemCount: availableIssues.length,
                    itemBuilder: (context, index) {
                      final issue = availableIssues[index];
                      final isSelected = _selectedIssues.contains(issue);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildIssueCheckbox(issue, isSelected),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Next button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
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

  Widget _buildIssueCheckbox(String issue, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleIssue(issue),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white70,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFE53935) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE53935) : Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFFE53935) : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 16),
            Text(
              issue,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.black : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
