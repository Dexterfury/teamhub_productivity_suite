import 'package:go_router/go_router.dart';
import 'package:teamhub_productivity_suite/src/common_widgets/root_layout.dart';
import 'package:teamhub_productivity_suite/src/features/auth/presentation/forgot_password_screen.dart';
import 'package:teamhub_productivity_suite/src/features/auth/presentation/login_screen.dart';
import 'package:teamhub_productivity_suite/src/features/auth/presentation/registration_screen.dart';
import 'package:teamhub_productivity_suite/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:teamhub_productivity_suite/src/features/inventory/presentation/add_edit_inventory_item_screen.dart';
import 'package:teamhub_productivity_suite/src/features/inventory/presentation/inventory_screen.dart';
import 'package:teamhub_productivity_suite/src/features/profile/presentation/edit_profile_screen.dart';
import 'package:teamhub_productivity_suite/src/features/profile/presentation/profile_screen.dart';
import 'package:teamhub_productivity_suite/src/features/projects/presentation/create_edit_project_screen.dart';
import 'package:teamhub_productivity_suite/src/features/projects/presentation/project_details_screen.dart';
import 'package:teamhub_productivity_suite/src/features/projects/presentation/projects_screen.dart';
import 'package:teamhub_productivity_suite/src/features/tasks/presentation/create_edit_task_screen.dart';
import 'package:teamhub_productivity_suite/src/features/tasks/presentation/tasks_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    // Auth routes
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    // Main navigation shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return RootLayout(navigationShell: navigationShell);
      },
      branches: [
        // Dashboard branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        // Projects branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/projects',
              builder: (context, state) => ProjectsListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const CreateEditProjectScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final projectId = state.pathParameters['id']!;
                    return ProjectDetailsScreen(projectId: projectId);
                  },
                ),
                GoRoute(
                  path: ':id/edit',
                  builder: (context, state) {
                    final projectId = state.pathParameters['id']!;
                    return CreateEditProjectScreen(projectId: projectId);
                  },
                ),
              ],
            ),
          ],
        ),
        // Tasks branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              builder: (context, state) => TasksScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) {
                    final projectId = state.uri.queryParameters['projectId'];
                    return CreateEditTaskScreen(projectId: projectId);
                  },
                ),
                GoRoute(
                  path: ':id/edit',
                  builder: (context, state) {
                    final taskId = state.pathParameters['id']!;
                    return CreateEditTaskScreen(taskId: taskId);
                  },
                ),
              ],
            ),
          ],
        ),
        // Inventory branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/inventory',
              builder: (context, state) => InventoryScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder:
                      (context, state) => const AddEditInventoryItemScreen(),
                ),
                GoRoute(
                  path: ':id/edit',
                  builder: (context, state) {
                    final itemId = state.pathParameters['id']!;
                    return AddEditInventoryItemScreen(itemId: itemId);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Main app routes
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/projects',
      builder: (context, state) => ProjectsListScreen(),
    ),
    GoRoute(
      path: '/projects/new',
      builder: (context, state) => const CreateEditProjectScreen(),
    ),
    GoRoute(
      path: '/projects/:id',
      builder: (context, state) {
        final projectId = state.pathParameters['id']!;
        return ProjectDetailsScreen(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/projects/:id/edit',
      builder: (context, state) {
        final projectId = state.pathParameters['id']!;
        return CreateEditProjectScreen(projectId: projectId);
      },
    ),
    GoRoute(path: '/tasks', builder: (context, state) => TasksScreen()),
    GoRoute(
      path: '/tasks/new',
      builder: (context, state) {
        final projectId = state.uri.queryParameters['projectId'];
        return CreateEditTaskScreen(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/tasks/:id/edit',
      builder: (context, state) {
        final taskId = state.pathParameters['id']!;
        return CreateEditTaskScreen(taskId: taskId);
      },
    ), // Inventory routes are handled in the StatefulShellBranch
  ],
);
