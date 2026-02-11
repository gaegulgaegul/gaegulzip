import '../auth_sdk.dart';
import 'package:core/core.dart';

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

  const AuthSdkConfig({
    required this.appCode,
    required this.apiBaseUrl,
    required this.providers,
    this.homeRoute = '/home',
    this.showBrowseButton = false,
    this.secureStorage,
  });
}
