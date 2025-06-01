import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:teamhub_productivity_suite/firebase_options.dart';
import 'package:teamhub_productivity_suite/src/common_widgets/root_layout.dart';
import 'package:teamhub_productivity_suite/src/features/admin_panel/presentation/manage_users_screen.dart';
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
import 'package:teamhub_productivity_suite/src/providers/authentication_provider.dart';
import 'package:teamhub_productivity_suite/src/widgets/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
      ],
      child: Consumer<AuthenticationProvider>(
        builder: (context, authProvider, child) {
          final goRouter = GoRouter(
            initialLocation: '/loading',
            redirect: (context, state) {
              final authProvider = context.read<AuthenticationProvider>();

              if (!authProvider.isInitialized) {
                // If auth state is not initialized, show loading screen
                return state.uri.path == '/loading' ? null : '/loading';
              }

              // Redirect to login if not authenticated and trying to access protected routes
              final isLoggedIn = authProvider.user != null;
              final currentPath = state.uri.path;
              final authPages = {'/login', '/register', '/forgot-password'};

              final isAuthPage = authPages.contains(currentPath);

              if (!isLoggedIn && !isAuthPage) {
                return '/login';
              }

              // Redirect to dashboard if logged in and trying to access login or registration pages
              if (isLoggedIn && (isAuthPage || currentPath == '/loading')) {
                return '/dashboard';
              }

              return null; // No redirection needed
            },
            refreshListenable: authProvider,
            routes: [
              // Auth routes
              GoRoute(
                path: '/loading',
                builder: (context, state) => const LoadingScreen(),
              ),
              GoRoute(
                path: '/login',
                builder: (context, state) => const LoginScreen(),
              ),

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
                            builder:
                                (context, state) =>
                                    const CreateEditProjectScreen(),
                          ),
                          GoRoute(
                            path: ':id',
                            builder: (context, state) {
                              final projectId = state.pathParameters['id']!;
                              return ProjectDetailsScreen(projectId: projectId);
                            },
                            routes: [
                              GoRoute(
                                path: 'tasks/new',
                                builder: (context, state) {
                                  final projectId = state.pathParameters['id']!;
                                  return CreateEditTaskScreen(
                                    projectId: projectId,
                                  );
                                },
                              ),
                            ],
                          ),
                          GoRoute(
                            path: ':id/edit',
                            builder: (context, state) {
                              final projectId = state.pathParameters['id']!;
                              return CreateEditProjectScreen(
                                projectId: projectId,
                              );
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
                              final projectId =
                                  state.uri.queryParameters['projectId'];
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
                                (context, state) =>
                                    const AddEditInventoryItemScreen(),
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

              // Profile routes (outside the main shell)
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                redirect: (context, state) {
                  if (state.uri.queryParameters['fromDashboard'] != 'true') {
                    return '/dashboard';
                  }
                  return null; // Otherwise, allow navigation to /profile.
                },
              ),
              GoRoute(
                path: '/profile/manage-users',
                builder: (context, state) => const ManageUsersScreen(),
              ),
              GoRoute(
                path: '/profile/edit',
                builder: (context, state) => const EditProfileScreen(),
              ),
            ],
          );
          return MaterialApp.router(
            title: 'TeamHub Productivity Suite',
            routerConfig: goRouter,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1A73E8), // Google Blue
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.interTextTheme(
                Theme.of(context).textTheme,
              ),
              appBarTheme: AppBarTheme(
                elevation: 0,
                centerTitle: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                titleTextStyle: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  minimumSize: const Size(88, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
              ),
            ),
          );
        },
      ),
    );
  }
}
