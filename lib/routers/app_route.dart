import 'package:flutter/cupertino.dart';
import 'package:flutter_todo_api/models/todo_model.dart';
import 'package:flutter_todo_api/views/pages/main_scaffold_page/main_scaffold_page.dart';
import 'package:flutter_todo_api/views/pages/todo_page/add_todo_page.dart';
import '../../views/pages/home_page.dart';
import 'package:go_router/go_router.dart';
import '../services/api/sp_service.dart';
import '../views/pages/auth_page/auth_page.dart';
import '../views/pages/error_page/error_page.dart';
import '../views/pages/notification_page/notification_page.dart';
import '../views/pages/profile_page/profile_page.dart';
import '../views/pages/search_page/search_page.dart';
part 'app_path.dart';
part 'path_name.dart';

class AppGoRouter {
  static GoRouter get router => _goRouter;
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorHomeKey =
      GlobalKey<NavigatorState>(debugLabel: 'home');
  static final _shellNavigatorstatsKey =
      GlobalKey<NavigatorState>(debugLabel: 'stats');
  static final _shellNavigatorNotificationKey =
      GlobalKey<NavigatorState>(debugLabel: 'notification');
  static final _shellNavigatorProfileKey =
      GlobalKey<NavigatorState>(debugLabel: 'profile');

  static final GoRouter _goRouter = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppPath.auth,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppPath.auth,
        name: AppPath.auth,
        builder: (context, state) {
          return const AuthPage();
        },
      ),
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return MainScaffoldPage(
            navigationShell: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(navigatorKey: _shellNavigatorHomeKey, routes: [
            GoRoute(
              path: AppPath.home,
              name: PathName.home,
              builder: (context, state) {
                return const HomePage();
              },
              routes: [
                GoRoute(
                  path: '/home/add-todo',
                  name: PathName.addTodo,
                  builder: (context, state) {
                    final todo = state.extra as TodoModel?;
                    return AddTodoPage(todo: todo);
                  },
                ),
              ],
            ),
          ]),
          StatefulShellBranch(navigatorKey: _shellNavigatorstatsKey, routes: [
            GoRoute(
              path: AppPath.stats,
              name: PathName.stats,
              builder: (context, state) {
                return const SearchPage();
              },
            ),
          ]),
          StatefulShellBranch(
              navigatorKey: _shellNavigatorNotificationKey,
              routes: [
                GoRoute(
                  path: AppPath.notification,
                  name: PathName.notification,
                  builder: (context, state) {
                    return const NotificationPage();
                  },
                ),
              ]),
          StatefulShellBranch(navigatorKey: _shellNavigatorProfileKey, routes: [
            GoRoute(
              path: AppPath.profile,
              name: PathName.profile,
              builder: (context, state) {
                return const ProfilePage();
              },
            ),
          ]),
        ],
      ),
    ],
    redirect: (context, state) async {
      final spService = SpService();
      final token = await spService.getToken();
      if (token == null && state.uri.toString() != AppPath.auth) {
        return AppPath.auth;
      } else if (token != null && state.uri.toString() == AppPath.auth) {
        return AppPath.home;
      }
      return null;
    },
    errorBuilder: (context, state) => const ErrorPage(),
  );
}
