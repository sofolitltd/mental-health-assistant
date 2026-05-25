import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/clients/domain/session.dart';
import '../../features/clients/presentation/screens/assessment_list_screen.dart';
import '../../features/clients/presentation/screens/client_detail_screen.dart';
import '../../features/clients/presentation/screens/client_screen.dart';
import '../../features/contacts/presentation/screens/contacts_screen.dart';
import '../../features/clients/presentation/screens/session_detail_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/settings/presentation/screens/mhpss_basics_screen.dart';
import '../../features/settings/presentation/screens/privacy_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/assessment_engine/domain/assessment_session.dart';
import '../../features/assessment_engine/presentation/assessment_results_screen.dart';
import '../../features/assessment_engine/presentation/assessment_runner_screen.dart';
import 'main_navigation_shell.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggingIn = state.uri.path == '/login';
      final isRegistering = state.uri.path == '/register';

      if (!authState.isAuthenticated) {
        if (isLoggingIn || isRegistering) return null;
        return '/login';
      }

      if (isLoggingIn || isRegistering) return '/dashboard';
      if (state.uri.path == '/') return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: RegisterScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return SelectionArea(
            child: MainNavigationShell(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DashboardScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/clients',
                name: 'clients',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ClientScreen()),
                routes: [
                  GoRoute(
                    path: ':clientId',
                    redirect: (context, state) =>
                        '/clients/${state.pathParameters['clientId']}/about',
                  ),
                  GoRoute(
                    path: ':clientId/about',
                    name: 'clientDetailAbout',
                    pageBuilder: (context, state) {
                      final clientId = state.pathParameters['clientId']!;
                      return NoTransitionPage(
                        child: ClientDetailScreen(clientId: clientId),
                      );
                    },
                  ),
                  GoRoute(
                    path: ':clientId/sessions',
                    name: 'clientDetailSessions',
                    pageBuilder: (context, state) {
                      final clientId = state.pathParameters['clientId']!;
                      return NoTransitionPage(
                        child: ClientDetailScreen(clientId: clientId),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: ':sessionId',
                        name: 'sessionDetail',
                        pageBuilder: (context, state) {
                          final extra = state.extra;
                          if (extra is Map<String, dynamic> && extra.containsKey('session')) {
                            return NoTransitionPage(
                              child: SessionDetailScreen(
                                session: extra['session'] as Session,
                              ),
                            );
                          }
                          final sessionId = state.pathParameters['sessionId']!;
                          return NoTransitionPage(
                            child: SessionDetailLoader(sessionId: sessionId),
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: ':clientId/assessments',
                    name: 'clientDetailAssessments',
                    pageBuilder: (context, state) {
                      final clientId = state.pathParameters['clientId']!;
                      return NoTransitionPage(
                        child: ClientDetailScreen(clientId: clientId),
                      );
                    },
                  ),
                  GoRoute(
                    path: ':clientId/new-assessment',
                    name: 'newAssessment',
                    pageBuilder: (context, state) {
                      final clientId = state.pathParameters['clientId']!;
                      return NoTransitionPage(
                        child: AssessmentListScreen(clientId: clientId),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/contacts',
                name: 'contacts',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ContactsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SettingsScreen()),
                routes: [
                  GoRoute(
                    path: 'mhpss-basics',
                    name: 'mhpssBasics',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: MhppsBasicsScreen()),
                  ),
                  GoRoute(
                    path: 'privacy',
                    name: 'privacy',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: PrivacyScreen()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/assessment/:testId',
        name: 'assessment',
        pageBuilder: (context, state) {
          final testId = state.pathParameters['testId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return NoTransitionPage(
            child: SelectionArea(child: AssessmentRunnerScreen(
              testId: testId,
              clientId: extra?['clientId'] as String?,
              sessionId: extra?['sessionId'] as String?,
              returnPath: extra?['returnPath'] as String?,
              clientAlias: extra?['clientAlias'] as String? ?? '',
            )),
          );
        },
      ),
      GoRoute(
        path: '/assessment/:testId/result',
        name: 'assessmentResult',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return NoTransitionPage(
            child: SelectionArea(child: AssessmentResultsScreen(
              session: extra['session'] as AssessmentSession,
              testName: extra['testName'] as String,
              returnPath: extra['returnPath'] as String?,
            )),
          );
        },
      ),
    ],
  );
}


