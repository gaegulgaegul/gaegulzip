import 'package:freezed_annotation/freezed_annotation.dart';
import 'box_model.dart';
import 'membership_model.dart';

part 'box_create_response.freezed.dart';
part 'box_create_response.g.dart';

/// 박스 생성 응답 모델
@freezed
class BoxCreateResponse with _$BoxCreateResponse {
  const factory BoxCreateResponse({
    /// 생성된 박스
    required BoxModel box,

    /// 생성된 멤버십 (자동 가입)
    required MembershipModel membership,

    /// 이전 박스 ID (탈퇴한 박스가 있을 경우)
    int? previousBoxId,
  }) = _BoxCreateResponse;

  factory BoxCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$BoxCreateResponseFromJson(json);
}
