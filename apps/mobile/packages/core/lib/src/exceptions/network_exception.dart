/// 네트워크 관련 예외
///
/// 네트워크 연결 실패, 타임아웃 등의 상황에서 발생합니다.
class NetworkException implements Exception {
  /// 에러 메시지
  final String message;

  /// HTTP 상태 코드 (선택 사항)
  final int? statusCode;

  const NetworkException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'NetworkException(${statusCode ?? 'N/A'}): $message';
}
