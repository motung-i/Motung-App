import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motunge/model/auth/enum/auth_state.dart';
import 'package:motunge/state/auth_notifier.dart';
import 'package:motunge/view/common/scaffold_with_nav_bar.dart';
import 'package:motunge/view/home/home.dart';
import 'package:motunge/view/login/login.dart';
import 'package:motunge/view/my/change_nickname.dart';
import 'package:motunge/view/my/my.dart';
import 'package:motunge/view/onBoarding/onboarding.dart';
import 'package:motunge/view/review/review_list.dart';
import 'package:motunge/view/review/review_write.dart';
import 'package:motunge/view/map/map.dart';
import 'package:motunge/view/my/system_setting.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final AuthNotifier authNotifier = AuthNotifier();

  static final GoRouter router = GoRouter(
    refreshListenable: authNotifier,
    navigatorKey: rootNavigatorKey,
    redirect: (context, state) {
      final status = authNotifier.status;
      final isLoggingIn = state.fullPath == '/login';
      final isOnboarding = state.fullPath == '/onboarding';

      switch (status) {
        case AuthStatus.unauthenticated:
          return isLoggingIn ? null : '/login';
        case AuthStatus.needRegister:
          return isOnboarding ? null : '/onboarding';
        case AuthStatus.authenticated:
          if (isLoggingIn || isOnboarding) return '/home';
          return null;
      }
    },
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const Onboarding(),
      ),
      GoRoute(
        path: '/review/write',
        name: 'reviewWrite',
        builder: (context, state) => const ReviewWrite(),
      ),
      GoRoute(
        path: '/my/change-nickname',
        name: 'changeNickname',
        builder: (context, state) => const ChangeNickname(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const MyHomePage(),
          ),
          GoRoute(
            path: '/review',
            name: 'review',
            builder: (context, state) => const ReviewList(),
          ),
          GoRoute(
            path: '/map',
            name: 'map',
            builder: (context, state) => const MapPage(),
          ),
          GoRoute(
            path: '/my',
            name: 'my',
            builder: (context, state) => const MyPage(),
          ),
          GoRoute(
            path: '/my/system-setting',
            name: 'systemSetting',
            builder: (context, state) => const SystemSettingPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('페이지를 찾을 수 없습니다: ${state.uri.path}'),
      ),
    ),
  );
}
