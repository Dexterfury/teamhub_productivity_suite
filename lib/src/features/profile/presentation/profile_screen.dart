import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/providers/authentication_provider.dart';
import 'package:teamhub_productivity_suite/src/widgets/profile_image_widget.dart';
import 'package:teamhub_productivity_suite/src/widgets/responsive_container.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrLarger = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(
        leading:
            context.canPop()
                ? BackButton(onPressed: () => context.pop())
                : IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () => context.go('/dashboard'),
                ),
        title: const Text(AppStrings.profileTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ResponsiveContainer(
            maxWidthMedium: 800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Header with Avatar and Name
                _buildProfileHeader(context),

                const SizedBox(height: 24.0),

                // Profile Information Cards
                // Use row layout for tablet and larger screens
                if (isTabletOrLarger)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildProfileCard(
                          context,
                          title: 'Contact Information',
                          children: _buildContactInfo(context),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: _buildProfileCard(
                          context,
                          title: 'Work Information',
                          children: _buildWorkInfo(context),
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildProfileCard(
                        context,
                        title: 'Contact Information',
                        children: _buildContactInfo(context),
                      ),
                      const SizedBox(height: 16.0),
                      _buildProfileCard(
                        context,
                        title: 'Work Information',
                        children: _buildWorkInfo(context),
                      ),
                    ],
                  ),

                const SizedBox(height: 24.0),

                // Action Buttons
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Profile header with avatar and name
  Widget _buildProfileHeader(BuildContext context) {
    final appUser = context.watch<AuthenticationProvider>().appUser;
    return Column(
      children: [
        // Avatar with edit button overlay
        ProfileImageWidget(imageUrl: appUser?.userPhotoUrl, radius: 60.0),

        const SizedBox(height: 16.0),

        Text(
          appUser!.fullName,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4.0),
        Text(
          appUser?.jobTitle ?? AppStrings.placeholderJobNotSet,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  // Profile card with title and content
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
          mainAxisSize:
              MainAxisSize
                  .min, // Ensure column only takes necessary vertical space
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => context.push('/profile/edit'),
                  tooltip: 'Edit ${title.toLowerCase()}',
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8.0),
            ...children,
          ],
        ),
      ),
    );
  }

  // Contact information section
  List<Widget> _buildContactInfo(BuildContext context) {
    final appUser = context.watch<AuthenticationProvider>().appUser;
    return [
      _buildInfoRow(
        context,
        icon: Icons.email_outlined,
        label: 'Email',
        value: appUser!.email,
      ),
      const SizedBox(height: 16.0),
      _buildInfoRow(
        context,
        icon: Icons.phone_outlined,
        label: 'Phone',
        value: appUser!.phone ?? AppStrings.placeholderPhoneNotSet,
      ),
    ];
  }

  // Work information section
  List<Widget> _buildWorkInfo(BuildContext context) {
    final appUser = context.watch<AuthenticationProvider>().appUser;
    return [
      _buildInfoRow(
        context,
        icon: Icons.business_outlined,
        label: 'Department',
        value: appUser!.department ?? AppStrings.placeholderDepartmentNotSet,
      ),
      const SizedBox(height: 16.0),
      _buildInfoRow(
        context,
        icon: Icons.location_on_outlined,
        label: 'Location',
        value: appUser!.location ?? AppStrings.placeholderNoLocation,
      ),
    ];
  }

  // Information row with icon, label and value
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 2.0),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Action buttons for profile
  Widget _buildActionButtons(BuildContext context) {
    final authProvider = context.read<AuthenticationProvider>();
    // Get screen width for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrLarger = screenWidth >= 600;

    if (isTabletOrLarger) {
      // Row layout for tablet and larger screens
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            // For tablet and larger
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
          const SizedBox(width: 16.0),
          TextButton.icon(
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text(AppStrings.logoutButton),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
            ),
          ),
        ],
      );
    } else {
      // Column layout for mobile screens
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/profile/edit'),
              icon: const Icon(Icons.edit),
              label: const Text(AppStrings.editProfileTitle),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          // Admin Panel Button (Placeholder - show only for admins)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // For now, assume user is admin to show the button
                context.push('/profile/manage-users');
              },
              icon: const Icon(Icons.admin_panel_settings_outlined),
              label: const Text(AppStrings.manageUsersTitle),
            ),
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () async {
                await authProvider.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text(AppStrings.logoutButton),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),
        ],
      );
    }
  }
}
