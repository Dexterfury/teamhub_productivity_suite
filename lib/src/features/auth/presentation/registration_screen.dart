import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/widgets/inputfield.dart';
import 'package:teamhub_productivity_suite/src/widgets/responsive_container.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  _buildRegistrationForm(context),

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
  Widget _buildRegistrationForm(BuildContext context) {
    return Column(
      children: [
        // Full Name Input
        const InputField(
          labelText: AppStrings.fullNameHint,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16.0),

        // Email Input
        const InputField(
          labelText: AppStrings.emailHint,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16.0),

        // Password Input
        const InputField(
          labelText: AppStrings.passwordHint,
          isPassword: true,
          icon: Icons.lock_outline,
        ),
        const SizedBox(height: 16.0),

        // Confirm Password Input
        const InputField(
          labelText: AppStrings.confirmPasswordHint,
          isPassword: true,
          icon: Icons.lock_outline,
        ),
        const SizedBox(height: 24.0),

        // Sign Up Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement registration logic
              context.go('/dashboard');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            child: const Text(AppStrings.signUpButton),
          ),
        ),
      ],
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
