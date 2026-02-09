import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_box_request.freezed.dart';
part 'create_box_request.g.dart';

/// 박스 생성 요청 모델
@freezed
class CreateBoxRequest with _$CreateBoxRequest {
  const factory CreateBoxRequest({
    /// 박스 이름
    required String name,

    /// 박스 지역
    required String region,

    /// 박스 설명 (nullable)
    String? description,
  }) = _CreateBoxRequest;

  factory CreateBoxRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBoxRequestFromJson(json);
}
