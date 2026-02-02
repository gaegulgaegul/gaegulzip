/// 인증 관련 예외
///
/// 소셜 로그인 실패, 토큰 만료, 권한 거부 등의 상황에서 발생합니다.
class AuthException implements Exception {
  /// 에러 코드 (예: 'user_cancelled', 'invalid_token')
  final String code;

  /// 에러 메시지 (사용자에게 표시할 메시지)
  final String message;

  /// 추가 데이터 (예: account_conflict 시 existingProvider 정보)
  final Map<String, dynamic>? data;

  const AuthException({
    required this.code,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'AuthException($code): $message';
}
