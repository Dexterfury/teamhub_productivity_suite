class AppStrings {
  // User Model Fields
  static const String fieldUid = 'uid';
  static const String fieldEmail = 'email';
  static const String fieldFullName = 'fullName';
  static const String fieldUserPhotoUrl = 'userPhotoUrl';
  static const String fieldIsFirstLogin = 'isFirstLogin';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldCreatedById = 'createdById';
  static const String fieldRoles = 'roles';
  static const String fieldIsOnline = 'isOnline';
  static const String fieldLastOnline = 'lastOnline';
  static const String fieldSearchTokens = 'searchTokens';
  static const String fieldAssignedOrganizationId = 'assignedOrganizationId';
  static const String fieldJobTitle = 'jobTitle';
  static const String fieldPhone = 'phone';
  static const String fieldDepartment = 'department';
  static const String fieldLocation = 'location';
  static const String fieldFcmToken = 'fcmToken';

  // User Role Fields
  static const String fieldIsAdmin = 'isAdmin';
  static const String fieldIsManager = 'isManager';
  static const String fieldIsMember = 'isMember';
  static const String fieldApproverLevel = 'approverLevel';

  // Additional User Role Fields (based on errors)
  static const String fieldCanAccessPOS = 'canAccessPOS';
  static const String fieldCanBalanceShifts = 'canBalanceShifts';
  static const String fieldCanAccessProcurement = 'canAccessProcurement';
  static const String fieldCanAccessAccounting = 'canAccessAccounting';
  static const String fieldCanManageCustomersAndSuppliers =
      'canManageCustomersAndSuppliers';
  static const String fieldCanManageItems = 'canManageItems';
  static const String fieldCanManageEquipment = 'canManageEquipment';
  static const String fieldCanProcessRentals = 'canProcessRentals';
  static const String fieldCanPerformStockCount = 'canPerformStockCount';
  static const String fieldCanManageUsers = 'canManageUsers';
  static const String fieldCanManageOrganizations = 'canManageOrganizations';
  static const String fieldCanManageSites = 'canManageSites';
  static const String fieldCanGenerateInvoices = 'canGenerateInvoices';
  static const String fieldCanManageAccountingPeriods =
      'canManageAccountingPeriods';
  static const String fieldCanOverrideRolloverConditions =
      'canOverrideRolloverConditions';
  static const String fieldCanPostToSoftClosedPeriod =
      'canPostToSoftClosedPeriod';

  // Task Model Fields
  static const String fieldTaskId = 'taskId';
  static const String fieldTitle = 'title';
  static const String fieldDescription = 'description';
  static const String fieldDueDate = 'dueDate';
  static const String fieldStatus = 'status';
  static const String fieldAssigneeId = 'assigneeId';
  static const String fieldTaskProjectId = 'projectId';

  // Project Model Fields
  static const String fieldProjectProjectId =
      'projectId'; // Renamed to be specific
  static const String fieldProjectName = 'projectName';
  static const String fieldProjectDescription = 'projectDescription';
  static const String fieldMemberIds = 'memberIds';
  static const String fieldProjectStatus = 'status';

  // Inventory Model Fields
  static const String fieldInventoryItemId = 'inventoryItemId';
  static const String fieldItemName = 'itemName';
  static const String fieldItemDescription = 'itemDescription';
  static const String fieldQuantity = 'quantity';
  static const String fieldCategory = 'category';
  static const String fieldSupplier = 'supplier';
  static const String fieldId = 'id';

  // Authentication Strings
  static const String loginTitle = 'Welcome Back!';
  static const String loginSubtitle = 'Sign in to continue';
  static const String emailHint = 'Email';
  static const String passwordHint = 'Password';
  static const String loginButton = 'Login';
  static const String forgotPassword = 'Forgot Password?';
  static const String noAccount = "Don't have an account?";
  static const String signUpLink = 'Sign Up';

  static const String registerTitle = 'Create Account';
  static const String registerSubtitle = 'Get started with TeamHub';
  static const String fullNameHint = 'Full Name';
  static const String confirmPasswordHint = 'Confirm Password';
  static const String signUpButton = 'Sign Up';
  static const String alreadyAccount = 'Already have an account?';
  static const String loginLink = 'Login';

  static const String forgotPasswordTitle = 'Forgot Password';
  static const String forgotPasswordSubtitle =
      'Enter your email to reset your password';
  static const String sendResetLinkButton = 'Send Reset Link';

  // General UI Strings
  static const String dashboardTitle = 'Dashboard';
  static const String projectsTitle = 'Projects';
  static const String tasksTitle = 'Tasks';
  static const String inventoryTitle = 'Inventory';
  static const String usersTitle = 'Users';
  static const String profileTitle = 'Profile';
  static const String settingsTitle =
      'Settings'; // Example, not in requirements but good practice

  static const String myTasksSection = 'My Tasks';
  static const String recentProjectsSection = 'Recent Projects';
  static const String quickStatsSection = 'Quick Stats';

  static const String createProjectTitle = 'Create Project';
  static const String editProjectTitle = 'Edit Project';
  static const String projectNameHint = 'Project Name';
  static const String projectDescriptionHint = 'Project Description';
  static const String addMembersHint = 'Add Members';
  static const String saveButton = 'Save';
  static const String cancelButton = 'Cancel';

  static const String createTaskTitle = 'Create Task';
  static const String editTaskTitle = 'Edit Task';
  static const String taskTitleHint = 'Task Title';
  static const String taskDescriptionHint = 'Task Description';
  static const String dueDateHint = 'Due Date';
  static const String statusHint = 'Status';
  static const String assigneeHint = 'Assignee';
  static const String selectProjectHint = 'Select Project';

  static const String addInventoryItemTitle = 'Add Inventory Item';
  static const String editInventoryItemTitle = 'Edit Inventory Item';
  static const String itemNameHint = 'Item Name';
  static const String itemDescriptionHint = 'Item Description';
  static const String quantityHint = 'Quantity';
  static const String categoryHint = 'Category';
  static const String supplierHint = 'Supplier (Optional)';

  static const String editProfileTitle = 'Edit Profile';
  static const String fullNameProfileHint = 'Full Name';
  static const String jobTitleProfileHint = 'Job Title';
  static const String changePhotoButton = 'Change Photo';
  static const String logoutButton = 'Logout';

  // Placeholder Data Strings
  static const String placeholderProjectName = 'Sample Project';
  static const String placeholderProjectDescription =
      'This is a placeholder project description. It should be long enough to demonstrate truncation in the list view.';
  static const String placeholderTaskTitle = 'Complete UI for Login Screen';
  static const String placeholderTaskDescription =
      'Implement the visual elements and layout for the login screen according to the design specifications.';
  static const String placeholderItemName = 'Laptop';
  static const String placeholderItemDescription =
      'Standard issue work laptop.';
  static const String placeholderUserName = 'John Doe';
  static const String placeholderUserEmail = 'john.doe@example.com';
  static const String placeholderJobTitle = 'Software Engineer';

  static const String placeholderJobNotSet = 'Job Title Not Set';
  static const String placeholderDepartmentNotSet = 'Department Not Set';
  static const String placeholderPhoneNotSet = 'Phone Not Set';
  static const String placeholderNoInventoryItems =
      'No inventory items available. Add new items to get started.';
  static const placeholderNoLocation = 'Location Not Set';

  // Error Messages (Placeholders)
  static const String genericError = 'An unexpected error occurred.';
  static const String networkError = 'Please check your internet connection.';
  static const String invalidEmailError = 'Please enter a valid email address.';
  static const String passwordTooShortError =
      'Password must be at least 6 characters long.';
  static const String passwordsDoNotMatchError = 'Passwords do not match.';
  static const String requiredFieldError = 'This field is required.';

  static const String taskCreatedSuccessfully = 'Task created successfully!';
  static const String taskUpdatedSuccessfully = 'Task updated successfully!';

  // Firestore collections
  static const String collectionUsers = 'users';
  static const String collectionProjects = 'projects';
  static const String collectionTasks = 'tasks';
  static const String collectionInventory = 'inventory';

  // Admin Panel Strings
  static const String manageUsersTitle = 'Manage Users';
  static const String searchUsersHint = 'Search users by name or email...';
  static const String noUsersFound = 'No users found';
  static const String noTasksFound = 'No tasks found.';
  static const String tryDifferentSearchTerm = 'Try a different search term';
  static const String tryDifferentFilter = 'Try a different role filter';
  static const String noUsersMessage =
      'No users to display. Add new users to get started.';
  static const String editRolesTooltip = 'Edit User Roles';
  static const String editRolesFor = 'Edit Roles for';
  static const String roleAdmin = 'Admin';
  static const String roleManager = 'Manager';
  static const String roleMember = 'Member';
  static const String approverLevel = 'Approver Level';
  static const String rolesUpdatedFor = 'Roles updated for';

  // User Role Permissions Strings
  static const String canAccessPOS = 'Can Access POS';
  static const String canBalanceShifts = 'Can Balance Shifts';
  static const String canAccessProcurement = 'Can Access Procurement';
  static const String canAccessAccounting = 'Can Access Accounting';
  static const String canManageCustomersAndSuppliers =
      'Can Manage Customers & Suppliers';
  static const String canManageItems = 'Can Manage Items';
  static const String canManageEquipment = 'Can Manage Equipment';
  static const String canProcessRentals = 'Can Process Rentals';
  static const String canPerformStockCount = 'Can Perform Stock Count';
  static const String canManageUsers = 'Can Manage Users';
  static const String canManageOrganizations = 'Can Manage Organizations';
  static const String canManageSites = 'Can Manage Sites';
  static const String canGenerateInvoices = 'Can Generate Invoices';
  static const String canManageAccountingPeriods =
      'Can Manage Accounting Periods';
  static const String canOverrideRolloverConditions =
      'Can Override Rollover Conditions';
  static const String canPostToSoftClosedPeriod =
      'Can Post to Soft Closed Period';

  // error messages
  static const String fullNameError = 'Full name is required.';
  static const String emailError = 'Email is required.';
  static const String passwordError = 'Password is required.';
  static const String passwordLengthError =
      'Password must be at least 6 characters long.';
  static const String confirmPasswordError = 'Confirm password is required.';

  static const String emailRequired = 'Email is required.';
  static const String passwordRequired = 'Password is required.';
  static const String invalidEmail = 'Please enter a valid email address.';
  static const String passwordTooShort =
      'Password must be at least 6 characters long.';
}

enum ApproverLevel { none, level1, level2, level3 }
