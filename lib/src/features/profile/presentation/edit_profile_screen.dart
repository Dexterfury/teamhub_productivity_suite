import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/providers/authentication_provider.dart';
import 'package:teamhub_productivity_suite/src/widgets/profile_image_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _jobTitleController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _departmentController = TextEditingController();
  TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with placeholder data
    _initializeControllers();
  }

  void _initializeControllers() {
    // Wait for the class to build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appUser = context.read<AuthenticationProvider>().appUser;
      setState(() {
        _fullNameController = TextEditingController(text: appUser!.fullName);
        _jobTitleController = TextEditingController(
          text: appUser.jobTitle ?? AppStrings.placeholderJobNotSet,
        );
        _emailController = TextEditingController(text: appUser.email);
        _phoneController = TextEditingController(
          text: appUser.phone ?? AppStrings.placeholderPhoneNotSet,
        );
        _departmentController = TextEditingController(
          text: appUser.department ?? AppStrings.placeholderDepartmentNotSet,
        );
        _locationController = TextEditingController(
          text: appUser.location ?? AppStrings.placeholderNoLocation,
        );
      });
    });
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

  File? _selectedProfileImage;
  // Variable to hold the selected profile image

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
              ProfileImageWidget(
                imageUrl:
                    context
                        .watch<AuthenticationProvider>()
                        .appUser
                        ?.userPhotoUrl,
                radius: 60,
                isEditable: true,
                onImageSelected: (File? image) {
                  setState(() {
                    _selectedProfileImage = image;
                  });
                  // TODO: Handle image upload logic here
                },
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

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );

        await context.read<AuthenticationProvider>().updateUserProfile(
          fullName: _fullNameController.text.trim(),
          jobTitle: _jobTitleController.text.trim(),
          phone: _phoneController.text.trim(),
          department: _departmentController.text.trim(),
          location: _locationController.text.trim(),
          profileImage: _selectedProfileImage,
        );

        // Hide loading indicator
        if (mounted) Navigator.of(context).pop();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }

        // Go back to previous screen
        if (mounted) context.pop();
      } catch (e) {
        // Hide loading indicator
        if (mounted) Navigator.of(context).pop();

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
        }
      }
    }
  }
}
