import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/providers/authentication_provider.dart';
import 'package:teamhub_productivity_suite/src/widgets/inputfield.dart';
import 'package:teamhub_productivity_suite/src/widgets/responsive_container.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
  }

  // Handle sign-up logic here
  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.passwordsDoNotMatchError)),
      );
      return;
    }

    final authProvider = context.read<AuthenticationProvider>();

    await authProvider.register(
      _emailController.text,
      _passwordController.text,
      _fullNameController.text,
    );

    if (mounted) {
      if (authProvider.errorMessage != null) {
        // Show error message if registration fails
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(authProvider.errorMessage!)));
      } else {
        // Registration successful, navigate to dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful! Welcome!')),
        );

        // Clear input fields
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _fullNameController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text(AppStrings.registerTitle)),
          // Make the body scrollable to avoid overflow issues
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                // Use responsive container for different screen sizes
                child: ResponsiveContainer(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header Section
                      _buildHeaderSection(context),

                      const SizedBox(height: 24.0),

                      // Registration Form
                      _buildRegistrationForm(context, authProvider),

                      const SizedBox(height: 24.0),

                      // Footer Section
                      _buildFooterSection(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Header section with title and subtitle
  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      children: [
        Text(
          AppStrings.registerTitle,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        Text(
          AppStrings.registerSubtitle,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Registration form with input fields
  Widget _buildRegistrationForm(
    BuildContext context,
    AuthenticationProvider authProvider,
  ) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          // Full Name Input
          InputField(
            controller: _fullNameController,
            labelText: AppStrings.fullNameHint,
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.fullNameError;
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // Email Input
          InputField(
            controller: _emailController,
            labelText: AppStrings.emailHint,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.emailError;
              }
              // Simple email validation regex
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
              if (!emailRegex.hasMatch(value)) {
                return AppStrings.invalidEmailError;
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // Password Input
          InputField(
            controller: _passwordController,
            labelText: AppStrings.passwordHint,
            isPassword: _isPasswordVisible,
            onTap: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            icon: Icons.lock_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.passwordError;
              }
              if (value.length < 6) {
                return AppStrings.passwordLengthError;
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // Confirm Password Input
          InputField(
            controller: _confirmPasswordController,
            labelText: AppStrings.confirmPasswordHint,
            isPassword: _isConfirmPasswordVisible,
            icon: Icons.lock_outline,
            onTap: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.confirmPasswordError;
              }
              if (value != _passwordController.text) {
                return AppStrings.passwordsDoNotMatchError;
              }
              return null;
            },
          ),
          const SizedBox(height: 24.0),

          // Sign Up Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleSignUp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child:
                  authProvider.isLoading
                      ? const CircularProgressIndicator()
                      : const Text(AppStrings.signUpButton),
            ),
          ),
        ],
      ),
    );
  }

  // Footer section with login link
  Widget _buildFooterSection(BuildContext context) {
    return TextButton(
      onPressed: () => context.go('/login'),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(AppStrings.alreadyAccount),
          const SizedBox(width: 4.0),
          Text(
            AppStrings.loginLink,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
