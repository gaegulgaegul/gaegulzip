import 'package:freezed_annotation/freezed_annotation.dart';
import '../auth/user_model.dart';

part 'box_member_model.freezed.dart';
part 'box_member_model.g.dart';

/// 박스 멤버 정보 모델
@freezed
class BoxMemberModel with _$BoxMemberModel {
  const factory BoxMemberModel({
    /// 멤버십 고유 ID
    required int id,

    /// 박스 ID
    required int boxId,

    /// 사용자 ID
    required int userId,

    /// 역할 (nullable)
    String? role,

    /// 가입 시간 (ISO 8601 형식)
    required String joinedAt,

    /// 사용자 정보 (nested, nullable)
    UserModel? user,
  }) = _BoxMemberModel;

  factory BoxMemberModel.fromJson(Map<String, dynamic> json) =>
      _$BoxMemberModelFromJson(json);
}
