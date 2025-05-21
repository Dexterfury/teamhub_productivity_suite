import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/models/user_model.dart';
import 'package:teamhub_productivity_suite/src/models/user_roles.dart';
import 'package:teamhub_productivity_suite/src/widgets/responsive_container.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String _searchQuery = '';
  String _selectedRoleFilter = 'All';
  bool _isLoading = false;

  // Placeholder user data
  final List<UserModel> _users = [
    UserModel(
      uid: 'user1',
      email: 'admin@example.com',
      fullName: 'Admin User',
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
      lastOnline: DateTime.now().subtract(const Duration(minutes: 5)),
      roles: UserRoles(isAdmin: true, isManager: true, canManageUsers: true),
    ),
    UserModel(
      uid: 'user2',
      email: 'manager@example.com',
      fullName: 'Manager User',
      createdAt: DateTime.now().subtract(const Duration(days: 50)),
      lastOnline: DateTime.now().subtract(const Duration(hours: 2)),
      roles: UserRoles(isManager: true),
    ),
    UserModel(
      uid: 'user3',
      email: 'member@example.com',
      fullName: 'Team Member',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      lastOnline: DateTime.now().subtract(const Duration(days: 1)),
      roles: UserRoles(isMember: true),
    ),
  ];

  List<UserModel> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesRole =
          _selectedRoleFilter == 'All' ||
          (_selectedRoleFilter == 'Admin' && user.roles.isAdmin) ||
          (_selectedRoleFilter == 'Manager' && user.roles.isManager) ||
          (_selectedRoleFilter == 'Member' && user.roles.isMember);

      return matchesSearch && matchesRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrLarger = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.manageUsersTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic to fetch latest users
          await Future.delayed(const Duration(seconds: 1));
        },
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: ResponsiveContainer(
                    maxWidthMedium: 900,
                    maxWidthLarge: 1200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBarAndFilters(context),
                        const SizedBox(height: 16.0),
                        _buildUserList(context, isTabletOrLarger),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildSearchBarAndFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: AppStrings.searchUsersHint,
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
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildRoleFilterChip('All', context),
              const SizedBox(width: 8),
              _buildRoleFilterChip('Admin', context),
              const SizedBox(width: 8),
              _buildRoleFilterChip('Manager', context),
              const SizedBox(width: 8),
              _buildRoleFilterChip('Member', context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleFilterChip(String label, BuildContext context) {
    final isSelected = _selectedRoleFilter == label;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) => setState(() => _selectedRoleFilter = label),
      showCheckmark: false,
      backgroundColor: Theme.of(context).chipTheme.backgroundColor,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : null,
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
    );
  }

  Widget _buildUserList(BuildContext context, bool isTabletOrLarger) {
    if (_filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_alt_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              AppStrings.noUsersFound,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? AppStrings.tryDifferentSearchTerm
                  : _selectedRoleFilter != 'All'
                  ? AppStrings.tryDifferentFilter
                  : AppStrings.noUsersMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  user.userPhotoUrl != null
                      ? NetworkImage(user.userPhotoUrl!)
                      : null,
              child:
                  user.userPhotoUrl == null
                      ? Text(user.fullName[0].toUpperCase())
                      : null,
            ),
            title: Text(user.fullName),
            subtitle: Text(user.email),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditRolesDialog(context, user),
              tooltip: AppStrings.editRolesTooltip,
            ),
          ),
        );
      },
    );
  }

  void _showEditRolesDialog(BuildContext context, UserModel user) {
    UserRoles tempRoles = UserRoles(
      isAdmin: user.roles.isAdmin,
      isManager: user.roles.isManager,
      isMember: user.roles.isMember,
      approverLevel: user.roles.approverLevel,
      canAccessPOS: user.roles.canAccessPOS,
      canBalanceShifts: user.roles.canBalanceShifts,
      canAccessProcurement: user.roles.canAccessProcurement,
      canAccessAccounting: user.roles.canAccessAccounting,
      canManageCustomersAndSuppliers: user.roles.canManageCustomersAndSuppliers,
      canManageItems: user.roles.canManageItems,
      canManageEquipment: user.roles.canManageEquipment,
      canProcessRentals: user.roles.canProcessRentals,
      canPerformStockCount: user.roles.canPerformStockCount,
      canManageUsers: user.roles.canManageUsers,
      canManageOrganizations: user.roles.canManageOrganizations,
      canManageSites: user.roles.canManageSites,
      canGenerateInvoices: user.roles.canGenerateInvoices,
      canManageAccountingPeriods: user.roles.canManageAccountingPeriods,
      canOverrideRolloverConditions: user.roles.canOverrideRolloverConditions,
      canPostToSoftClosedPeriod: user.roles.canPostToSoftClosedPeriod,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('${AppStrings.editRolesFor} ${user.fullName}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      title: const Text(AppStrings.roleAdmin),
                      value: tempRoles.isAdmin,
                      onChanged: (bool? value) {
                        setState(() {
                          tempRoles.isAdmin = value ?? false;
                          if (tempRoles.isAdmin) {
                            tempRoles.isManager = true;
                            tempRoles.isMember = false;
                          }
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text(AppStrings.roleManager),
                      value: tempRoles.isManager,
                      onChanged: (bool? value) {
                        setState(() {
                          tempRoles.isManager = value ?? false;
                          if (tempRoles.isManager) {
                            tempRoles.isMember = false;
                          } else {
                            tempRoles.isAdmin = false;
                          }
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text(AppStrings.roleMember),
                      value: tempRoles.isMember,
                      onChanged: (bool? value) {
                        setState(() {
                          tempRoles.isMember = value ?? false;
                          if (tempRoles.isMember) {
                            tempRoles.isAdmin = false;
                            tempRoles.isManager = false;
                          }
                        });
                      },
                    ),
                    ListTile(
                      title: const Text(AppStrings.approverLevel),
                      trailing: DropdownButton<ApproverLevel>(
                        value: tempRoles.approverLevel,
                        onChanged: (ApproverLevel? newValue) {
                          setState(() {
                            tempRoles.approverLevel = newValue!;
                          });
                        },
                        items:
                            ApproverLevel.values.map<
                              DropdownMenuItem<ApproverLevel>
                            >((ApproverLevel value) {
                              return DropdownMenuItem<ApproverLevel>(
                                value: value,
                                child: Text(value.toString().split('.').last),
                              );
                            }).toList(),
                      ),
                    ),
                    // Add more role checkboxes here based on UserRoles model
                    _buildPermissionCheckbox(
                      AppStrings.canAccessPOS,
                      tempRoles.canAccessPOS,
                      (value) => setState(
                        () => tempRoles.canAccessPOS = value ?? false,
                      ),
                    ),
                    _buildPermissionCheckbox(
                      AppStrings.canBalanceShifts,
                      tempRoles.canBalanceShifts,
                      (value) => setState(
                        () => tempRoles.canBalanceShifts = value ?? false,
                      ),
                    ),
                    _buildPermissionCheckbox(
                      AppStrings.canAccessProcurement,
                      tempRoles.canAccessProcurement,
                      (value) => setState(
                        () => tempRoles.canAccessProcurement = value ?? false,
                      ),
                    ),
                    _buildPermissionCheckbox(
                      AppStrings.canAccessAccounting,
                      tempRoles.canAccessAccounting,
                      (value) => setState(
                        () => tempRoles.canAccessAccounting = value ?? false,
                      ),
                    ),
                    _buildPermissionCheckbox(
                      AppStrings.canManageCustomersAndSuppliers,
                      tempRoles.canManageCustomersAndSuppliers,
                      (value) => setState(
                        () =>
                            tempRoles.canManageCustomersAndSuppliers =
                                value ?? false,
                      ),
                    ),
                    _buildPermissionCheckbox(
                      AppStrings.canManageItems,
                      tempRoles.canManageItems,
                      (value) => setState(
                        () => tempRoles.canManageItems = value ?? false,
                      ),
                    ),
                    _buildPermissionCheckbox(
                      AppStrings.canManageEquipment,
                      tempRoles.canManageEquipment,
                      (value) => setState(
                        () => tempRoles.canManageEquipment = value ?? false,
                      ),
                    ),
                    _buildPermissionCheckbox(
                      AppStrings.canProcessRentals,
                      tempRoles.canProcessRentals,
                      (value) => setState(
                        () => tempRoles.canProcessRentals = value ?? false,
                      ),
                    ),
                    _buildPermissionCheckbox(
                      AppStrings.canPerformStockCount,
                      tempRoles.canPerformStockCount,
                      (value) => setState(
                        () => tempRoles.canPerformStockCount = value ?? false,
                      ),
                    ),
                    _buildPermissionCheckbox(
                      AppStrings.canManageUsers,
                      tempRoles.canManageUsers,
                      (value) => setState(
                        () => tempRoles.canManageUsers = value ?? false,
                      ),
                    ),
                    _buildPermissionCheckbox(
                      AppStrings.canManageOrganizations,
                      tempRoles.canManageOrganizations,
                      (value) => setState(
                        () => tempRoles.canManageOrganizations = value ?? false,
                      ),
                    ),
                    _buildPermissionCheckbox(
                      AppStrings.canManageSites,
                      tempRoles.canManageSites,
                      (value) => setState(
                        () => tempRoles.canManageSites = value ?? false,
                      ),
                    ),
                    _buildPermissionCheckbox(
                      AppStrings.canGenerateInvoices,
                      tempRoles.canGenerateInvoices,
                      (value) => setState(
                        () => tempRoles.canGenerateInvoices = value ?? false,
                      ),
                    ),
                    _buildPermissionCheckbox(
                      AppStrings.canManageAccountingPeriods,
                      tempRoles.canManageAccountingPeriods,
                      (value) => setState(
                        () =>
                            tempRoles.canManageAccountingPeriods =
                                value ?? false,
                      ),
                    ),
                    _buildPermissionCheckbox(
                      AppStrings.canOverrideRolloverConditions,
                      tempRoles.canOverrideRolloverConditions,
                      (value) => setState(
                        () =>
                            tempRoles.canOverrideRolloverConditions =
                                value ?? false,
                      ),
                    ),
                    _buildPermissionCheckbox(
                      AppStrings.canPostToSoftClosedPeriod,
                      tempRoles.canPostToSoftClosedPeriod,
                      (value) => setState(
                        () =>
                            tempRoles.canPostToSoftClosedPeriod =
                                value ?? false,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(AppStrings.cancelButton),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement actual update logic using UserService
                    print(
                      'Updating roles for ${user.fullName} to ${tempRoles.toMap()}',
                    );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${AppStrings.rolesUpdatedFor} ${user.fullName}',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text(AppStrings.saveButton),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPermissionCheckbox(
    String title,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}

// </final_file_content>

// IMPORTANT: For any future changes to this file, use the final_file_content shown above as your reference. This content reflects the current state of the file, including any auto-formatting (e.g., if you used single quotes but the formatter converted them to double quotes). Always base your SEARCH/REPLACE operations on this final version to ensure accuracy.



// New problems detected after saving the file:
// lib/src/features/admin_panel/presentation/manage_users_screen.dart
// - [dart Error] Line 418: Expected to find ')'.
// - [dart Error] Line 334: Too many positional arguments: 3 expected, but 16 found.
// Try removing the extra arguments.
// - [dart Error] Line 316: The argument type 'Widget' can't be assigned to the parameter type 'String'. 
// - [dart Error] Line 321: The argument type 'Widget' can't be assigned to the parameter type 'bool'. 
// - [dart Error] Line 327: The argument type 'Widget' can't be assigned to the parameter type 'ValueChanged<bool?>'.<environment_details>
// # VSCode Visible Files
// lib/src/features/admin_panel/presentation/manage_users_screen.dart

// # VSCode Open Tabs
// lib/src/features/dashboard/presentation/dashboard_screen.dart
// lib/src/models/user_model.dart
// lib/src/features/admin_panel/presentation/admin_panel_screen.dart
// lib/src/routing/app_router.dart
// lib/src/features/profile/presentation/profile_screen.dart
// lib/src/services/project_service.dart
// lib/src/services/task_service.dart
// lib/src/services/inventory_service.dart
// lib/src/constants/appstrings.dart
// lib/src/features/admin_panel/presentation/manage_users_screen.dart
// lib/src/services/user_service.dart

// # Current Time
// 5/21/2025, 9:13:02 PM (Africa/Lusaka, UTC+2:00)

// # Context Window Usage
// 152,490 / 1,048.576K tokens used (15%)

// # Current Mode
// ACT MODE
// </environment_details>
