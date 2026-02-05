/// 비즈니스 로직 관련 예외
///
/// 이미 박스에 가입됨, 이미 처리된 제안 등 비즈니스 규칙 위반 시 발생합니다.
class BusinessException implements Exception {
  /// 에러 코드 (예: 'already_joined', 'already_processed')
  final String code;

  /// 에러 메시지 (사용자에게 표시할 메시지)
  final String message;

  const BusinessException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'BusinessException($code): $message';
}
