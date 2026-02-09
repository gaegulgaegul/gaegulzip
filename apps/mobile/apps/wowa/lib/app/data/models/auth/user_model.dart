import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// 사용자 정보 모델
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    /// 사용자 고유 ID
    required int id,

    /// 가입 시 사용한 소셜 플랫폼
    required String provider,

    /// 이메일 주소 (nullable: 애플은 이메일 제공 거부 가능)
    String? email,

    /// 사용자 닉네임
    required String nickname,

    /// 프로필 이미지 URL (nullable)
    String? profileImage,

    /// 앱 식별 코드
    required String appCode,

    /// 마지막 로그인 시각 (ISO 8601 형식)
    required String lastLoginAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
