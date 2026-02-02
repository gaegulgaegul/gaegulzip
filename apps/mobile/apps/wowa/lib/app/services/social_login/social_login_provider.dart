/// 소셜 로그인 Provider 추상 클래스
///
/// 모든 소셜 로그인 플랫폼(카카오, 네이버, 애플, 구글)이 구현해야 하는 공통 인터페이스입니다.
abstract class SocialLoginProvider {
  /// 플랫폼 이름 (예: 'kakao', 'naver', 'apple', 'google')
  String get platformName;

  /// OAuth 인증을 시작하고 authorization code를 획득합니다.
  ///
  /// Returns: OAuth authorization code
  /// Throws:
  ///   - [AuthException] 사용자 취소, 권한 거부 등 인증 오류
  ///   - [NetworkException] 네트워크 연결 오류
  ///   - [Exception] 기타 예외
  Future<String> signIn();

  /// 로그아웃을 처리합니다.
  ///
  /// SDK에서 관리하는 세션을 종료합니다.
  Future<void> signOut();

  /// SDK 초기화 여부를 확인합니다.
  ///
  /// 일부 SDK는 명시적인 초기화가 필요합니다.
  bool get isInitialized;
}
