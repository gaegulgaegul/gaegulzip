import 'package:freezed_annotation/freezed_annotation.dart';

part 'membership_model.freezed.dart';
part 'membership_model.g.dart';

/// 박스 멤버십 모델
@freezed
class MembershipModel with _$MembershipModel {
  const factory MembershipModel({
    /// 멤버십 고유 ID
    required int id,

    /// 박스 ID
    required int boxId,

    /// 사용자 ID
    required int userId,

    /// 가입 일시 (ISO 8601 형식)
    required String joinedAt,
  }) = _MembershipModel;

  factory MembershipModel.fromJson(Map<String, dynamic> json) =>
      _$MembershipModelFromJson(json);
}
