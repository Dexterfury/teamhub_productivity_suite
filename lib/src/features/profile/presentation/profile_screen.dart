import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profileTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/300', // Placeholder avatar
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              AppStrings.placeholderUserName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4.0),
            Text(
              AppStrings.placeholderJobTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24.0),
            _buildProfileCard(
              context,
              title: 'Contact Information',
              children: [
                _buildInfoRow(
                  context,
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: AppStrings.placeholderUserEmail,
                ),
                const SizedBox(height: 12.0),
                _buildInfoRow(
                  context,
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: '+1 234 567 8900', // Placeholder
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            _buildProfileCard(
              context,
              title: 'Work Information',
              children: [
                _buildInfoRow(
                  context,
                  icon: Icons.business_outlined,
                  label: 'Department',
                  value: 'Engineering', // Placeholder
                ),
                const SizedBox(height: 12.0),
                _buildInfoRow(
                  context,
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: 'San Francisco, CA', // Placeholder
                ),
              ],
            ),
            const SizedBox(height: 24.0),              ElevatedButton.icon(
                onPressed: () => context.go('/profile/edit'),
                icon: const Icon(Icons.edit),
                label: const Text(AppStrings.editProfileTitle),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                ),
              ),
            const SizedBox(height: 12.0),              TextButton.icon(
                onPressed: () => context.go('/login'), // For now, just redirect to login
                icon: const Icon(Icons.logout),
                label: const Text(AppStrings.logoutButton),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16.0),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 2.0),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}
