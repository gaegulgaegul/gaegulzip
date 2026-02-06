import 'package:freezed_annotation/freezed_annotation.dart';
import 'program_data.dart';

part 'wod_model.freezed.dart';
part 'wod_model.g.dart';

/// WOD 정보 모델
@freezed
class WodModel with _$WodModel {
  const factory WodModel({
    /// WOD 고유 ID
    required int id,

    /// 박스 ID
    required int boxId,

    /// 날짜 (YYYY-MM-DD 형식)
    required String date,

    /// 프로그램 데이터
    required ProgramData programData,

    /// 원본 텍스트 (nullable)
    String? rawText,

    /// Base WOD 여부
    required bool isBase,

    /// 등록자 ID
    required int createdBy,

    /// 등록자 닉네임 (nullable)
    String? registeredBy,

    /// 선택 횟수 (nullable)
    int? selectedCount,

    /// 생성 시간 (ISO 8601 형식)
    required String createdAt,
  }) = _WodModel;

  factory WodModel.fromJson(Map<String, dynamic> json) =>
      _$WodModelFromJson(json);
}
