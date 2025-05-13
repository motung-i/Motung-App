import 'package:go_router/go_router.dart';
import 'package:motunge/routes/app_router.dart';

class Navigation {
  // 로그인 화면으로 이동
  static void toLogin({bool replace = false}) {
    if (replace) {
      AppRouter.rootNavigatorKey.currentContext?.go('/login');
    } else {
      AppRouter.rootNavigatorKey.currentContext?.push('/login');
    }
  }

  // 온보딩 화면으로 이동
  static void toOnboarding() {
    AppRouter.rootNavigatorKey.currentContext?.push('/onboarding');
  }

  // 홈 화면으로 이동
  static void toHome({bool replace = false}) {
    if (replace) {
      AppRouter.rootNavigatorKey.currentContext?.go('/home');
    } else {
      AppRouter.rootNavigatorKey.currentContext?.push('/home');
    }
  }

  // 리뷰 목록 화면으로 이동
  static void toReviewList() {
    AppRouter.rootNavigatorKey.currentContext?.push('/review');
  }

  // 리뷰 작성 화면으로 이동
  static void toReviewWrite() {
    AppRouter.rootNavigatorKey.currentContext?.push('/review/write');
  }

  // 투어 화면으로 이동
  static void toTour() {
    AppRouter.rootNavigatorKey.currentContext?.push('/tour');
  }

  // 뒤로 가기
  static void back() {
    if (AppRouter.rootNavigatorKey.currentContext != null && 
        GoRouter.of(AppRouter.rootNavigatorKey.currentContext!).canPop()) {
      AppRouter.rootNavigatorKey.currentContext?.pop();
    }
  }
} 