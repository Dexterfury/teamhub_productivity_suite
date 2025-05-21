import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/widgets/inputfield.dart';
import 'package:teamhub_productivity_suite/src/widgets/responsive_container.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.loginTitle)),
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

                  // Login Form Section
                  _buildLoginForm(context),

                  const SizedBox(height: 24.0),

                  // Footer Section with Navigation Links
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
          AppStrings.loginTitle,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        Text(
          AppStrings.loginSubtitle,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Login form with email and password fields
  Widget _buildLoginForm(BuildContext context) {
    return Column(
      children: [
        // Email Input Field
        const InputField(
          labelText: AppStrings.emailHint,
          isPassword: false,
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 16.0),
        // Password Input Field
        const InputField(
          labelText: AppStrings.passwordHint,
          isPassword: true,
          icon: Icons.lock_outline,
        ),
        const SizedBox(height: 24.0),
        // Login Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/dashboard'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            child: const Text(AppStrings.loginButton),
          ),
        ),
      ],
    );
  }

  // Footer section with additional navigation options
  Widget _buildFooterSection(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () => context.go('/forgot-password'),
          child: const Text(AppStrings.forgotPassword),
        ),
        const SizedBox(height: 16.0),
        TextButton(
          onPressed: () => context.go('/register'),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(AppStrings.noAccount),
              const SizedBox(width: 4.0),
              Text(
                AppStrings.signUpLink,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
