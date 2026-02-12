import 'package:core/core.dart';

/// 소셜 로그인 프로바이더 열거형
enum SocialProvider {
  kakao,
  naver,
  google,
  apple,
}

/// 프로바이더별 설정
class ProviderConfig {
  /// 클라이언트 ID (네이티브 SDK 설정용)
  final String? clientId;

  /// 클라이언트 시크릿 (iOS 앱 전용)
  final String? clientSecret;

  const ProviderConfig({
    this.clientId,
    this.clientSecret,
  });
}

/// Auth SDK 설정 클래스
///
/// SDK 초기화 시 필요한 모든 설정을 담는 불변 객체
class AuthSdkConfig {
  /// 앱 식별 코드 (예: 'wowa')
  final String appCode;

  /// API 기본 URL (예: 'https://api.gaegulzip.com')
  final String apiBaseUrl;

  /// 소셜 프로바이더별 OAuth 설정
  final Map<SocialProvider, ProviderConfig> providers;

  /// 로그인 성공 후 이동할 라우트 (기본값: '/home')
  final String homeRoute;

  /// 둘러보기 버튼 표시 여부 (기본값: false)
  final bool showBrowseButton;

  /// 커스텀 SecureStorage (선택적)
  final SecureStorageService? secureStorage;

  /// 로그인 성공 후 콜백 (예: FCM 토큰 서버 등록)
  final Future<void> Function()? onPostLogin;

  /// 로그아웃 전 콜백 (예: FCM 토큰 비활성화)
  final Future<void> Function()? onPreLogout;

  const AuthSdkConfig({
    required this.appCode,
    required this.apiBaseUrl,
    required this.providers,
    this.homeRoute = '/home',
    this.showBrowseButton = false,
    this.secureStorage,
    this.onPostLogin,
    this.onPreLogout,
  });
}
