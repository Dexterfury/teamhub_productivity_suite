import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/widgets/responsive_container.dart';
import 'package:teamhub_productivity_suite/src/widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrLarger = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.go('/profile?fromDashboard=true'),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: ResponsiveContainer(
            maxWidthMedium: 900,
            maxWidthLarge: 1400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(context),

                const SizedBox(height: 24.0),

                // Quick Stats Section - Grid layout for tablet and larger
                Text(
                  AppStrings.quickStatsSection,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8.0),
                _buildQuickStats(isTabletOrLarger),

                const SizedBox(height: 24.0),

                // My Tasks Section
                Text(
                  AppStrings.myTasksSection,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8.0),
                _buildTasksList(),

                const SizedBox(height: 24.0),

                // Recent Projects Section
                Text(
                  AppStrings.recentProjectsSection,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8.0),
                _buildRecentProjects(),
              ],
            ),
          ),
        ),
      ),
      // Add a drawer for mobile view
      drawer: screenWidth < 600 ? _buildDrawer(context) : null,
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: () {
          context.go('/tasks/new');
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Welcome section with user greeting
  Widget _buildWelcomeSection(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, User!', // Placeholder
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Today is ${_getFormattedDate()}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get formatted date
  String _getFormattedDate() {
    final now = DateTime.now();
    // Example: Friday, September 15, 2023
    return DateFormat('EEEE, MMMM d, yyyy').format(now);
  }

  // Quick stats section with responsive grid
  Widget _buildQuickStats(bool isTabletOrLarger) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isTabletOrLarger ? 4 : 2,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      childAspectRatio: isTabletOrLarger ? 1.5 : 1.3,
      children: [
        StatCard(
          title: 'Total Tasks',
          value: '12',
          icon: Icons.task_alt,
          color: Colors.blue,
        ),
        StatCard(
          title: 'In Progress',
          value: '5',
          icon: Icons.pending_actions,
          color: Colors.orange,
        ),
        StatCard(
          title: 'Completed',
          value: '7',
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
        StatCard(
          title: 'Active Projects',
          value: '3',
          icon: Icons.folder_open,
          color: Colors.purple,
        ),
      ],
    );
  }

  // Tasks list with horizontal scrolling
  Widget _buildTasksList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3, // Placeholder count
        itemBuilder: (context, index) {
          return _taskItem();
        },
      ),
    );
  }

  _taskItem() {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'In Progress', // Placeholder status
                      style: TextStyle(color: Colors.blue[700], fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  const Text(
                    'Due Tomorrow', // Placeholder due date
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Complete Dashboard UI', // Placeholder task title
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Implement the dashboard screen with all required components and proper styling.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const Spacer(),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/300', // Placeholder avatar
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    // Prevent assignee name from causing horizontal overflow
                    child: Text(
                      'John Doe', // Placeholder assignee
                      style: TextStyle(fontSize: 12),
                      overflow:
                          TextOverflow.ellipsis, // Add ellipsis for long names
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to task details
                    },
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Recent projects with horizontal scrolling
  Widget _buildRecentProjects() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3, // Placeholder count
        itemBuilder: (context, index) {
          return _recentProjectItem();
        },
      ),
    );
  }

  _recentProjectItem() {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.folder_outlined,
                      color: Colors.purple[700],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Active', // Placeholder status
                      style: TextStyle(color: Colors.green[700], fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'TeamHub Mobile App', // Placeholder project title
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                // Allow description to fill available vertical space
                child: Text(
                  'Development of the TeamHub mobile application with Flutter.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Flexible(
                    // Make task count text flexible
                    child: Text(
                      '8 Tasks', // Placeholder task count
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 64.0, // Calculated width for the avatars
                    height: 24.0, // Height of a single avatar
                    child: Stack(
                      children: [
                        for (var i = 0; i < 3; i++)
                          Positioned(
                            right: i * 20.0,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 11,
                                backgroundImage: NetworkImage(
                                  'https://i.pravatar.cc/300?img=${i + 1}', // Placeholder avatars
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation drawer for mobile view
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                ),
                const SizedBox(height: 10),
                Text(
                  'User Name',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                Text(
                  'user@example.com',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            onTap: () => context.go('/dashboard'),
            selected: true,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.task_alt_outlined,
            title: 'Tasks',
            onTap: () {
              // TODO: Navigate to tasks screen
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.folder_outlined,
            title: 'Projects',
            onTap: () {
              // TODO: Navigate to projects screen
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.inventory_2_outlined,
            title: 'Inventory',
            onTap: () => context.go('/inventory'),
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              // TODO: Navigate to settings screen
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () => context.go('/login'),
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  // Helper method to build drawer items
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            selected
                ? Theme.of(context).primaryColor
                : textColor ?? Theme.of(context).iconTheme.color,
      ),
      title: Text(
        title,
        style: TextStyle(
          color:
              selected
                  ? Theme.of(context).primaryColor
                  : textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: selected ? FontWeight.bold : null,
        ),
      ),
      onTap: onTap,
      selected: selected,
    );
  }
}
