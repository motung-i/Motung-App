class AppConstants {
  // 국가 코드
  static const String countryKorea = 'KOREA';

  // 에러 메시지
  static const String loginErrorMessage = '로그인 중 오류가 발생했습니다. 다시 시도해주세요.';
  static const String networkErrorMessage = '네트워크 오류가 발생했습니다.';
  static const String unknownErrorMessage = '알 수 없는 오류가 발생했습니다.';

  // UI 메시지
  static const String loadingText = '로딩중...';
  static const String loginButtonText = 'Google로 시작하기';
  static const String loginLoadingText = '로그인 중...';
  static const String appleLoginText = 'Apple로 시작하기';

  // 기본값
  static const Duration defaultTimeout = Duration(seconds: 30);

  // 네트워크 설정
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // API 엔드포인트
  static const String authGoogleLoginEndpoint = '/auth/google/login/callback';
  static const String authAppleLoginEndpoint = '/auth/apple/login/callback';
  static const String authCheckRegisterEndpoint = '/auth/check-register';
  static const String authRegisterEndpoint = '/auth/register';
  static const String authRefreshEndpoint = '/auth/refresh';
  static const String authLogoutEndpoint = '/auth/logout';
  static const String authDeleteAccountEndpoint = '/auth/delete-account';
  static const String userEndpoint = '/user';
  static const String userNicknameEndpoint = '/user/nickname';

  // 입력 필드 제한
  static const int nicknameMaxLength = 12;
  static const int reviewMaxLength = 400;
  static const int reviewMaxLines = 8;

  // 보안 저장소 키
  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refreshToken';
}
