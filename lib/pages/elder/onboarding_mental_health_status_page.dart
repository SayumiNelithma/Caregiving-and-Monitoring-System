import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/elder_profile_model.dart';
import '../../services/elder_profile_service.dart';

class OnboardingMentalHealthStatusPage extends StatefulWidget {
  final AppUser user;
  final ElderProfile initialProfile;
  final Function(ElderProfile) onProfileUpdate;
  final VoidCallback onComplete;

  const OnboardingMentalHealthStatusPage({
    super.key,
    required this.user,
    required this.initialProfile,
    required this.onProfileUpdate,
    required this.onComplete,
  });

  @override
  State<OnboardingMentalHealthStatusPage> createState() =>
      _OnboardingMentalHealthStatusPageState();
}

class _OnboardingMentalHealthStatusPageState
    extends State<OnboardingMentalHealthStatusPage> {
  final ElderProfileService _profileService = ElderProfileService();
  final TextEditingController _statusController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _statusController.text = widget.initialProfile.mentalHealthStatus;
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedProfile = widget.initialProfile.copyWith(
        mentalHealthStatus: _statusController.text.trim(),
        isOnboardingComplete: true,
      );

      // Save to Firestore
      await _profileService.saveElderProfile(updatedProfile);

      if (mounted) {
        widget.onProfileUpdate(updatedProfile);
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF81C784), Color(0xFFC8E6C9)],
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
                      'Step 6 of 6 - Final',
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
                          value: 1.0,
                          minHeight: 4,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF388E3C),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Question
                const Text(
                  'Tell us more about your wellbeing',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Share any additional details (optional)',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                // Text input
                Expanded(
                  child: TextField(
                    controller: _statusController,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText:
                          'Tell us about your current mental and physical wellbeing. What areas would you like help with?',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF388E3C),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF388E3C),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
                const SizedBox(height: 24),
                // Complete button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _completeOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF388E3C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Complete Setup',
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
}
