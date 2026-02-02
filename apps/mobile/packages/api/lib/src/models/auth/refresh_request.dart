import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_request.freezed.dart';
part 'refresh_request.g.dart';

/// 토큰 갱신 요청 모델
@freezed
class RefreshRequest with _$RefreshRequest {
  const factory RefreshRequest({
    /// refreshToken (Authorization 헤더로도 전송 가능)
    required String refreshToken,
  }) = _RefreshRequest;

  factory RefreshRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshRequestFromJson(json);
}
