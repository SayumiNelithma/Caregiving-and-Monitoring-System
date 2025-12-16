import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
// import '../../services/user_service.dart';
import '../../widgets/role_based_wrapper.dart';

class ElderOnboardingFlow extends StatefulWidget {
  final AppUser? user;
  
  const ElderOnboardingFlow({super.key, this.user});

  @override
  State<ElderOnboardingFlow> createState() => _ElderOnboardingFlowState();
}

class _ElderOnboardingFlowState extends State<ElderOnboardingFlow> {
  final PageController _controller = PageController();
  final UserService _userService = UserService();
  
  // State for Answers
  double _age = 65;
  String _gender = 'Male';
  String _mobility = 'Independent'; 
  String _cognitive = 'Normal';     
  bool _isLoading = false;

  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 3) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut
      );
      setState(() => _currentPage++);
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      // 1. Prepare Data
      Map<String, dynamic> profileData = {
        'uid': user.uid,
        'name': widget.user?.name ?? user.displayName, 
        'age': _age.toInt(),
        'gender': _gender,
        'mobility_level': _mobility,
        'cognitive_level': _cognitive,
        'mental_health': 'Normal', // Default or add a field for this
        'completed_at': DateTime.now().toIso8601String(),
      };

      // 2. Send to Python Backend
      bool success = await _userService.createElderProfile(profileData);

      if (success && mounted) {
        // 3. Navigate to Home
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => const RoleBasedWrapper())
        );
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("Failed to save profile. Is the Backend running?"))
           );
        }
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Your Profile")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // PAGE 1: Age
                  _buildPage(
                    title: "How old are you?",
                    content: Column(
                      children: [
                        Text("${_age.toInt()} Years Old", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                        Slider(
                          value: _age, 
                          min: 50, max: 100, divisions: 50, 
                          onChanged: (v) => setState(() => _age = v)
                        ),
                      ],
                    )
                  ),
                  // PAGE 2: Gender
                  _buildPage(
                    title: "What is your Gender?",
                    content: _buildDropdown(
                      value: _gender,
                      items: ['Male', 'Female', 'Other'],
                      onChanged: (v) => setState(() => _gender = v!),
                    )
                  ),
                  // PAGE 3: Mobility
                  _buildPage(
                    title: "How is your mobility?",
                    subtitle: "This helps us predict if you need more time for tasks.",
                    content: _buildDropdown(
                      value: _mobility,
                      items: ['Independent', 'Cane', 'Walker', 'Wheelchair', 'Bedbound'],
                      onChanged: (v) => setState(() => _mobility = v!),
                    )
                  ),
                  // PAGE 4: Cognitive
                  _buildPage(
                    title: "Cognitive Status",
                    subtitle: "Do you often forget things?",
                    content: _buildDropdown(
                      value: _cognitive,
                      items: ['Normal', 'Mild Impairment', 'Moderate', 'Severe'],
                      onChanged: (v) => setState(() => _cognitive = v!),
                    )
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  child: Text(_currentPage == 3 ? "Finish Setup" : "Next"),
                ),
              ),
            )
          ],
        ),
    );
  }

  Widget _buildPage({required String title, String? subtitle, required Widget content}) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 10),
            Text(subtitle, style: TextStyle(fontSize: 16, color: Colors.grey[600]), textAlign: TextAlign.center),
          ],
          const SizedBox(height: 40),
          content,
        ],
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}