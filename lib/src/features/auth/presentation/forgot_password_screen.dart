import 'package:flutter/material.dart';
import 'package:teamhub_productivity_suite/src/utils/appstrings.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.forgotPasswordTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.forgotPasswordTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8.0),
              Text(
                AppStrings.forgotPasswordSubtitle,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              TextField(
                decoration: InputDecoration(
                  labelText: AppStrings.emailHint,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement send reset link logic
                },
                child: const Text(AppStrings.sendResetLinkButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
