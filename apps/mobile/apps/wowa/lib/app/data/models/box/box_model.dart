import 'package:freezed_annotation/freezed_annotation.dart';

part 'box_model.freezed.dart';
part 'box_model.g.dart';

/// 박스(크로스핏 짐) 정보 모델
@freezed
class BoxModel with _$BoxModel {
  const factory BoxModel({
    /// 박스 고유 ID
    required int id,

    /// 박스 이름
    required String name,

    /// 박스 지역
    required String region,

    /// 박스 설명 (nullable)
    String? description,

    /// 멤버 수 (nullable)
    int? memberCount,

    /// 가입 시간 (ISO 8601 형식, nullable)
    String? joinedAt,
  }) = _BoxModel;

  factory BoxModel.fromJson(Map<String, dynamic> json) =>
      _$BoxModelFromJson(json);
}
