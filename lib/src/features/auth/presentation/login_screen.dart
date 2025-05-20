import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.loginTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.loginTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8.0),
              Text(
                AppStrings.loginSubtitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24.0),
              TextField(
                decoration: InputDecoration(
                  labelText: AppStrings.emailHint,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppStrings.passwordHint,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text(AppStrings.loginButton),
              ),
              const SizedBox(height: 16.0),              TextButton(
                onPressed: () => context.go('/forgot-password'),
                child: const Text(AppStrings.forgotPassword),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () => context.go('/register'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.noAccount),
                    const SizedBox(width: 4.0),
                    Text(
                      AppStrings.signUpLink,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
