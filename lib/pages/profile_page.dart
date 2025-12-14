import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class ProfilePage extends StatefulWidget {
  final AppUser user;
  
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  final _userService = UserService();
  
  bool _isEditing = false;
  bool _isLoading = false;
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = await _authService.getCurrentAppUser();
      if (user != null) {
        setState(() {
          _currentUser = user;
          _nameController.text = user.name ?? '';
          _emailController.text = user.email;
          _isLoading = false;
        });
      } else {
        setState(() {
          _currentUser = widget.user;
          _nameController.text = widget.user.name ?? '';
          _emailController.text = widget.user.email;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentUser = widget.user;
        _nameController.text = widget.user.name ?? '';
        _emailController.text = widget.user.email;
        _isLoading = false;
      });
    }
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _currentUser ?? widget.user;
      final newName = _nameController.text.trim();
      final newEmail = _emailController.text.trim();

      // Check if anything changed
      bool nameChanged = newName != (user.name ?? '');
      bool emailChanged = newEmail != user.email;

      if (!nameChanged && !emailChanged) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No changes to save'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Update email in Firebase Auth if changed
      if (emailChanged) {
        await _authService.updateEmail(newEmail);
        // Note: verifyBeforeUpdateEmail sends a verification email
        // The email in Firestore is updated immediately, but Firebase Auth
        // will update after the user verifies the new email
      }

      // Update display name in Firebase Auth if changed
      if (nameChanged) {
        await _authService.updateDisplayName(newName);
      }

      // Update user in Firestore
      await _userService.updateUser(
        user.uid,
        name: nameChanged ? newName : null,
        email: emailChanged ? newEmail : null,
      );

      // Reload user data
      await _loadUserData();

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      if (mounted) {
        String message = 'Profile updated successfully';
        if (emailChanged) {
          message += '. Please check your new email to verify the change.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _nameController.text = _currentUser?.name ?? widget.user.name ?? '';
      _emailController.text = _currentUser?.email ?? widget.user.email;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser ?? widget.user;
    final roleColor = _getRoleColor(user.role);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: roleColor,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profile',
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancel',
              onPressed: _cancelEdit,
            ),
        ],
      ),
      body: _isLoading && _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    roleColor.withOpacity(0.1),
                    Colors.white,
                  ],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Profile Avatar
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                roleColor,
                                roleColor.withOpacity(0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: roleColor.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user.name != null && user.name!.isNotEmpty
                                  ? user.name![0].toUpperCase()
                                  : user.email[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Name
                        Text(
                          user.name ?? 'No name set',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: roleColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: roleColor,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            user.role.displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: roleColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Form Fields
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Profile Information',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Name Field
                                TextFormField(
                                  controller: _nameController,
                                  enabled: _isEditing,
                                  decoration: InputDecoration(
                                    labelText: 'Full Name',
                                    prefixIcon: const Icon(Icons.person),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: !_isEditing,
                                    fillColor: _isEditing
                                        ? null
                                        : Colors.grey[100],
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  enabled: _isEditing,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: const Icon(Icons.email),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: !_isEditing,
                                    fillColor: _isEditing
                                        ? null
                                        : Colors.grey[100],
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                // User ID (Read-only)
                                TextFormField(
                                  initialValue: user.uid,
                                  enabled: false,
                                  decoration: InputDecoration(
                                    labelText: 'User ID',
                                    prefixIcon: const Icon(Icons.fingerprint),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Account Created Date
                                TextFormField(
                                  initialValue: _formatDate(user.createdAt),
                                  enabled: false,
                                  decoration: InputDecoration(
                                    labelText: 'Account Created',
                                    prefixIcon: const Icon(Icons.calendar_today),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Save Button (only when editing)
                                if (_isEditing)
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _saveProfile,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: roleColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                              ),
                                            )
                                          : const Text(
                                              'Save Changes',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

