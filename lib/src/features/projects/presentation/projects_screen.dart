import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // Added import
import 'package:teamhub_productivity_suite/src/models/project_model.dart';
import 'package:teamhub_productivity_suite/src/providers/authentication_provider.dart'; // Added import
import 'package:teamhub_productivity_suite/src/services/project_service.dart'; // Added import
import 'package:teamhub_productivity_suite/src/widgets/responsive_container.dart';

class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  String _searchQuery = '';
  ProjectFilter _selectedFilter = ProjectFilter.all; // Changed to enum
  bool _isLoading = false;
  List<ProjectModel> _projects = []; // Will be populated from Firestore

  final ProjectService _projectService = ProjectService();

  // Filtered projects based on search and filter
  List<ProjectModel> get filteredProjects {
    final authProvider = context.read<AuthenticationProvider>();
    final currentUserId = authProvider.appUser?.uid;

    return _projects.where((project) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          project.projectName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          project.projectDescription.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      final matchesFilter =
          _selectedFilter == ProjectFilter.all ||
          (_selectedFilter == ProjectFilter.recent &&
              project.createdAt.isAfter(
                DateTime.now().subtract(const Duration(days: 14)),
              )) ||
          (_selectedFilter == ProjectFilter.myProjects &&
              project.createdById == currentUserId);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthenticationProvider>();
      final currentUserId = authProvider.appUser?.uid;

      if (currentUserId == null) {
        // Handle unauthenticated user, maybe navigate to login
        setState(() => _isLoading = false);
        return;
      }

      final fetchedProjects = await _projectService.getProjects(
        currentUserId: currentUserId,
        filter: _selectedFilter,
        searchQuery: _searchQuery,
      );
      setState(() {
        _projects = fetchedProjects;
      });
    } catch (e) {
      print('Error fetching projects: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading projects: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrLarger = screenWidth >= 600;
    final isDesktop = screenWidth >= 1200;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter projects',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortDialog(context),
            tooltip: 'Sort projects',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProjects, // Call _fetchProjects for refresh
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ResponsiveContainer(
                    maxWidthMedium: 900,
                    maxWidthLarge: 1400,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search and Filter Row
                        _buildSearchAndFilterRow(context),

                        const SizedBox(height: 16.0),

                        // Projects Stats
                        if (isTabletOrLarger) _buildProjectsStats(context),

                        const SizedBox(height: 16.0),

                        // Projects List
                        _buildProjectsList(
                          context,
                          isTabletOrLarger,
                          isDesktop,
                        ),
                      ],
                    ),
                  ),
                ),
      ),
      floatingActionButton: Consumer<AuthenticationProvider>(
        builder: (context, authProvider, child) {
          final isManager = authProvider.appUser?.roles.isManager ?? false;
          final canManageSites =
              authProvider.appUser?.roles.canManageSites ?? false;
          return isManager || canManageSites
              ? FloatingActionButton.extended(
                heroTag: 'projectsListFAB', // Add unique heroTag
                onPressed: () => context.go('/projects/new'),
                icon: const Icon(Icons.add),
                label: const Text('New Project'),
                tooltip: 'Create new project',
              )
              : const SizedBox.shrink(); // Hide FAB if not manager
        },
      ),
    );
  }

  // Search bar and filter chips
  Widget _buildSearchAndFilterRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search projects...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _searchQuery = ''),
                      tooltip: 'Clear search',
                    )
                    : null,
          ),
        ),

        const SizedBox(height: 16.0),

        // Filter Chips
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip('All', Icons.folder_outlined),
              const SizedBox(width: 8),
              _buildFilterChip('Recent', Icons.access_time),
              const SizedBox(width: 8),
              _buildFilterChip('My Projects', Icons.person_outline),
            ],
          ),
        ),
      ],
    );
  }

  // Individual filter chip
  Widget _buildFilterChip(String label, IconData icon) {
    ProjectFilter filterValue;
    switch (label) {
      case 'All':
        filterValue = ProjectFilter.all;
        break;
      case 'Recent':
        filterValue = ProjectFilter.recent;
        break;
      case 'My Projects':
        filterValue = ProjectFilter.myProjects;
        break;
      default:
        filterValue = ProjectFilter.all;
    }

    final isSelected = _selectedFilter == filterValue;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      avatar: Icon(icon, size: 18),
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filterValue;
          _fetchProjects(); // Fetch projects when filter changes
        });
      },
      showCheckmark: false,
      backgroundColor: Theme.of(context).chipTheme.backgroundColor,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : null,
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
    );
  }

  // Projects statistics
  Widget _buildProjectsStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Total Projects',
            value: _projects.length.toString(),
            icon: Icons.folder_outlined,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Active Projects',
            value: '3', // Placeholder value
            icon: Icons.play_circle_outline,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Completed Projects',
            value: '0', // Placeholder value
            icon: Icons.check_circle_outline,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  // Stat card widget
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      // Wrap the Card's child with a SizedBox to give it a fixed height.
      // This allows the Spacer within the Column to work correctly.
      child: SizedBox(
        height: 160, // You can adjust this height as needed for your UI.
        width:
            double.infinity, // Ensures the Card takes the width from Expanded.
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(), // This will now expand to fill the remaining space in the 160px SizedBox.
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Projects list with responsive layout
  Widget _buildProjectsList(
    BuildContext context,
    bool isTabletOrLarger,
    bool isDesktop,
  ) {
    if (filteredProjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No projects found',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : _selectedFilter != 'All'
                  ? 'Try a different filter'
                  : 'Create your first project',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Use grid for desktop
    if (isDesktop) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredProjects.length,
        itemBuilder: (context, index) {
          return _buildProjectCard(context, filteredProjects[index]);
        },
      );
    }
    // Use grid with 2 columns for tablet
    else if (isTabletOrLarger) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredProjects.length,
        itemBuilder: (context, index) {
          return _buildProjectCard(context, filteredProjects[index]);
        },
      );
    }
    // Use list for mobile
    else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredProjects.length,
        itemBuilder: (context, index) {
          return _buildProjectListItem(context, filteredProjects[index]);
        },
      );
    }
  }

  // Project card for grid layout
  Widget _buildProjectCard(BuildContext context, ProjectModel project) {
    final authProvider = context.read<AuthenticationProvider>();
    final currentUserId = authProvider.appUser?.uid;
    final isCreator = project.createdById == currentUserId;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => context.go('/projects/${project.projectId}'),
        borderRadius: BorderRadius.circular(4),
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
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.folder_outlined,
                      color: Colors.blue,
                    ),
                  ),
                  const Spacer(),
                  if (isCreator)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          context.go('/projects/${project.projectId}/edit');
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(context, project);
                        }
                      },
                      itemBuilder:
                          (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                project.projectName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                project.projectDescription,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(project.createdAt),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Project list item for mobile layout
  Widget _buildProjectListItem(BuildContext context, ProjectModel project) {
    final authProvider = context.read<AuthenticationProvider>();
    final currentUserId = authProvider.appUser?.uid;
    final isCreator = project.createdById == currentUserId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => context.go('/projects/${project.projectId}'),
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
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.folder_outlined,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.projectName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(project.createdAt),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isCreator)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          context.go('/projects/${project.projectId}/edit');
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(context, project);
                        }
                      },
                      itemBuilder:
                          (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                project.projectDescription,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Member avatars
                  SizedBox(
                    height: 32,
                    child: Stack(
                      children: List.generate(
                        project.memberIds.length > 3
                            ? 3
                            : project.memberIds.length,
                        (index) => Positioned(
                          left: index * 20.0,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                width: 2,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 14,
                              backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/150?img=${index + 1}',
                              ),
                            ),
                          ),
                        ),
                      )..add(
                        project.memberIds.length > 3
                            ? Positioned(
                              left: 3 * 20.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                    width: 2,
                                  ),
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.grey.shade300,
                                  child: Text(
                                    '+${project.memberIds.length - 3}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Project status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 16,
                          color: Colors.green,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
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

  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Show filter dialog
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Projects'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text('All Projects'),
                selected: _selectedFilter == ProjectFilter.all,
                onTap: () {
                  setState(() {
                    _selectedFilter = ProjectFilter.all;
                    _fetchProjects();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Recent Projects'),
                selected: _selectedFilter == ProjectFilter.recent,
                onTap: () {
                  setState(() {
                    _selectedFilter = ProjectFilter.recent;
                    _fetchProjects();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('My Projects'),
                selected: _selectedFilter == ProjectFilter.myProjects,
                onTap: () {
                  setState(() {
                    _selectedFilter = ProjectFilter.myProjects;
                    _fetchProjects();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Show sort dialog
  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sort Projects'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Name (A-Z)'),
                onTap: () {
                  setState(() {
                    _projects.sort(
                      (a, b) => a.projectName.compareTo(b.projectName),
                    );
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Name (Z-A)'),
                onTap: () {
                  setState(() {
                    _projects.sort(
                      (a, b) => b.projectName.compareTo(a.projectName),
                    );
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Newest First'),
                onTap: () {
                  setState(() {
                    _projects.sort(
                      (a, b) => b.createdAt.compareTo(a.createdAt),
                    );
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Oldest First'),
                onTap: () {
                  setState(() {
                    _projects.sort(
                      (a, b) => a.createdAt.compareTo(b.createdAt),
                    );
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, ProjectModel project) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Project?'),
          content: Text(
            'Are you sure you want to delete "${project.projectName}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog first
                setState(() => _isLoading = true); // Show loading indicator

                try {
                  await _projectService.deleteProject(project.projectId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Project "${project.projectName}" deleted',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  _fetchProjects(); // Refresh the list after deletion
                } catch (e) {
                  print('Error deleting project: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error deleting project: ${e.toString()}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
