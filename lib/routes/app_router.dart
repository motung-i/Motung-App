import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motunge/view/common/scaffold_with_nav_bar.dart';
import 'package:motunge/view/home/home.dart';
import 'package:motunge/view/login/login.dart';
import 'package:motunge/view/onBoarding/onboarding.dart';
import 'package:motunge/view/review/review_list.dart';
import 'package:motunge/view/review/review_write.dart';
import 'package:motunge/view/tour/tour.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
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
            path: '/review/write',
            name: 'review_write',
            builder: (context, state) => const ReviewWrite(),
          ),
          GoRoute(
            path: '/tour',
            name: 'tour',
            builder: (context, state) => const TourPage(),
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