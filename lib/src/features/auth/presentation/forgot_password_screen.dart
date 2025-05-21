import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/widgets/inputfield.dart';
import 'package:teamhub_productivity_suite/src/widgets/responsive_container.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.forgotPasswordTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
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

                  const SizedBox(height: 32.0),

                  // Reset Password Form
                  _buildResetForm(context),
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
          AppStrings.forgotPasswordTitle,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16.0),
        Text(
          AppStrings.forgotPasswordSubtitle,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Reset password form
  Widget _buildResetForm(BuildContext context) {
    return Column(
      children: [
        // Email Input
        const InputField(
          labelText: AppStrings.emailHint,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24.0),

        // Send Reset Link Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement send reset link logic
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password reset link sent to your email'),
                  backgroundColor: Colors.green,
                ),
              );

              // Navigate back to login after a delay
              Future.delayed(const Duration(seconds: 2), () {
                if (context.mounted) context.go('/login');
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            child: const Text(AppStrings.sendResetLinkButton),
          ),
        ),
        const SizedBox(height: 16.0),

        // Back to Login Button
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, size: 16),
              SizedBox(width: 8),
              Text('Back to Login'),
            ],
          ),
        ),
      ],
    );
  }
}
