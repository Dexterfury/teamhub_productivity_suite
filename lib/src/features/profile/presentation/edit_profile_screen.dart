import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _jobTitleController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with placeholder data
    _fullNameController = TextEditingController(
      text: AppStrings.placeholderUserName,
    );
    _jobTitleController = TextEditingController(
      text: AppStrings.placeholderJobTitle,
    );
    _emailController = TextEditingController(
      text: AppStrings.placeholderUserEmail,
    );
    _phoneController = TextEditingController(
      text: '+1 234 567 8900',
    ); // Placeholder
    _departmentController = TextEditingController(
      text: 'Engineering',
    ); // Placeholder
    _locationController = TextEditingController(
      text: 'San Francisco, CA',
    ); // Placeholder
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _jobTitleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text(AppStrings.editProfileTitle),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveProfile),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/300', // Placeholder avatar
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // TODO: Implement photo change
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              _buildTextField(
                controller: _fullNameController,
                label: AppStrings.fullNameProfileHint,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: _jobTitleController,
                label: AppStrings.jobTitleProfileHint,
                prefixIcon: Icons.work_outline,
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: _emailController,
                label: AppStrings.emailHint,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                enabled: false, // Email should typically not be editable
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: _departmentController,
                label: 'Department',
                prefixIcon: Icons.business_outlined,
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: _locationController,
                label: 'Location',
                prefixIcon: Icons.location_on_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(prefixIcon),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppStrings.requiredFieldError;
        }
        return null;
      },
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement save profile logic
      context.pop();
    }
  }
}
