import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/providers/authentication_provider.dart';
import 'package:teamhub_productivity_suite/src/widgets/inputfield.dart';
import 'package:teamhub_productivity_suite/src/widgets/responsive_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    // Dispose of controllers to free up resources
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // Handle login logic here
  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthenticationProvider>();

    await authProvider.signIn(_emailController.text, _passwordController.text);

    if (mounted && authProvider.errorMessage != null) {
      // Show error message if login fails
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authProvider.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, child) {
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
                      _buildLoginForm(context, authProvider),

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
      },
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
  Widget _buildLoginForm(
    BuildContext context,
    AuthenticationProvider authProvider,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Input Field
          InputField(
            controller: _emailController,
            labelText: AppStrings.emailHint,
            isPassword: false,
            icon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.emailRequired;
              }
              // Simple email validation
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
              if (!emailRegex.hasMatch(value)) {
                return AppStrings.invalidEmail;
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          // Password Input Field
          InputField(
            controller: _passwordController,
            labelText: AppStrings.passwordHint,
            isPassword: true,
            icon: Icons.lock_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.passwordRequired;
              }
              if (value.length < 8) {
                return AppStrings.passwordTooShort;
              }
              return null;
            },
          ),
          const SizedBox(height: 24.0),
          // Login Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child:
                  authProvider.isLoading
                      ? CircularProgressIndicator()
                      : Text(AppStrings.loginButton),
            ),
          ),
        ],
      ),
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
