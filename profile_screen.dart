import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthapp/models/profile_model.dart';
import 'package:healthapp/services/profile_service.dart';
import 'package:healthapp/features/profile/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  File? _profileImage;
  Profile? _profile;

  late AnimationController _imageAnimController;
  bool _showTexts = false;
  bool _showButtons = false;

  @override
  void initState() {
    super.initState();
    _imageAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
      lowerBound: 0.8,
      upperBound: 1.0,
    )..forward();

    _loadProfile();

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _showTexts = true);
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      setState(() => _showButtons = true);
    });
  }

  Future<void> _loadProfile() async {
    final profile = await _profileService.fetchProfile();
    if (profile != null) {
      setState(() {
        _profile = profile;
        if (profile.profileImagePath.isNotEmpty) {
          _profileImage = File(profile.profileImagePath);
        }
      });
    } else {
      final defaultProfile = Profile(
        name: 'John Doe',
        age: 30,
        gender: 'Not specified',
        email:
            FirebaseAuth.instance.currentUser?.email ?? 'noemail@example.com',
        phone: '',
        profileImagePath: '',
      );
      setState(() => _profile = defaultProfile);
      await _profileService.saveProfile(defaultProfile);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null && _profile != null) {
      final newImage = File(pickedFile.path);
      final updatedProfile =
          _profile!.copyWith(profileImagePath: pickedFile.path);
      setState(() {
        _profileImage = newImage;
        _profile = updatedProfile;
      });
      await _profileService.updateProfile(updatedProfile);
    }
  }

  void _editProfile() {
    if (_profile == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          name: _profile!.name,
          age: _profile!.age.toString(),
          email: _profile!.email,
          gender: _profile!.gender,
          phone: _profile!.phone,
          onSave: (updatedName, updatedAge, updatedEmail, updatedGender,
              updatedPhone) async {
            final updatedProfile = _profile!.copyWith(
              name: updatedName,
              age: int.tryParse(updatedAge) ?? _profile!.age,
              email: updatedEmail,
              gender: updatedGender,
              phone: updatedPhone,
            );
            setState(() => _profile = updatedProfile);
            await _profileService.updateProfile(updatedProfile);
          },
        ),
      ),
    );
  }

  Future<void> _resetProfile() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Profile'),
        content: const Text(
            'Are you sure you want to reset your profile to default? This action cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Yes, Reset'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final defaultProfile = Profile(
        name: 'John Doe',
        age: 30,
        gender: 'Not specified',
        email:
            FirebaseAuth.instance.currentUser?.email ?? 'noemail@example.com',
        phone: '',
        profileImagePath: '',
      );
      setState(() {
        _profile = defaultProfile;
        _profileImage = null;
      });
      await _profileService.updateProfile(defaultProfile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile reset to default')),
      );
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _imageAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: ScaleTransition(
                scale: _imageAnimController,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : const AssetImage('assets/images/placeholder.png')
                          as ImageProvider,
                ),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSlide(
              offset: _showTexts ? Offset.zero : const Offset(0, 0.5),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: _showTexts ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: Column(
                  children: [
                    Text(_profile!.name,
                        style: Theme.of(context).textTheme.headline6),
                    Text('Age: ${_profile!.age}'),
                    Text('Email: ${_profile!.email}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            AnimatedOpacity(
              opacity: _showButtons ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _editProfile,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _resetProfile,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Profile'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on TextTheme {
  TextStyle? get headline6 => titleLarge;
}
