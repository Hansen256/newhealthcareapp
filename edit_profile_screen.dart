import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String age;
  final String email;
  final String gender;
  final String phone;
  final Function(String, String, String, String, String) onSave;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.age,
    required this.email,
    required this.gender,
    required this.phone,
    required this.onSave,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _emailController;
  late TextEditingController _genderController;
  late TextEditingController _phoneController;

  late AnimationController _fieldAnimController;
  bool _showSaveButton = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _ageController = TextEditingController(text: widget.age);
    _emailController = TextEditingController(text: widget.email);
    _genderController = TextEditingController(text: widget.gender);
    _phoneController = TextEditingController(text: widget.phone);

    _fieldAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _showSaveButton = true);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _genderController.dispose();
    _phoneController.dispose();
    _fieldAnimController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedField(TextEditingController controller, String label,
      {TextInputType? keyboardType}) {
    return AnimatedSlide(
      offset: Offset(0, _fieldAnimController.value * 0.5),
      duration: const Duration(milliseconds: 600),
      child: AnimatedOpacity(
        opacity: _fieldAnimController.value,
        duration: const Duration(milliseconds: 600),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(labelText: label),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildAnimatedField(_nameController, 'Name'),
            const SizedBox(height: 16),
            _buildAnimatedField(_ageController, 'Age',
                keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildAnimatedField(_emailController, 'Email',
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildAnimatedField(_genderController, 'Gender'),
            const SizedBox(height: 16),
            _buildAnimatedField(_phoneController, 'Phone',
                keyboardType: TextInputType.phone),
            const SizedBox(height: 24),
            AnimatedOpacity(
              opacity: _showSaveButton ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                onPressed: () {
                  widget.onSave(
                    _nameController.text,
                    _ageController.text,
                    _emailController.text,
                    _genderController.text,
                    _phoneController.text,
                  );
                  Navigator.pop(context);
                },
                label: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
